#!/usr/bin/env bash
#
# test-install.sh — focused smoke tests for aet-install.sh.
#
# Run from the repository root:
#   bash scripts/test-install.sh
#
# Exit 0 if all tests pass, non-zero if any fail.

set -uo pipefail

PASS=0
FAIL=0

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALLER="$SCRIPT_DIR/aet-install.sh"
AET_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
MANIFEST="$SCRIPT_DIR/aet-manifest.txt"
MANIFEST_ENTRIES=()

ok()   { PASS=$((PASS + 1)); printf '[PASS] %s\n' "$*"; }
fail() { FAIL=$((FAIL + 1)); printf '[FAIL] %s\n' "$*"; }

if ! TMP="$(mktemp -d)" || [[ -z "$TMP" ]]; then
  printf '[test-install] error: could not create scratch directory\n' >&2
  exit 1
fi
if ! TMP="$(cd -- "$TMP" && pwd -P)" || [[ -z "$TMP" ]]; then
  printf '[test-install] error: could not normalize scratch directory\n' >&2
  exit 1
fi
trap 'rm -rf -- "$TMP"' EXIT

validate_manifest_entry() {
  local entry="$1" lineno="$2" framed="/$1/" reason=""

  if [[ "${entry:0:1}" == "/" ]]; then
    reason="absolute path"
  elif [[ "$entry" == *[[:cntrl:]]* ]]; then
    reason="control character"
  elif [[ "$entry" == *"//"* || "$entry" == */ ]]; then
    reason="empty path component"
  elif [[ "$framed" == *"/./"* ]]; then
    reason="noncanonical dot component"
  elif [[ "$framed" == *"/../"* ]]; then
    reason="parent traversal"
  fi

  [[ -z "$reason" ]] || {
    printf '[test-install] error: invalid manifest entry at line %s (%s)\n' \
      "$lineno" "$reason" >&2
    exit 1
  }
}

load_canonical_manifest() {
  [[ -f "$MANIFEST" ]] \
    || { printf '[test-install] error: manifest not found: %s\n' "$MANIFEST" >&2; exit 1; }
  local manifest_hex
  manifest_hex="$(LC_ALL=C od -An -v -tx1 "$MANIFEST" 2>/dev/null)" || {
    printf '[test-install] error: manifest validation failed\n' >&2
    exit 1
  }
  if printf '%s\n' "$manifest_hex" \
      | grep -Eq '(^|[[:space:]])00([[:space:]]|$)'; then
    printf '[test-install] error: manifest validation failed\n' >&2
    exit 1
  fi

  local line lineno=0 existing
  while IFS= read -r line || [[ -n "$line" ]]; do
    lineno=$((lineno + 1))
    [[ -z "$line" || "${line:0:1}" == "#" ]] && continue
    validate_manifest_entry "$line" "$lineno"
    if [[ -n "${MANIFEST_ENTRIES[*]-}" ]]; then
      for existing in "${MANIFEST_ENTRIES[@]}"; do
        [[ "$existing" != "$line" ]] || {
          printf '[test-install] error: invalid manifest entry at line %s (duplicate entry)\n' \
            "$lineno" >&2
          exit 1
        }
      done
    fi
    MANIFEST_ENTRIES+=("$line")
  done < "$MANIFEST"
  [[ ${#MANIFEST_ENTRIES[@]} -gt 0 ]] \
    || { printf '[test-install] error: manifest is empty: %s\n' "$MANIFEST" >&2; exit 1; }
}

load_canonical_manifest

# ---------------------------------------------------------------------------
# t1: manifest file exists and is non-empty
# ---------------------------------------------------------------------------
t1_manifest_exists() {
  local count
  # Exact package contract; update this count whenever the manifest changes.
  count="${#MANIFEST_ENTRIES[@]}"
  if [[ "$count" -ne 32 ]]; then
    fail "t1: expected 32 manifest entries, got $count"
  else
    ok "t1: manifest exists with $count entries"
  fi
}

# ---------------------------------------------------------------------------
# t2: every manifest entry exists in the source tree
# ---------------------------------------------------------------------------
t2_manifest_complete() {
  local missing=0 entry
  for entry in "${MANIFEST_ENTRIES[@]}"; do
    if [[ ! -f "$AET_ROOT/$entry" ]]; then
      fail "t2: manifest entry missing from source: $entry"
      missing=$((missing + 1))
    fi
  done
  if [[ "$missing" -eq 0 ]]; then
    ok "t2: all manifest entries present in source tree"
  fi
}

# ---------------------------------------------------------------------------
# t3: dry-run exits 0 and writes no files
# ---------------------------------------------------------------------------
t3_dry_run_no_writes() {
  local dest="$TMP/t3"
  local install_output
  mkdir -p "$dest"
  if ! install_output="$(bash "$INSTALLER" --target "$dest" --dry-run 2>&1)"; then
    fail "t3: dry-run exited non-zero"
    return
  fi
  local count
  count="$(find "$dest" -mindepth 1 -print | wc -l | tr -d ' ')"
  if [[ "$count" -ne 0 ]]; then
    fail "t3: dry-run created $count destination path(s)"
  elif [[ "$install_output" == *"Audience template for host project root AGENTS.md"* ]]; then
    fail "t3: dry-run printed audience template"
  else
    ok "t3: dry-run exits 0 and writes nothing"
  fi
}

# ---------------------------------------------------------------------------
# t4: normal install writes the orchestrator agent
# ---------------------------------------------------------------------------
t4_install_writes_files() {
  local dest="$TMP/t4"
  local install_output
  mkdir -p "$dest"
  if ! install_output="$(bash "$INSTALLER" --target "$dest" 2>&1)"; then
    fail "t4: install exited non-zero"
    return
  fi
  if [[ ! -f "$dest/.github/agents/aet-orchestrator.agent.md" ]]; then
    fail "t4: orchestrator not found after install"
  elif ! cmp -s "$AET_ROOT/LICENSE" "$dest/.github/LICENSE"; then
    fail "t4: installed LICENSE differs from source"
  elif [[ "$install_output" != *"Audience template for host project root AGENTS.md"* ]]; then
    fail "t4: local install did not print audience template"
  else
    ok "t4: install writes orchestrator agent and unchanged LICENSE"
  fi
}

# ---------------------------------------------------------------------------
# t5: reinstall with identical files succeeds (skip path)
# ---------------------------------------------------------------------------
t5_identical_skip() {
  local dest="$TMP/t5"
  mkdir -p "$dest"
  if ! bash "$INSTALLER" --target "$dest" >/dev/null 2>&1; then
    fail "t5: first install failed"
    return
  fi
  if bash "$INSTALLER" --target "$dest" >/dev/null 2>&1; then
    ok "t5: reinstall with identical files succeeds"
  else
    fail "t5: reinstall failed on identical files"
  fi
}

# ---------------------------------------------------------------------------
# t6: changed engine file aborts without --force
# ---------------------------------------------------------------------------
t6_collision_aborts_without_force() {
  local dest="$TMP/t6"
  mkdir -p "$dest"
  if ! bash "$INSTALLER" --target "$dest" >/dev/null 2>&1; then
    fail "t6: setup install failed"
    return
  fi
  # Mutate an installed engine file.
  echo "MODIFIED" >> "$dest/.github/agents/aet-orchestrator.agent.md"
  if bash "$INSTALLER" --target "$dest" >/dev/null 2>&1; then
    fail "t6: expected abort on collision but install succeeded"
  else
    ok "t6: changed engine file aborts without --force"
  fi
}

# ---------------------------------------------------------------------------
# t7: changed engine file succeeds with --force
# ---------------------------------------------------------------------------
t7_force_overwrites_engine_file() {
  local dest="$TMP/t7"
  mkdir -p "$dest"
  if ! bash "$INSTALLER" --target "$dest" >/dev/null 2>&1; then
    fail "t7: setup install failed"
    return
  fi
  echo "MODIFIED" >> "$dest/.github/agents/aet-orchestrator.agent.md"
  if bash "$INSTALLER" --target "$dest" --force >/dev/null 2>&1; then
    ok "t7: --force overwrites changed engine file"
  else
    fail "t7: --force install failed"
  fi
}

# ---------------------------------------------------------------------------
# t8: content pack file with engine namespace aborts (even with --force)
# ---------------------------------------------------------------------------
t8_content_over_engine_aborts() {
  local dest="$TMP/t8"
  local content="$TMP/t8-content"
  mkdir -p "$dest" "$content/instructions"

  # Pick the first engine instruction file from the manifest.
  local engine_instr="" entry
  for entry in "${MANIFEST_ENTRIES[@]}"; do
    if [[ "$entry" == instructions/* ]]; then
      engine_instr="$entry"
      break
    fi
  done
  if [[ -z "$engine_instr" ]]; then
    fail "t8: no instructions entries in manifest"
    return
  fi
  local fname
  fname="$(basename "$engine_instr")"
  echo "CONTENT OVERRIDE" > "$content/instructions/$fname"

  # Without --force.
  if bash "$INSTALLER" --target "$dest" --content-path "$content" >/dev/null 2>&1; then
    fail "t8: expected abort on content-over-engine but succeeded"
    return
  fi

  # With --force — must still abort.
  if bash "$INSTALLER" --target "$dest" --content-path "$content" --force >/dev/null 2>&1; then
    fail "t8: expected abort on content-over-engine with --force but succeeded"
  else
    ok "t8: content-over-engine aborts regardless of --force"
  fi
}

# ---------------------------------------------------------------------------
# t9: content/content collision aborts when source and destination differ
# ---------------------------------------------------------------------------
t9_content_collision_aborts() {
  local dest="$TMP/t9"
  local content="$TMP/t9-content"
  mkdir -p "$dest" "$content/instructions"
  echo "VERSION 1" > "$content/instructions/my-custom.instructions.md"

  # First install — custom file goes in.
  if ! bash "$INSTALLER" --target "$dest" --content-path "$content" >/dev/null 2>&1; then
    fail "t9: first install with content pack failed"
    return
  fi

  # Change the content source; second install should abort.
  echo "VERSION 2" > "$content/instructions/my-custom.instructions.md"
  if bash "$INSTALLER" --target "$dest" --content-path "$content" >/dev/null 2>&1; then
    fail "t9: expected abort on content/content collision but succeeded"
  else
    ok "t9: changed content/content collision aborts"
  fi
}

# ---------------------------------------------------------------------------
# t10: build-release.sh creates bundle with expected path inventory
# ---------------------------------------------------------------------------
check_bundle_inventory() {
  local tarball="$1" bundle_name="$2"
  local members types member relative inventory="" expected
  members="$(tar -tzf "$tarball")" || return 1
  types="$(tar -tvzf "$tarball" | cut -c1 | LC_ALL=C sort -u)" || return 1
  [[ "$types" == $'-\nd' || "$types" == "-" ]] || return 1
  while IFS= read -r member; do
    member="${member#./}"
    [[ "$member" == "$bundle_name/"* ]] || return 1
    relative="${member#"$bundle_name"/}"
    [[ "$relative" != /* && "$relative" != *"//"* \
        && "/$relative/" != *"/../"* && "/$relative/" != *"/./"* ]] || return 1
    [[ "$member" == */ ]] && continue
    inventory+="$relative"$'\n'
  done <<< "$members"
  expected="$(printf '%s\n' "${MANIFEST_ENTRIES[@]}" \
    'scripts/aet-manifest.txt' | LC_ALL=C sort)"
  [[ "$(printf '%s' "$inventory" | LC_ALL=C sort)" == "$expected" ]]
}

t10_bundle_inventory() {
  local build_script="$SCRIPT_DIR/build-release.sh"
  if [[ ! -f "$build_script" ]]; then
    fail "t10: build-release.sh not found"
    return
  fi
  local ver="v0.0.1"
  local work="$TMP/t10"
  mkdir -p "$work"
  if ! (cd "$work" && bash "$build_script" "$ver" >/dev/null 2>&1); then
    fail "t10: build-release.sh exited non-zero"
    return
  fi
  local bundle_name="aet-bundle-${ver}"
  local tarball="$work/${bundle_name}.tar.gz"
  if [[ ! -f "$tarball" ]]; then
    fail "t10: tarball not created"
    return
  fi
  if ! check_bundle_inventory "$tarball" "$bundle_name"; then
    fail "t10: bundle regular-file inventory differs from manifest plus manifest itself"
    return
  fi
  if ! tar -xOzf "$tarball" "$bundle_name/LICENSE" | cmp -s "$AET_ROOT/LICENSE" -; then
    fail "t10: packaged LICENSE differs from source"
    return
  fi
  local unpack="$work/unpack"
  if ! mkdir -p "$unpack" \
      || ! tar -xzf "$tarball" -C "$unpack" \
      || ! rm -- "$unpack/$bundle_name/LICENSE" \
      || ! tar -czf "$work/missing.tar.gz" -C "$unpack" "$bundle_name"; then
    fail "t10: missing-member fixture setup failed"
    return
  fi
  if check_bundle_inventory "$work/missing.tar.gz" "$bundle_name"; then
    fail "t10: missing LICENSE was accepted"
    return
  fi
  if ! cp "$AET_ROOT/LICENSE" "$unpack/$bundle_name/LICENSE" \
      || ! printf 'unexpected bundle member\n' > "$unpack/$bundle_name/LICENSE.extra" \
      || ! tar -czf "$work/extra.tar.gz" -C "$unpack" "$bundle_name"; then
    fail "t10: extra-member fixture setup failed"
    return
  fi
  if check_bundle_inventory "$work/extra.tar.gz" "$bundle_name"; then
    fail "t10: extra bundle member was accepted"
    return
  fi
  ok "t10: exact bundle inventory, unchanged LICENSE, missing/extra members rejected"
}

# ---------------------------------------------------------------------------
# t11: SHA-256 checksum file matches the tarball
# ---------------------------------------------------------------------------
t11_bundle_checksum() {
  local build_script="$SCRIPT_DIR/build-release.sh"
  if [[ ! -f "$build_script" ]]; then
    fail "t11: build-release.sh not found"
    return
  fi
  local ver="v0.0.1"
  local work="$TMP/t11"
  mkdir -p "$work"
  if ! (cd "$work" && bash "$build_script" "$ver" >/dev/null 2>&1); then
    fail "t11: build-release.sh exited non-zero"
    return
  fi
  local bundle_name="aet-bundle-${ver}"
  local tarball="$work/${bundle_name}.tar.gz"
  local sha256_file="$work/${bundle_name}.sha256"
  if [[ ! -f "$sha256_file" ]]; then
    fail "t11: sha256 file not created"
    return
  fi
  local computed expected
  if command -v sha256sum >/dev/null 2>&1; then
    computed="$(sha256sum "$tarball" | awk '{print $1}')"
  else
    computed="$(shasum -a 256 "$tarball" | awk '{print $1}')"
  fi
  expected="$(awk '{print $1}' "$sha256_file")"
  if [[ "$computed" == "$expected" ]]; then
    ok "t11: SHA-256 checksum self-consistent"
  else
    fail "t11: SHA-256 mismatch — computed $computed expected $expected"
  fi
}

# ---------------------------------------------------------------------------
# t12: unmanaged collision (no managed state) rejects --force
# ---------------------------------------------------------------------------
t12_unmanaged_rejects_force() {
  local dest="$TMP/t12"
  mkdir -p "$dest/.github/agents"
  # Place a file without installing (no managed state exists).
  echo "UNMANAGED CONTENT" > "$dest/.github/agents/aet-orchestrator.agent.md"
  # --force must still abort — no managed state for this path.
  if bash "$INSTALLER" --target "$dest" --force >/dev/null 2>&1; then
    fail "t12: expected abort on unmanaged collision with --force but succeeded"
    return
  fi
  # Verify the installer wrote nothing else (preflight aborts before any write).
  local count
  count="$(find "$dest/.github" -type f 2>/dev/null | wc -l | tr -d ' ')"
  if [[ "$count" -eq 1 ]]; then
    ok "t12: unmanaged collision rejects --force and writes no files"
  else
    fail "t12: expected 1 pre-placed file, found $count"
  fi
}

# ---------------------------------------------------------------------------
# t13: managed changed file permits --force
# ---------------------------------------------------------------------------
t13_managed_changed_permits_force() {
  local dest="$TMP/t13"
  mkdir -p "$dest"
  # First install creates managed state.
  if ! bash "$INSTALLER" --target "$dest" >/dev/null 2>&1; then
    fail "t13: setup install failed"
    return
  fi
  if [[ ! -f "$dest/.github/.aet-managed-state" ]]; then
    fail "t13: managed state file not created by install"
    return
  fi
  # Mutate a managed engine file.
  echo "MODIFIED" >> "$dest/.github/agents/aet-orchestrator.agent.md"
  # --force must succeed because the file is managed.
  if bash "$INSTALLER" --target "$dest" --force >/dev/null 2>&1; then
    ok "t13: managed changed file permits --force overwrite"
  else
    fail "t13: --force failed on managed changed file"
  fi
}

# ---------------------------------------------------------------------------
# t14: symlink at DEST (.github/) rejects install
# ---------------------------------------------------------------------------
t14_symlink_dest_rejects() {
  local real_dir="$TMP/t14-real"
  local target_dir="$TMP/t14"
  mkdir -p "$real_dir" "$target_dir"
  # Make .github a symlink to a real directory.
  ln -s "$real_dir" "$target_dir/.github"
  if bash "$INSTALLER" --target "$target_dir" >/dev/null 2>&1; then
    fail "t14: expected abort when DEST is a symlink but succeeded"
    return
  fi
  # Confirm the installer wrote nothing through the symlink.
  local count
  count="$(find "$real_dir" -type f 2>/dev/null | wc -l | tr -d ' ')"
  if [[ "$count" -eq 0 ]]; then
    ok "t14: symlink destination rejects and writes nothing"
  else
    fail "t14: symlink destination rejected but $count file(s) found in real dir"
  fi
}

# ---------------------------------------------------------------------------
# t15: symlinked --target rejects install
# ---------------------------------------------------------------------------
t15_symlinked_parent_rejects() {
  local real_parent="$TMP/t15-real"
  local link_parent="$TMP/t15-link"
  mkdir -p "$real_parent"
  ln -s "$real_parent" "$link_parent"
  # Installer must reject a symlinked --target before any writes.
  if bash "$INSTALLER" --target "$link_parent" >/dev/null 2>&1; then
    fail "t15: expected abort when --target is a symlink but succeeded"
    return
  fi
  local count
  count="$(find "$real_parent" -type f 2>/dev/null | wc -l | tr -d ' ')"
  if [[ "$count" -eq 0 ]]; then
    ok "t15: symlinked --target rejects and writes nothing"
  else
    fail "t15: symlinked --target rejected but $count file(s) found in real dir"
  fi
}

# ---------------------------------------------------------------------------
# t16: malformed state files reject install before any writes
# ---------------------------------------------------------------------------
t16_malformed_state_rejects() {
  local dest="$TMP/t16"
  local state_file="$dest/.github/.aet-managed-state"
  local case_name output before after bad=0
  local malformed_cases=(
    "empty"
    "headerless"
    "wrong-version"
    "displaced-blank"
    "displaced-comment"
    "duplicate-header"
    "bom-prefixed"
    "malformed-row"
  )
  mkdir -p "$dest"
  if ! bash "$INSTALLER" --target "$dest" >/dev/null 2>&1; then
    fail "t16: setup install failed"
    return
  fi

  for case_name in "${malformed_cases[@]}"; do
    case "$case_name" in
      empty)
        : > "$state_file"
        ;;
      headerless)
        printf 'agents/aet-orchestrator.agent.md\t%064d\n' 0 > "$state_file"
        ;;
      wrong-version)
        printf '# aet-managed-state v2\n' > "$state_file"
        ;;
      displaced-blank)
        printf '\n# aet-managed-state v1\n' > "$state_file"
        ;;
      displaced-comment)
        printf '# fixture comment\n# aet-managed-state v1\n' > "$state_file"
        ;;
      duplicate-header)
        printf '# aet-managed-state v1\n# aet-managed-state v1\n' > "$state_file"
        ;;
      bom-prefixed)
        printf '\357\273\277# aet-managed-state v1\n' > "$state_file"
        ;;
      malformed-row)
        printf '# aet-managed-state v1\nBAD_STATE_NO_TAB_HERE\n' > "$state_file"
        ;;
    esac

    before="$(find "$dest/.github" -type f -exec cksum {} \; | LC_ALL=C sort)"
    if output="$(bash "$INSTALLER" --target "$dest" 2>&1)"; then
      bad=$((bad + 1))
      continue
    fi
    after="$(find "$dest/.github" -type f -exec cksum {} \; | LC_ALL=C sort)"
    if [[ "$before" != "$after" ]] \
        || ! printf '%s\n' "$output" | grep -qF 'malformed state file at line '; then
      bad=$((bad + 1))
    fi
  done

  if [[ "$bad" -eq 0 ]]; then
    ok "t16: malformed state headers and rows reject without writes"
  else
    fail "t16: malformed state validation failed ($bad case(s))"
  fi
}

# ---------------------------------------------------------------------------
# t17: no writes occur when a symlinked path component causes preflight failure
# ---------------------------------------------------------------------------
t17_no_writes_on_symlink_preflight_failure() {
  local real_dir="$TMP/t17-real"
  local wrapper="$TMP/t17"
  mkdir -p "$real_dir" "$wrapper"
  # Create a symlink inside wrapper; use it as --target.
  local sym_target="$wrapper/middle"
  ln -s "$real_dir" "$sym_target"
  if bash "$INSTALLER" --target "$sym_target" >/dev/null 2>&1; then
    fail "t17: expected abort with symlinked --target but succeeded"
    return
  fi
  local count
  count="$(find "$real_dir" -type f 2>/dev/null | wc -l | tr -d ' ')"
  if [[ "$count" -eq 0 ]]; then
    ok "t17: no writes occur on symlink preflight failure"
  else
    fail "t17: symlink preflight failed but $count file(s) written to real dir"
  fi
}

check_bundle_reference_closure() {
  local root="$1" manifest_paths="$2"
  local entry src_file entry_dir raw_target target link_dir link_file abs_dir resolved
  BUNDLE_REFERENCE_ERRORS=()
  while IFS= read -r entry; do
    [[ -z "$entry" ]] && continue
    src_file="$root/$entry"
    [[ -f "$src_file" ]] || continue
    entry_dir="$(dirname "$entry")"

    # Extract [text](url) hyperlink targets.
    while IFS= read -r raw_target; do
      [[ -z "$raw_target" ]] && continue
      # Strip fragment identifier.
      target="${raw_target%%#*}"
      [[ -z "$target" ]] && continue
      # Skip external URLs and explicit illustrative install destinations.
      [[ "$target" == http://* || "$target" == https://* ]] && continue
      [[ "$target" == .github/* || "$target" == "~/.aet/"* ]] && continue

      # Resolve relative path via cd (works for simple ../dir/file.md patterns).
      link_dir="$(dirname "$target")"
      link_file="$(basename "$target")"
      if ! abs_dir="$(cd "$root/$entry_dir/$link_dir" 2>/dev/null && pwd -P)"; then
        BUNDLE_REFERENCE_ERRORS+=(
          "$entry links to '$target' whose parent directory cannot resolve"
        )
        continue
      fi
      resolved="${abs_dir#$root/}/$link_file"

      if ! printf '%s\n' "$manifest_paths" | grep -qxF "$resolved"; then
        BUNDLE_REFERENCE_ERRORS+=(
          "$entry links to '$resolved' not in portable bundle"
        )
      fi
    done < <(grep -oE '\[[^]]*\]\([^)]+\)' "$src_file" \
               | sed 's/^[^(]*(\(.*\))$/\1/' \
               | grep -v '^https\?://')
  done <<< "$manifest_paths"
}

check_omitted_governance_references() {
  local root="$1" manifest_paths="$2"
  local entry src_file source_artifact
  local source_artifacts=(
    "repository-rules.md"
    "aet-steward.agent.md"
    "reevaluate-toolkit/SKILL.md"
  )
  OMITTED_GOVERNANCE_REFERENCE_ERRORS=()
  while IFS= read -r entry; do
    [[ -z "$entry" ]] && continue
    src_file="$root/$entry"
    [[ -f "$src_file" ]] || continue
    for source_artifact in "${source_artifacts[@]}"; do
      if grep -qF -- "$source_artifact" "$src_file"; then
        OMITTED_GOVERNANCE_REFERENCE_ERRORS+=(
          "$entry names omitted source-governance artifact '$source_artifact'"
        )
      fi
    done
  done <<< "$manifest_paths"
}

# ---------------------------------------------------------------------------
# t18: bundle references resolve and omit source-governance artifacts
# ---------------------------------------------------------------------------
t18_bundle_reference_closure() {
  local bad=0 reference_error governance_error
  local manifest_paths
  manifest_paths="$(printf '%s\n' "${MANIFEST_ENTRIES[@]}")"

  check_bundle_reference_closure "$AET_ROOT" "$manifest_paths"
  if [[ -n "${BUNDLE_REFERENCE_ERRORS[*]-}" ]]; then
    for reference_error in "${BUNDLE_REFERENCE_ERRORS[@]}"; do
      fail "t18: $reference_error"
      bad=$((bad + 1))
    done
  fi

  check_omitted_governance_references "$AET_ROOT" "$manifest_paths"
  if [[ -n "${OMITTED_GOVERNANCE_REFERENCE_ERRORS[*]-}" ]]; then
    for governance_error in "${OMITTED_GOVERNANCE_REFERENCE_ERRORS[@]}"; do
      fail "t18: $governance_error"
      bad=$((bad + 1))
    done
  fi

  local fixture_root="$TMP/t18-broken-link"
  mkdir -p "$fixture_root/docs"
  printf '[broken](missing/target.md)\n' > "$fixture_root/docs/source.md"
  check_bundle_reference_closure "$fixture_root" "docs/source.md"
  if [[ ${#BUNDLE_REFERENCE_ERRORS[@]} -ne 1 \
      || "${BUNDLE_REFERENCE_ERRORS[0]-}" != *"parent directory cannot resolve"* ]]; then
    fail "t18: unresolved link parent regression was not detected"
    bad=$((bad + 1))
  fi

  local exemption_fixture_root="$TMP/t18-link-exemptions"
  mkdir -p "$exemption_fixture_root/docs"
  printf '%s\n' \
    '[absolute](/tmp/private.md)' \
    '[embedded](notes/.github/workflow.md)' \
    '[github-install](.github/agents/example.agent.md)' \
    '[aet-install](~/.aet/content/example.md)' \
    '[external](https://example.com/reference)' \
    > "$exemption_fixture_root/docs/source.md"
  check_bundle_reference_closure "$exemption_fixture_root" "docs/source.md"
  if [[ ${#BUNDLE_REFERENCE_ERRORS[@]} -ne 2 \
      || "${BUNDLE_REFERENCE_ERRORS[0]-}" != *"'/tmp/private.md'"* \
      || "${BUNDLE_REFERENCE_ERRORS[1]-}" != *"'notes/.github/workflow.md'"* ]]; then
    fail "t18: portable-link exemption regressions were not enforced"
    bad=$((bad + 1))
  fi

  local governance_fixture_root="$TMP/t18-omitted-governance"
  mkdir -p "$governance_fixture_root/skills/example"
  printf 'Inspect `repository-rules.md` and host `AGENTS.md`.\n' \
    > "$governance_fixture_root/skills/example/SKILL.md"
  check_omitted_governance_references \
    "$governance_fixture_root" "skills/example/SKILL.md"
  if [[ ${#OMITTED_GOVERNANCE_REFERENCE_ERRORS[@]} -ne 1 \
      || "${OMITTED_GOVERNANCE_REFERENCE_ERRORS[0]-}" \
        != *"repository-rules.md"* ]]; then
    fail "t18: omitted source-governance reference regression was not detected"
    bad=$((bad + 1))
  fi

  if [[ "$bad" -eq 0 ]]; then
    ok "t18: bundle links resolve and omitted governance references reject"
  fi
}

# ---------------------------------------------------------------------------
# t19: dangling symlink at a manifest file rejects before writes
# ---------------------------------------------------------------------------
t19_dangling_file_symlink_rejects() {
  local dest="$TMP/t19"
  local outside="$TMP/t19-outside"
  mkdir -p "$dest/.github/agents" "$outside"
  ln -s "$outside/missing.md" "$dest/.github/agents/aet-orchestrator.agent.md"
  if bash "$INSTALLER" --target "$dest" --force >/dev/null 2>&1; then
    fail "t19: expected dangling destination symlink to abort"
    return
  fi
  if [[ ! -e "$outside/missing.md" ]]; then
    ok "t19: dangling destination symlink rejects without outside write"
  else
    fail "t19: installer wrote through dangling destination symlink"
  fi
}

# ---------------------------------------------------------------------------
# t20: symlinked module directory rejects before writes
# ---------------------------------------------------------------------------
t20_symlinked_module_directory_rejects() {
  local dest="$TMP/t20"
  local outside="$TMP/t20-outside"
  mkdir -p "$dest/.github" "$outside"
  ln -s "$outside" "$dest/.github/agents"
  if bash "$INSTALLER" --target "$dest" --force >/dev/null 2>&1; then
    fail "t20: expected symlinked module directory to abort"
    return
  fi
  local count
  count="$(find "$outside" -type f 2>/dev/null | wc -l | tr -d ' ')"
  if [[ "$count" -eq 0 ]]; then
    ok "t20: symlinked module directory rejects without outside writes"
  else
    fail "t20: installer wrote $count file(s) through module symlink"
  fi
}

# ---------------------------------------------------------------------------
# t21: dangling managed-state symlink rejects before writes
# ---------------------------------------------------------------------------
t21_dangling_state_symlink_rejects() {
  local dest="$TMP/t21"
  local outside="$TMP/t21-outside"
  mkdir -p "$dest/.github" "$outside"
  ln -s "$outside/missing-state" "$dest/.github/.aet-managed-state"
  if bash "$INSTALLER" --target "$dest" >/dev/null 2>&1; then
    fail "t21: expected dangling state symlink to abort"
    return
  fi
  local count
  count="$(find "$dest/.github" "$outside" -type f 2>/dev/null | wc -l | tr -d ' ')"
  if [[ "$count" -eq 0 ]]; then
    ok "t21: dangling state symlink rejects without writes"
  else
    fail "t21: dangling state symlink rejection wrote $count file(s)"
  fi
}

# ---------------------------------------------------------------------------
# t23: global dry-run uses isolated HOME and writes nothing
# ---------------------------------------------------------------------------
t23_global_dry_run_no_writes() {
  local home="$TMP/t23-home"
  local work="$TMP/t23-work"
  mkdir -p "$home" "$work"
  if ! (cd "$work" && HOME="$home" bash "$INSTALLER" --global --dry-run \
      >/dev/null 2>&1); then
    fail "t23: global dry-run exited non-zero"
    return
  fi
  if [[ -e "$home/.aet" ]] \
      || [[ -n "$(find "$work" -mindepth 1 -print -quit)" ]]; then
    fail "t23: global dry-run wrote to HOME or working directory"
  else
    ok "t23: global dry-run writes nothing"
  fi
}

# ---------------------------------------------------------------------------
# t24: global install writes bundle/state and prints location settings
# ---------------------------------------------------------------------------
t24_global_install_and_guidance() {
  local home="$TMP/t24-home"
  local install_output
  mkdir -p "$home"
  if ! install_output="$(HOME="$home" bash "$INSTALLER" --global 2>&1)"; then
    fail "t24: global install exited non-zero"
    return
  fi

  local missing=0 entry
  for entry in "${MANIFEST_ENTRIES[@]}"; do
    if [[ ! -f "$home/.aet/$entry" ]] \
        || ! cmp -s "$AET_ROOT/$entry" "$home/.aet/$entry"; then
      missing=$((missing + 1))
    fi
  done

  local expected_count state_count
  expected_count="${#MANIFEST_ENTRIES[@]}"
  state_count="$(grep -v '^[[:space:]]*$' "$home/.aet/.aet-managed-state" \
    | grep -cv '^#')"
  if [[ "$missing" -ne 0 || "$state_count" -ne "$expected_count" ]]; then
    fail "t24: global bundle/state incomplete ($missing bad files, $state_count state entries)"
    return
  fi

  if ! printf '%s\n' "$install_output" \
      | grep -qF '"chat.agentFilesLocations"' \
      || ! printf '%s\n' "$install_output" \
      | grep -qF '"chat.instructionsFilesLocations"' \
      || [[ "$install_output" == *'"chat.agentSkillsLocations"'* \
         || "$install_output" == *'"chat.promptFilesLocations"'* \
         || "$install_output" != *"native user-skill discovery location"* ]] \
      || [[ "$install_output" != *"Audience template for host project root AGENTS.md"* ]]; then
    fail "t24: global location settings are incomplete"
    return
  fi

  ok "t24: global install writes bundle/state and prints location settings"
}

# ---------------------------------------------------------------------------
# t25: identical global reinstall succeeds
# ---------------------------------------------------------------------------
t25_global_identical_reinstall() {
  local home="$TMP/t25-home"
  mkdir -p "$home"
  if ! HOME="$home" bash "$INSTALLER" --global >/dev/null 2>&1; then
    fail "t25: first global install failed"
    return
  fi
  if HOME="$home" bash "$INSTALLER" --global >/dev/null 2>&1; then
    ok "t25: identical global reinstall succeeds"
  else
    fail "t25: identical global reinstall failed"
  fi
}

# ---------------------------------------------------------------------------
# t26: changed managed global engine file requires --force
# ---------------------------------------------------------------------------
t26_global_managed_change_requires_force() {
  local home="$TMP/t26-home"
  local installed="$home/.aet/agents/aet-orchestrator.agent.md"
  mkdir -p "$home"
  if ! HOME="$home" bash "$INSTALLER" --global >/dev/null 2>&1; then
    fail "t26: setup global install failed"
    return
  fi
  echo "MODIFIED" >> "$installed"
  if HOME="$home" bash "$INSTALLER" --global >/dev/null 2>&1; then
    fail "t26: changed managed global file succeeded without --force"
    return
  fi
  if ! HOME="$home" bash "$INSTALLER" --global --force >/dev/null 2>&1; then
    fail "t26: changed managed global file failed with --force"
    return
  fi
  if cmp -s "$AET_ROOT/agents/aet-orchestrator.agent.md" "$installed"; then
    ok "t26: changed managed global file requires and accepts --force"
  else
    fail "t26: --force did not restore changed managed global file"
  fi
}

# ---------------------------------------------------------------------------
# t27: --global with --target rejects before writes
# ---------------------------------------------------------------------------
t27_global_with_target_rejects() {
  local home="$TMP/t27-home"
  local target="$TMP/t27-target"
  local output
  mkdir -p "$home" "$target"
  if output="$(HOME="$home" bash "$INSTALLER" --global --target "$target" 2>&1)"; then
    fail "t27: --global with --target succeeded"
    return
  fi
  if [[ ! -e "$home/.aet" ]] \
      && printf '%s\n' "$output" | grep -qF 'mutually exclusive'; then
    ok "t27: --global with --target rejects before writes"
  else
    fail "t27: --global with --target rejection was incomplete"
  fi
}

# ---------------------------------------------------------------------------
# t28: symlinked global destination rejects before writes
# ---------------------------------------------------------------------------
t28_symlinked_global_destination_rejects() {
  local home="$TMP/t28-home"
  local real_dir="$TMP/t28-real"
  mkdir -p "$home" "$real_dir"
  ln -s "$real_dir" "$home/.aet"
  if HOME="$home" bash "$INSTALLER" --global >/dev/null 2>&1; then
    fail "t28: symlinked global destination succeeded"
    return
  fi
  local count
  count="$(find "$real_dir" -type f 2>/dev/null | wc -l | tr -d ' ')"
  if [[ "$count" -eq 0 ]]; then
    ok "t28: symlinked global destination rejects without writes"
  else
    fail "t28: symlinked global destination wrote $count file(s)"
  fi
}

# ---------------------------------------------------------------------------
# t30: raw target/global path symlinks reject before canonicalization
# ---------------------------------------------------------------------------
t30_raw_path_component_symlinks_reject() {
  local parent_real="$TMP/t30-parent-real"
  local parent_wrapper="$TMP/t30-parent-wrapper"
  local trailing_real="$TMP/t30-trailing-real"
  local trailing_link="$TMP/t30-trailing-link"
  local global_real="$TMP/t30-global-real"
  local global_wrapper="$TMP/t30-global-wrapper"
  local bad=0 count

  mkdir -p "$parent_real/target" "$parent_wrapper"
  ln -s "$parent_real" "$parent_wrapper/linked-parent"
  if bash "$INSTALLER" \
      --target "$parent_wrapper/linked-parent/target" >/dev/null 2>&1; then
    bad=$((bad + 1))
  fi
  count="$(find "$parent_real/target" -type f 2>/dev/null | wc -l | tr -d ' ')"
  [[ "$count" -eq 0 ]] || bad=$((bad + 1))

  mkdir -p "$trailing_real"
  ln -s "$trailing_real" "$trailing_link"
  if bash "$INSTALLER" --target "$trailing_link/" >/dev/null 2>&1; then
    bad=$((bad + 1))
  fi
  count="$(find "$trailing_real" -type f 2>/dev/null | wc -l | tr -d ' ')"
  [[ "$count" -eq 0 ]] || bad=$((bad + 1))

  mkdir -p "$global_real/home" "$global_wrapper"
  ln -s "$global_real" "$global_wrapper/linked-parent"
  if HOME="$global_wrapper/linked-parent/home" \
      bash "$INSTALLER" --global >/dev/null 2>&1; then
    bad=$((bad + 1))
  fi
  count="$(find "$global_real/home" -type f 2>/dev/null | wc -l | tr -d ' ')"
  [[ "$count" -eq 0 ]] || bad=$((bad + 1))

  if [[ "$bad" -eq 0 ]]; then
    ok "t30: raw target/global symlink components reject without writes"
  else
    fail "t30: raw path symlink regression failed ($bad assertion(s))"
  fi
}

# ---------------------------------------------------------------------------
# t31: malformed manifests reject before source/destination file access
# ---------------------------------------------------------------------------
t31_malformed_manifest_paths_reject() {
  local source_root="$TMP/t31-source"
  local dest="$TMP/t31-dest"
  local output entry index bad=0
  local malformed_entries=(
    "/absolute.md"
    "../outside.md"
    "agents/../outside.md"
    "./agents/aet-orchestrator.agent.md"
    "agents//bad.md"
    "agents/./bad.md"
    "agents/bad.md/"
    $'agents/\tbad.md'
    $'agents/\rbad.md'
  )

  mkdir -p "$source_root/scripts" "$source_root/agents" "$dest"
  cp "$INSTALLER" "$source_root/scripts/aet-install.sh"
  printf 'fixture\n' > "$source_root/agents/aet-orchestrator.agent.md"

  for ((index=0; index<${#malformed_entries[@]}; index++)); do
    entry="${malformed_entries[$index]}"
    rm -rf "$dest/.github"
    printf '# fixture manifest\n\nagents/aet-orchestrator.agent.md\n%s\n' \
      "$entry" > "$source_root/scripts/aet-manifest.txt"
    if output="$(bash "$source_root/scripts/aet-install.sh" \
        --target "$dest" 2>&1)"; then
      bad=$((bad + 1))
      continue
    fi
    if [[ -e "$dest/.github" ]] \
        || ! printf '%s\n' "$output" \
        | grep -qF 'invalid manifest entry at line 4'; then
      bad=$((bad + 1))
    fi
  done

  rm -rf "$dest/.github"
  printf '# fixture manifest\n\nagents/aet-orchestrator.agent.md\0agents/bad.md\n' \
    > "$source_root/scripts/aet-manifest.txt"
  if output="$(bash "$source_root/scripts/aet-install.sh" \
      --target "$dest" 2>&1)"; then
    bad=$((bad + 1))
  elif [[ -e "$dest/.github" ]] \
      || ! printf '%s\n' "$output" | grep -qF 'manifest validation failed'; then
    bad=$((bad + 1))
  fi

  rm -rf "$dest/.github"
  printf '# fixture manifest\n\nagents/aet-orchestrator.agent.md\nagents/aet-orchestrator.agent.md\n' \
    > "$source_root/scripts/aet-manifest.txt"
  if output="$(bash "$source_root/scripts/aet-install.sh" \
      --target "$dest" 2>&1)"; then
    bad=$((bad + 1))
  elif [[ -e "$dest/.github" ]] \
      || ! printf '%s\n' "$output" \
      | grep -qF 'invalid manifest entry at line 4 (duplicate entry)'; then
    bad=$((bad + 1))
  fi

  if [[ "$bad" -eq 0 ]]; then
    ok "t31: malformed and duplicate manifests reject before file access"
  else
    fail "t31: malformed manifest validation failed ($bad case(s))"
  fi
}

# ---------------------------------------------------------------------------
# t32: legacy predictable state temp symlink cannot overwrite outside files
# ---------------------------------------------------------------------------
t32_state_temp_symlink_cannot_overwrite() {
  local dest="$TMP/t32-dest"
  local outside="$TMP/t32-outside"
  local marker="$TMP/t32-legacy-path"
  local legacy temp_count bad=0

  mkdir -p "$dest/.github"
  printf 'outside sentinel\n' > "$outside"
  if ! bash -c '
      target="$1"
      installer="$2"
      outside="$3"
      marker="$4"
      legacy="$target/.github/.aet-managed-state.tmp.$$"
      printf "%s\n" "$legacy" > "$marker"
      ln -s "$outside" "$legacy"
      . "$installer" --target "$target"
    ' _ "$dest" "$INSTALLER" "$outside" "$marker" >/dev/null 2>&1; then
    fail "t32: install failed with legacy temp symlink present"
    return
  fi

  legacy="$(cat "$marker")"
  [[ "$(cat "$outside")" == "outside sentinel" ]] || bad=$((bad + 1))
  [[ -L "$legacy" ]] || bad=$((bad + 1))
  [[ -f "$dest/.github/.aet-managed-state" \
      && ! -L "$dest/.github/.aet-managed-state" ]] || bad=$((bad + 1))
  rm -f "$legacy"
  temp_count="$(find "$dest/.github" -maxdepth 1 \
    -name '.aet-managed-state.tmp.*' -print | wc -l | tr -d ' ')"
  [[ "$temp_count" -eq 0 ]] || bad=$((bad + 1))

  if [[ "$bad" -eq 0 ]]; then
    ok "t32: state temp symlink cannot overwrite outside or leave temp files"
  else
    fail "t32: state temp symlink regression failed ($bad assertion(s))"
  fi
}

# ---------------------------------------------------------------------------
# t33: existing managed-state directory rejects before writes
# ---------------------------------------------------------------------------
t33_state_directory_rejects_without_writes() {
  local dest="$TMP/t33-dest"
  local state_dir="$dest/.github/.aet-managed-state"
  local output nested_count file_count bad=0

  mkdir -p "$state_dir"
  if output="$(bash "$INSTALLER" --target "$dest" 2>&1)"; then
    fail "t33: existing state directory succeeded"
    return
  fi

  nested_count="$(find "$state_dir" -mindepth 1 -print | wc -l | tr -d ' ')"
  file_count="$(find "$dest/.github" -type f -print | wc -l | tr -d ' ')"
  [[ "$nested_count" -eq 0 ]] || bad=$((bad + 1))
  [[ "$file_count" -eq 0 ]] || bad=$((bad + 1))
  printf '%s\n' "$output" \
    | grep -qF "state path is not a regular file: $state_dir" \
    || bad=$((bad + 1))
  if printf '%s\n' "$output" | grep -qF 'done —'; then
    bad=$((bad + 1))
  fi

  if [[ "$bad" -eq 0 ]]; then
    ok "t33: state directory rejects without nested temp or success"
  else
    fail "t33: state directory regression failed ($bad assertion(s))"
  fi
}

# ---------------------------------------------------------------------------
# t34: raw NUL bytes in managed state reject before parsing or writes
# ---------------------------------------------------------------------------
t34_state_raw_nul_rejects_without_writes() {
  local dest="$TMP/t34-dest"
  local state_file="$dest/.github/.aet-managed-state"
  local case_name output before after bad=0

  mkdir -p "$dest"
  if ! bash "$INSTALLER" --target "$dest" >/dev/null 2>&1; then
    fail "t34: setup install failed"
    return
  fi

  for case_name in header body; do
    case "$case_name" in
      header)
        printf '# aet-managed\000-state v1\n' > "$state_file"
        ;;
      body)
        printf '# aet-managed-state v1\nagents/aet-orchestrator.agent.md\000\t%064d\n' \
          0 > "$state_file"
        ;;
    esac

    before="$(find "$dest/.github" -type f -exec cksum {} \; | LC_ALL=C sort)"
    if output="$(bash "$INSTALLER" --target "$dest" 2>&1)"; then
      bad=$((bad + 1))
      continue
    fi
    after="$(find "$dest/.github" -type f -exec cksum {} \; | LC_ALL=C sort)"
    if [[ "$before" != "$after" ]] \
        || ! printf '%s\n' "$output" \
        | grep -qF 'malformed state file (raw NUL byte)'; then
      bad=$((bad + 1))
    fi
  done

  if [[ "$bad" -eq 0 ]]; then
    ok "t34: raw NUL state header and body reject without writes"
  else
    fail "t34: raw NUL state validation failed ($bad case(s))"
  fi
}

# ---------------------------------------------------------------------------
# t35: engine destination directories reject, including with --force
# ---------------------------------------------------------------------------
t35_engine_directory_rejects_without_writes() {
  local mode dest engine output before after nested_count bad=0
  local args

  for mode in normal force; do
    dest="$TMP/t35-$mode"
    engine="$dest/.github/agents/aet-orchestrator.agent.md"
    mkdir -p "$dest"
    if ! bash "$INSTALLER" --target "$dest" >/dev/null 2>&1; then
      bad=$((bad + 1))
      continue
    fi
    rm -f "$engine"
    mkdir "$engine"
    before="$(find "$dest/.github" -type f -exec cksum {} \; | LC_ALL=C sort)"
    args=(--target "$dest")
    [[ "$mode" == "normal" ]] || args+=(--force)

    if output="$(bash "$INSTALLER" "${args[@]}" 2>&1)"; then
      bad=$((bad + 1))
      continue
    fi
    after="$(find "$dest/.github" -type f -exec cksum {} \; | LC_ALL=C sort)"
    nested_count="$(find "$engine" -mindepth 1 -print | wc -l | tr -d ' ')"
    if [[ "$before" != "$after" || ! -d "$engine" || "$nested_count" -ne 0 ]] \
        || ! printf '%s\n' "$output" \
        | grep -qF "destination is not a regular file: $engine"; then
      bad=$((bad + 1))
    fi
  done

  if [[ "$bad" -eq 0 ]]; then
    ok "t35: engine directory rejects without writes, including --force"
  else
    fail "t35: engine directory regression failed ($bad case(s))"
  fi
}

# ---------------------------------------------------------------------------
# t36: engine destination FIFOs reject without blocking, including --force
# ---------------------------------------------------------------------------
t36_engine_fifo_rejects_without_writes() {
  local mode dest engine output before after feeder bad=0
  local args

  for mode in normal force; do
    dest="$TMP/t36-$mode"
    engine="$dest/.github/agents/aet-orchestrator.agent.md"
    mkdir -p "$dest"
    if ! bash "$INSTALLER" --target "$dest" >/dev/null 2>&1; then
      bad=$((bad + 1))
      continue
    fi
    rm -f "$engine"
    mkfifo "$engine"
    before="$(find "$dest/.github" -type f -exec cksum {} \; | LC_ALL=C sort)"
    args=(--target "$dest")
    if [[ "$mode" == "force" ]]; then
      args+=(--force)
      (printf 'different\n' > "$engine"; cat "$engine" >/dev/null) &
    else
      (printf 'different\n' > "$engine") &
    fi
    feeder=$!

    if output="$(bash "$INSTALLER" "${args[@]}" 2>&1)"; then
      bad=$((bad + 1))
    fi
    kill "$feeder" 2>/dev/null || true
    wait "$feeder" 2>/dev/null || true
    after="$(find "$dest/.github" -type f -exec cksum {} \; | LC_ALL=C sort)"
    if [[ "$before" != "$after" || ! -p "$engine" ]] \
        || ! printf '%s\n' "$output" \
        | grep -qF "destination is not a regular file: $engine"; then
      bad=$((bad + 1))
    fi
  done

  if [[ "$bad" -eq 0 ]]; then
    ok "t36: engine FIFO rejects without blocking or writes, including --force"
  else
    fail "t36: engine FIFO regression failed ($bad case(s))"
  fi
}

# ---------------------------------------------------------------------------
# t37: global mode rejects unsafe HOME values before writes
# ---------------------------------------------------------------------------
t37_global_home_rejects() {
  local work="$TMP/t37-work"
  local relative_home="$TMP/t37-work/relative-home"
  local missing_home="$TMP/t37-missing"
  local root_equivalent="$AET_ROOT"
  local current="$AET_ROOT"
  local output
  local bad=0
  mkdir -p "$relative_home"

  while [[ "$current" != "/" ]]; do
    root_equivalent="$root_equivalent/.."
    current="$(dirname "$current")"
  done

  if output="$(cd "$work" && env -u HOME bash "$INSTALLER" --global 2>&1)"; then
    bad=$((bad + 1))
  elif ! printf '%s\n' "$output" | grep -qF 'HOME is not set'; then
    bad=$((bad + 1))
  fi
  if output="$(cd "$work" && HOME="relative-home" \
      bash "$INSTALLER" --global 2>&1)"; then
    bad=$((bad + 1))
  elif ! printf '%s\n' "$output" \
      | grep -qF 'HOME must be an absolute path: relative-home'; then
    bad=$((bad + 1))
  fi
  if output="$(HOME="$missing_home" bash "$INSTALLER" --global 2>&1)"; then
    bad=$((bad + 1))
  elif ! printf '%s\n' "$output" \
      | grep -qF "HOME is not a directory: $missing_home"; then
    bad=$((bad + 1))
  fi
  if output="$(HOME="/" bash "$INSTALLER" --global --dry-run 2>&1)"; then
    bad=$((bad + 1))
  elif ! printf '%s\n' "$output" \
      | grep -qF 'HOME cannot be the filesystem root'; then
    bad=$((bad + 1))
  fi
  if output="$(HOME="$root_equivalent" bash "$INSTALLER" --global \
      --dry-run 2>&1)"; then
    bad=$((bad + 1))
  elif ! printf '%s\n' "$output" \
      | grep -qF 'HOME cannot be the filesystem root'; then
    bad=$((bad + 1))
  fi

  if [[ -e "$relative_home/.aet" || -e "$work/.aet" || -e "$missing_home" ]]; then
    bad=$((bad + 1))
  fi

  if [[ "$bad" -eq 0 ]]; then
    ok "t37: unsafe HOME values reject without writes"
  else
    fail "t37: unsafe HOME validation failed ($bad case(s))"
  fi
}

# ---------------------------------------------------------------------------
# t38: unsafe release manifests reject before source copies or artifact writes
# ---------------------------------------------------------------------------
t38_release_manifest_validation_rejects_without_writes() {
  local build_script="$SCRIPT_DIR/build-release.sh"
  local source_root="$TMP/t38-source"
  local work="$TMP/t38-work"
  local bin_dir="$TMP/t38-bin"
  local copy_marker="$TMP/t38-copy-marker"
  local real_cp output entry file_count
  local index bad=0
  local malformed_entries=(
    "/absolute.md"
    "../outside.md"
    "agents/../outside.md"
    "./agents/valid.md"
    "agents//bad.md"
    "agents/./bad.md"
    "agents/bad.md/"
    $'agents/\tbad.md'
    $'agents/\rbad.md'
  )

  real_cp="$(command -v cp)"
  mkdir -p "$source_root/scripts" "$source_root/agents" "$bin_dir"
  cp "$build_script" "$source_root/scripts/build-release.sh"
  printf 'fixture\n' > "$source_root/agents/valid.md"
  printf '%s\n' \
    '#!/usr/bin/env bash' \
    'printf "copy\n" >> "$COPY_MARKER"' \
    'exec "$REAL_CP" "$@"' \
    > "$bin_dir/cp"
  chmod +x "$bin_dir/cp"

  for ((index=0; index<${#malformed_entries[@]}; index++)); do
    entry="${malformed_entries[$index]}"
    rm -rf "$work"
    rm -f "$copy_marker"
    mkdir -p "$work"
    printf '# fixture manifest\n\nagents/valid.md\n%s\n' "$entry" \
      > "$source_root/scripts/aet-manifest.txt"
    if output="$(cd "$work" && COPY_MARKER="$copy_marker" REAL_CP="$real_cp" \
        PATH="$bin_dir:$PATH" \
        bash "$source_root/scripts/build-release.sh" v0.0.1 2>&1)"; then
      bad=$((bad + 1))
      continue
    fi
    file_count="$(find "$work" -mindepth 1 -print | wc -l | tr -d ' ')"
    if [[ -e "$copy_marker" || "$file_count" -ne 0 ]] \
        || ! printf '%s\n' "$output" \
        | grep -qF 'invalid manifest entry at line 4'; then
      bad=$((bad + 1))
    fi
  done

  rm -rf "$work"
  rm -f "$copy_marker"
  mkdir -p "$work"
  printf '# fixture manifest\n\nagents/valid.md\nagents/valid.md\n' \
    > "$source_root/scripts/aet-manifest.txt"
  if output="$(cd "$work" && COPY_MARKER="$copy_marker" REAL_CP="$real_cp" \
      PATH="$bin_dir:$PATH" \
      bash "$source_root/scripts/build-release.sh" v0.0.1 2>&1)"; then
    bad=$((bad + 1))
  else
    file_count="$(find "$work" -mindepth 1 -print | wc -l | tr -d ' ')"
    if [[ -e "$copy_marker" || "$file_count" -ne 0 ]] \
        || ! printf '%s\n' "$output" \
        | grep -qF 'invalid manifest entry at line 4 (duplicate entry)'; then
      bad=$((bad + 1))
    fi
  fi

  rm -rf "$work"
  rm -f "$copy_marker"
  mkdir -p "$work"
  printf '# fixture manifest\n\nagents/valid.md\0agents/bad.md\n' \
    > "$source_root/scripts/aet-manifest.txt"
  if output="$(cd "$work" && COPY_MARKER="$copy_marker" REAL_CP="$real_cp" \
      PATH="$bin_dir:$PATH" \
      bash "$source_root/scripts/build-release.sh" v0.0.1 2>&1)"; then
    bad=$((bad + 1))
  else
    file_count="$(find "$work" -mindepth 1 -print | wc -l | tr -d ' ')"
    if [[ -e "$copy_marker" || "$file_count" -ne 0 ]] \
        || ! printf '%s\n' "$output" \
        | grep -qF 'manifest validation failed'; then
      bad=$((bad + 1))
    fi
  fi

  if [[ "$bad" -eq 0 ]]; then
    ok "t38: unsafe release manifests reject before copies or artifacts"
  else
    fail "t38: release manifest validation failed ($bad case(s))"
  fi
}

# ---------------------------------------------------------------------------
# t39: installer rejects manifest source symlinks and escaped parents
# ---------------------------------------------------------------------------
t39_installer_source_symlinks_reject() {
  local source_root="$TMP/t39-source"
  local dest="$TMP/t39-dest"
  local outside="$TMP/t39-outside"
  local output bad=0

  mkdir -p "$source_root/scripts" "$source_root/agents" "$dest" "$outside"
  cp "$INSTALLER" "$source_root/scripts/aet-install.sh"
  printf 'fixture\n' > "$source_root/agents/aet-orchestrator.agent.md"
  printf 'outside\n' > "$outside/file.md"

  ln -s "$outside/file.md" "$source_root/agents/external.md"
  printf 'agents/aet-orchestrator.agent.md\nagents/external.md\n' \
    > "$source_root/scripts/aet-manifest.txt"
  if output="$(bash "$source_root/scripts/aet-install.sh" --target "$dest" 2>&1)"; then
    bad=$((bad + 1))
  elif ! printf '%s\n' "$output" | grep -qF 'manifest entry is a symlink:'; then
    bad=$((bad + 1))
  fi

  rm -f "$source_root/agents/external.md"
  ln -s "$outside" "$source_root/linked"
  printf 'agents/aet-orchestrator.agent.md\nlinked/file.md\n' \
    > "$source_root/scripts/aet-manifest.txt"
  if output="$(bash "$source_root/scripts/aet-install.sh" --target "$dest" 2>&1)"; then
    bad=$((bad + 1))
  elif ! printf '%s\n' "$output" \
      | grep -qF 'manifest entry resolves outside source root:'; then
    bad=$((bad + 1))
  fi

  [[ ! -e "$dest/.github" ]] || bad=$((bad + 1))
  if [[ "$bad" -eq 0 ]]; then
    ok "t39: installer source symlinks and escaped parents reject before writes"
  else
    fail "t39: installer source containment regression failed ($bad assertion(s))"
  fi
}

# ---------------------------------------------------------------------------
# t40: release build rejects manifest source symlinks and escaped parents
# ---------------------------------------------------------------------------
t40_release_source_symlinks_reject() {
  local source_root="$TMP/t40-source"
  local work="$TMP/t40-work"
  local outside="$TMP/t40-outside"
  local output file_count bad=0

  mkdir -p "$source_root/scripts" "$source_root/agents" "$work" "$outside"
  cp "$SCRIPT_DIR/build-release.sh" "$source_root/scripts/build-release.sh"
  printf 'fixture\n' > "$source_root/agents/valid.md"
  printf 'outside\n' > "$outside/file.md"

  ln -s "$outside/file.md" "$source_root/agents/external.md"
  printf 'agents/valid.md\nagents/external.md\n' \
    > "$source_root/scripts/aet-manifest.txt"
  if output="$(cd "$work" && \
      bash "$source_root/scripts/build-release.sh" v0.0.1 2>&1)"; then
    bad=$((bad + 1))
  elif ! printf '%s\n' "$output" | grep -qF 'manifest entry is a symlink:'; then
    bad=$((bad + 1))
  fi

  rm -f "$source_root/agents/external.md"
  ln -s "$outside" "$source_root/linked"
  printf 'agents/valid.md\nlinked/file.md\n' \
    > "$source_root/scripts/aet-manifest.txt"
  if output="$(cd "$work" && \
      bash "$source_root/scripts/build-release.sh" v0.0.1 2>&1)"; then
    bad=$((bad + 1))
  elif ! printf '%s\n' "$output" \
      | grep -qF 'manifest entry resolves outside repository root:'; then
    bad=$((bad + 1))
  fi

  file_count="$(find "$work" -mindepth 1 -print | wc -l | tr -d ' ')"
  [[ "$file_count" -eq 0 ]] || bad=$((bad + 1))
  if [[ "$bad" -eq 0 ]]; then
    ok "t40: release source symlinks and escaped parents reject before artifacts"
  else
    fail "t40: release source containment regression failed ($bad assertion(s))"
  fi
}

# ---------------------------------------------------------------------------
# t41: test harness rejects unsafe canonical manifests before tests run
# ---------------------------------------------------------------------------
t41_test_manifest_startup_validation() {
  local fixture="$TMP/t41-fixture"
  local output case_name expected bad=0
  mkdir -p "$fixture/scripts"
  cp "$SCRIPT_DIR/test-install.sh" "$fixture/scripts/test-install.sh"

  for case_name in traversal control duplicate; do
    case "$case_name" in
      traversal)
        printf 'agents/../outside.md\n' > "$fixture/scripts/aet-manifest.txt"
        expected='parent traversal'
        ;;
      control)
        printf 'agents/\tbad.md\n' > "$fixture/scripts/aet-manifest.txt"
        expected='control character'
        ;;
      duplicate)
        printf 'agents/valid.md\nagents/valid.md\n' > "$fixture/scripts/aet-manifest.txt"
        expected='duplicate entry'
        ;;
    esac
    if output="$(bash "$fixture/scripts/test-install.sh" 2>&1)"; then
      bad=$((bad + 1))
    elif [[ "$output" != *"$expected"* || "$output" == *'[PASS]'* ]]; then
      bad=$((bad + 1))
    fi
  done

  printf 'agents/valid.md\0agents/bad.md\n' > "$fixture/scripts/aet-manifest.txt"
  if output="$(bash "$fixture/scripts/test-install.sh" 2>&1)"; then
    bad=$((bad + 1))
  elif [[ "$output" != *'manifest validation failed'* || "$output" == *'[PASS]'* ]]; then
    bad=$((bad + 1))
  fi

  if [[ "$bad" -eq 0 ]]; then
    ok "t41: unsafe canonical manifests reject before tests run"
  else
    fail "t41: test manifest startup validation failed ($bad case(s))"
  fi
}

t42_test_scratch_startup_validation() {
  local fixture="$TMP/t42-fixture"
  local output case_name expected result bad=0
  mkdir -p "$fixture/scripts" "$fixture/scratch"
  cp "$SCRIPT_DIR/test-install.sh" "$fixture/scripts/test-install.sh"
  printf 'agents/../outside.md\n' > "$fixture/scripts/aet-manifest.txt"
  cat > "$fixture/startup-stubs.sh" <<'STUB'
mktemp() {
  case "$TEST_CASE" in
    mktemp-failure) return 1 ;;
    mktemp-failure-output) printf '%s\n' "$PWD"; return 1 ;;
    mktemp-empty) return 0 ;;
    *) printf '%s\n' "$TEST_SCRATCH" ;;
  esac
}
cd() {
  if [[ "$TEST_CASE" == cd-failure &&
      ( "${1-}" == "$TEST_SCRATCH" || "${2-}" == "$TEST_SCRATCH" ) ]]; then
    return 1
  fi
  builtin cd "$@"
}
pwd() {
  if [[ "${1-}" == -P ]]; then
    case "$TEST_CASE" in
      pwd-failure) return 1 ;;
      pwd-empty) return 0 ;;
    esac
  fi
  builtin pwd "$@"
}
trap() { printf 'cleanup trap registered\n'; builtin trap "$@"; }
rm() { printf 'cleanup called:'; printf ' <%s>' "$@"; printf '\n'; }
STUB

  for case_name in mktemp-failure mktemp-failure-output mktemp-empty \
      cd-failure pwd-failure pwd-empty normal; do
    case "$case_name" in
      mktemp-*) expected='could not create scratch directory' ;;
      normal) expected='parent traversal' ;;
      *) expected='could not normalize scratch directory' ;;
    esac
    result=0
    output="$(TEST_CASE="$case_name" TEST_SCRATCH="$fixture/scratch" \
      BASH_ENV="$fixture/startup-stubs.sh" \
      bash "$fixture/scripts/test-install.sh" 2>&1)" || result=$?
    if [[ "$result" -ne 1 || "$output" != *"$expected"* || "$output" == *'[PASS]'* ]]; then
      bad=$((bad + 1))
    elif [[ "$case_name" == normal ]]; then
      if [[ "$output" != *'cleanup trap registered'* ||
          "$(printf '%s\n' "$output" | grep -F 'cleanup called:')" != \
            "cleanup called: <-rf> <--> <$fixture/scratch>" ]]; then
        bad=$((bad + 1))
      fi
    elif [[ "$output" == *'cleanup trap registered'* ||
        "$output" == *'cleanup called:'* || "$output" == *'invalid manifest entry'* ]]; then
      bad=$((bad + 1))
    fi
  done

  if [[ "$bad" -eq 0 ]]; then
    ok "t42: scratch startup failures stop before cleanup; normal startup cleans only scratch"
  else
    fail "t42: scratch startup validation failed ($bad case(s))"
  fi
}

t43_team_sharing_inventory() {
  local dest="$TMP/t43-source" team="$TMP/t43-team" content="$TMP/t43-content"
  local output inventory expected relative
  mkdir -p "$dest/.github/private" "$dest/.github/workflows" \
    "$dest/.github/instructions" "$content/instructions" "$team"
  printf 'private fixture\n' > "$dest/.github/private/notes.md"
  printf 'unrelated workflow\n' > "$dest/.github/workflows/host.yml"
  printf 'private instruction\n' > "$dest/.github/instructions/private.instructions.md"
  printf 'content fixture\n' > "$content/instructions/team.instructions.md"
  if ! output="$(bash "$INSTALLER" --target "$dest" --content-path "$content" 2>&1)"; then
    fail "t43: sharing fixture install failed"
    return
  fi
  inventory="$(printf '%s\n' "$output" | sed -n 's/^\[aet-install\] share: //p')"
  expected="$(printf '.github/%s\n' "${MANIFEST_ENTRIES[@]}" '.aet-managed-state')"
  if [[ "$(printf '%s\n' "$inventory" | LC_ALL=C sort)" \
      != "$(printf '%s\n' "$expected" | LC_ALL=C sort)" ]]; then
    fail "t43: sharing inventory must contain exactly managed files plus state"
    return
  fi
  while IFS= read -r relative; do
    if ! mkdir -p "$(dirname "$team/$relative")" \
        || ! cp "$dest/$relative" "$team/$relative"; then
      fail "t43: sharing inventory could not be consumed"
      return
    fi
  done <<< "$inventory"
  if ! cmp -s "$AET_ROOT/LICENSE" "$team/.github/LICENSE" \
      || ! cmp -s "$dest/.github/.aet-managed-state" "$team/.github/.aet-managed-state"; then
    fail "t43: shared notice or provenance changed"
    return
  fi
  printf 'modified notice fixture\n' >> "$team/.github/LICENSE"
  if ! bash "$INSTALLER" --target "$team" --force >/dev/null 2>&1 \
      || ! cmp -s "$AET_ROOT/LICENSE" "$team/.github/LICENSE"; then
    fail "t43: shared LICENSE was not recognized as managed"
    return
  fi
  ok "t43: sharing inventory carries governance, notice and provenance, excluding private/content files"
}

t44_bundle_permissions_and_umask() {
  local work="$TMP/t44" source_root="$TMP/t44/source" bin_dir="$TMP/t44/bin"
  local tar_program entry mask tarball modes
  mkdir -p "$source_root/scripts" "$bin_dir" "$work/022" "$work/077"
  cp "$SCRIPT_DIR/build-release.sh" "$source_root/scripts/build-release.sh"
  cp "$MANIFEST" "$source_root/scripts/aet-manifest.txt"
  for entry in "${MANIFEST_ENTRIES[@]}"; do
    mkdir -p "$(dirname "$source_root/$entry")"
    cp "$AET_ROOT/$entry" "$source_root/$entry"
  done
  chmod 0700 "$source_root/LICENSE" "$source_root/scripts/aet-manifest.txt"
  tar_program="$(command -v tar)"
  if ! "$tar_program" --version 2>/dev/null | grep -q 'GNU tar' \
      && command -v gtar >/dev/null 2>&1; then
    tar_program="$(command -v gtar)"
  fi
  ln -s "$tar_program" "$bin_dir/tar"
  for mask in 022 077; do
    if ! (umask "$mask"; cd "$work/$mask" && PATH="$bin_dir:$PATH" \
        bash "$source_root/scripts/build-release.sh" v0.0.1 >/dev/null 2>&1); then
      fail "t44: build failed under umask $mask"
      return
    fi
    tarball="$work/$mask/aet-bundle-v0.0.1.tar.gz"
    if ! check_bundle_inventory "$tarball" aet-bundle-v0.0.1; then
      fail "t44: inventory changed under umask $mask"
      return
    fi
    modes="$(tar -tvzf "$tarball" | cut -c1-10 | LC_ALL=C sort -u)"
    if [[ "$modes" != $'-rw-r--r--\ndrwxr-xr-x' ]]; then
      fail "t44: staging modes depend on source permissions or umask $mask"
      return
    fi
  done
  if "$tar_program" --version 2>/dev/null | grep -q 'GNU tar'; then
    if ! cmp -s "$work/022/aet-bundle-v0.0.1.tar.gz" "$work/077/aet-bundle-v0.0.1.tar.gz" \
        || ! cmp -s "$work/022/aet-bundle-v0.0.1.sha256" "$work/077/aet-bundle-v0.0.1.sha256"; then
      fail "t44: GNU tar output differs across umasks 022 and 077"
      return
    fi
  else
    printf '[SKIP] t44: GNU tar unavailable; byte reproducibility comparison unrun\n'
  fi
  ok "t44: bundle inventory and staging modes stable across umasks 022 and 077"
}

t45_standalone_dry_run_destination_unchanged() {
  local work="$TMP/t45" standalone="$TMP/t45/standalone" assets="$TMP/t45/assets"
  local dest case_name output result before after before_paths after_paths downloaded
  if ! command -v python3 >/dev/null 2>&1 && ! command -v jq >/dev/null 2>&1; then
    fail "t45: standalone test requires python3 or jq for release metadata"
    return
  fi
  mkdir -p "$standalone/scripts" "$assets" "$work/downloads"
  cp "$INSTALLER" "$standalone/scripts/aet-install.sh"
  if ! (cd "$assets" && bash "$SCRIPT_DIR/build-release.sh" v0.0.1 >/dev/null 2>&1); then
    fail "t45: standalone bundle fixture build failed"
    return
  fi
  printf 'signature fixture\n' > "$assets/aet-bundle-v0.0.1.tar.gz.cosign.bundle"
  printf 'signature fixture\n' > "$assets/aet-bundle-v0.0.1.sha256.cosign.bundle"
  cat > "$work/remote-stubs.sh" <<'STUB'
mktemp() {
  [[ "$#" -eq 1 && "$1" == -d ]] || return 1
  command mktemp -d "$MOCK_TMP_ROOT/aet.XXXXXX"
}
curl() {
  local output_file="" url=""
  while [[ "$#" -gt 0 ]]; do
    case "$1" in
      -o) output_file="$2"; shift 2 ;;
      --max-time) shift 2 ;;
      -fsSL) shift ;;
      https://*) url="$1"; shift ;;
      *) return 1 ;;
    esac
  done
  if [[ "$url" == "$GH_RELEASES_API" && -z "$output_file" ]]; then
    printf '[{"tag_name":"v0.0.1","draft":false,"prerelease":false}]\n'
    return
  fi
  [[ "$url" == "$REPO_URL/releases/download/v0.0.1/"* \
      && "$output_file" == "$MOCK_TMP_ROOT/"* ]] || return 1
  printf '%s\n' "$output_file" >> "$MOCK_DOWNLOADS"
  cp "$MOCK_ASSETS/${url##*/}" "$output_file"
}
cosign() {
  [[ "$1" == verify-blob ]] || return 1
  printf 'verify\n' >> "$MOCK_VERIFICATIONS"
  [[ "$MOCK_CASE" != signature-failure ]]
}
STUB
  for case_name in empty existing signature-failure; do
    dest="$work/$case_name"
    mkdir -p "$dest"
    if [[ "$case_name" == existing ]]; then
      if ! bash "$INSTALLER" --target "$dest" >/dev/null 2>&1; then
        fail "t45: existing destination setup failed"
        return
      fi
      printf 'modified notice fixture\n' >> "$dest/.github/LICENSE"
    fi
    : > "$work/download-log"
    : > "$work/verify-log"
    before="$(find "$dest" -type f -exec cksum {} \; | LC_ALL=C sort)"
    before_paths="$(find "$dest" -print | LC_ALL=C sort)"
    result=0
    output="$(MOCK_CASE="$case_name" MOCK_ASSETS="$assets" \
      MOCK_TMP_ROOT="$work/downloads" MOCK_DOWNLOADS="$work/download-log" \
      MOCK_VERIFICATIONS="$work/verify-log" BASH_ENV="$work/remote-stubs.sh" \
      bash "$standalone/scripts/aet-install.sh" --target "$dest" --dry-run --force 2>&1)" \
      || result=$?
    if [[ "$case_name" == signature-failure ]]; then
      if [[ "$result" -eq 0 || "$(wc -l < "$work/verify-log" | tr -d ' ')" -ne 1 ]]; then
        fail "t45: signature failure did not stop standalone dry-run"
        return
      fi
    elif [[ "$result" -ne 0 || "$(wc -l < "$work/verify-log" | tr -d ' ')" -ne 2 ]]; then
      fail "t45: standalone dry-run failed for $case_name: $output"
      return
    fi
    after="$(find "$dest" -type f -exec cksum {} \; | LC_ALL=C sort)"
    after_paths="$(find "$dest" -print | LC_ALL=C sort)"
    if [[ "$before" != "$after" || "$before_paths" != "$after_paths" \
        || "$(wc -l < "$work/download-log" | tr -d ' ')" -ne 4 \
        || -n "$(find "$work/downloads" -mindepth 1 -print -quit)" ]]; then
      fail "t45: destination changed, downloads missing, or temporary assets leaked ($case_name)"
      return
    fi
    while IFS= read -r downloaded; do
      if [[ "$downloaded" != "$work/downloads/"* ]]; then
        fail "t45: standalone download escaped owned temporary storage"
        return
      fi
    done < "$work/download-log"
  done
  ok "t45: standalone dry-run leaves destinations unchanged and cleans temporary downloads (3 cases)"
}

# ---------------------------------------------------------------------------
# t46: skill content copying retains direct-Markdown and legacy-input contracts
# ---------------------------------------------------------------------------
t46_skill_content_contract() {
  local dest="$TMP/t46-dest" content="$TMP/t46-content" output entry before after
  mkdir -p "$dest" "$content/skills/example/resources" "$content/prompts"
  printf '%s\n' '---' 'name: example' 'description: "Example content skill."' \
    '---' '# Example' > "$content/skills/example/SKILL.md"
  printf 'Supporting Markdown\n' > "$content/skills/example/reference.md"
  printf 'Nested resource\n' > "$content/skills/example/resources/nested.md"
  printf 'Non-Markdown resource\n' > "$content/skills/example/helper.sh"
  # Deliberate legacy content input, still supported but not a bundled workflow.
  printf 'Legacy content\n' > "$content/prompts/example.prompt.md"
  if ! bash "$INSTALLER" --target "$dest" --content-path "$content" >/dev/null 2>&1; then
    fail "t46: skill content install failed"
    return
  fi
  for entry in skills/example/SKILL.md skills/example/reference.md prompts/example.prompt.md; do
    if ! cmp -s "$content/$entry" "$dest/.github/$entry"; then
      fail "t46: supported content file was not preserved: $entry"
      return
    fi
  done
  if [[ -e "$dest/.github/skills/example/resources" \
      || -e "$dest/.github/skills/example/helper.sh" ]] \
      || grep -qF 'skills/example/' "$dest/.github/.aet-managed-state"; then
    fail "t46: content copy scope or managed ownership changed"
    return
  fi
  if ! bash "$INSTALLER" --target "$dest" --content-path "$content" >/dev/null 2>&1; then
    fail "t46: identical skill content reinstall failed"
    return
  fi
  before="$(find "$dest" -type f -exec cksum {} \; | LC_ALL=C sort)"
  mkdir -p "$content/skills/code-review"
  printf 'Content override\n' > "$content/skills/code-review/SKILL.md"
  if output="$(bash "$INSTALLER" --target "$dest" --content-path "$content" --force 2>&1)"; then
    fail "t46: content overwrote bundled skill with --force"
    return
  fi
  after="$(find "$dest" -type f -exec cksum {} \; | LC_ALL=C sort)"
  if [[ "$before" != "$after" || "$output" != *"content pack cannot replace engine file"* ]]; then
    fail "t46: skill collision did not reject before writes"
    return
  fi
  rm "$content/skills/code-review/SKILL.md"
  printf 'Changed content\n' >> "$content/skills/example/SKILL.md"
  if bash "$INSTALLER" --target "$dest" --content-path "$content" --force >/dev/null 2>&1; then
    fail "t46: changed skill content overwrote destination"
    return
  fi
  after="$(find "$dest" -type f -exec cksum {} \; | LC_ALL=C sort)"
  if [[ "$before" != "$after" ]]; then
    fail "t46: changed content rejection wrote files"
    return
  fi
  ok "t46: direct skill Markdown and legacy content copy; collisions preserve destination"
}

# ---------------------------------------------------------------------------
# t47: legacy managed prompts reject non-destructively; documented recovery works
# ---------------------------------------------------------------------------
t47_legacy_prompt_migration() {
  local mode option home target dest legacy state before after paths output backup
  local args=()
  # Deliberate retired bundled path fixture for the manual migration contract.
  legacy="prompts/assess-project.prompt.md"
  for mode in repo global; do
    home="$TMP/t47-$mode-home"
    target="$TMP/t47-$mode-target"
    mkdir -p "$home" "$target"
    if [[ "$mode" == global ]]; then
      args=(--global)
      dest="$home/.aet"
    else
      args=(--target "$target")
      dest="$target/.github"
    fi
    mkdir -p "$dest/prompts" "$dest/agents"
    cp "$AET_ROOT/agents/aet-orchestrator.agent.md" "$dest/agents/"
    printf 'User-edited legacy assessment\n' > "$dest/$legacy"
    state="$dest/.aet-managed-state"
    {
      printf '# aet-managed-state v1\n'
      printf 'agents/aet-orchestrator.agent.md\t%064d\n' 0
      printf '%s\t%064d\n' "$legacy" 0
    } > "$state"
    before="$(find "$dest" -type f -exec cksum {} \; | LC_ALL=C sort)"
    paths="$(find "$dest" -print | LC_ALL=C sort)"
    for option in --dry-run --force ""; do
      if output="$(HOME="$home" bash "$INSTALLER" "${args[@]}" ${option:+"$option"} 2>&1)"; then
        fail "t47: legacy state unexpectedly upgraded ($mode $option)"
        return
      fi
      after="$(find "$dest" -type f -exec cksum {} \; | LC_ALL=C sort)"
      if [[ "$before" != "$after" || "$paths" != "$(find "$dest" -print | LC_ALL=C sort)" \
          || "$output" != *"#legacy-prompt-migration"* ]]; then
        fail "t47: legacy upgrade mutated destination or omitted recovery ($mode $option)"
        return
      fi
    done
    # Follow the documented manual backup/move/state-row removal, never automatic.
    backup="$TMP/t47-$mode-backup"
    mkdir -p "$backup"
    cp -R "$dest/." "$backup/"
    mv "$dest/$legacy" "$backup/retired-assessment.md"
    grep -vF "$legacy" "$state" > "$TMP/t47-$mode-state"
    cp "$TMP/t47-$mode-state" "$state"
    if ! HOME="$home" bash "$INSTALLER" "${args[@]}" --dry-run >/dev/null 2>&1 \
        || ! HOME="$home" bash "$INSTALLER" "${args[@]}" >/dev/null 2>&1 \
        || ! cmp -s "$AET_ROOT/skills/assess-project/SKILL.md" \
          "$dest/skills/assess-project/SKILL.md" \
        || ! cmp -s "$backup/$legacy" "$backup/retired-assessment.md" \
        || [[ -e "$dest/$legacy" ]]; then
      fail "t47: manual migration failed or lost legacy edits ($mode)"
      return
    fi
  done
  ok "t47: legacy state rejects unchanged in 6 cases; manual migration preserves edits in both modes"
}

# ---------------------------------------------------------------------------
# t48: --self installs the Steward profile into a source clone's .github/
# ---------------------------------------------------------------------------
t48_self_install() {
  local src="$TMP/t48-src" lone="$TMP/t48-lone" out self_paths entry dir args
  local reference_error unexpected=0
  mkdir -p "$src" "$lone/scripts"
  for dir in LICENSE agents docs instructions scripts skills validation; do
    cp -R "$AET_ROOT/$dir" "$src/"
  done
  rm -rf "$src/.github"

  for args in "--target $TMP/t48-x" "--global" "--content-path $TMP"; do
    # shellcheck disable=SC2086
    if out="$(HOME="$TMP/t48-home" bash "$src/scripts/aet-install.sh" \
        --self --dry-run $args 2>&1)" \
        || [[ "$out" != *"--self cannot be combined"* ]]; then
      fail "t48: --self accepted with $args"
      return
    fi
  done
  cp "$INSTALLER" "$lone/scripts/"
  if out="$(bash "$lone/scripts/aet-install.sh" --self --dry-run 2>&1)" \
      || [[ "$out" != *"--self requires"* || "$out" == *standalone* ]]; then
    fail "t48: --self without local source did not fail closed"
    return
  fi
  if ! bash "$src/scripts/aet-install.sh" --self --dry-run >/dev/null 2>&1 \
      || [[ -e "$src/.github" ]]; then
    fail "t48: --self dry-run failed or wrote destination"
    return
  fi
  cp "$src/scripts/aet-self-manifest.txt" "$TMP/t48-manifest"
  printf '.github/agents/x.md\n' >> "$src/scripts/aet-self-manifest.txt"
  if out="$(bash "$src/scripts/aet-install.sh" --self 2>&1)" \
      || [[ "$out" != *"self-install destination path"* || -e "$src/.github" ]]; then
    fail "t48: self manifest .github/ entry was not rejected without writes"
    return
  fi
  cp "$TMP/t48-manifest" "$src/scripts/aet-self-manifest.txt"
  if ! out="$(bash "$src/scripts/aet-install.sh" --self 2>&1)"; then
    fail "t48: --self install exited non-zero"
    return
  fi
  while IFS= read -r entry; do
    [[ -z "$entry" || "${entry:0:1}" == "#" ]] && continue
    cmp -s "$src/$entry" "$src/.github/$entry" \
      || { fail "t48: self entry not installed: $entry"; return; }
  done < "$src/scripts/aet-self-manifest.txt"
  if [[ -e "$src/.github/agents/aet-orchestrator.agent.md" \
      || -e "$src/.github/agents/aet-investigator.agent.md" \
      || ! -f "$src/.github/.aet-managed-state" \
      || "$out" != *'"AET Steward"'* || "$out" == *"share:"* \
      || "$out" == *"Audience template"* ]]; then
    fail "t48: self profile contents or guidance wrong"
    return
  fi
  if ! out="$(bash "$src/scripts/aet-install.sh" --self 2>&1)" \
      || [[ "$out" != *"0 file(s) installed"* ]]; then
    fail "t48: identical --self reinstall was not a no-op"
    return
  fi
  printf '\nSource edit.\n' >> "$src/docs/philosophy.md"
  if bash "$src/scripts/aet-install.sh" --self >/dev/null 2>&1 \
      || ! bash "$src/scripts/aet-install.sh" --self --force >/dev/null 2>&1 \
      || ! cmp -s "$src/docs/philosophy.md" "$src/.github/docs/philosophy.md"; then
    fail "t48: changed source did not require --force refresh"
    return
  fi

  # Links resolve within the self profile; only omitted Orchestrator is allowed.
  self_paths="$(grep -v '^#' "$AET_ROOT/scripts/aet-self-manifest.txt" | sed '/^$/d')"
  check_bundle_reference_closure "$AET_ROOT" "$self_paths"
  if [[ -n "${BUNDLE_REFERENCE_ERRORS[*]-}" ]]; then
    for reference_error in "${BUNDLE_REFERENCE_ERRORS[@]}"; do
      if [[ "$reference_error" != skills/review-proposal/SKILL.md*"'agents/aet-orchestrator.agent.md' not in"* \
          && "$reference_error" != skills/generate-architecture-doc/SKILL.md*"'agents/aet-orchestrator.agent.md' not in"* ]]; then
        fail "t48: $reference_error"
        unexpected=$((unexpected + 1))
      fi
    done
  fi
  [[ "$unexpected" -eq 0 ]] || return
  ok "t48: --self installs Steward profile locally, excludes Orchestrator, refreshes with --force"
}

# ---------------------------------------------------------------------------
# Run all tests
# ---------------------------------------------------------------------------
t1_manifest_exists
t2_manifest_complete
t3_dry_run_no_writes
t4_install_writes_files
t5_identical_skip
t6_collision_aborts_without_force
t7_force_overwrites_engine_file
t8_content_over_engine_aborts
t9_content_collision_aborts
t10_bundle_inventory
t11_bundle_checksum
t12_unmanaged_rejects_force
t13_managed_changed_permits_force
t14_symlink_dest_rejects
t15_symlinked_parent_rejects
t16_malformed_state_rejects
t17_no_writes_on_symlink_preflight_failure
t18_bundle_reference_closure
t19_dangling_file_symlink_rejects
t20_symlinked_module_directory_rejects
t21_dangling_state_symlink_rejects
t23_global_dry_run_no_writes
t24_global_install_and_guidance
t25_global_identical_reinstall
t26_global_managed_change_requires_force
t27_global_with_target_rejects
t28_symlinked_global_destination_rejects
t30_raw_path_component_symlinks_reject
t31_malformed_manifest_paths_reject
t32_state_temp_symlink_cannot_overwrite
t33_state_directory_rejects_without_writes
t34_state_raw_nul_rejects_without_writes
t35_engine_directory_rejects_without_writes
t36_engine_fifo_rejects_without_writes
t37_global_home_rejects
t38_release_manifest_validation_rejects_without_writes
t39_installer_source_symlinks_reject
t40_release_source_symlinks_reject
t41_test_manifest_startup_validation
t42_test_scratch_startup_validation
t43_team_sharing_inventory
t44_bundle_permissions_and_umask
t45_standalone_dry_run_destination_unchanged
t46_skill_content_contract
t47_legacy_prompt_migration
t48_self_install

printf '\nResults: %d passed, %d failed\n' "$PASS" "$FAIL"
[[ "$FAIL" -eq 0 ]] || exit 1
