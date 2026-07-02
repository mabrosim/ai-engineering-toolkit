# AI Engineering Toolkit

[![Markdown Lint](https://github.com/mabrosim/ai-engineering-toolkit/actions/workflows/lint.yml/badge.svg)](https://github.com/mabrosim/ai-engineering-toolkit/actions/workflows/lint.yml)

Extract your project's coding standards into reusable instruction files for GitHub Copilot, Cursor, and other AI coding assistants.

---

## The Problem

AI coding assistants generate plausible code but have no memory of your conventions. Every conversation starts cold — your naming rules, error handling patterns, and architectural preferences are invisible to the model. You correct the same things repeatedly.

AET extracts your project's implicit standards into explicit `.instructions.md` files. Once loaded, your AI assistant applies your rules in every conversation, across every project you open.

---

## Who This Is For

- Developers using GitHub Copilot, Cursor, or Windsurf who want consistent, standards-aware AI output
- Teams that want to codify and share coding conventions as loadable AI context
- Developers who want to turn their own tacit expertise into reusable instruction files

---

## Prerequisites

- VS Code with the GitHub Copilot extension (agent mode required)
- Bash (for the install script)
- Optional: Cursor or Windsurf — both support `.instructions.md` format, but the agent picker integration is VS Code-specific

---

## Quick Start

Install AET into your current repository:

```bash
curl -fsSL https://raw.githubusercontent.com/mabrosim/ai-engineering-toolkit/main/scripts/aet-install.sh | bash
```

Or preview before making any changes:

```bash
bash scripts/aet-install.sh --dry-run
```

Then:

1. Open the repo in VS Code
2. Select **AET Orchestrator** from the Copilot agent picker
3. Type `assess this repo`

The orchestrator discovers your project structure, reviews it against built-in standards, and returns a prioritized improvement plan. Nothing changes until you approve a step.

Common follow-up prompts:

```text
Extract rules from src/analytics — add to my instructions repo
Review the analytics proposal and adopt what's useful
Refactor module X — preserve behavior, apply standards
Add docstrings to package Y
Validate this file for public release
```

Each task routes through built-in validation gates. NDA-safety checks run automatically before any output leaves the context.

---

## How It Works

AET runs a five-step workflow through a coordinated set of agents. Extraction never writes a canonical rule directly — it stops at a proposal that has to be reviewed and adopted first:

1. **Discover** — maps your project structure, file types, and theme clusters
2. **Extract** — mines coding rules, naming conventions, and patterns into a review-ready proposal under `.aet/proposals/`
3. **Review** — ask the Orchestrator to review the proposal; it decides adopt, keep local, return, defer, or abandon — nothing becomes canonical without this step
4. **Generate** — on adoption, writes the canonical artifact: an always-on `.instructions.md` file, or a `SKILL.md` loaded only on demand when the task domain matches (cheaper on tokens for narrow, infrequently-needed knowledge)
5. **Validate** — runs the quality gate (NDA-safety, compactness, markdown quality) on the generated artifact

```text
your code
    │
    ▼
 Discover    ── maps project structure and file themes
    │
 Extract     ── mines patterns into a proposal (.aet/proposals/)
    │
 Review      ── adopt / keep local / return / defer / abandon
    │
 Generate    ── writes .instructions.md (always-on) or SKILL.md (on-demand)
    │
 Validate    ── NDA-safety and quality gate
    │
    ▼
.instructions.md / SKILL.md
```

The output is yours to keep private, share with your team, or publish.

---

## The Two-Repo Model

AET keeps the engine separate from your content:

- **This repo (AET)** — the extraction and validation engine: agents, prompts, and workflows. Public, generic, no personal content.
- **Your instructions repo** — mined rules, style guides, and patterns from your own code. Private by default; you decide what to share.

After running AET, you own a separate instructions repository loaded into your AI assistant. Update it as your codebase evolves. Share the full repo or export individual files to colleagues.

See [docs/philosophy.md](docs/philosophy.md) for the design rationale behind this separation.

---

## Installation

### Option A — Per-Repo Install (Default)

Installs into a specific repository's `.github/` folder. VS Code auto-discovers agents and prompts from `.github/` with no extra configuration. Commit the files so your team gets the same agents.

```bash
# From inside the AET repo
bash scripts/aet-install.sh

# Download and run in one step
curl -fsSL https://raw.githubusercontent.com/mabrosim/ai-engineering-toolkit/main/scripts/aet-install.sh | bash

# Target a specific repo
bash /path/to/aet-install.sh --target /path/to/your/repo
```

Installs `AET Orchestrator` plus supporting instructions, prompts, and validation checklists into `.github/`.

### Option B — User-Global Install

Installs once into `~/.aet/` — available in every workspace you open. After running, add the printed path to your VS Code user settings (`Code > Settings > Open User Settings JSON`):

```bash
bash scripts/aet-install.sh --global
```

### Preview First

```bash
bash scripts/aet-install.sh --dry-run           # Option A preview
bash scripts/aet-install.sh --global --dry-run  # Option B preview
```

---

## What You Get

| Artifact | Format | Loads into |
|---|---|---|
| Coding standards | `.instructions.md` | GitHub Copilot, Cursor, Windsurf |
| On-demand domain skills | `.md` (skills) | VS Code agent skill picker |
| Reusable workflows | `.prompt.md` | VS Code chat or any assistant |
| Validation checklists | `.md` | Manual review or automation gates |
| Custom agents | `.agent.md` | VS Code agent picker |

Use AET's own prompts (`discover-workspace-file-knowledge`, `extract-code-knowledge`) to mine your codebase and populate a private instructions repo tailored to your stack.

---

## The Agent System

AET uses a two-tier agent model. Most users only need the **Orchestrator** — it travels with you to any project. The **Steward** stays inside this repo to govern AET itself.

### Orchestrators

| Agent | Scope | Use |
|---|---|---|
| **AET Orchestrator** | External repos | Review, refactor, extract rules from your projects |
| **AET Steward** | This repo only | Govern AET, triage proposals, improve the engine |

Both delegate to the same specialists:

### Specialists

| Agent | Role | Read-Only |
|---|---|---|
| `aet-engineering` | Implementation, refactoring | No |
| `aet-validation` | NDA-safety, public-release gate | Yes |
| `aet-review` | Code review | Yes |
| `aet-documentation` | Docstrings, README, markdown | No |
| `aet-prompt` | Prompt authoring | No |
| `aet-lightweight` | Small tasks, weak-model friendly | No |

The portable bundle installed by `aet-install.sh` includes the Orchestrator plus four core specialists: `engineering`, `validation`, `documentation`, `review`.

**Why a specialist instead of the same model in plain chat?** The underlying LLM doesn't change — the process around it does. `aet-engineering` always loads your exported instructions before writing a line of code, works through a fixed understand → design → implement → test → verify loop instead of freehand generation, matches the conventions already in the surrounding code when no rule applies, and escalates design conflicts instead of forcing a fix through. A plain chat session does none of this by default — you would have to restate your conventions and process every time.

---

## Your Instructions Repo

After using AET on your projects, you accumulate extracted rules in a separate private repository you control:

```text
my-instructions/
  instructions/            # always-on rules (loaded on file-type glob match)
    python-style.instructions.md
    testing-style.instructions.md
  skills/                  # on-demand domain knowledge (loaded when task domain matches)
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

- **Always-on instructions**: add the `instructions/` path to `chat.instructionsFilesLocations` in VS Code settings
- **On-demand skills**: add the `skills/` path to `chat.agentSkillsLocations` in VS Code settings
- **Paste workflows**: open a `.prompt.md` file and paste into any assistant
- **Team sharing**: commit shared standards to a team repo; keep personal preferences in a fork

**Public vs Private:**

- Keep client-specific rules, internal tooling, and proprietary patterns private
- Publish generic language standards and framework best practices
- Run `aet-validation` on any file before publishing to verify NDA-safety

**Example output** — a generated Python style instruction file:

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
| `agents/` | Orchestrator, Steward, and all specialist agent definitions | Bundle |
| `instructions/` | Engine-level instruction files (style, collaboration) | Yes |
| `prompts/` | Core reusable workflows (review, extract, gate, propose) | Yes |
| `validation/` | NDA-safety and quality checklists | Yes |
| `scripts/` | `aet-install.sh` installer | Yes |
| `docs/` | Philosophy, decisions, usage guides | Reference |

**Standalone use:** Copy `instructions/`, `prompts/`, or `validation/` into any project without the rest of AET.

---

## Self-Improvement (Maintainers Only)

AET can improve from real use via an optional feedback loop. External users are unaffected.

Install AET into an external project you work in regularly:

```bash
bash scripts/aet-install.sh --target /path/to/client-project
```

The feedback loop:

1. Work in the external project — select **AET Orchestrator** from the agent picker
2. After each engagement, the Orchestrator delegates to `aet-proposal`
3. `aet-proposal` writes observed gaps to `.aet/proposals/export/` (engine improvements) or `.aet/proposals/local/` (project-specific)
4. Copy `export/` proposals to this repo's `proposals/` folder
5. Switch to this repo — **AET Steward** triages each proposal: adopt, keep local, or discard
6. Improved rules export in the next install

> `--with-proposal` automation is planned but not yet implemented. Install the proposal agent manually if needed.

---

## Limitations

- Designed primarily for VS Code with GitHub Copilot. Cursor and Windsurf support the `.instructions.md` file format, but agent picker integration is VS Code-specific.
- The built-in instruction files in `instructions/` reflect one maintainer's conventions. Fork and replace them for your own team defaults.
- No GUI. All interaction is through the VS Code agent picker or by pasting prompts into a chat window.
- The `aet-proposal` self-improvement loop requires manual setup. It is not included in the default install bundle.
- AET adds the most value once a codebase or convention set exists to extract from. For a brand-new, convention-free project, a plain coding agent is enough — install AET later once patterns emerge worth preserving.

---

## Philosophy

- **Engine vs Content** — separates the extraction workflow (public, generic) from mined rules (personal, private by default)
- **Public-safe** — built-in NDA and safety checks on every output
- **Weak-model friendly** — instructions explicit enough to work on budget models, not only frontier ones
- **Incremental** — build what is needed now, extend when the need is clear
- **Dogfooded** — AET uses itself to improve itself

See [docs/philosophy.md](docs/philosophy.md) for the full design rationale.

---

## Contributing

Contributions to the engine (agents, prompts, validation workflows, scripts) are welcome. Contributions to `instructions/` must be generic, NDA-safe, and broadly applicable — no company-specific or proprietary patterns.

See [CONTRIBUTING.md](CONTRIBUTING.md) and [docs/repository-rules.md](docs/repository-rules.md) before opening a pull request.

---

## Safety

Everything here is public-safe by design. Never commit:

- Company-confidential code, customer data, or internal architecture
- Credentials, secrets, or production configuration
- Proprietary prompts or sensitive business logic

The `aet-validation` agent and checklists in `validation/` enforce this before anything ships.

---

## Status

Early development. Built incrementally to prioritize clarity, maintainability, and long-term quality. See [docs/philosophy.md](docs/philosophy.md) for the principles behind the design.

---

## License

MIT — see [LICENSE](LICENSE).
