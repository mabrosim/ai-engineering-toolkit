# Installation & Utility Scripts

`aet-install.sh` installs the portable engine into an external repo or personal VS Code location.

`aet-manifest.txt` owns managed engine membership; paths map from source root to destination.

`aet-self-manifest.txt` owns the source-only Steward profile for `--self`.

---

## Usage

Repo-local installation is recommended for teams and reproducible setup.

```bash
git clone https://github.com/mabrosim/ai-engineering-toolkit.git
cd ai-engineering-toolkit
bash scripts/aet-install.sh --dry-run
bash scripts/aet-install.sh
bash scripts/aet-install.sh --target /path/to/your/repo
bash scripts/aet-install.sh --global
bash scripts/aet-install.sh --force
bash scripts/aet-install.sh --content-path /path/to/my-instructions
bash scripts/aet-install.sh --self          # maintain this source clone
bash scripts/aet-install.sh --self --force  # refresh after canonical edits
```

Run `bash scripts/aet-install.sh --help` for all options.

---

## Requirements

See [delivery requirements](../docs/installer-release-contracts.md#requirements)
for local SHA tooling, standalone dependencies, and build/test prerequisites.

---

## Notes

- Review only the emitted `share:` file inventory for team sharing; see
  [installation scope](../docs/installer-release-contracts.md#installation-scope).
- Global mode installs to `~/.aet/` and affects every configured workspace.
- Agent/instruction discovery needs VS Code extension-host settings; `~/.aet/skills/`
  is not a native user-skill location. Workflows read skills directly; manual discovery is not configured.
- Do not combine active global AET locations with a repo-local install.
- Collision checks precede destination writes; `--force` never replaces _unmanaged_ files.
- Destination-path symlinks are rejected.
- Old prompt-based installs require [manual migration](../docs/installer-release-contracts.md#legacy-prompt-migration).
- Successful installs print a manual Audience template for the host root `AGENTS.md`.
  The installer never changes that file. `--self` prints Steward guidance instead.
- See [installer and release contracts](../docs/installer-release-contracts.md) for details.
- `bash scripts/test-install.sh` tests installer behavior and consumed bundle integrity.
- [Repository rules](../docs/repository-rules.md#validation-and-review) own check selection.
