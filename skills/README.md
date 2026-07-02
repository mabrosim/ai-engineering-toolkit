# Workflow Skills

Index reusable workflows; each skill owns its inputs, outputs, and dependencies.

## Usage

Invoke a discovered skill (for example, `/assess-project`), or ask
**AET Orchestrator**: `Extract reusable error-handling knowledge from this module.`

## Requirements

Install the complete [manifest bundle](../scripts/aet-manifest.txt) and satisfy
[host setup](../docs/installer-release-contracts.md#installation-scope).
Skill text alone does not supply tools, specialists, or referenced rules.
Reevaluate Toolkit is source-only and requires the [source bootstrap](../AGENTS.md).

## Skills

| Owner | Use |
|---|---|
| [Assess Project](assess-project/SKILL.md) | Nonwriting project assessment |
| [Code Review](code-review/SKILL.md) | Correctness review procedure |
| [Commit Message](commit-message/SKILL.md) | Draft a commit message |
| [Discover Workspace File Knowledge](discover-workspace-file-knowledge/SKILL.md) | File cards and discovery CONTENT proposals |
| [Extract Code Knowledge](extract-code-knowledge/SKILL.md) | Evidence-grounded CONTENT proposals |
| [Generate Architecture Doc](generate-architecture-doc/SKILL.md) | Architecture reference or overview |
| [Generate Instruction](generate-instruction/SKILL.md) | Accepted GENERIC-ENGINE instruction drafting only |
| [NDA Safety Review](nda-safety-review/SKILL.md) | Applicable safety review |
| [Propose Improvement](propose-improvement/SKILL.md) | Opt-in engine capture and canonical Route contract |
| [Quality Gate](quality-gate/SKILL.md) | Final validation procedure |
| [Review Proposal](review-proposal/SKILL.md) | Engine review, source PREPARE, and candidate-fit review |
| [Reevaluate Toolkit](reevaluate-toolkit/SKILL.md) | Explicitly requested source-only toolkit audit |

## Notes

All skills are manually invocable. Commit Message, Generate Architecture Doc,
and Reevaluate Toolkit disable model invocation. Other skills permit loading
for explicit requests or required owning-workflow steps, preserving automatic
assessment, gates, and opted-in capture.

Existing agents load required `SKILL.md` procedures by direct read from their
selected bundle root without native discovery or agent `skills` frontmatter.
Reading policy is not permission to execute. Owners run inline; other agents
route or stop if ownership or required boundaries are unavailable.
Do not use forked context or assume skill prose restricts tools.

Discovery owns [adaptive read depth](discover-workspace-file-knowledge/SKILL.md#3-adaptive-read-depth-decision),
including ambiguous, high-value, and full-context reads. Architecture reuses only
nonwriting steps 1-5; standalone discovery/extraction retain CONTENT proposal writes.
Project-specific instruction authoring follows CONTENT review, not Generate Instruction.
