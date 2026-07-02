---
description: "Scan a black-box workspace and propose file-card metadata for downstream agents."
agent: "AET Orchestrator"
---

## Discover Workspace File Knowledge Prompt

Inspect a software workspace as a black box and produce reusable file-card metadata for downstream processing.
The workspace may contain any language, framework, file structure, generated artifact, notebook, script, config, documentation, data-as-code file, or domain convention.
Do not assume technologies, domains, file types, layouts, naming conventions, or project purpose.
Change nothing. Read-only only.

### Purpose

Build a reliable workspace map for later agents and prompts.
Output a Markdown proposal under `.aet/proposals/` describing file populations, file-card schema, candidate file rules, adaptive read-depth rules, exclusions, safety notes, and downstream consumers.
The proposal is not adoption; review it later with proposal-review workflow.

### Principles

- Discover first; classify second.
- Treat filenames and directories as weak hints.
- Prefer content evidence over naming evidence.
- Keep structure, content tags, dependency profile, complexity, utility, and safety separate.
- Use adaptive reading; do not deep-read everything by default.
- Never ignore long files only because they are long.
- Never classify solely from one signal.
- Report ambiguity instead of guessing.
- Produce metadata useful for downstream work, not labels only.

### File-card schema

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

### Procedure

#### 0. Anchor investigation

State workspace scope, why file-card metadata is needed, and intended downstream consumers.
If unknown, assume extraction, refactoring, test-mining, documentation, and proposal-review workflows.

#### 1. Inventory without body reads

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

#### 2. Cheap fingerprint pass

For each effective file or representative cluster, collect extension, shebang/frontmatter, first/last meaningful lines, syntax markers, comment density, generated patterns, large literal/data blocks, dependency/import/include declarations, entrypoint markers, test markers, config keys, markdown headings, notebook/cell markers, minified/bundled markers, license/SPDX headers, local path/environment assumptions, and binary/unreadable status.
Language-specific signals are allowed only when discovered from content.

#### 3. Adaptive read-depth decision

Choose read strategy before deep reading:

- `metadata-only`: obvious binary, vendor, generated, dependency, cache, lockfile, or irrelevant artifact.
- `head-tail`: docs, config, simple markup, large generated-like files, or low-value files.
- `symbol-map`: source-like files mappable from declarations, headings, keys, selectors, exports, imports, anchors, or sections.
- `sampled-sections`: large or dense files with multiple internal regions.
- `full-read`: tiny/small files, ambiguous files, representative samples, high-value files, or files needing full context.
Do not skip large files solely due to length.
For large files, build a skeleton first, then read targeted sections.

#### 4. Build preliminary file cards

Create file cards for high-value files and clusters for repeated low-risk files.
Classify on separate axes: structure, content tags, dependency profile, complexity, vintage, utility, and safety.

#### 5. Cluster by evidence

Cluster by observed signals, not preset categories: extension/syntax, structure markers, content tags, dependency profile, execution context, complexity class, utility/disposition, safety concerns, downstream fit.
Do not let one axis override another.

For each candidate extraction theme — a library, framework, or cross-cutting concern — record where it appears: which clusters or files contain it and its rough density. A single theme often spans several clusters; capture that spread. For `mixed` files, list the co-occurring libraries or languages rather than labelling by the dominant one alone.

#### 6. Derive candidate rules

For each meaningful cluster, propose rules only with enough evidence.
Each rule must include distinguishing signals, minimal detector, false-positive risks, disambiguation, populated metadata fields, confidence, downstream consumer, and route.
Hold weak or sub-threshold patterns as outliers.

#### 7. Downstream consumer mapping

Map metadata to consumers:

- `extract-code-knowledge`: snippets, conventions, APIs, patterns
- `refactor`: all-in-one files, legacy style, duplication, dead code
- `test-generation`: tests, fixtures, gaps, assertions
- `documentation`: README, architecture, runbooks, ADRs, docs-as-code
- `security-validation`: secrets, unsafe config, sensitive content
- `nda-safety-review`: export/public-release candidates
- `archive-cleanup`: stale, duplicate, generated, backup, obsolete files
- `no-action`: low-value or external artifact
When routing to `extract-code-knowledge`, pass the theme-presence map and flag secondary or orphan themes — libraries pervasive across files but never the dominant one — as candidate extraction themes in their own right.
ADOPT recommendations require at least one named downstream consumer.

#### 8. Route safely

Use EXPORT for generic, public-safe metadata rules.
Use KEEP-LOCAL for project-specific naming, proprietary conventions, internal URLs, internal frameworks, or sensitive context.
When unsure, use KEEP-LOCAL.
Never include secrets, customer data, private URLs, credentials, or proprietary literals in EXPORT proposals.

#### 9. Write proposal

Write one proposal under `.aet/proposals/export/` or `.aet/proposals/local/`.
Inspect existing proposals first; refine matching proposals instead of duplicating.

### Expected proposal format

```md
# Proposal: Workspace file-card classification rules for {generic project}
- Type: rule | instruction | catalog | validation | prompt
- Route: EXPORT | KEEP-LOCAL
- Topic: {investigation topic}
- Corpus: {raw count, excluded count, effective count, scan method}
- Suggested destination: instructions/ | content-repo | prompt | agent | discuss
- Intended consumer: {prompt, agent, instruction, validation, reviewer, or none}
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
- Route:
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
- Route:
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
## Triage hint
- ADOPT | LOCAL | RETURN | DISCARD per rule — and why.
- If ADOPT: name instruction/rule file and downstream consumer.
```

### Notes

- Discover metadata; do not refactor.
- Write proposals; do not adopt them.
- Adoption happens through proposal review.
- Keep evidence compact and safe.
- Prefer reusable rules over exhaustive file listings.

---

## Canonical references

- `prompts/extract-code-knowledge.prompt.md` — primary downstream consumer; use file-card metadata and proposed themes to scope and drive extraction
- `validation/nda-safety-checklist.md` — mandatory gate before any EXPORT proposal
