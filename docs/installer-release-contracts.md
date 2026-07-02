# Installer and Release Contracts

Detailed operating contracts for [the installer](../scripts/aet-install.sh),
its managed files, and portable release artifacts.

---

## Requirements

All installs need Bash, standard POSIX file utilities, and `sha256sum` or
`shasum`: the managed-state writer computes SHA-256 even for local-clone
installs. Standalone mode additionally needs `curl`, `cosign`, `tar`, and
`python3` or `jq` for JSON release metadata.

[Release building](../scripts/build-release.sh) also uses `tar`, `gzip`, and
Git for the commit timestamp (falling back to epoch zero without Git history).
[Installer tests](../scripts/test-install.sh) use these local tools plus
`python3` or `jq` for mocked standalone cases; no live downloads or signing
are needed. The GNU-tar byte comparison is skipped when GNU tar is unavailable.

## Installation Modes

### Local-Clone Mode

Run the installer inside a cloned AET repository. It detects the local source
tree and installs only after validating it against
[the manifest](../scripts/aet-manifest.txt). This mode needs no network access
or standalone-specific tools; the baseline requirements above still apply.

### Standalone Mode

Without a local AET source tree, the installer fetches the latest stable GitHub
release, excluding drafts and pre-releases. It verifies the SHA-256 checksum and
Sigstore keyless signature before installation. Missing tools, artifacts, or
valid verification evidence cause a closed failure.

### Self Mode

`--self` maintains this AET source clone. It installs the source-only Steward
profile from [the self manifest](../scripts/aet-self-manifest.txt) into
`<source root>/.github/` from the local tree only; it never falls back to
standalone mode. The profile excludes AET Orchestrator and AET Investigator.
Self-manifest entries must not start with `.github/`. Installed copies and their
managed state are gitignored local outputs; canonical sources stay at the root.
Installed Review Proposal and Generate Architecture Doc skills keep links to the
omitted Orchestrator implementation-readiness section; read it from the root
`agents/` copy.
Collision policy and managed state match repo mode, so refresh copies after
canonical edits with `--self --force`. Remove repo-root
`chat.agentFilesLocations` and `chat.instructionsFilesLocations` entries from
local settings to avoid duplicate customization names. Managed state from
another mode is rejected without writes; remove those managed copies and
`.github/.aet-managed-state` before switching modes.

---

## Options

| Option | Contract |
|---|---|
| `--global` | Install into `~/.aet/` for personal VS Code extension-host use |
| `--target DIR` | Use DIR as the repo root instead of the current directory |
| `--self` | Install the Steward profile into this source clone; excludes `--global`, `--target`, and `--content-path` |
| `--force` | Overwrite changed _managed_ engine files; reject _unmanaged_ collisions |
| `--dry-run` | Print planned actions without destination writes |
| `--content-path DIR` | Merge instructions, skills, catalogs, and legacy prompts from DIR |
| `-h`, `--help` | Show help |

Dry-run still resolves and validates the source and runs collision preflight.
Standalone source resolution downloads and verifies assets in owned temporary
storage before preflight; cleanup removes that storage on exit. Dry-run does
not create destination directories, copy files, or rewrite managed state.
It is not a networkless mode.

---

## Installation Scope

Repo-local installation is the default for teams, reviewed and pinned
behavior, and reproducible setup. Review and commit only the paths emitted as
`[aet-install] share: <repo-relative-path>` after a successful repo install.
This consumed inventory contains exactly the manifest-listed files under
`.github/`, including `.github/LICENSE` and required `.github/docs/` governance,
plus `.github/.aet-managed-state`. Sharing the state preserves managed-file
provenance for collaborators. Do not stage all of `.github/` or entire module
directories: unrelated files and private content are excluded from the
inventory. Review content-pack files separately before sharing.

Global mode supports one developer using AET across workspaces in the VS Code
extension host. It requires AET entries in the VS Code user settings for
`chat.agentFilesLocations` and `chat.instructionsFilesLocations`.

The destination remains `~/.aet/`. Its `skills/` directory is not natively
discovered by Copilot: native project skills use `.github/skills/`, and native
user skills use `~/.copilot/skills/`. Required AET workflows load their skill
procedures directly from the selected bundle root, independently of discovery.
Manual slash-skill discovery is not configured by global installation.
Do not add deprecated `chat.agentSkillsLocations` as new setup. Agent Host and
CLI do not use these editor settings; this global setup does not establish
compatibility with them. The installer does not change settings or populate
native user locations. Updating a global install affects every workspace using
the configured AET locations.

Do not combine active global AET locations with a repo-local install because
duplicate customization-name precedence is undocumented. Before using a
repo-local install, disable or remove only AET entries from `chat.*Locations`;
preserve unrelated entries. Remove `~/.aet/` only when the personal install is
no longer needed.

### Content-Pack Skills

`--content-path` retains its existing copy contract: direct Markdown files in
`instructions/`, legacy `prompts/`, and `catalogs/`, plus direct Markdown files
inside each `skills/<name>/` directory. It does not recursively copy skill
resources, scripts, or nested directories. Bundle-owned skill paths cannot be
replaced by content, even with `--force`.

Legacy content-pack prompt inputs are still copied, not silently discarded or
converted. For VS Code's **Copilot harness**, migrate reusable prompt workflows
to `skills/<name>/SKILL.md`: its sessions do not load `*.prompt.md` files.
**Local harness** sessions still support prompt files. This is the
[documented harness behavior](https://code.visualstudio.com/docs/agent-customization/migrate-customizations#_convert-prompt-files-to-skills)
retrieved 2026-11-12 (page updated 2026-11-11), not a minimum-version guarantee.
[Local and Copilot are session harness choices](https://code.visualstudio.com/docs/agents/run/move-to-copilot),
not a blanket distinction between Copilot IDE features. GitHub's
[customization support table](https://docs.github.com/en/copilot/reference/customization-cheat-sheet)
(retrieved 2026-11-12) lists prompt files for VS Code and some other IDEs, but
not Copilot CLI.

When converting, use valid skill metadata, explicit ownership, and an invocation
policy. Recheck prompt-specific `agent`, `model`, and `tools` selections:
conversion drops them; skill text does not select agents or enforce tool
boundaries. VS Code's automatic conversion adds `disable-model-invocation: true`;
removing it permits model selection of the skill, not selection of a model.
Review changed CONTENT independently of the public engine.

---

## Collision Policy

All collision checks finish before destination writes. The installer records each
engine file's installed SHA-256 in `<dest>/.aet-managed-state`. A path is
_managed_ when it appears in a valid state file; every other existing path is
_unmanaged_.

| Scenario | Behavior |
|---|---|
| Engine destination absent | Write |
| Engine destination identical | Skip and adopt into managed state |
| _Managed_ engine destination differs | Abort unless `--force` |
| _Managed_ engine destination differs with `--force` | Overwrite |
| _Unmanaged_ engine collision | Always abort, including with `--force` |
| Content file would overwrite engine path | Always abort, including with `--force` |
| Content destination differs | Always abort |
| Content destination identical | Skip without writing |

Symlinks in the destination path, including the root and every ancestor, are
rejected before destination reads or writes. State validation fails closed on malformed,
duplicate, traversal, unknown-path, or symlink entries. After engine writes
finish, state is written atomically by renaming a temporary file within the
destination.

### Legacy Prompt Migration

Bundled `prompts/<name>.prompt.md` workflows have moved to
`skills/<name>/SKILL.md`; the source index is now `skills/README.md`.
Old managed-state prompt entries are unknown to the new manifest and reject
upgrade before writes, including with `--force`. The installer never deletes
installed legacy prompts, rewrites their provenance, or converts user changes.

For either repo-local `.github/` or global `~/.aet/` installations:

1. Back up the entire installed destination, including `.aet-managed-state`,
   outside host-discovered customization directories, under the same audience
   and access protections. Review local edits and unmanaged content separately.
2. Compare the old bundle and new source manifest. For retired bundled prompt
   entries only, manually move the corresponding installed files to that
   protected backup after reconciling useful edits into new skills. Do not
   delete files or move unrelated host prompts, skills, or instructions.
3. Manually remove only those retired prompt rows from the installed state file.
   Preserve its exact header, remaining paths, tabs, and SHA-256 values. Retain
   the original state in the backup; never erase state to bypass collisions.
4. Run the new installer with `--dry-run`, then install only after reviewing its
   plan. Reconcile changed managed files before deliberately using `--force`;
   unmanaged skill collisions must be preserved and resolved manually.

An alternative is a fresh install into a separate clean target for comparison,
followed by a human-reviewed replacement of only the old managed bundle.
Do not mix active old and new copies with duplicate names. Apply the same
backup, move, and single-row removal steps to a retired `docs/philosophy.md`
entry; that document is now source-only. If another unknown state path remains,
stop and investigate rather than removing unrelated rows.

---

## Release Artifact Contract

[The manifest](../scripts/aet-manifest.txt) solely owns portable file membership:
31 regular files, including the unchanged root [LICENSE](../LICENSE).
The archive contains exactly those files plus `scripts/aet-manifest.txt`
(32 regular files), all under its versioned prefix. Installation copies only
manifest entries and generates managed state; it does not install the manifest.
The license's rights-holder attribution retains the
[deliberately public identity exception](public-safety.md#deliberately-public-identity);
it grants no exception for host identities or licenses.

Standalone mode downloads exactly four assets from the GitHub release page:

| Artifact | Purpose |
|---|---|
| `aet-bundle-<version>.tar.gz` | Engine bundle extracting to `aet-bundle-<version>/` |
| `aet-bundle-<version>.sha256` | Tarball checksum in `sha256sum` format |
| `aet-bundle-<version>.tar.gz.cosign.bundle` | Tarball Sigstore bundle |
| `aet-bundle-<version>.sha256.cosign.bundle` | Checksum-file Sigstore bundle |

Sigstore identity is pinned per release, not matched by a regular expression:

- **Certificate SAN**:
  `https://github.com/mabrosim/ai-engineering-toolkit/.github/workflows/release.yml@refs/tags/<version>`
- **OIDC issuer**: `https://token.actions.githubusercontent.com`

The installer verifies the checksum-file signature before trusting its hash,
then verifies the tarball signature, verifies SHA-256, and validates every
archive member path before extraction. Any failure is fatal.

The [release workflow](../.github/workflows/release.yml) runs the installer
suite before building or signing. It signs both assets with GitHub OIDC keyless
identity from a strict `vX.Y.Z` tag:

```bash
cosign sign-blob --yes --bundle <name>.cosign.bundle <file>
```

### Archive Repeatability

Staging permissions are fixed to `0755` for directories and `0644` for regular
files; the current manifest carries no executable payload. Source permissions
and the invoking umask do not determine archive modes.

GNU tar fixes ordering, commit-derived mtime, and ownership; `gzip -n` omits
the gzip timestamp. The focused regression compares archive and checksum
bytes from the same fixture under umasks `022` and `077` when GNU tar is
available as `tar` or `gtar`. This does not establish reproducibility across
tool versions or platforms. The builder uses GNU behavior only when `tar`
itself is GNU tar.

BSD tar remains the fallback with the same file inventory and normalized
permissions, but no byte-reproducibility guarantee. Use the GNU-tar release
environment for signed artifacts. Generated root-level assets and
`release-notes.md` are narrowly ignored by [.gitignore](../.gitignore).
