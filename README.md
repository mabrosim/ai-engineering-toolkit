# AI Engineering Toolkit

[![Markdown Lint](https://github.com/mabrosim/ai-engineering-toolkit/actions/workflows/lint.yml/badge.svg)](https://github.com/mabrosim/ai-engineering-toolkit/actions/workflows/lint.yml)

Extract your project's coding standards into reusable instruction files for
GitHub Copilot.

---

## Purpose

Make project conventions available as explicit, reusable guidance for
AI-assisted work.

An assistant may lack conventions absent from its active context. AET provides
workflows to extract and review those conventions; host discovery, settings,
available tools, and model behavior still affect loading and compliance.

---

## Who This Is For

- Developers using GitHub Copilot who want consistent, standards-aware AI output
- Teams that want to codify and share coding conventions as loadable AI context
- Developers who want to turn their own tacit expertise into reusable instruction files

---

## Prerequisites

- VS Code with the GitHub Copilot extension (agent mode required)
- All installs: Bash, POSIX file utilities, and `sha256sum` or `shasum`, including
  local-clone installs; see [installer requirements](docs/installer-release-contracts.md#requirements)
- Standalone downloads additionally require `curl`, `cosign`, `tar`, and
  `python3` or `jq`

---

## Quick Start

Clone the repository and install AET into the project you want to work on:

```bash
git clone https://github.com/mabrosim/ai-engineering-toolkit.git
bash ai-engineering-toolkit/scripts/aet-install.sh --target /path/to/your/project --dry-run
bash ai-engineering-toolkit/scripts/aet-install.sh --target /path/to/your/project
```

Use the installer to install the complete
[manifest bundle](scripts/aet-manifest.txt), including supporting rules and
governance. Local-clone installation is recommended; without a local source
tree, [standalone mode](docs/installer-release-contracts.md#standalone-mode)
downloads and verifies release assets using the additional prerequisites above.

Then:

1. Open the target project in VS Code
2. Select **AET Orchestrator** from the Copilot agent picker
3. Type `assess this repo`

The [assessment workflow](skills/assess-project/SKILL.md) requests a nonwriting
assessment using applicable project guidance. Review its proposed next step
before authorizing implementation.

Common follow-up requests:

```text
Extract reusable knowledge from src/analytics
Review the prepared KEEP-LOCAL analytics candidate for source fit
Refactor module X — preserve behavior, apply standards
Add docstrings to package Y
Validate this file for public release
```

For manual use, invoke a discovered skill such as `/assess-project` or
`/code-review`; see the [skill index](skills/README.md) for ownership and
invocation policy. Required agent workflows load their skill procedures
directly even when native discovery is unavailable.

Correctness-bearing changes require [Review](agents/aet-review.agent.md), then
[Validation](agents/aet-validation.agent.md). Applicable safety uncertainty
blocks adoption or disclosure; technical results do not replace human authorization.

---

## How It Works

AET coordinates discovery, extraction, review, and validation. Extracted
CONTENT follows [Review Proposal](skills/review-proposal/SKILL.md):

1. **Capture**: discovery or extraction writes a source proposal under
  `.aet/proposals/<export|local>/`; neither adopts instructions.
2. **Source review**: `ABANDON`, `DEFER`, or `PREPARE` a noncanonical candidate
  under route-matching `.aet/content-candidates/<export|local>/`.
3. **Transfer**: a human transfers only sanitized, prepared EXPORT candidates
  to the destination content-pack; KEEP-LOCAL stays in its source project.
4. **Fit review**: compare against destination owners before `ABANDON`, `MERGE`,
  `ADOPT`, or `DEFER`; KEEP-LOCAL fit review occurs in the source project.
5. **Integrate**: require Review, then Validation, and required human approval
  before canonical adoption or merge.

Processed proposals are not copied to content-pack. Generic engine improvements
use the separate [engine proposal route](skills/propose-improvement/SKILL.md#prompt).

---

## The Two-Repo Model

AET keeps the engine separate from your content:

- **This repo (AET)** — the extraction and validation engine: agents, skills, and workflows. Public, generic, no personal content.
- **Your instructions repo** — mined rules, style guides, and patterns from your own code. Private by default; you decide what to share.

You create and manage any separate content repository; AET does not create one
or automatically adopt extracted output. Configure its reviewed content for your
host, and authorize sharing only after applicable safety and destination review.

See [docs/philosophy.md](docs/philosophy.md) for the design rationale behind this separation.

---

## Installation

### Option A — Per-Repo Install (Default)

Installs the complete engine into a repository's `.github/` folder. This is the
recommended scope for teams sharing a reviewed version. The host must discover
the installed agent, skill, and instruction locations; check host support and
settings rather than assuming every artifact loads automatically.

```bash
# From inside the AET repo
bash scripts/aet-install.sh

# Target a specific repo
bash /path/to/aet-install.sh --target /path/to/your/repo
```

Review and share only the exact `[aet-install] share:` entries emitted after a
successful repo install. They include manifest files, governed `.github/docs/`
files, `.github/LICENSE`, and `.github/.aet-managed-state`. Do not stage all of
`.github/` or entire directories; review content-pack files separately. See
[installation scope](docs/installer-release-contracts.md#installation-scope).

### Option B — Personal VS Code Install

`--global` installs into `~/.aet/` for one developer who wants the same AET
customizations across workspaces in the VS Code extension host. After running,
add the printed locations to your VS Code user settings:

```bash
bash scripts/aet-install.sh --global
```

This destination is not a native user-skill location. Copilot discovers user
skills in `~/.copilot/skills/`, not `~/.aet/skills/`; manual skill discovery is
therefore not provided by `--global`. Required AET workflows still read skills
from their bundle root. Do not add deprecated `chat.agentSkillsLocations` as new
setup. The printed agent/instruction settings are extension-host only; Agent
Host and CLI do not use that editor setup. Global updates affect every workspace
using the configured locations. Do not combine active global AET locations with a
repo-local install because duplicate customization-name precedence is
undocumented.

### Preview First

```bash
bash scripts/aet-install.sh --dry-run           # Option A preview
bash scripts/aet-install.sh --global --dry-run  # Option B preview
```

### Options

| Option | Description |
|---|---|
| `--global` | Install into `~/.aet/` for personal VS Code extension-host use |
| `--target DIR` | Repo root for repo install (default: current directory) |
| `--force` | Overwrite changed engine files; still aborts on unmanaged collisions |
| `--dry-run` | Print planned actions without destination writes; see [standalone temporary-download caveat](docs/installer-release-contracts.md#options) |
| `--content-path DIR` | Merge extra instructions, skills, catalogs, and legacy prompts from DIR |
| `--self` | Maintainers: install the Steward profile into this source clone; see [self mode](docs/installer-release-contracts.md#self-mode) |

See [scripts/README.md](scripts/README.md) for minimal installer usage and
[installer and release contracts](docs/installer-release-contracts.md) for
location settings, scope switching, collisions, and release assets.

Existing prompt-based managed installs require the documented
[manual migration](docs/installer-release-contracts.md#legacy-prompt-migration);
the installer rejects old state without deleting legacy files or user edits.

---

## What You Get

| Artifact | Format | Intended consumer |
|---|---|---|
| Coding standards | `.instructions.md` | Host-supported custom instructions |
| Reusable workflows | `skills/<name>/SKILL.md` | Host-supported skill discovery or required agent reads |
| Optional domain skills | `SKILL.md` | Reviewed CONTENT, not bundled domain policy |
| Validation checklists | `.md` | Manual review or automation gates |
| Custom agents | `.agent.md` | VS Code agent picker |

Use [discovery](skills/discover-workspace-file-knowledge/SKILL.md) and
[extraction](skills/extract-code-knowledge/SKILL.md) to propose CONTENT for the
review path above. Bundled workflow skills are engine; optional domain skills
and project-specific standards are CONTENT, not preinstalled domain knowledge.

---

## The Agent System

AET uses a two-tier agent model. Most users only need the **Orchestrator** for
general project work. The **Steward** is specialized for maintaining AET itself.

### Orchestrators

| Agent | Scope | Use |
|---|---|---|
| **AET Orchestrator** | Current VS Code workspace | Assess, implement, review, and validate project work |
| **AET Steward** | AET source repository | Govern AET, triage proposals, improve the engine |

They share five specialists. Steward adds workflow skill authoring; Orchestrator adds
proposal capture during project work.

### Specialists

| Agent | Role | Routing | Read-Only |
|---|---|---|---|
| `aet-engineering` | Implementation, refactoring | Both | No |
| `aet-validation` | Safety and quality gates | Both | Yes |
| `aet-review` | Correctness review | Both | Yes |
| `aet-documentation` | Docstrings, README, markdown | Both | No |
| `aet-lightweight` | Small tasks with limited context | Both | No |
| `aet-investigator` | Evidence-led diagnosis and impact analysis | Orchestrator | Yes |
| `aet-prompt` | Workflow skill authoring (stable agent name) | Steward | No |
| `aet-proposal` | Project improvement capture | Orchestrator | No |

The portable bundle installed by `aet-install.sh` includes the Orchestrator plus
seven specialists: `engineering`, `validation`, `documentation`, `review`,
`proposal`, `lightweight`, and `investigator`.

**What do specialist roles add?** Explicit task scope, requested procedures,
and handoff contracts. [AET Engineering](agents/aet-engineering.agent.md), for
example, requires applicable guidance, focused implementation, testing, and
escalation of unresolved conflicts. These are instructions, not proof of model
compliance or better runtime results than plain chat. See the
[agent index](agents/README.md) for role owners and availability.

---

## Your Instructions Repo

An optional, separately managed CONTENT repository could organize reviewed
guidance like this:

```text
my-instructions/
  instructions/            # file-scoped guidance after host discovery
    python-style.instructions.md
    testing-style.instructions.md
  skills/                  # host-discovered, on-demand domain knowledge
    pyspark/
      SKILL.md
    aws-lambda/
      SKILL.md
  catalogs/                # named pattern libraries referenced by skills
    pyspark-patterns.md
    pyspark-solutions.md
  README.md
```

**Loading into AI assistants:**

- **Instructions**: configure `chat.instructionsFilesLocations`; `applyTo`
  selects file applicability after host discovery, not discovery itself
- **On-demand skills**: place reviewed skills in the host's native project
  `.github/skills/` or Copilot user `~/.copilot/skills/` location; do not use
  deprecated `chat.agentSkillsLocations` for new setup
- **Other assistants**: inspect host support and supply required dependencies;
  pasting prompt text does not establish equivalent tools or behavior
- **Team sharing**: commit shared standards to a team repo; keep personal preferences in a fork

**Public vs Private:**

- Keep project-specific guidance subject to source policy; KEEP-LOCAL stays local
- Review EXPORT material under the [Public Safety Guide](docs/public-safety.md)
- Require applicable gates and human authorization before sharing or publication

**Synthetic CONTENT example**, not a bundled Python policy:

```markdown
---
applyTo: "**/*.py"
---
- Use snake_case for all function and variable names
- Prefer list comprehensions over explicit loops for simple transformations
- Always include type annotations on public function signatures
- Use `pathlib.Path` instead of `os.path` for file operations
- Raise domain-specific exceptions, not bare `Exception`
```

See [docs/using-aet-on-external-projects.md](docs/using-aet-on-external-projects.md) for a worked example.

---

## Repository Structure

| Folder | Contents | Portable |
|---|---|---|
| `agents/` | Orchestrator, Steward, and specialist agent definitions | Selected |
| `instructions/` | Engine-level instruction files (style, collaboration) | Yes |
| `skills/` | Core reusable workflows (review, extract, gate, propose) | Selected |
| `validation/` | NDA-safety and quality checklists | Yes |
| `scripts/` | Installer and release tooling | No payloads |
| `docs/` | Philosophy, governance, decisions, usage guides | Selected |

The [manifest](scripts/aet-manifest.txt) solely defines portable membership;
directory READMEs and source governance are not a substitute for the installed
dependencies. Do not install isolated agents or copy partial engine directories.

---

## Self-Improvement (Maintainers Only)

The proposal agent is installed with the portable bundle but does not run unless
you explicitly enable proposal capture for the current engagement or workspace.

After opt-in, [AET Proposal](agents/aet-proposal.agent.md) captures observed
engine gaps under the [Route contract](skills/propose-improvement/SKILL.md#prompt).
Humans carry sanitized generic engine EXPORT proposals to toolkit `proposals/`
for [AET Steward](agents/aet-steward.agent.md) review. Project CONTENT follows
source preparation and candidate-fit review instead; it is not toolkit feedback.

---

## Limitations

- AET targets VS Code with GitHub Copilot; this documentation does not establish
  runtime reliability or compatibility with other hosts.
- Bundled instructions require functional engine/content classification; review
  them before reusing them as team defaults.
- Required tools, dependencies, and host discovery must be available for a
  workflow to run; missing capabilities require a stop, not an equivalent-result claim.
- The `aet-proposal` agent is installed by default but proposal capture remains
  off until explicitly enabled.
- Extraction needs grounded source evidence; defer capture when useful
  conventions or solutions are not yet available.

---

## Philosophy

- **Engine vs Content** — separates the extraction workflow (public, generic) from mined rules (personal, private by default)
- **Public-safe** — mandatory safety gates before commit, publication, export, or adoption
- **AI-compatible** — instructions stay explicit and scannable across model
  capabilities; added or changed capability-based routing mappings require
  predeclared, independently reproduced benchmark evidence; unsupported
  mappings may be removed without a benchmark
- **Incremental** — build what is needed now, extend when the need is clear
- **Dogfooded** — AET uses itself to improve itself

See [docs/philosophy.md](docs/philosophy.md) for the full design rationale.

---

## Contributing

Contributions to the engine (agents, skills, validation workflows, scripts) are welcome. Contributions to `instructions/` must be generic, NDA-safe, and broadly applicable — no company-specific or proprietary patterns.

See [CONTRIBUTING.md](CONTRIBUTING.md) and [docs/repository-rules.md](docs/repository-rules.md) before opening a pull request.

---

## Safety

AET source and managed engine artifacts require full public sanitization under
the [Public Safety Guide](docs/public-safety.md#scope). Apply the
[validation criteria](validation/README.md) before adoption or disclosure;
required human review remains separate from technical checks.

---

## Status

Early development. Built incrementally to prioritize clarity, maintainability, and long-term quality. See [docs/philosophy.md](docs/philosophy.md) for the principles behind the design.

---

## License

MIT — see [LICENSE](LICENSE).
