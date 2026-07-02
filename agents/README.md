# Agent Definitions

## Purpose

Index AET roles; each agent definition owns its constraints and procedure.

## Usage

After installation, select **AET Orchestrator** and request:

```text
Assess this repo without changing files.
```

Use **AET Steward** for inward AET maintenance; the other roles are delegated
specialists, not user-invocable picker entries.

## Requirements

Install the complete [manifest bundle](../scripts/aet-manifest.txt), including
supporting skills, instructions, validation rules, and portable governance.
Do not copy isolated agent files.

The host must discover installed locations and provide required tools; follow
[installation scope](../docs/installer-release-contracts.md#installation-scope).

## Agents

| Agent | Responsibility | Scope |
|---|---|---|
| [AET Orchestrator](aet-orchestrator.agent.md) | Coordinates current-workspace work | Portable |
| [AET Steward](aet-steward.agent.md) | Governs AET source | Source-only |
| [AET Engineering](aet-engineering.agent.md) | Implementation and authorized runtime evidence | Portable |
| [AET Investigator](aet-investigator.agent.md) | Read-only diagnosis and impact analysis | Portable |
| [AET Review](aet-review.agent.md) | Read-only correctness review | Portable |
| [AET Validation](aet-validation.agent.md) | Read-only safety and gate aggregation | Portable |
| [AET Documentation](aet-documentation.agent.md) | Semantic documentation and docstrings | Portable |
| [AET Lightweight](aet-lightweight.agent.md) | Bounded, low-risk mechanical or factual tasks | Portable |
| [AET Proposal](aet-proposal.agent.md) | Opt-in engine proposal capture | Portable |
| [AET Prompt](aet-prompt.agent.md) | Workflow skill authoring | Source-only |

## Notes

Roles specify requested process, not proven runtime or model advantages.
Follow the [source bootstrap](../AGENTS.md) for AET maintenance; source-only
governance does not travel with the installed engine.
