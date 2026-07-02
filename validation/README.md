# Quality & Safety Validation Rules

## Purpose

Index criteria for safety, correctness review, and final output validation.

## Usage

```text
Review this completed change, then validate it using the complete Review packet.
```

[AET Review](../agents/aet-review.agent.md) owns correctness;
[AET Validation](../agents/aet-validation.agent.md) aggregates its evidence.
Their procedures are [Code Review](../skills/code-review/SKILL.md) and
[Quality Gate](../skills/quality-gate/SKILL.md), respectively.

## Requirements

Resolve [artifact scope](../docs/public-safety.md#scope) and apply safety checks
before other checks. Correctness-bearing changes require a complete owner
handoff under [implementation readiness](../agents/aet-orchestrator.agent.md#approach),
then Review before Validation.

Installed workflows require the complete [manifest bundle](../scripts/aet-manifest.txt),
not isolated checklists.

## Rules

| Owner | Criteria |
|---|---|
| [AI Output Validation](ai-output-validation.md) | Correctness aggregation, result precedence, human-review states |
| [Code Review Rules](code-review-rules.md) | Correctness and technical mergeability |
| [Compactness Rules](compactness-rules.md) | Concision and artifact limits |
| [Gate Report Contract](gate-report-contract.md) | Finding syntax, packet validity, and consumer behavior |
| [Markdown Quality Rules](markdown-quality-rules.md) | Semantic accuracy, organization, links, and presentation |
| [NDA Safety Checklist](nda-safety-checklist.md) | Baseline and applicable public sanitization |
| [Public Release Checklist](public-release-checklist.md) | Publication readiness |

## Notes

[Repository tooling](../.markdownlint-cli2.yaml) owns mechanical Markdown
enforcement; semantic Markdown quality is a separate check, not formatter output.
Lint success is not gate approval; technical results do not replace required
human review or disclosure authorization.
