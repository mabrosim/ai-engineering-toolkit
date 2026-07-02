---
description: "Mine reusable project code knowledge into NDA-safe content proposals."
name: extract-code-knowledge
user-invocable: true
disable-model-invocation: false
---
# Extract Code Knowledge

## Invocation and ownership

Activate only for requested extraction or delegated capture, never unsolicited
mining. AET Orchestrator owns the workflow; AET Proposal may execute delegated
capture within its opt-in and proposal-only write limits. Run inline in an
authorized owner; otherwise route through AET Orchestrator. Stop and report
degraded capability if unavailable; never self-delegate.
Preserve the theme-selection interaction below. Loading this skill does not
enable optional proposal capture or grant tools or write authority.

Use this skill to mine reusable code knowledge from a software project.

The project may contain any language, framework, platform, file structure,
library, notebook format, script style, test style, generated artifact, or
domain-specific convention.

Do not assume specific technologies, domains, file types, libraries, platforms,
or workspace conventions. Discover the relevant scope and extraction theme at
runtime.

The output is one or more CONTENT proposals under
`.aet/proposals/<export|local>/`, split by coherent concept.

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

Extracted output is CONTENT. It may propose a content catalog or content
instruction, but never a canonical engine catalog. Any engine skill,
instruction, agent, rule, or validation improvement must be captured separately
through [Propose Improvement](../propose-improvement/SKILL.md) and toolkit `proposals/`
governance.

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

If the user says `auto-discover`, inspect available project evidence and infer
at most three ranked extraction themes. For each candidate, report its evidence,
likely scope, usage contexts, and proposed output shape. Ask the user to select
one theme and one context, then stop. Do not extract knowledge or write a
proposal before that selection.

If the user named or selected a theme, restate it and the assumed scope in one
line before proceeding.

Default the selection basis to `all`. Ask only when user direction makes that
default materially uncertain:

> Should I capture recurring patterns (repeated idioms), unique solutions
> (rare, complex, or hard-won one-offs), or both? Default is both.

Recurring and unique knowledge route to different catalogs: `{theme}-patterns`
for repeated idioms, `{theme}-solutions` for rare or complex one-offs. Do not
discard a unique, high-value block only because it appears once.

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

Mine reusable code knowledge from the project. Do not change project source or
configuration. Begin only after one theme and one context are selected. Write
only CONTENT proposals selected below.

### 0. Establish extraction contract

Resolve per-artifact audience, destination, role, and policy evidence under the
[Public Safety Guide](../../docs/public-safety.md#scope), including on direct entry.
Apply applicable safety checks before other checks. Use the Route contract in
[Propose Improvement](../propose-improvement/SKILL.md) for routing;
KEEP-LOCAL is not an exemption from mandatory public sanitization.

Determine:

- `theme`: what kind of knowledge to extract
- `selection_basis`: `recurring` (repeated idioms), `unique` (rare, complex, or
  hard-won one-offs), or `all` (both). Default `all`.
- `scope`: what files or areas may contain relevant evidence
- `output_shape`: patterns catalog, solutions catalog, instruction proposal,
  refactoring rule pack, architecture catalog, discovery report, or mixed proposal
- `candidate_type`: `catalog` or `instruction`
- `route`: EXPORT or KEEP-LOCAL
- `safety_level`: public-safe, project-local, or unknown
- `consumer`: `implementation workflow`, `review workflow`,
  `refactoring workflow`, `architecture workflow`, `validation workflow`,
  `proposal workflow`, `core agent`, or `none`

An existing skill, catalog, instruction, or other owning artifact is not a
precondition for extraction. Record a plausible consumer class and candidate
destination without deciding whether the knowledge is already known or
adoptable.

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
skill.

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
  theme. Record these as candidate follow-up themes; do not extract them in the
  current run.

---

### 5. Generalize safely

Apply the resolved scope to proposal content, evidence, and metadata. Where
public sanitization applies, remove sensitive or project-specific details.
Ordinary KEEP-LOCAL host CONTENT may retain necessary authorized nonpersonal
identifiers under the Public Safety Guide; baseline protections still apply.

Assign each proposal a synthetic public-safe ID and each retained unit a stable
public-safe ID unique within that proposal. Do not derive IDs from private
paths, repository, project, or user names, or source-system identifiers.

Where public sanitization applies, replace real names and values with neutral
placeholders, including:

- project names, customer names, people names
- internal services, repositories, URLs
- table names, field names, file paths
- bucket or container names, account IDs
- tokens or credentials
- business-specific literals, proprietary labels
- internal package names

Use placeholders such as `{project}`, `{service}`, `{resource}`, `{path}`,
`{identifier}`, `{threshold}`, `{config_key}`, `{input}`, `{output}`,
`{domain_value}`, `source`, `target`, `client`, `record`, `result`.

If a unit loses its meaning after scrubbing, route it KEEP-LOCAL.

If a unit contains secrets, credentials, or PII, describe only the safe
remediation or pattern; never include the sensitive value.

---

### 6. Normalize into teaching form

Rewrite each retained unit into a clear, minimal, reusable example.

Preserve the idea, not accidental project complexity.

Each example should include:

- stable proposal-scoped unit ID
- short name
- one-line intent
- classification tag
- applies-when trigger
- evidence summary appropriate to the resolved scope
- destination hint
- generic code, pseudocode, or instruction
- notes on variations
- optional anti-pattern it replaces

If exact code would be unsafe or too project-specific, provide pseudocode or
instructional guidance instead.

Every retained unit must match the proposal route. If any retained unit requires
`KEEP-LOCAL`, route the whole proposal `KEEP-LOCAL`. Never place project-local
knowledge in an `EXPORT` proposal.

---

### 7. Decide output shape

Choose the shape that best fits the theme.

- **Patterns catalog** (`{theme}-patterns`) — recurring code fragments or operations
- **Solutions catalog** (`{theme}-solutions`) — rare, complex, or hard-won one-off solutions
- **Content instruction** — coding conventions, local guidance, or refactoring rules
- **Architecture catalog** — reusable components, entry-point patterns, or pipeline stages
- **Discovery proposal** — bounded evidence and actionable follow-up themes

Map every catalog shape to extracted type `catalog`; map content instructions
and discovery proposals to extracted type `instruction`. Choose from evidence,
not from which destination artifacts currently exist.

---

### 8. Route the proposal draft

Apply the Route contract and public-safety rules in
[Propose Improvement](../propose-improvement/SKILL.md). Its generic rule to skip one-offs or
already-covered guidance does not apply to extraction: retain grounded unique
units and leave knowledge-status classification to source review. Mark each
draft `Workflow: extracted-code-knowledge` and `Content class: CONTENT`. Record
`EXPORT` or `KEEP-LOCAL`. Do not recommend adoption or select a decision.

---

### 9. Avoid pending-proposal duplicates

Before writing, inspect the selected `.aet/proposals/<export|local>/` folder.

If a matching pending proposal exists, refine it instead of creating a parallel
draft. Do not classify knowledge as known or new here; source review owns that
decision. Existing skills, catalogs, instructions, or other knowledge artifacts
never suppress an extraction proposal.

Write one proposal per coherent concept. A selected theme and context may yield
multiple proposals, but never split or duplicate one knowledge unit across them.

---

## Content artifact

A catalog holds reusable code keyed by an `Applies when` trigger — not style rules.
Two catalog shapes are available per theme:

- `{theme}-patterns` — recurring idioms.
- `{theme}-solutions` — rare, complex, or hard-won one-offs.

For selection basis `all`, keep both bases in one proposal and tag every unit.
Proposal review may route recurring and unique units to their corresponding
catalogs without duplicating a unit.

Catalog and instruction drafts define reusable CONTENT and candidate
destinations. Source review may prepare candidate documents; only candidate-fit
review in the destination may adopt them.

---

## Canonical references

- [skills/discover-workspace-file-knowledge/SKILL.md](../discover-workspace-file-knowledge/SKILL.md) - upstream workspace
  discovery; run first on unfamiliar projects
- [skills/review-proposal/SKILL.md](../review-proposal/SKILL.md) - source classification, candidate
  preparation, destination fit, and adoption owner
- [validation/nda-safety-checklist.md](../../validation/nda-safety-checklist.md) —
  mandatory genericization gate for EXPORT proposals
- [skills/propose-improvement/SKILL.md](../propose-improvement/SKILL.md) —
  route, consumer vocabulary, owner mapping, and public-safety owner

---

## Output format

This schema is authoritative for every proposal marked
`Workflow: extracted-code-knowledge`. Do not substitute the generic AET
Proposal schema from [AET Proposal](../../agents/aet-proposal.agent.md#output-format)
or [Propose Improvement](../propose-improvement/SKILL.md).

Write proposals under:

- `.aet/proposals/export/` for EXPORT proposals
- `.aet/proposals/local/` for KEEP-LOCAL proposals

Use this structure:

```text
# Proposal: Code knowledge catalog — {theme}

- Workflow: extracted-code-knowledge
- Proposal ID: {synthetic public-safe identifier}
- Content class: CONTENT
- Type: catalog | instruction
- Route: EXPORT | KEEP-LOCAL
- Topic: {user-requested or inferred extraction theme}
- Observed in: {project description permitted by resolved scope; generic for EXPORT}
- Candidate owner: content catalog | content instruction
- Suggested destination: content-pack catalog | content-pack instruction |
  project-local content catalog | project-local content instruction
- Intended consumer: implementation workflow | review workflow |
  refactoring workflow | architecture workflow | validation workflow |
  proposal workflow | core agent | none

## Extraction contract

- Theme:
- Selection basis: recurring | unique | all
- Scope:
- Output shape:
- Candidate type: catalog | instruction
- Assumptions:
- Exclusions:
- Intended consumer:

## Evidence

Summarize observed evidence without leaking sensitive details.
Include counts, file categories, or representative signals permitted by resolved
scope; sanitize EXPORT evidence and metadata.

## Extracted knowledge

### {knowledge-unit-name}

- Unit ID: {stable public-safe identifier unique within Proposal ID}
- Classification tag: {short textual tag}
- Kind: snippet | style | refactoring-target | test-pattern |
  architecture-building-block | validation | other
- Basis: recurring | unique
- Value signal: {occurrence count for recurring; complexity or rarity reason for unique}
- Evidence summary: {scope-permitted signals; sanitized for EXPORT}
- Intent: {one-line description}
- Applies when: {trigger or situation}
- Reusable because: {why this generalizes}
- Route: EXPORT | KEEP-LOCAL
- Consumer: {one canonical intended-consumer value}
- Destination hint: {scope-permitted owner class or destination; public-safe for EXPORT}
- Replaces: {anti-pattern or n/a}

{generic code, pseudocode, or instruction}

(repeat per knowledge unit)

```

For EXPORT, `Proposal ID`, `Unit ID`, `Evidence summary`, and `Destination hint`
must exclude private paths, repository, project, or user names, and
source-system identifiers.

---

## Next step

After writing the proposal file, report the route-specific next step:

- EXPORT: report the proposal path, then request source review to classify units
  and prepare any sanitized content candidate.
- KEEP-LOCAL: report the proposal path, then request source review in the current
  project and state that prepared content must remain there.

Length justification: this portable skill keeps its mandatory interaction,
bounded discovery procedure, and authoritative extraction schema together so
it remains independently executable.
