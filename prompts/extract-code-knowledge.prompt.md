---
description: "Interactively mine reusable code knowledge from a project into NDA-safe catalogs, instruction candidates, refactoring rules, or local guidance."
agent: "AET Orchestrator"
---
# Extract Code Knowledge Prompt

Use this prompt to mine reusable code knowledge from a software project.

The project may contain any language, framework, platform, file structure,
library, notebook format, script style, test style, generated artifact, or
domain-specific convention.

Do not assume specific technologies, domains, file types, libraries, platforms,
or workspace conventions. Discover the relevant scope and extraction theme at
runtime.

The output is a Markdown proposal under `.aet/proposals/`.

Change no project source files.

---

## Purpose

Extract reusable engineering knowledge from observed project evidence.

The extracted knowledge may become:

- a patterns catalog (recurring idioms)
- a solutions catalog (rare, complex, or hard-won one-offs)
- a themed Copilot instruction file
- a refactoring rule pack
- a style or convention proposal
- an architecture or building-block catalog
- a project-local guidance file
- a discovery report for future extraction work

---

## Core principle

Do not start by assuming what matters.

First discover what evidence exists, then ask or infer what kind of reusable
knowledge should be extracted.

Possible extraction themes include, but are not limited to:

- recurring implementation snippets
- library or framework usage
- data transformations
- API/client usage
- file I/O
- configuration handling
- validation logic
- error handling
- logging
- test patterns
- setup or initialization idioms
- notebook-to-module refactoring candidates
- duplicated logic
- coding style conventions
- architecture building blocks
- domain helper patterns
- generated-code cleanup patterns
- modernization candidates
- migration candidates
- anti-patterns and replacements

These are examples only. The user's requested theme wins.

---

## Interaction

Always wait for explicit user direction before extracting. Do not begin
extraction until the user has either named a theme or replied `auto-discover`.
This confirmation turn is mandatory even when a theme seems obvious.

If the theme is missing, present the choice and stop for the user's answer:

> What kind of reusable code knowledge should I extract?
> Examples: recurring snippets, library usage, style conventions, refactoring
> candidates, test patterns, data-processing operations, API usage, duplicated
> logic — or reply `auto-discover` to have me infer the strongest themes.

If the user named a theme, restate it and the assumed scope in one line before
proceeding.

Also confirm the selection basis when it is unclear:

> Should I capture recurring patterns (repeated idioms), unique solutions
> (rare, complex, or hard-won one-offs), or both? Default is both.

Recurring and unique knowledge route to different catalogs: `{theme}-patterns`
for repeated idioms, `{theme}-solutions` for rare or complex one-offs. Do not
discard a unique, high-value block only because it appears once.

If the user says `auto-discover`, inspect available project evidence and infer
the strongest extraction themes.

If the user provides a theme but not an output shape, choose the most useful
default:

- recurring implementation logic → patterns catalog
- unique or hard-won one-off solutions → solutions catalog
- coding conventions → instruction proposal
- duplicated or outdated patterns → refactoring rule proposal
- structural observations → architecture or building-block catalog
- uncertain or mixed evidence → discovery proposal with candidate themes

Ask at most one clarification question at a time. The theme-vs-`auto-discover`
choice always requires a user answer; for lesser choices, if a reasonable
default exists, state the assumption and proceed.

---

## Evidence discovery

Before deep-reading files, look for project-level evidence.

Use whatever exists. Do not require any specific file.

Possible evidence sources:

- file tree or manifest
- existing file classification rules
- existing proposals
- README or architecture documentation
- package, build, or dependency files
- source file names and extensions
- imports, includes, or dependency declarations
- test directories and test markers
- notebook markers
- generated-file markers
- entry points
- scripts
- previous analysis results
- user-provided examples

If existing classification rules are present, use them as hints, not as fixed
truth.

If no classification rules exist, derive lightweight temporary categories from
observable signals such as path, extension, imports, headers, entry points, test
markers, dependency declarations, or repeated naming patterns.

---

## Procedure

Mine reusable code knowledge from the project. Change nothing.

### 0. Establish extraction contract

Determine:

- `theme`: what kind of knowledge to extract
- `selection_basis`: `recurring` (repeated idioms), `unique` (rare, complex, or
  hard-won one-offs), or `all` (both). Default `all`.
- `scope`: what files or areas may contain relevant evidence
- `output_shape`: patterns catalog, solutions catalog, instruction proposal,
  refactoring rule pack, architecture catalog, discovery report, or mixed proposal
- `route`: EXPORT or KEEP-LOCAL
- `safety_level`: public-safe, project-local, or unknown
- `consumer`: who will use the extracted knowledge, if known

If any item is unclear and materially changes the result, ask one concise
clarifying question. Otherwise proceed with explicit assumptions.

---

### 1. Discover candidate scope

Use a cheap first pass to narrow the project.

Do not deep-read every file unless the project is small.

Look for files likely to contain the requested theme using generic signals:

- names and paths
- extensions
- imports or dependencies
- file headers
- function, method, class, or symbol names
- decorators or annotations
- entry points
- test markers
- notebook or script markers
- repeated terms
- generated, archive, debug, backup, or copy indicators
- existing classification tags, if available

Classify files only as much as needed for this extraction.

Use temporary neutral labels such as:

- candidate
- strong-candidate
- weak-candidate
- exclude
- archive-or-copy
- generated
- test-like
- notebook-like
- script-like
- library-like
- configuration-like
- data-like
- unknown

If richer project labels already exist, use them, but do not bake them into this
prompt.

---

### 2. Ask or infer scoping choices

If the candidate set is too broad, ask the user to choose one narrowing option.

Example:

> I found several possible areas for this theme. Should I focus on:
> A) active source files, B) tests, C) notebooks/scripts,
> D) archived or duplicate code, E) everything relevant?

If the answer is not available, prefer active, reusable, non-generated,
non-archive files.

---

### 3. Collect candidate knowledge units

Within the scoped files, identify complete reusable knowledge units.

A knowledge unit may be:

- a function
- a method
- a class pattern
- a cohesive block of statements
- a notebook cell or cell sequence
- an expression chain
- a configuration idiom
- an import/setup idiom
- a test fixture or assertion style
- a repeated error-handling pattern
- a validation rule
- a data structure used as code
- a repeated API call pattern
- a transformation pipeline
- a small architectural component
- a recurring anti-pattern and its replacement
- a style convention with enough evidence to standardize

A unit qualifies on either axis — do not require recurrence:

- **Recurrence value**: repeated in multiple places or canonical within the project.
- **Intrinsic value**: complex, rare, non-obvious, costly to rediscover, or easy
  to get subtly wrong, even when it appears only once.

Honor `selection_basis`: under `recurring` keep repeated units; under `unique`
keep high intrinsic-value one-offs; under `all` keep both and tag each unit's basis.

A single occurrence is sufficient evidence for a unique, high-value solution.
Drop only isolated trivial lines that carry neither recurrence nor intrinsic value.

Also apply these sweeps so high-value units are not missed:

- **Gotcha sweep**: flag single calls whose behavior hinges on a non-default
  argument or non-obvious semantics — a flag that changes null or empty
  handling, one that switches unit, encoding, or precision, or a required
  prepare-before-use step. These one-line idioms are often the highest value
  per line.
- **Decompose composites**: when a high-value unit is a container — a custom
  class, a large function, or a long pipeline — also extract its constituent
  reusable sub-idioms as separate units, not only the container.
- **Mixed-file rule**: extract the requested theme's idioms even inside files
  dominated by another library or language. Never skip a file because its
  dominant technology differs from the theme.

---

### 4. Cluster by purpose

Group candidate units by what they accomplish, not by exact syntax.

For each cluster, infer:

- purpose
- context where it appears
- inputs and outputs
- trigger or applicability condition
- common variations
- dependencies
- surrounding assumptions
- replacement opportunity, if any
- whether it is reusable outside this project
- whether it should remain project-local

Merge near-duplicates. Keep variants only when they teach materially different
usage. Unique, high intrinsic-value solutions need no recurrence to be retained;
do not drop them for lack of a cluster.

Before finishing, run a coverage check:

- Enumerate the distinct usage contexts where the theme appears — for example
  analysis vs. ETL vs. serving, or different subsystems. Confirm at least one
  unit per context, or record an explicit "no reusable unit here" note. Do not
  let one dense context crowd out the others.
- Note recurring idioms from co-occurring libraries or concerns adjacent to the
  theme. Record these as candidate follow-up themes.

---

### 5. Generalize safely

Before proposing anything for export, remove sensitive or project-specific
details.

Replace real names and values with neutral placeholders, including:

- project names, customer names, people names
- internal services, repositories, URLs
- table names, field names, file paths
- bucket or container names, account IDs
- tokens or credentials
- business-specific literals, proprietary labels
- internal package names (unless the proposal is KEEP-LOCAL)

Use placeholders such as `{project}`, `{service}`, `{resource}`, `{path}`,
`{identifier}`, `{threshold}`, `{config_key}`, `{input}`, `{output}`,
`{domain_value}`, `source`, `target`, `client`, `record`, `result`.

If a unit loses its meaning after scrubbing, route it KEEP-LOCAL.

If a unit contains secrets or credentials, describe only the safe remediation or
pattern — never include the secret value.

---

### 6. Normalize into teaching form

Rewrite each retained unit into a clear, minimal, reusable example.

Preserve the idea, not accidental project complexity.

Each example should include:

- short name
- one-line intent
- classification tag
- applies-when trigger
- generic code, pseudocode, or instruction
- notes on variations
- optional anti-pattern it replaces

If exact code would be unsafe or too project-specific, provide pseudocode or
instructional guidance instead.

---

### 7. Decide output shape

Choose the shape that best fits the theme.

- **Patterns catalog** (`{theme}-patterns`) — recurring code fragments or operations
- **Solutions catalog** (`{theme}-solutions`) — rare, complex, or hard-won one-off solutions
- **Instruction proposal** — coding style, conventions, or agent guidance
- **Refactoring rule proposal** — repeated anti-patterns, duplication, legacy idioms
- **Architecture or building-block catalog** — reusable components, entry-point patterns, pipeline stages
- **Discovery report** — broad or uncertain theme; main value is identifying candidate directions

---

### 8. Route proposal

Use EXPORT when the extracted lesson is broadly reusable and can be made
public-safe.

Use KEEP-LOCAL when the lesson depends on project-specific architecture,
internal naming, proprietary conventions, sensitive data, or non-public context.

When unsure, prefer KEEP-LOCAL.

---

### 9. Need-gate extracted knowledge

Before recommending adoption, confirm a plausible future consumer exists.

A knowledge unit is ADOPT when a plausible future consumer could route, gate,
suggest, refactor, validate, or instruct based on it. The core engine holds no
advance knowledge of content; catalogs and themed instructions are built for
later use by any loading agent — review, refactoring, architecture, or the core
agent. A generic future consumer is sufficient; do not require a named, existing one.

Mark a unit LOCAL only when reuse is implausible, or RETURN/DISCARD when it has no
practical value.

---

### 10. Avoid duplicates

Before writing, inspect existing `.aet/proposals/`.

If a similar proposal exists, refine it instead of creating a duplicate.

Write one proposal per coherent concept or theme.

---

## Catalog artifact

A catalog holds reusable code keyed by an `Applies when` trigger — not style rules.
Two types per theme (`pyspark`, `numpy`, `pandas`, …):

- `{theme}-patterns` — recurring idioms.
- `{theme}-solutions` — rare, complex, or hard-won one-offs.

Catalogs are content, not engine. A themed catalog pairs with its themed
instruction file (both agent-loaded on demand, never `applyTo` by default) and
lives in the content repo or project-local `.aet/`, never in the core engine.
A content-repo index README lists available themed instructions and catalogs so an
agent loads only what a task needs.

---

## Canonical references

- `prompts/discover-workspace-file-knowledge.prompt.md` — upstream workspace discovery; run first on unfamiliar projects to build file-card metadata and candidate extraction themes
- `prompts/review-proposal.prompt.md` — triage the generated proposal: adopt, localize, return, or discard
- `validation/nda-safety-checklist.md` — mandatory genericization gate for EXPORT proposals
- `prompts/propose-improvement.prompt.md` — proposal shape and triage hint

---

## Output format

Write proposals under:

- `.aet/proposals/export/` for EXPORT proposals
- `.aet/proposals/local/` for KEEP-LOCAL proposals

Use this structure:

```text
# Proposal: Code knowledge catalog — {theme}

- Type: instruction | prompt | validation-rule | catalog | refactoring | discovery
  # instruction → instructions/*.instructions.md
  # prompt      → prompts/*.prompt.md
  # validation-rule → validation/*.md
  # catalog     → catalogs/{theme}-patterns.md or catalogs/{theme}-solutions.md
  # refactoring → rule pack for code transformation (becomes prompt or instruction)
  # discovery   → report only; no artifact yet
- Route: EXPORT | KEEP-LOCAL
- Topic: {user-requested or inferred extraction theme}
- Observed in: {generic project description, NDA-safe}
- Suggested destination: instructions/ | content-repo | prompt | agent |
  this project's instructions | discuss
- Intended consumer: {prompt, agent, instruction, validation, reviewer, or none}

## Extraction contract

- Theme:
- Selection basis: recurring | unique | all
- Scope:
- Output shape:
- Assumptions:
- Exclusions:
- Intended consumer:

## Evidence

Summarize observed evidence without leaking sensitive details.
Include counts, file categories, or representative generic signals where useful.

## Extracted knowledge

### {knowledge-unit-name}

- Classification tag: {short textual tag}
- Kind: snippet | style | refactoring-target | test-pattern | architecture-building-block | validation | other
- Basis: recurring | unique
- Value signal: {occurrence count for recurring; complexity or rarity reason for unique}
- Intent: {one-line description}
- Applies when: {trigger or situation}
- Reusable because: {why this generalizes}
- Route: EXPORT | KEEP-LOCAL
- Consumer: {prompt, agent, instruction, rule pack, validation, reviewer, or none}
- Replaces: {anti-pattern or n/a}

{generic code, pseudocode, or instruction}

(repeat per knowledge unit)

## Triage hint

ADOPT | LOCAL | RETURN | DISCARD per unit — and why.
```

---

## Next step

After writing the proposal file, tell the user exactly:

> Proposal saved at `<path>`. Run `prompts/review-proposal.prompt.md` to assess and adopt it.
