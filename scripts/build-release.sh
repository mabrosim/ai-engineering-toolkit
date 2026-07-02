#!/usr/bin/env bash
#
# build-release.sh — build the AET release bundle.
#
# Usage: bash scripts/build-release.sh <vX.Y.Z>
#
# Run from any directory; the script locates the repository root from its own
# path.  Output files are written to the current working directory:
#
#   aet-bundle-<version>.tar.gz      engine bundle (top-level aet-bundle-<version>/)
#   aet-bundle-<version>.sha256      SHA-256 checksum in sha256sum format
#
# GNU tar normalizes ordering, mtime, ownership and gzip timestamps; staging
# permissions are fixed for the current non-executable manifest payload.
# BSD tar preserves payload content but has no byte-reproducibility guarantee.
# Repeatability across tool versions or platforms is not guaranteed.

set -euo pipefail

# ---------------------------------------------------------------------------
# Arguments
# ---------------------------------------------------------------------------
VERSION="${1:-}"
if [[ -z "$VERSION" ]]; then
  printf 'Usage: %s <vX.Y.Z>\n' "$0" >&2
  exit 1
fi

if ! [[ "$VERSION" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  printf 'error: tag must be strict semver vX.Y.Z (got: %s)\n' "$VERSION" >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd -P)"
MANIFEST="$SCRIPT_DIR/aet-manifest.txt"
BUNDLE_NAME="aet-bundle-${VERSION}"
OUT_DIR="$(pwd)"
TARBALL="${OUT_DIR}/${BUNDLE_NAME}.tar.gz"
SHA256_FILE="${OUT_DIR}/${BUNDLE_NAME}.sha256"

# ---------------------------------------------------------------------------
# Validate manifest
# ---------------------------------------------------------------------------
[[ -f "$MANIFEST" ]] || { printf 'error: manifest not found: %s\n' "$MANIFEST" >&2; exit 1; }

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
    || { printf 'error: invalid manifest entry at line %s (%s)\n' \
      "$lineno" "$reason" >&2; exit 1; }
}

manifest_hex="$(LC_ALL=C od -An -v -tx1 "$MANIFEST" 2>/dev/null)" || {
  printf 'error: manifest validation failed\n' >&2
  exit 1
}
if printf '%s\n' "$manifest_hex" \
    | grep -Eq '(^|[[:space:]])00([[:space:]]|$)'; then
  printf 'error: manifest validation failed\n' >&2
  exit 1
fi

ENTRIES=()
lineno=0
while IFS= read -r line || [[ -n "$line" ]]; do
  lineno=$((lineno + 1))
  [[ -z "$line" || "${line:0:1}" == "#" ]] && continue
  validate_manifest_entry "$line" "$lineno"
  if [[ -n "${ENTRIES[*]-}" ]]; then
    for existing in "${ENTRIES[@]}"; do
      [[ "$existing" != "$line" ]] \
        || { printf 'error: invalid manifest entry at line %s (duplicate entry)\n' \
          "$lineno" >&2; exit 1; }
    done
  fi
  ENTRIES+=("$line")
done < "$MANIFEST"

[[ ${#ENTRIES[@]} -gt 0 ]] || { printf 'error: manifest is empty\n' >&2; exit 1; }

missing=0
for entry in "${ENTRIES[@]}"; do
  source_path="$REPO_ROOT/$entry"
  if [[ -L "$source_path" ]]; then
    printf 'error: manifest entry is a symlink: %s\n' "$entry" >&2
    missing=$((missing + 1))
    continue
  fi
  if [[ ! -f "$source_path" ]]; then
    printf 'error: manifest entry missing from source: %s\n' "$entry" >&2
    missing=$((missing + 1))
    continue
  fi
  resolved_parent="$(cd "$(dirname "$source_path")" 2>/dev/null && pwd -P)" || {
    printf 'error: manifest entry parent cannot resolve: %s\n' "$entry" >&2
    missing=$((missing + 1))
    continue
  }
  if [[ "$resolved_parent" != "$REPO_ROOT" \
      && "$resolved_parent" != "$REPO_ROOT/"* ]]; then
    printf 'error: manifest entry resolves outside repository root: %s\n' \
      "$entry" >&2
    missing=$((missing + 1))
  fi
done
[[ $missing -eq 0 ]] || exit 1

printf 'manifest: %d entries validated\n' "${#ENTRIES[@]}"

# ---------------------------------------------------------------------------
# Stage bundle tree
# ---------------------------------------------------------------------------
STAGE="$(mktemp -d)"
trap 'rm -rf "$STAGE"' EXIT

BUNDLE_DIR="$STAGE/$BUNDLE_NAME"
mkdir -p "$BUNDLE_DIR"

# Manifest itself is always included under scripts/.
mkdir -p "$BUNDLE_DIR/scripts"
cp "$MANIFEST" "$BUNDLE_DIR/scripts/aet-manifest.txt"

# Every manifest-listed file, preserving directory structure.
for entry in "${ENTRIES[@]}"; do
  dst="$BUNDLE_DIR/$entry"
  mkdir -p "$(dirname "$dst")"
  cp "$REPO_ROOT/$entry" "$dst"
done
find "$BUNDLE_DIR" -type d -exec chmod 0755 {} +
find "$BUNDLE_DIR" -type f -exec chmod 0644 {} +

# ---------------------------------------------------------------------------
# Create tarball
# ---------------------------------------------------------------------------
# Prefer GNU tar for a reproducible archive; fall back to BSD tar.
if tar --version 2>/dev/null | grep -q 'GNU tar'; then
  SOURCE_DATE_EPOCH="$(git -C "$REPO_ROOT" log -1 --format='%ct' 2>/dev/null || printf '0')"
  tar \
    --sort=name \
    "--mtime=@${SOURCE_DATE_EPOCH}" \
    --owner=0 --group=0 --numeric-owner \
    -cf - -C "$STAGE" "$BUNDLE_NAME" \
    | gzip -n > "$TARBALL"
else
  tar -czf "$TARBALL" -C "$STAGE" "$BUNDLE_NAME"
fi
printf 'created: %s\n' "$(basename "$TARBALL")"

# ---------------------------------------------------------------------------
# SHA-256 checksum (portable: Linux sha256sum or macOS shasum)
# ---------------------------------------------------------------------------
if command -v sha256sum >/dev/null 2>&1; then
  (cd "$OUT_DIR" && sha256sum "${BUNDLE_NAME}.tar.gz") > "$SHA256_FILE"
elif command -v shasum >/dev/null 2>&1; then
  (cd "$OUT_DIR" && shasum -a 256 "${BUNDLE_NAME}.tar.gz") > "$SHA256_FILE"
else
  printf 'error: sha256sum or shasum is required\n' >&2
  exit 1
fi
printf 'created: %s\n' "$(basename "$SHA256_FILE")"

printf 'done — sign both artifacts with:\n'
printf '  cosign sign-blob --yes --bundle %s.tar.gz.cosign.bundle %s\n' \
  "$BUNDLE_NAME" "${BUNDLE_NAME}.tar.gz"
printf '  cosign sign-blob --yes --bundle %s.sha256.cosign.bundle %s\n' \
  "$BUNDLE_NAME" "${BUNDLE_NAME}.sha256"
