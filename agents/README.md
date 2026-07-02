# Agent Definitions

`.agent.md` files loaded by the VS Code agent picker for use in this repository.

| Agent | `user-invocable` | Purpose |
|---|---|---|
| `aet-steward` | true | Governs this repo (inward) |
| `aet-orchestrator` | true | Improves external projects (outward, export) |
| `aet-proposal` | false | Capture engine improvements during external engagements (invoked by Orchestrator) |
| `aet-engineering` | false | Implementation and refactoring |
| `aet-validation` | false | NDA/quality gate |
| `aet-review` | false | Code review |
| `aet-documentation` | false | Docs and markdown |
| `aet-prompt` | false | Prompt authoring |
| `aet-lightweight` | false | Small, weak-model-safe tasks |

The installer (`scripts/aet-install.sh`) copies `aet-orchestrator`
and the portable specialists (`aet-engineering`, `aet-validation`,
`aet-documentation`, `aet-review`, `aet-proposal`, `aet-lightweight`) into a target repo.
