---
description: "Review AET proposals and decide whether to abandon, adopt, keep local, return, or defer."
agent: "AET Orchestrator"
---

## Review Proposal Prompt

Use when the user asks:

- review the NNN proposal
- review proposal NNN
- review proposals
- adopt this proposal
- decide what to do with this proposal
Review proposal Markdown files under `.aet/proposals/` and turn accepted proposals into explicit downstream assets.
Change no project source files.
Only write or update AET governance artifacts when adoption is justified.

### Purpose

Convert proposal inbox items into decisions:

- ABANDON
- ADOPT
- LOCAL
- RETURN
- DEFER
If ADOPT, create or update the explicit instruction, prompt fragment, validation checklist, or catalog needed by downstream consumers.
A proposal is not adoption.
A reviewed proposal must clearly state decision and reason.

### Inputs

Read requested proposal file(s), nearby existing proposals, relevant instruction files, relevant prompts or agents named as consumers, and safety or NDA review prompts/checklists when route is EXPORT.
Use `prompts/generate-instruction.prompt.md` only after ADOPT is selected and an instruction file is needed.

### Decision meanings

- `ABANDON`: lacks evidence, duplicates guidance, has no useful consumer, is unsafe, or is not worth maintaining.
- `ADOPT`: accept and implement as explicit governance artifact.
- `LOCAL`: useful but project-specific; keep or convert to project-local guidance only.
- `RETURN`: belongs to another upstream project/toolkit; record destination.
- `DEFER`: potentially useful, but needs more evidence; state exact missing evidence.

### Review gates

Apply every gate.

#### 1. Evidence gate

Reject or defer if evidence is invented/vague, examples are not grounded, classification lacks detector signals, or rule cannot be tested.
Counts matter only for `recurring` units; a single occurrence is valid evidence for a `unique` solution when its complexity or rarity is grounded in real code. Judge unique units by intrinsic value, not frequency.

#### 2. Duplicate gate

Search existing proposals, instructions, rule packs, and prompt rules.
If equivalent guidance exists, update existing owner when improvement is real; otherwise ABANDON as duplicate.

#### 3. Scope gate

Check whether proposal is one coherent concept.
If mixed, split conceptually when safe and useful; otherwise DEFER with split recommendation.

#### 4. Route gate

EXPORT requires generic, public-safe content.
KEEP-LOCAL may include project-specific details.
If EXPORT contains private names, internal URLs, secrets, client details, proprietary architecture, or NDA-sensitive specifics, sanitize if meaning survives; otherwise downgrade to LOCAL.

#### 5. Consumer gate

ADOPT requires a plausible consumer, not a named existing one.
The engine holds no advance knowledge of content; catalogs and themed instructions are built for later use by any loading agent — review, refactoring, architecture, or the core agent. A generic future consumer class is sufficient.
Valid consumers: prompt, agent, instruction file, catalog, validation checklist, reviewer/refactoring/architecture workflow, or the core agent loading content on demand.
Choose LOCAL when reuse is implausible, or ABANDON for no practical use.

#### 6. Ownership gate

ADOPT requires a single owning artifact:

- `instructions/*.instructions.md`
- `prompts/*.prompt.md`
- `validation/*.md`
- `catalogs/*.md`
- project-local instruction path
Do not scatter one rule across many files.
Reference related files instead of duplicating rules.

#### 7. Actionability gate

Accepted guidance must be explicit and testable.
Require applies-when trigger, do/do-not rule, metadata/output shape when relevant, downstream consumer behavior, and false-positive or ambiguity handling when relevant.

### Actions

**Idempotency:** if a prior draft or existing artifact already covers this proposal, reconcile and replace it — do not create a parallel version. Two competing drafts for the same owning artifact is an error.

If ADOPT:

1. Identify target artifact type: `instruction` → `instructions/`, `prompt` → `prompts/`, `validation-rule` → `validation/`.
2. Read existing artifact if present.
3. Add minimal rule text or create one new artifact.
4. Use house style: one purpose, short bullets, imperative voice, no rationale essays, references instead of restating owned rules.
   Use `prompts/generate-instruction.prompt.md` as style guidance when creating an instruction file.
   The generated frontmatter (`applyTo`, `description`, file path) must match the owning-artifact decision recorded in step 1. If they differ, reconcile before writing.
5. Run `quality-gate.prompt.md` on the created/updated artifact. Save the report to
   `.aet/reports/<proposal-name>-quality.md`. This is non-blocking — report issues and continue.
6. Verify: confirm both the artifact file and the quality report exist on disk. If either is missing, create it before proceeding. Do not report a path that does not exist.
7. Append decision notes to the reviewed proposal.
8. Report created/updated artifact path and quality report path.
If LOCAL:

When evidence quality is medium or high and a local consumer is known, create a project-local artifact — follow the same steps as ADOPT but write to the project-local path:

1. Identify target artifact type: `instruction` → `.aet/instructions/`, `catalog` → `.aet/catalogs/`, `validation-rule` → `.aet/validation/`.
2. Read existing artifact if present.
3. Add minimal rule text or create one new artifact. Same house style as ADOPT.
4. Run `quality-gate.prompt.md` on the created/updated artifact. Save the report to `.aet/reports/<proposal-name>-quality.md`. Non-blocking.
5. Verify: confirm both the artifact file and the quality report exist on disk. Create either if missing before proceeding.
6. Append decision notes to the reviewed proposal, including why it cannot be exported and path to local artifact.
7. Report created/updated artifact path and quality report path.

When evidence quality is low or consumer is unknown:

- keep under `.aet/proposals/local/` with decision notes only.
- state why it cannot be exported.
- state what evidence or consumer clarity is missing.
If ABANDON:
- do not create instructions.
- state exact reason.
- mark superseded-by existing file when useful.
If RETURN:
- state owning upstream project or toolkit area.
- do not adopt locally unless also needed locally.
If DEFER:
- state exact missing evidence.
- state what future scan would resolve it.
- do not create instructions.

### Output format

When reviewing one proposal, write or update review notes:

```md
## Review decision
- Decision: ABANDON | ADOPT | LOCAL | RETURN | DEFER
- Reviewer: AET Proposal
- Reason:
- Evidence quality: high | medium | low
- Duplicate check:
- Route decision:
- Intended consumer:
- Owning artifact:
- Action taken:
- Follow-up:
```

Chat response must be one concise summary line:

```text
Reviewed {proposal-path}: {DECISION} — {reason}.
Artifact: {path or none}. Quality report: {.aet/reports/... or n/a}.
```

### Notes

- Do not adopt proposals without a plausible consumer.
- Do not export unsafe details.
- Do not create broad instruction files for narrow rules.
- Do not rewrite project source.
- Prefer small explicit artifacts over large vague guidance.
