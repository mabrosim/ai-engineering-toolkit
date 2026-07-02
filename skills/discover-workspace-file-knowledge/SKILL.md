---
description: "Scan a black-box workspace and propose file-card metadata for downstream agents."
name: discover-workspace-file-knowledge
user-invocable: true
disable-model-invocation: false
---

# Discover Workspace File Knowledge

## Invocation and ownership

Activate only for requested discovery or an explicitly required discovery step
in another AET workflow. AET Orchestrator owns standalone discovery; AET Proposal
may execute a delegated capture within its existing opt-in and write limits.
Run inline in either authorized owner; otherwise route through AET Orchestrator.
If the required owner is unavailable, stop and report degraded capability.
Never self-delegate. Reusing the nonwriting discovery steps does not authorize
proposal capture or writes. Skill text supplies no tool sandbox.

Inspect a software workspace as a black box and produce reusable file-card metadata for downstream processing.
The workspace may contain any language, framework, file structure, generated artifact, notebook, script, config, documentation, data-as-code file, or domain convention.
Do not assume technologies, domains, file types, layouts, naming conventions, or project purpose.
Do not change project source or configuration. The CONTENT proposal under
`.aet/proposals/` is the only permitted write.

## Purpose

Build a reliable workspace map for later agents and skills.
Output project-local discovery CONTENT describing file populations, file-card
schema, candidate file rules, adaptive read-depth rules, exclusions, safety
notes, and downstream consumers. This is not a generic engine proposal.
The proposal is not adoption; review it later with
[Proposal Review](../review-proposal/SKILL.md).

## Principles

- Discover first; classify second.
- Treat filenames and directories as weak hints.
- Prefer content evidence over naming evidence.
- Keep structure, content tags, dependency profile, complexity, utility, and safety separate.
- Use adaptive reading; do not deep-read everything by default.
- Never ignore long files only because they are long.
- Never classify solely from one signal.
- Report ambiguity instead of guessing.
- Produce metadata useful for downstream work, not labels only.

## File-card schema

```yaml
file_card:
  path_pattern: "<path or glob>"
  representative_files: []
  extension: "<extension or none>"
  language_or_format: "unknown | detected value"
  size_class: "tiny | small | medium | large | huge"
  complexity_class: "simple | modular | dense | all-in-one | generated-like | data-heavy | mixed | unknown"
  read_strategy: "metadata-only | head-tail | symbol-map | sampled-sections | full-read"
  structure_type: "<one primary structure label>"
  content_tags: []
  dependency_profile: []
  execution_context: "imported | runnable | generated | config | documentation | data | test | notebook | unknown"
  vintage: "legacy-handwritten | mixed | modern-tooled | generated | unknown"
  utility: "extract | keep | refactor | archive | delete-candidate | documentation | no-action | unknown"
  downstream_candidates: []
  safety_notes: []
  confidence: "high | medium | low"
  ambiguity_notes: []
```

Use `unknown` when evidence is missing.
Do not force unsupported fields.

## Procedure

### 0. Anchor investigation

State workspace scope, why file-card metadata is needed, and intended downstream
consumers. Use only the
[canonical consumer values](../propose-improvement/SKILL.md#content-workflow-exception).
If unknown, assume `implementation
workflow`, `refactoring workflow`, `architecture workflow`, `review workflow`,
and `proposal workflow`.

### 1. Inventory without body reads

Collect cheap metadata first: path, extension, byte size, line count if cheap, modified time if available, directory group, generated/vendor/archive/cache indicators.
Exclude dependency and build noise before classification:

- `**/.git/**`
- `**/.venv/**`, `**/venv/**`, `**/env/**`
- `**/node_modules/**`, `**/site-packages/**`
- `**/__pycache__/**`, `**/.pytest_cache/**`, `**/.mypy_cache/**`, `**/.ruff_cache/**`
- `**/.ipynb_checkpoints/**`
- `**/build/**`, `**/dist/**`, `**/*.egg-info/**`
- clearly external generated lock/vendor folders
Report raw, excluded, and effective counts; count by extension and top-level directory.
If tools cap results, mark counts as capped; never extrapolate exact totals.

### 2. Cheap fingerprint pass

For each effective file or representative cluster, collect extension, shebang/frontmatter, first/last meaningful lines, syntax markers, comment density, generated patterns, large literal/data blocks, dependency/import/include declarations, entrypoint markers, test markers, config keys, markdown headings, notebook/cell markers, minified/bundled markers, license/SPDX headers, local path/environment assumptions, and binary/unreadable status.
Language-specific signals are allowed only when discovered from content.

### 3. Adaptive read-depth decision

Choose read strategy before deep reading:

- `metadata-only`: obvious binary, vendor, generated, dependency, cache, lockfile, or irrelevant artifact.
- `head-tail`: docs, config, simple markup, large generated-like files, or low-value files.
- `symbol-map`: source-like files mappable from declarations, headings, keys, selectors, exports, imports, anchors, or sections.
- `sampled-sections`: large or dense files with multiple internal regions.
- `full-read`: tiny/small files, ambiguous files, representative samples, high-value files, or files needing full context.
Do not skip large files solely due to length.
For large files, build a skeleton first, then read targeted sections.

### 4. Build preliminary file cards

Create file cards for high-value files and clusters for repeated low-risk files.
Classify on separate axes: structure, content tags, dependency profile, complexity, vintage, utility, and safety.

### 5. Cluster by evidence

Cluster by observed signals, not preset categories: extension/syntax, structure markers, content tags, dependency profile, execution context, complexity class, utility/disposition, safety concerns, downstream fit.
Do not let one axis override another.

For each candidate extraction theme — a library, framework, or cross-cutting concern — record where it appears: which clusters or files contain it and its rough density. A single theme often spans several clusters; capture that spread. For `mixed` files, list the co-occurring libraries or languages rather than labelling by the dominant one alone.

### 6. Derive candidate rules

For each meaningful cluster, propose rules only with enough evidence.
Each rule must include distinguishing signals, minimal detector, false-positive risks, disambiguation, populated metadata fields, confidence, downstream consumer, and route.
Hold weak or sub-threshold patterns as outliers.

### 7. Downstream consumer mapping

Assign only canonical intended-consumer values from
[Propose Improvement](../propose-improvement/SKILL.md#content-workflow-exception):
`implementation workflow`, `review
workflow`, `refactoring workflow`, `architecture workflow`, `validation
workflow`, `proposal workflow`, `core agent`, or `none`. Describe specific
uses, such as extraction, test review, documentation, safety validation, or
archive triage, separately from the intended-consumer value.

When routing to [Extract Code Knowledge](../extract-code-knowledge/SKILL.md), pass the theme-presence map and flag secondary or orphan themes - libraries pervasive across files but never the dominant one - as candidate extraction themes in their own right.

### 8. Route the proposal draft

Apply the routing and public-safety rules in
[Propose Improvement](../propose-improvement/SKILL.md). Default to `KEEP-LOCAL` because paths,
clusters, and workspace metadata are source-bound. Use `EXPORT` only for fully
sanitized, reusable classification rules that do not disclose source identity
or structure. Record the route without recommending adoption.

### 9. Write proposal

Write one proposal under `.aet/proposals/export/` or `.aet/proposals/local/`.
Inspect existing proposals first; refine matching proposals instead of duplicating.

## Expected proposal format

This schema is authoritative for
`Workflow: workspace-file-knowledge-discovery` CONTENT proposals.

```md
# Proposal: Workspace file-card classification rules for {generic project}
- Workflow: workspace-file-knowledge-discovery
- Content class: CONTENT
- Type: catalog | instruction
- Route: EXPORT | KEEP-LOCAL
- Topic: {investigation topic}
- Corpus: {raw count, excluded count, effective count, scan method}
- Candidate owner: content catalog | content instruction
- Suggested destination: project-local content catalog | project-local content
  instruction | content-pack catalog | content-pack instruction
- Intended consumer: implementation workflow | review workflow |
  refactoring workflow | architecture workflow | validation workflow |
  proposal workflow | core agent | none
## Scan contract
- Scope:
- Assumptions:
- Exclusions:
- Read strategy:
## Inventory summary
- Raw files:
- Excluded files:
- Effective files:
- Main extensions:
- Main directories:
## File-card schema
{schema or schema changes proposed}
## File clusters
### {cluster-name}
- Defining signals:
- Detector:
- Metadata populated:
- Common content tags:
- Typical complexity:
- Typical utility:
- Downstream consumers:
- Evidence:
- Confidence:
## Theme presence map
### {theme or library}
- Role: primary | secondary | orphan
- Appears in clusters:
- Density:
- Co-occurring themes:
- Extraction contexts to cover:
## Adaptive read-depth rules
### {rule-name}
- Applies when:
- Read strategy:
- Reason:
- False positives:
## Downstream routing rules
### {consumer-name}
- Receives files when:
- Uses metadata fields:
- Exclusions:
## Safety and routing notes
- EXPORT-safe notes:
- KEEP-LOCAL notes:
- NDA/public-safety concerns:
## Name-content mismatches
- {path or pattern} — name suggests {X}, content suggests {Y}
## Outliers and ambiguity
- {path or pattern} — {why unresolved}
```

## Notes

- Length exception: portable adaptive discovery and its file-card/output schema
  must remain self-contained for installed agents.
- Discover metadata; do not refactor.
- Write proposals; do not adopt them.
- Source review may only `ABANDON`, `DEFER`, or `PREPARE`; adoption happens only
  through candidate-fit review.
- Keep evidence compact and safe.
- Prefer reusable rules over exhaustive file listings.

---

## Canonical references

- [skills/extract-code-knowledge/SKILL.md](../extract-code-knowledge/SKILL.md) - primary downstream consumer; use file-card metadata and proposed themes to scope and drive extraction
- [skills/propose-improvement/SKILL.md](../propose-improvement/SKILL.md) — proposal routing and public-safety owner
- [skills/review-proposal/SKILL.md](../review-proposal/SKILL.md) - adoption and governance owner
- [validation/nda-safety-checklist.md](../../validation/nda-safety-checklist.md) — mandatory gate before any EXPORT proposal
