# Engine Instruction Files

## Purpose

Index generic instructions governing AET-assisted work and artifact authoring.

## Usage

For a Markdown edit, apply documentation guidance alongside applicable `**` rules:

```text
Update this README using the applicable documentation instructions.
```

## Requirements

Install the complete [manifest bundle](../scripts/aet-manifest.txt); instruction
files rely on supporting governance and validation rules.

The host must first discover configured instruction locations; see
[installation scope](../docs/installer-release-contracts.md#installation-scope).
`applyTo` selects file applicability after discovery, not automatic loading or
guaranteed compliance.

## Instructions

| Owner | `applyTo` | Purpose |
|---|---|---|
| [AI Collaboration Rules](ai-collaboration-rules.instructions.md) | `**` | Execution, review, safety, and evidence |
| [Communication Style](communication-style.instructions.md) | `**` | Terse technical chat output |
| [Documentation Style](documentation-style.instructions.md) | `**/*.md` | Documentation and docstring conventions |

## Notes

Classify rules by function, not directory placement, under the
[engine/content boundary](../docs/philosophy.md#engine-vs-content).
Personal, language, and domain conventions belong in separately reviewed CONTENT;
`--content-path` installation does not replace proposal review or adopt drafts.
