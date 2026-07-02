#!/usr/bin/env bash
#
# aet-install.sh — install the AET Orchestrator bundle.
#
# Repo install (default): installs into <repo>/.github/ — committed to the
# repo, VSCode discovers it automatically with no settings change.
#
# Global install (--global): installs into ~/.aet/ — applies to every
# workspace. Add ~/.aet/agents to your VSCode user settings once and the
# Orchestrator appears in every repo you open (the script prints the path).
#
# --target DIR targets a specific repo root instead of the current directory
# (only meaningful for the repo install; global install always goes to ~/.aet/).
#
# Works from a local clone or standalone (downloads the bundle when run via
# `curl ... | bash`).
#
# Usage:
#   bash scripts/aet-install.sh [--global] [--target DIR] [--ref REF] [--dry-run] [--content-path DIR]
#   curl -fsSL <raw-url>/scripts/aet-install.sh | bash
#
# Options:
#   --global              Global install into ~/.aet/ (applies to all workspaces)
#   --target DIR          Repo root for repo install (default: current directory)
#   --ref REF             Git ref to fetch when downloading (default: main)
#   --dry-run             Print actions without writing anything
#   --content-path DIR    Add extra instructions and prompts from DIR/instructions/
#                         and DIR/prompts/ on top of the bundled ones
#   -h, --help            Show this help

set -euo pipefail

REPO_URL="https://github.com/mabrosim/ai-engineering-toolkit.git"
TARGET="$(pwd)"
GLOBAL="false"
REF="main"
DRY_RUN="false"
CONTENT_PATH=""

# Portable specialists the Orchestrator delegates to.
SPECIALISTS=(
  aet-engineering
  aet-validation
  aet-documentation
  aet-review
  aet-proposal
  aet-lightweight
)

log() { printf '[aet-install] %s\n' "$*"; }
err() { printf '[aet-install] error: %s\n' "$*" >&2; }

usage() {
  cat <<'EOF'
aet-install.sh — install the AET Orchestrator bundle.

  Repo install (default)    install into <repo>/.github/  zero-config, commit to repo
  Global install (--global) install into ~/.aet/          applies to all workspaces

Options:
  --global              Global install into ~/.aet/ (applies to all workspaces)
  --target DIR          Repo root for repo install (default: current directory)
  --ref REF             Git ref to fetch when downloading (default: main)
  --dry-run             Print actions without writing anything
  --content-path DIR    Add extra instructions and prompts from DIR/instructions/
                        and DIR/prompts/ on top of the bundled ones
  -h, --help            Show this help
EOF
  exit "${1:-0}"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --global)             GLOBAL="true"; shift ;;
    --target)             TARGET="${2:?--target needs a path}"; shift 2 ;;
    --ref)                REF="${2:?--ref needs a value}"; shift 2 ;;
    --dry-run)            DRY_RUN="true"; shift ;;
    --content-path)       CONTENT_PATH="${2:?--content-path needs a path}"; shift 2 ;;
    -h|--help)            usage 0 ;;
    *) err "unknown argument: $1"; usage 1 ;;
  esac
done

if [[ "$GLOBAL" == "true" && "$TARGET" != "$(pwd)" ]]; then
  err "--global and --target are mutually exclusive (--global always installs into ~/.aet/)"
  exit 1
fi

if [[ -n "$CONTENT_PATH" ]]; then
  [[ -d "$CONTENT_PATH" ]] || { err "--content-path is not a directory: $CONTENT_PATH"; exit 1; }
  CONTENT_PATH="$(cd "$CONTENT_PATH" && pwd)"
  log "using custom content from: $CONTENT_PATH"
fi

# --- Resolve destination root -------------------------------------------------

dest_root() {
  if [[ "$GLOBAL" == "true" ]]; then
    echo "$HOME/.aet"
  else
    echo "$TARGET/.github"
  fi
}

# --- Resolve a source tree (local clone or freshly downloaded) ----------------

SOURCE=""
CLEANUP_DIR=""

resolve_source() {
  local self_dir=""
  if [[ -n "${BASH_SOURCE[0]:-}" && -f "${BASH_SOURCE[0]}" ]]; then
    self_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." 2>/dev/null && pwd || true)"
  fi
  if [[ -n "$self_dir" && -d "$self_dir/agents" && -f "$self_dir/agents/aet-orchestrator.agent.md" ]]; then
    SOURCE="$self_dir"
    log "using local source: $SOURCE"
    return
  fi

  command -v git >/dev/null 2>&1 || { err "git is required to download the bundle"; exit 1; }
  CLEANUP_DIR="$(mktemp -d)"
  log "downloading bundle ($REF) from $REPO_URL"
  git clone --depth 1 --branch "$REF" "$REPO_URL" "$CLEANUP_DIR/repo" >/dev/null 2>&1 \
    || { err "git clone failed for ref '$REF'"; exit 1; }
  SOURCE="$CLEANUP_DIR/repo"
}

cleanup() { [[ -n "$CLEANUP_DIR" ]] && rm -rf "$CLEANUP_DIR"; return 0; }
trap cleanup EXIT

# --- Copy helpers -------------------------------------------------------------

run() {
  if [[ "$DRY_RUN" == "true" ]]; then
    log "DRY-RUN: $*"
  else
    "$@"
  fi
}

copy_file() {
  local src="$1" dst="$2"
  [[ -f "$src" ]] || { err "missing source file: $src"; exit 1; }
  run cp "$src" "$dst"
  log "copied $(basename "$src") -> $dst/"
}

copy_module() {
  local name="$1" dest="$2"
  local src="$SOURCE/$name"
  local dst="$dest/$name"
  [[ -d "$src" ]] || { err "missing source dir: $src"; exit 1; }
  run mkdir -p "$dst"
  local f
  for f in "$src"/*.md; do
    [[ -e "$f" ]] || continue
    run cp "$f" "$dst/"
    log "copied $(basename "$f") -> $dst/"
  done
}

# --- Post-install message -----------------------------------------------------

print_next_steps() {
  local dest="$1"
  if [[ "$GLOBAL" == "true" ]]; then
    local tilde_dest="${dest/#$HOME/~}"
    local skills_note=""
    if [[ -d "$dest/skills" ]]; then
      skills_note="  \"chat.skillsFilesLocations\": {
    \"$tilde_dest/skills\": true
  },
"
    fi
    cat <<EOF

Agents installed to $dest/agents/

Add these to your VSCode user settings (Code > Settings > Open User Settings JSON)
so the bundle is available in every workspace:

  "chat.agentFilesLocations": {
    "$tilde_dest/agents": true
  },
  "chat.promptFilesLocations": {
    "$tilde_dest/prompts": true
  },
  "chat.instructionsFilesLocations": {
    "$tilde_dest/instructions": true
  },
${skills_note}
Note: VS Code also auto-discovers instructions from ~/.copilot/instructions/ —
symlink or copy $dest/instructions/ there to avoid the setting above.

Agents and prompts are then available in every repo you open.
EOF
  else
    cat <<EOF

Agents installed to $dest/agents/

VSCode discovers .github/agents/ and .github/prompts/ automatically — no settings
change needed. Re-open the repo and pick "AET Orchestrator" in the chat agent
picker. Commit .github/agents/, .github/instructions/, .github/validation/,
.github/prompts/ to share the bundle with your team.
EOF
  fi
  if [[ -n "$CONTENT_PATH" ]]; then
    log "Content sourced from: $CONTENT_PATH"
  fi
}

# --- Main ---------------------------------------------------------------------

main() {
  if [[ "$GLOBAL" == "false" ]]; then
    [[ -d "$TARGET" ]] || { err "target is not a directory: $TARGET"; exit 1; }
    TARGET="$(cd "$TARGET" && pwd)"
  fi
  resolve_source

  local dest
  dest="$(dest_root)"
  local agents_dir="$dest/agents"
  run mkdir -p "$agents_dir"

  log "installing into $dest"

  run cp "$SOURCE/agents/aet-orchestrator.agent.md" "$agents_dir/"
  log "copied aet-orchestrator.agent.md -> $agents_dir/"
  local name
  for name in "${SPECIALISTS[@]}"; do
    run cp "$SOURCE/agents/$name.agent.md" "$agents_dir/"
    log "copied $name.agent.md -> $agents_dir/"
  done

  # Modules the agents reference via ../instructions, ../validation, ../prompts.
  # Mirrored alongside agents/ so those relative links resolve.
  copy_module instructions "$dest"
  copy_module validation   "$dest"
  copy_module prompts      "$dest"

  # Add extra instructions and prompts from content path on top of bundled.
  if [[ -n "$CONTENT_PATH" && -d "$CONTENT_PATH/instructions" ]]; then
    local f
    for f in "$CONTENT_PATH/instructions"/*.md; do
      [[ -e "$f" ]] || continue
      run cp "$f" "$dest/instructions/"
      log "copied $(basename "$f") -> $dest/instructions/"
    done
  fi
  if [[ -n "$CONTENT_PATH" && -d "$CONTENT_PATH/prompts" ]]; then
    local f
    for f in "$CONTENT_PATH/prompts"/*.md; do
      [[ -e "$f" ]] || continue
      run cp "$f" "$dest/prompts/"
      log "copied $(basename "$f") -> $dest/prompts/"
    done
  fi

  # Copy skills subdirectories from content path (each skill is a named subfolder).
  if [[ -n "$CONTENT_PATH" && -d "$CONTENT_PATH/skills" ]]; then
    run mkdir -p "$dest/skills"
    local skill_dir skill_name sf
    for skill_dir in "$CONTENT_PATH/skills"/*/; do
      [[ -d "$skill_dir" ]] || continue
      skill_name="$(basename "$skill_dir")"
      run mkdir -p "$dest/skills/$skill_name"
      for sf in "$skill_dir"*.md; do
        [[ -e "$sf" ]] || continue
        run cp "$sf" "$dest/skills/$skill_name/"
        log "copied $skill_name/$(basename "$sf") -> $dest/skills/$skill_name/"
      done
    done
  fi

  # Copy catalog flat files from content path.
  if [[ -n "$CONTENT_PATH" && -d "$CONTENT_PATH/catalogs" ]]; then
    run mkdir -p "$dest/catalogs"
    local cf
    for cf in "$CONTENT_PATH/catalogs"/*.md; do
      [[ -e "$cf" ]] || continue
      run cp "$cf" "$dest/catalogs/"
      log "copied $(basename "$cf") -> $dest/catalogs/"
    done
  fi

  log "done."
  [[ "$DRY_RUN" == "true" ]] && log "dry-run only — no files were written."
  print_next_steps "$dest"
}

main
