# Installation & Utility Scripts

`aet-install.sh` installs the portable AET Orchestrator bundle into an external
repository or user-global location.

## Usage

```bash
# Install into current repo (committed to .github/)
bash scripts/aet-install.sh

# Install user-globally (~/.aet/, applies to every workspace)
bash scripts/aet-install.sh --global

# Or download and run directly
curl -fsSL <raw-url>/scripts/aet-install.sh | bash
```

Run `bash scripts/aet-install.sh --help` for full options.
