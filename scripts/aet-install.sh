#!/usr/bin/env bash
#
# aet-install.sh — install the AET Orchestrator bundle.
#
# Modes:
#   Local-clone  Run from inside a cloned AET repository; installs from the
#                local tree after manifest validation.
#   Standalone   No local AET source found; downloads the latest stable GitHub
#                release (no drafts, no pre-releases), verifies the SHA-256
#                checksum and Sigstore keyless signature, then installs.
#   Self         --self; installs the source-only Steward profile from
#                scripts/aet-self-manifest.txt into this AET clone's .github/.
#
# Usage:
#   bash scripts/aet-install.sh [OPTIONS]
#
# Collision policy (full preflight before destination writes):
#   Engine file — destination absent            write
#   Engine file — destination identical         skip (adopted into managed state)
#   Engine file — managed, destination differs  abort unless --force
#   Engine file — managed, --force              overwrite
#   Engine file — unmanaged collision           always abort (even with --force)
#   Content over engine path                    always abort (even with --force)
#   Content/content — destination differs       always abort
#   Content/content — destination identical     skip
#
# Standalone mode prerequisites:
#   curl       HTTP downloads
#   sha256sum  (Linux) or shasum (macOS) — checksum verification
#   cosign     https://docs.sigstore.dev/cosign/system_config/installation
#   python3    or jq — release metadata parsing

set -euo pipefail

# ---------------------------------------------------------------------------
# Repository identity
# ---------------------------------------------------------------------------
REPO_OWNER="mabrosim"
REPO_NAME="ai-engineering-toolkit"
REPO_URL="https://github.com/${REPO_OWNER}/${REPO_NAME}"
GH_RELEASES_API="https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/releases"

# Sigstore keyless OIDC issuer — pinned; identity is constructed per-version
# inside resolve_source_remote() to match exactly the release workflow at the
# specific tag being installed.
COSIGN_OIDC_ISSUER="https://token.actions.githubusercontent.com"

# Path to the engine manifest, relative to the AET source root.
MANIFEST_REL="scripts/aet-manifest.txt"
# Source-only Steward profile used by --self.
SELF_MANIFEST_REL="scripts/aet-self-manifest.txt"

# ---------------------------------------------------------------------------
# Defaults
# ---------------------------------------------------------------------------
TARGET="$(pwd)"
TARGET_SET="false"
GLOBAL="false"
SELF="false"
FORCE="false"
DRY_RUN="false"
CONTENT_PATH=""

# Set in main() before preflight; referenced by preflight and check_collision.
DEST=""

# State file name, relative to DEST.
STATE_FILE_NAME=".aet-managed-state"

# Managed-state data: newline-separated "path<TAB>sha256" lines (no header).
MANAGED_STATE_DATA=""
MANAGED_STATE_COUNT=0

# Set by resolve_source.
SOURCE=""
CLEANUP_DIR=""

# Manifest entries loaded by load_manifest.
MANIFEST_ENTRIES=()

# Write queue populated by preflight; executed only after full preflight passes.
WRITE_SRCS=()
WRITE_DSTS=()

# Preflight error counter; incremented without aborting to collect all errors.
PREFLIGHT_ERRORS=0

# ---------------------------------------------------------------------------
# Logging
# ---------------------------------------------------------------------------
log() { printf '[aet-install] %s\n' "$*"; }
err() { printf '[aet-install] error: %s\n' "$*" >&2; }

# ---------------------------------------------------------------------------
# Usage
# ---------------------------------------------------------------------------
usage() {
  cat <<'EOF'
aet-install.sh — install the AET Orchestrator bundle.

Modes:
  Local-clone  Run from inside a cloned AET repository; installs from the
               local tree after manifest validation.
  Standalone   No local AET source found; downloads the latest stable GitHub
               release, verifies SHA-256 and Sigstore signature, then installs.
               Requires: curl, sha256sum or shasum, cosign, python3 or jq.

Install location:
  Repo install (default)    <repo>/.github/   auto-discovered by VS Code
  Global install (--global) ~/.aet/           personal VS Code extension-host use

Global mode retains ~/.aet/ for personal VS Code extension-host use. Prefer repo
installs for native project skill discovery and team sharing. ~/.aet/skills/ is
not a native Copilot user-skill location; required AET workflows read it directly.
Agent Host and CLI do not use the printed VS Code editor settings.

Do not enable global AET locations in a workspace with a repo-local AET install;
duplicate customization names have undocumented host precedence.

Self install (--self) is for maintaining the AET source clone itself. It
installs the source-only Steward profile from scripts/aet-self-manifest.txt into
<source root>/.github/ from the local tree only; AET Orchestrator is excluded.

Options:
  --global              Install into ~/.aet/ for personal VS Code use
  --target DIR          Repo root for repo install (default: current directory)
  --self                Install the Steward profile into this AET source clone;
                        excludes --global, --target, and --content-path
  --force               Overwrite changed engine files listed in the AET
                        manifest; still aborts on unmanaged collisions
  --dry-run             Print planned actions without destination writes
                        Standalone mode still downloads and verifies assets
                        in owned temporary storage, removed on exit
  --content-path DIR    Merge extra instructions, skills, catalogs, and legacy prompts
                        from DIR on top of the bundled engine files
  -h, --help            Show this help
EOF
  exit "${1:-0}"
}

# ---------------------------------------------------------------------------
# Argument parsing
# ---------------------------------------------------------------------------
while [[ $# -gt 0 ]]; do
  case "$1" in
    --global)        GLOBAL="true"; shift ;;
    --target)        TARGET="${2:?--target needs a path}"; TARGET_SET="true"; shift 2 ;;
    --self)          SELF="true"; shift ;;
    --force)         FORCE="true"; shift ;;
    --dry-run)       DRY_RUN="true"; shift ;;
    --content-path)  CONTENT_PATH="${2:?--content-path needs a path}"; shift 2 ;;
    -h|--help)       usage 0 ;;
    *) err "unknown argument: $1"; usage 1 ;;
  esac
done

if [[ "$GLOBAL" == "true" && "$TARGET_SET" == "true" ]]; then
  err "--global and --target are mutually exclusive"
  exit 1
fi

if [[ "$SELF" == "true" ]]; then
  if [[ "$GLOBAL" == "true" || "$TARGET_SET" == "true" || -n "$CONTENT_PATH" ]]; then
    err "--self cannot be combined with --global, --target, or --content-path"
    exit 1
  fi
  MANIFEST_REL="$SELF_MANIFEST_REL"
fi

if [[ -n "$CONTENT_PATH" ]]; then
  [[ -d "$CONTENT_PATH" ]] || { err "--content-path is not a directory: $CONTENT_PATH"; exit 1; }
  CONTENT_PATH="$(cd "$CONTENT_PATH" && pwd)"
  log "content path: $CONTENT_PATH"
fi

# ---------------------------------------------------------------------------
# Destination root
# ---------------------------------------------------------------------------
dest_root() {
  if [[ "$GLOBAL" == "true" ]]; then
    echo "$HOME/.aet"
  else
    echo "$TARGET/.github"
  fi
}

# ---------------------------------------------------------------------------
# SHA-256 helper (portable: Linux sha256sum or macOS shasum)
# ---------------------------------------------------------------------------
sha256_of_file() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$1" | awk '{print $1}'
  elif command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$1" | awk '{print $1}'
  else
    err "sha256sum or shasum is required"; exit 1
  fi
}

# ---------------------------------------------------------------------------
# Manifest loading and lookup
# ---------------------------------------------------------------------------
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

  [[ -z "$reason" ]] \
    || { err "invalid manifest entry at line $lineno ($reason)"; exit 1; }
}

load_manifest() {
  local mf="$SOURCE/$MANIFEST_REL"
  [[ -f "$mf" ]] || { err "manifest not found: $mf"; exit 1; }
  local manifest_hex
  manifest_hex="$(LC_ALL=C od -An -v -tx1 "$mf" 2>/dev/null)" || {
    err "manifest validation failed"; exit 1
  }
  if printf '%s\n' "$manifest_hex" \
      | grep -Eq '(^|[[:space:]])00([[:space:]]|$)'; then
    err "manifest validation failed"; exit 1
  fi
  local lineno=0 existing
  while IFS= read -r line || [[ -n "$line" ]]; do
    lineno=$((lineno + 1))
    [[ -z "$line" || "${line:0:1}" == "#" ]] && continue
    validate_manifest_entry "$line" "$lineno"
    if [[ "$SELF" == "true" && ( "$line" == .github || "$line" == .github/* ) ]]; then
      err "invalid manifest entry at line $lineno (self-install destination path)"
      exit 1
    fi
    if [[ -n "${MANIFEST_ENTRIES[*]-}" ]]; then
      for existing in "${MANIFEST_ENTRIES[@]}"; do
        [[ "$existing" != "$line" ]] \
          || { err "invalid manifest entry at line $lineno (duplicate entry)"; exit 1; }
      done
    fi
    MANIFEST_ENTRIES+=("$line")
  done < "$mf"
  [[ ${#MANIFEST_ENTRIES[@]} -gt 0 ]] || { err "manifest is empty: $mf"; exit 1; }
  log "manifest: ${#MANIFEST_ENTRIES[@]} engine files"
}

# Returns 0 if the relative path is listed in the manifest.
in_manifest() {
  local rel="$1" entry
  for entry in "${MANIFEST_ENTRIES[@]}"; do
    [[ "$entry" == "$rel" ]] && return 0
  done
  return 1
}

# Returns 0 if the relative path is present in the loaded managed state.
is_managed() {
  [[ -z "$MANAGED_STATE_DATA" ]] && return 1
  printf '%s' "$MANAGED_STATE_DATA" \
    | awk -F'\t' -v p="$1" '$1==p{found=1} END{exit !found}'
}

# Confirms every manifest entry exists under SOURCE.
validate_source() {
  local source_root entry source_path resolved_parent
  source_root="$(cd "$SOURCE" && pwd -P)" \
    || { err "source root cannot resolve: $SOURCE"; exit 1; }
  for entry in "${MANIFEST_ENTRIES[@]}"; do
    source_path="$SOURCE/$entry"
    [[ ! -L "$source_path" ]] \
      || { err "manifest entry is a symlink: $source_path"; exit 1; }
    [[ -f "$source_path" ]] \
      || { err "manifest entry missing from source: $source_path"; exit 1; }
    resolved_parent="$(cd "$(dirname "$source_path")" 2>/dev/null && pwd -P)" \
      || { err "manifest entry parent cannot resolve: $source_path"; exit 1; }
    if [[ "$resolved_parent" != "$source_root" \
        && "$resolved_parent" != "$source_root/"* ]]; then
      err "manifest entry resolves outside source root: $source_path"
      exit 1
    fi
  done
}

# ---------------------------------------------------------------------------
# Source resolution
# ---------------------------------------------------------------------------
resolve_source_local() {
  local self_dir=""
  if [[ -n "${BASH_SOURCE[0]:-}" && -f "${BASH_SOURCE[0]}" ]]; then
    self_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." 2>/dev/null && pwd || true)"
  fi
  if [[ -n "$self_dir" \
        && -f "$self_dir/$MANIFEST_REL" \
        && -d "$self_dir/agents" \
        && -f "$self_dir/agents/aet-orchestrator.agent.md" ]]; then
    SOURCE="$self_dir"
    log "local source: $SOURCE"
    return 0
  fi
  return 1
}

resolve_source_remote() {
  # Prerequisites check — fail closed if any tool is missing.
  local missing=()
  command -v curl   >/dev/null 2>&1 || missing+=("curl")
  command -v cosign >/dev/null 2>&1 || missing+=("cosign")
  if [[ ${#missing[@]} -gt 0 ]]; then
    err "standalone mode requires: ${missing[*]}"
    err "install missing tools or run from inside a cloned AET repository."
    exit 1
  fi

  # Fetch release list; find first entry where draft=false and prerelease=false.
  log "fetching release list from GitHub..."
  local releases_json
  releases_json="$(curl -fsSL --max-time 30 "$GH_RELEASES_API")" \
    || { err "failed to reach GitHub releases API: $GH_RELEASES_API"; exit 1; }

  local version=""
  if command -v python3 >/dev/null 2>&1; then
    version="$(printf '%s\n' "$releases_json" | python3 -c '
import sys, json
try:
    data = json.load(sys.stdin)
except Exception as e:
    sys.stderr.write("JSON parse error: " + str(e) + "\n")
    sys.exit(1)
if not isinstance(data, list):
    sys.stderr.write("API error: " + str(data.get("message", "unexpected response")) + "\n")
    sys.exit(1)
for r in data:
    if not r.get("draft") and not r.get("prerelease"):
        print(r["tag_name"])
        sys.exit(0)
sys.exit(1)
' 2>/dev/null)" || true
  fi

  if [[ -z "$version" ]] && command -v jq >/dev/null 2>&1; then
    version="$(printf '%s\n' "$releases_json" \
      | jq -r 'map(select(.draft==false and .prerelease==false)) | first | .tag_name // ""' \
      2>/dev/null)" || true
  fi

  [[ -n "$version" && "$version" != "null" ]] \
    || { err "no stable GitHub release found; publish a tagged release or run from a clone"; exit 1; }
  log "latest stable release: $version"

  # Release artifact naming contract (four assets per release):
  #   aet-bundle-<version>.tar.gz                  engine bundle
  #   aet-bundle-<version>.sha256                  SHA-256 of the tarball (sha256sum format)
  #   aet-bundle-<version>.tar.gz.cosign.bundle    Sigstore bundle for the tarball
  #   aet-bundle-<version>.sha256.cosign.bundle    Sigstore bundle for the checksum file
  local asset_base="aet-bundle-${version}"
  local download_base="${REPO_URL}/releases/download/${version}"

  # Certificate SAN pinned to the exact release workflow at the specific tag.
  local cosign_cert_identity
  cosign_cert_identity="https://github.com/${REPO_OWNER}/${REPO_NAME}/.github/workflows/release.yml@refs/tags/${version}"

  CLEANUP_DIR="$(mktemp -d)"
  local bundle_file="$CLEANUP_DIR/${asset_base}.tar.gz"
  local sha256_file="$CLEANUP_DIR/${asset_base}.sha256"
  local cosign_bundle_tar="$CLEANUP_DIR/${asset_base}.tar.gz.cosign.bundle"
  local cosign_bundle_sha="$CLEANUP_DIR/${asset_base}.sha256.cosign.bundle"

  log "downloading ${asset_base} assets (4)..."
  curl -fsSL --max-time 120 -o "$bundle_file" \
    "${download_base}/${asset_base}.tar.gz" \
    || { err "download failed: ${asset_base}.tar.gz"; exit 1; }
  curl -fsSL --max-time 30 -o "$sha256_file" \
    "${download_base}/${asset_base}.sha256" \
    || { err "download failed: ${asset_base}.sha256"; exit 1; }
  curl -fsSL --max-time 30 -o "$cosign_bundle_tar" \
    "${download_base}/${asset_base}.tar.gz.cosign.bundle" \
    || { err "download failed: ${asset_base}.tar.gz.cosign.bundle"; exit 1; }
  curl -fsSL --max-time 30 -o "$cosign_bundle_sha" \
    "${download_base}/${asset_base}.sha256.cosign.bundle" \
    || { err "download failed: ${asset_base}.sha256.cosign.bundle"; exit 1; }

  # Step 1: verify checksum file signature before trusting its content.
  log "verifying checksum file signature (cosign)..."
  cosign verify-blob \
    --certificate-identity "$cosign_cert_identity" \
    --certificate-oidc-issuer "$COSIGN_OIDC_ISSUER" \
    --bundle "$cosign_bundle_sha" \
    "$sha256_file" \
    || { err "checksum file Sigstore verification failed — refusing to trust hash"; exit 1; }
  log "checksum file signature verified"

  # Step 2: verify tarball signature.
  log "verifying tarball signature (cosign)..."
  cosign verify-blob \
    --certificate-identity "$cosign_cert_identity" \
    --certificate-oidc-issuer "$COSIGN_OIDC_ISSUER" \
    --bundle "$cosign_bundle_tar" \
    "$bundle_file" \
    || { err "tarball Sigstore verification failed — refusing to install unverified bundle"; exit 1; }
  log "tarball signature verified"

  # Step 3: verify SHA-256 against the now-trusted checksum file.
  log "verifying SHA-256..."
  local computed expected
  computed="$(sha256_of_file "$bundle_file")"
  expected="$(awk '{print $1}' "$sha256_file")"
  [[ -n "$expected" ]] || { err "SHA-256 file is empty"; exit 1; }
  [[ "$computed" == "$expected" ]] \
    || { err "SHA-256 mismatch — bundle may be corrupt or tampered with"; exit 1; }
  log "SHA-256 verified"

  # Step 4: validate archive member paths before extraction.
  # Reject absolute paths, .. traversal, and unexpected top-level prefixes.
  log "validating archive member paths..."
  local bad_members=0 member
  while IFS= read -r member; do
    [[ -z "$member" ]] && continue
    if [[ "${member:0:1}" == "/" ]]; then
      err "archive contains absolute path: $member"
      bad_members=$((bad_members + 1))
    elif [[ "$member" == *..* ]]; then
      err "archive contains path traversal: $member"
      bad_members=$((bad_members + 1))
    elif [[ "$member" != "${asset_base}" && "$member" != "${asset_base}/"* ]]; then
      err "unexpected top-level entry in archive: $member"
      bad_members=$((bad_members + 1))
    fi
  done < <(tar -tzf "$bundle_file" 2>/dev/null)
  [[ $bad_members -eq 0 ]] \
    || { err "archive member validation failed — refusing to extract"; exit 1; }
  log "archive member paths validated"

  # Step 5: extract bundle.
  log "extracting ${asset_base}.tar.gz..."
  tar -xzf "$bundle_file" -C "$CLEANUP_DIR" \
    || { err "bundle extraction failed"; exit 1; }
  SOURCE="$CLEANUP_DIR/${asset_base}"
  [[ -d "$SOURCE" && -f "$SOURCE/$MANIFEST_REL" ]] \
    || { err "manifest not found after extraction; expected $SOURCE/$MANIFEST_REL"; exit 1; }
}

cleanup() { [[ -n "$CLEANUP_DIR" ]] && rm -rf "$CLEANUP_DIR"; return 0; }
trap cleanup EXIT

# ---------------------------------------------------------------------------
# Managed-state helpers
# ---------------------------------------------------------------------------

validate_managed_state_path() {
  local state_file="$DEST/$STATE_FILE_NAME"
  if [[ -L "$state_file" ]]; then
    err "state file is a symlink: $state_file — aborting"; return 1
  fi
  if [[ -e "$state_file" && ! -f "$state_file" ]]; then
    err "state path is not a regular file: $state_file — aborting"; return 1
  fi
}

# Load and validate the state file.  Fails closed on any error.
load_managed_state() {
  local state_file="$DEST/$STATE_FILE_NAME"
  validate_managed_state_path || exit 1
  [[ -f "$state_file" ]] || return 0
  local state_hex
  state_hex="$(LC_ALL=C od -An -v -tx1 "$state_file" 2>/dev/null)" || {
    err "state file validation failed"; exit 1
  }
  if printf '%s\n' "$state_hex" \
      | grep -Eq '(^|[[:space:]])00([[:space:]]|$)'; then
    err "malformed state file (raw NUL byte)"; exit 1
  fi
  local line="" lineno=1 seen=""
  {
    IFS= read -r line || [[ -n "$line" ]] || {
      err "malformed state file at line 1 (expected # aet-managed-state v1)"; exit 1
    }
    [[ "$line" == "# aet-managed-state v1" ]] || {
      err "malformed state file at line 1 (expected # aet-managed-state v1)"; exit 1
    }
    while IFS= read -r line || [[ -n "$line" ]]; do
      lineno=$((lineno + 1))
      [[ "$line" != "# aet-managed-state v1" ]] || {
        err "malformed state file at line $lineno (duplicate header)"; exit 1
      }
      [[ -z "$line" || "${line:0:1}" == "#" ]] && continue
      # Validate: path<TAB>sha256 — exactly one tab, two non-empty fields.
      local path sha
      path="${line%%$'\t'*}"
      sha="${line#*$'\t'}"
      if [[ -z "$path" || "$path" == "$line" || -z "$sha" || "$sha" == *$'\t'* ]]; then
        err "malformed state file at line $lineno (expected path<TAB>sha256)"; exit 1
      fi
      # Path must be relative and traversal-free.
      if [[ "${path:0:1}" == "/" || "$path" == *..* ]]; then
        err "state file path traversal at line $lineno: $path"; exit 1
      fi
      # sha256: 64 lowercase hex characters.
      if ! printf '%s' "$sha" | grep -qE '^[0-9a-f]{64}$'; then
        err "state file invalid sha256 at line $lineno: $sha"; exit 1
      fi
      # Path must be a known manifest entry.
      if ! in_manifest "$path"; then
        err "state file unknown path at line $lineno: $path"
        if [[ "$path" == prompts/*.prompt.md ]]; then
          err "  legacy prompts require manual skill migration; no files were changed"
          err "  see docs/installer-release-contracts.md#legacy-prompt-migration"
        fi
        exit 1
      fi
      # No duplicates.
      if printf '%s' "$seen" | grep -qxF "$path"; then
        err "state file duplicate entry at line $lineno: $path"; exit 1
      fi
      # The corresponding destination must not be a symlink.
      if [[ -L "$DEST/$path" ]]; then
        err "state file references symlink destination: $DEST/$path"; exit 1
      fi
      seen="${seen}${path}"$'\n'
      MANAGED_STATE_DATA="${MANAGED_STATE_DATA}${path}"$'\t'"${sha}"$'\n'
      MANAGED_STATE_COUNT=$((MANAGED_STATE_COUNT + 1))
    done
  } < "$state_file"
  log "managed state: $MANAGED_STATE_COUNT path(s) loaded"
}

# Write the managed state file atomically (temp + rename within DEST).
# Called after execute_writes completes; records all real engine files in DEST.
write_managed_state() {
  local state_file="$DEST/$STATE_FILE_NAME"
  local tmp_state="" old_hup old_int old_term
  preflight_symlinks
  validate_managed_state_path || exit 1

  old_hup="$(trap -p HUP)"
  old_int="$(trap -p INT)"
  old_term="$(trap -p TERM)"
  trap '[[ -z "$tmp_state" ]] || rm -f "$tmp_state"; exit 1' HUP INT TERM

  tmp_state="$(mktemp "$DEST/${STATE_FILE_NAME}.tmp.XXXXXX")" || {
    err "failed to create state temp file"; exit 1
  }
  chmod 600 "$tmp_state" || {
    err "failed to secure state temp file"
    rm -f "$tmp_state"; exit 1
  }
  printf '# aet-managed-state v1\n' > "$tmp_state" || {
    err "failed to write state temp file"
    rm -f "$tmp_state"; exit 1
  }
  local entry dst sha
  for entry in "${MANIFEST_ENTRIES[@]}"; do
    dst="$DEST/$entry"
    [[ -f "$dst" && ! -L "$dst" ]] || continue
    sha="$(sha256_of_file "$dst")" || {
      rm -f "$tmp_state"; exit 1
    }
    printf '%s\t%s\n' "$entry" "$sha" >> "$tmp_state" || {
      err "failed to write state temp file"
      rm -f "$tmp_state"; exit 1
    }
  done
  validate_managed_state_path || {
    rm -f "$tmp_state"; exit 1
  }
  mv "$tmp_state" "$state_file" || {
    err "failed to rename state file: $state_file"
    rm -f "$tmp_state"; exit 1
  }
  trap - HUP INT TERM
  [[ -z "$old_hup" ]] || eval "$old_hup"
  [[ -z "$old_int" ]] || eval "$old_int"
  [[ -z "$old_term" ]] || eval "$old_term"
  log "managed state: written to $state_file"
}

# Check all path components from DEST up to (and including) TARGET for symlinks.
# Exits immediately on any violation — does not accumulate errors, must run
# before any state or file operation.
preflight_raw_path_symlinks() {
  local path="$1" label="$2" current remaining component
  remaining="$path"
  if [[ "${remaining:0:1}" == "/" ]]; then
    current="/"
    while [[ "${remaining:0:1}" == "/" ]]; do
      remaining="${remaining:1}"
    done
  else
    current="$(pwd -P)"
  fi

  while [[ -n "$remaining" ]]; do
    component="${remaining%%/*}"
    if [[ "$remaining" == */* ]]; then
      remaining="${remaining#*/}"
    else
      remaining=""
    fi
    [[ -z "$component" || "$component" == "." ]] && continue
    if [[ "$current" == "/" ]]; then
      current="/$component"
    else
      current="$current/$component"
    fi
    if [[ -L "$current" ]]; then
      err "$label path contains a symlink: $current"
      err "  install into a real (non-symlink) directory"
      exit 1
    fi
  done
}

preflight_symlinks() {
  # Check from DEST upward, but stop at the user-provided root so that system
  # directories above TARGET (e.g. /var -> /private/var on macOS) are not
  # considered part of the install scope.
  local stop_at
  if [[ "$GLOBAL" == "true" ]]; then
    stop_at="$HOME"
  else
    stop_at="$TARGET"
  fi
  local dir="$DEST" depth=0
  while true; do
    if [[ -L "$dir" ]]; then
      err "destination path contains a symlink: $dir"
      err "  install into a real (non-symlink) directory"
      exit 1
    fi
    if [[ -e "$dir" && ! -d "$dir" ]]; then
      err "destination path component is not a directory: $dir"
      exit 1
    fi
    [[ "$dir" == "$stop_at" ]] && break
    local parent
    parent="$(dirname "$dir")"
    [[ "$parent" == "$dir" ]] && break
    dir="$parent"
    depth=$((depth + 1))
    [[ $depth -gt 100 ]] && break
  done
}

resolve_source() {
  if resolve_source_local; then
    return
  fi
  if [[ "$SELF" == "true" ]]; then
    err "--self requires running scripts/aet-install.sh from an AET source clone"
    exit 1
  fi
  log "no local AET source detected — using standalone (remote) mode"
  resolve_source_remote
}

# ---------------------------------------------------------------------------
# Preflight: collision detection
# ---------------------------------------------------------------------------
files_identical() { cmp -s "$1" "$2"; }

queue_write() {
  WRITE_SRCS+=("$1")
  WRITE_DSTS+=("$2")
}

check_write_path() {
  local dst="$1" parent="$1"
  if [[ -L "$dst" ]]; then
    err "destination is a symlink: $dst"
    return 1
  fi
  if [[ -e "$dst" && ! -f "$dst" ]]; then
    err "destination is not a regular file: $dst"
    return 1
  fi
  parent="$(dirname "$dst")"
  while [[ "$parent" == "$DEST"/* || "$parent" == "$DEST" ]]; do
    if [[ -L "$parent" ]]; then
      err "destination parent is a symlink: $parent"
      return 1
    fi
    if [[ -e "$parent" && ! -d "$parent" ]]; then
      err "destination parent is not a directory: $parent"
      return 1
    fi
    [[ "$parent" == "$DEST" ]] && break
    parent="$(dirname "$parent")"
  done
  return 0
}

# check_collision SRC DST IS_ENGINE
#   IS_ENGINE="true"  — engine manifest file; --force allows overwrite
#   IS_ENGINE="false" — content file; always abort on difference
check_collision() {
  local src="$1" dst="$2" is_engine="$3"

  if ! check_write_path "$dst"; then
    PREFLIGHT_ERRORS=$((PREFLIGHT_ERRORS + 1))
    return
  fi

  if [[ ! -e "$dst" ]]; then
    queue_write "$src" "$dst"
    return
  fi

  if files_identical "$src" "$dst"; then
    log "skip (identical): $dst"
    return
  fi

  # Files differ.
  if [[ "$is_engine" == "true" ]]; then
    local rel="${dst#${DEST}/}"
    if ! is_managed "$rel"; then
      err "unmanaged collision: $dst"
      err "  no prior managed state — cannot overwrite even with --force"
      err "  remove the file manually or install into an empty directory"
      PREFLIGHT_ERRORS=$((PREFLIGHT_ERRORS + 1))
      return
    fi
    if [[ "$FORCE" == "true" ]]; then
      log "WARN overwriting changed managed engine file (--force): $dst"
      queue_write "$src" "$dst"
    else
      err "collision — managed engine file changed: $dst"
      err "  re-run with --force to overwrite, or remove the file first"
      PREFLIGHT_ERRORS=$((PREFLIGHT_ERRORS + 1))
    fi
  else
    # Content files: always abort on any difference (--force does not apply).
    err "collision — content file would change destination: $dst"
    err "  make source and destination identical or remove the destination first"
    PREFLIGHT_ERRORS=$((PREFLIGHT_ERRORS + 1))
  fi
}

# Run full collision checks on all planned writes.
# Populates WRITE_SRCS/WRITE_DSTS; sets PREFLIGHT_ERRORS on any violation.
# No destination writes occur here; execute_writes() follows a clean preflight.
preflight() {
  # 1. Engine files from manifest.
  local entry src dst
  for entry in "${MANIFEST_ENTRIES[@]}"; do
    src="$SOURCE/$entry"
    dst="$DEST/$entry"
    if [[ ! -f "$src" ]]; then
      err "manifest entry missing from source: $src"
      PREFLIGHT_ERRORS=$((PREFLIGHT_ERRORS + 1))
      continue
    fi
    check_collision "$src" "$dst" "true"
  done

  # 2. Content-pack files (if any).
  if [[ -n "$CONTENT_PATH" ]]; then
    local mod f rel_src dst_file

    # Preserve legacy content-pack prompt copying; bundled workflows use skills.
    for mod in instructions prompts; do
      [[ -d "$CONTENT_PATH/$mod" ]] || continue
      for f in "$CONTENT_PATH/$mod"/*.md; do
        [[ -e "$f" ]] || continue
        rel_src="$mod/$(basename "$f")"
        dst_file="$DEST/$rel_src"
        if in_manifest "$rel_src"; then
          err "content pack cannot replace engine file: $rel_src"
          err "  rename the content file to avoid the engine namespace"
          PREFLIGHT_ERRORS=$((PREFLIGHT_ERRORS + 1))
          continue
        fi
        check_collision "$f" "$dst_file" "false"
      done
    done

    # skills subdirectories.
    if [[ -d "$CONTENT_PATH/skills" ]]; then
      local skill_dir skill_name sf
      for skill_dir in "$CONTENT_PATH/skills"/*/; do
        [[ -d "$skill_dir" ]] || continue
        skill_name="$(basename "$skill_dir")"
        for sf in "$skill_dir"*.md; do
          [[ -e "$sf" ]] || continue
          rel_src="skills/$skill_name/$(basename "$sf")"
          dst_file="$DEST/$rel_src"
          if in_manifest "$rel_src"; then
            err "content pack cannot replace engine file: $rel_src"
            PREFLIGHT_ERRORS=$((PREFLIGHT_ERRORS + 1))
            continue
          fi
          check_collision "$sf" "$dst_file" "false"
        done
      done
    fi

    # catalogs.
    if [[ -d "$CONTENT_PATH/catalogs" ]]; then
      local cf
      for cf in "$CONTENT_PATH/catalogs"/*.md; do
        [[ -e "$cf" ]] || continue
        rel_src="catalogs/$(basename "$cf")"
        dst_file="$DEST/$rel_src"
        if in_manifest "$rel_src"; then
          err "content pack cannot replace engine file: $rel_src"
          PREFLIGHT_ERRORS=$((PREFLIGHT_ERRORS + 1))
          continue
        fi
        check_collision "$cf" "$dst_file" "false"
      done
    fi
  fi

  if [[ $PREFLIGHT_ERRORS -gt 0 ]]; then
    err "$PREFLIGHT_ERRORS preflight error(s) - no destination files were written"
    exit 1
  fi
  log "preflight passed: ${#WRITE_SRCS[@]} file(s) queued"
}

# ---------------------------------------------------------------------------
# Write phase — only reached after a clean preflight
# ---------------------------------------------------------------------------
execute_writes() {
  local i
  for ((i=0; i<${#WRITE_SRCS[@]}; i++)); do
    local src="${WRITE_SRCS[$i]}"
    local dst="${WRITE_DSTS[$i]}"
    check_write_path "$dst" || {
      err "destination changed after preflight — aborting"
      exit 1
    }
    mkdir -p "$(dirname "$dst")"
    check_write_path "$dst" || {
      err "destination changed after preflight — aborting"
      exit 1
    }
    cp "$src" "$dst"
    if [[ -L "$dst" || ! -f "$dst" ]]; then
      err "installed destination is not a regular file: $dst"
      exit 1
    fi
    log "installed: $dst"
  done
}

# ---------------------------------------------------------------------------
# Post-install guidance
# ---------------------------------------------------------------------------
print_next_steps() {
  if [[ "$SELF" == "true" ]]; then
    cat <<EOF

Steward profile installed to $DEST/

Installed copies are local, gitignored outputs; canonical sources stay at the
repository root. Re-open the repo and pick "AET Steward" in the chat agent
picker. Remove repo-root chat.agentFilesLocations and
chat.instructionsFilesLocations entries from local settings to avoid duplicate
customization names. After editing canonical sources, refresh with:

  bash scripts/aet-install.sh --self --force
EOF
    return
  fi
  if [[ "$GLOBAL" == "true" ]]; then
    local tilde_dest="${DEST/#$HOME/~}"
    cat <<EOF

Agents installed to $DEST/agents/

Global mode is a personal VS Code extension-host convenience. Prefer repo
installs for team sharing and native project skill discovery.
Agent Host and CLI do not use the editor settings below.

Add to VS Code user settings (Code > Settings > Open User Settings JSON):

  "chat.agentFilesLocations": {
    "$tilde_dest/agents": true
  },
  "chat.instructionsFilesLocations": {
    "$tilde_dest/instructions": true
  },
These settings expose agents and instructions in the VS Code extension host.
Skills remain at $tilde_dest/skills/ for required AET workflow reads; this is NOT
a native user-skill discovery location. Copilot user skills use ~/.copilot/skills/.
Manual slash-skill discovery is not configured by --global. Do not add deprecated
chat.agentSkillsLocations as new setup; no settings or native user locations
were changed by this installer.

Do not enable these global AET locations in a workspace with a repo-local AET
install; duplicate customization names have undocumented host precedence.
EOF
  else
    cat <<EOF

Agents installed to $DEST/agents/

VS Code auto-discovers .github/agents/ and .github/skills/ — no settings
change needed. Re-open the repo and pick "AET Orchestrator" in the chat agent
picker.

For team sharing, review and commit the files in the repo-relative inventory
below, including portable governance, LICENSE, and managed state. Do not stage
all of .github/: unrelated files and private content are excluded. Review
content-pack files separately before sharing.
EOF
    local entry
    for entry in "${MANIFEST_ENTRIES[@]}"; do
      log "share: .github/$entry"
    done
    log "share: .github/$STATE_FILE_NAME"
  fi
  cat <<'EOF'

Audience template for host project root AGENTS.md (copy/paste manually):

## Audience

- Ordinary host work defaults to internal/private for authorized project members.
- Necessary nonpersonal company names, system identifiers, and internal links
  may remain when host policy permits.
- Public or external delivery requires destination-specific disclosure review.
- This default does not relax baseline safety or engine/EXPORT public-safety
  requirements.
EOF
  if [[ -n "$CONTENT_PATH" ]]; then
    log "Content sourced from: $CONTENT_PATH"
  fi
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
main() {
  if [[ "$SELF" == "true" ]]; then
    resolve_source
    TARGET="$SOURCE"
  fi
  if [[ "$GLOBAL" == "false" ]]; then
    preflight_raw_path_symlinks "$TARGET" "target"
    [[ -d "$TARGET" ]] || { err "target is not a directory: $TARGET"; exit 1; }
    TARGET="$(cd "$TARGET" && pwd)"
  else
    [[ -n "${HOME:-}" ]] || { err "HOME is not set"; exit 1; }
    [[ "$HOME" == /* ]] || { err "HOME must be an absolute path: $HOME"; exit 1; }
    preflight_raw_path_symlinks "$HOME" "HOME"
    [[ -d "$HOME" ]] || { err "HOME is not a directory: $HOME"; exit 1; }
    HOME="$(cd "$HOME" && pwd -P)"
    [[ "$HOME" != "/" ]] || { err "HOME cannot be the filesystem root"; exit 1; }
    preflight_raw_path_symlinks "$(dest_root)" "destination"
  fi

  [[ "$SELF" == "true" ]] || resolve_source
  load_manifest
  validate_source

  DEST="$(dest_root)"
  log "destination: $DEST"

  # Symlink check is first; exits immediately on any violation.
  preflight_symlinks

  # Load managed state; fails closed on any malformed or untrustworthy state.
  load_managed_state

  # Full collision preflight before destination writes.
  preflight

  if [[ "$DRY_RUN" == "true" ]]; then
    log "DRY-RUN: ${#WRITE_SRCS[@]} file(s) would be installed:"
    local i
    for ((i=0; i<${#WRITE_SRCS[@]}; i++)); do
      log "  ${WRITE_SRCS[$i]} -> ${WRITE_DSTS[$i]}"
    done
    log "dry-run complete - no destination files were written."
    return
  fi

  execute_writes
  write_managed_state
  log "done — ${#WRITE_SRCS[@]} file(s) installed."
  print_next_steps
}

main
