---
description: "Review engine proposals, extracted knowledge, or prepared content candidates."
name: review-proposal
user-invocable: true
disable-model-invocation: false
---

# Review Proposal

## Invocation and ownership

Activate only for an explicit proposal review/adoption request or its required
continuation. AET Orchestrator coordinates installed host-project review.
Toolkit EXPORT inbox review requires the source repository's authorized
coordinator and local governance; neither is supplied by the portable bundle.
Run inline in the applicable coordinator; otherwise hand off with this skill
and the artifact. Stop on unavailable ownership or uncertain route; never
self-delegate. Implementers draft; independent Review then Validation retain
their gate roles. This governance review is not the AET Review gate.
Skill metadata grants no tools or write authority beyond the action below.

Use when the user asks:

- review the NNN proposal
- review proposal NNN
- review proposals
- adopt this proposal
- decide what to do with this proposal
- review extracted code knowledge
- review this prepared content candidate

Load [Propose Improvement](../propose-improvement/SKILL.md) and apply its Route contract.
Stop if that contract is unavailable.

Independently resolve per-artifact audience, destination, role, and policy
evidence under the [Public Safety Guide](../../docs/public-safety.md#scope),
including on direct entry. Verify supplied scope and apply applicable safety
checks before other checks. Keep scope and applicability evidence outside gate
packets. KEEP-LOCAL does not exempt engine artifacts or known public targets
from public sanitization; a public-safe `PASS` does not authorize disclosure.

Change no project source files. Decision notes are always permitted. Write
quality reports and owning artifacts only when the selected action allows them.

Before review, set `Review path` and `Route mode`, then verify workspace,
artifact location, destination, and required human approval. Stop on mismatch.
The extracted-source path may classify and PREPARE in the source project under
the Route-contract exception; it cannot adopt content.

## Purpose

Use exactly one review path:

- `GENERIC-ENGINE`: generic proposal governance; decisions `ABANDON`, `ADOPT`,
   `LOCAL`, `RETURN`, or `DEFER`.
- `EXTRACTED-SOURCE`: a CONTENT proposal marked `Workflow:
   extracted-code-knowledge` or `Workflow: workspace-file-knowledge-discovery`
   in its source project; decisions `ABANDON`, `PREPARE`, or `DEFER` only.
- `CANDIDATE-FIT`: a prepared CONTENT document in its destination content-pack
   workspace, or a KEEP-LOCAL candidate in its source; decisions `ABANDON`,
   `MERGE`, `ADOPT`, or `DEFER`.

Classify proposed knowledge against artifacts available to the active path as
known, an extension of known knowledge, new, mixed, or unresolved. Status never
implies adoption.

`PREPARE` creates a portable candidate, not canonical content. `MERGE` or
`ADOPT` integrates a candidate only after destination comparison, applicable
review and validation, and required human gates. A proposal is never adoption.

## Inputs

Read requested proposal or candidate files, nearby duplicates, relevant owners,
named consumer workflows, and applicable safety checks. For `CANDIDATE-FIT`, read
destination content that could overlap. Use [Generate Instruction](../generate-instruction/SKILL.md)
only for generic engine instruction adoption.

## Decision meanings

- `ABANDON`: lacks evidence, duplicates guidance, has no useful consumer, is
   unsafe, or is not worth maintaining.
- `PREPARE`: source review only; write a noncanonical content catalog or
   instruction candidate.
- `MERGE`: candidate-fit only; integrate a material delta into an existing
   destination content owner.
- `ADOPT`: create a new canonical owner in the applicable engine or content
   destination.
- `LOCAL` (`GENERIC-ENGINE` only): useful but project-specific; keep or convert
   to project-local guidance only.
- `RETURN` (`GENERIC-ENGINE` only): belongs to another upstream project/toolkit;
   record destination.
- `DEFER`: potentially useful, but needs more evidence; state exact missing evidence.

`LOCAL` and `RETURN` are `GENERIC-ENGINE` decisions only. Never use them for
`EXTRACTED-SOURCE`; express recapture needs in `Follow-up` metadata.

## Review gates

Apply every gate.

### 1. Evidence gate

Reject or defer if evidence is invented or vague, examples are not grounded,
classification lacks detector signals, or a rule cannot be tested.
Counts matter only for `recurring` units. A single occurrence is valid evidence
for a `unique` solution when complexity or rarity is grounded in real code.
Judge unique units by intrinsic value, not frequency.

For capability-neutral claims, select the cheapest sufficient evidence based on
claim type, decision risk, and reversibility. Choose from a context-dependent
set: thought experiments or counterexamples, existing direct evidence,
deterministic checks, separately authorized bounded reversible pilot results,
and replicated empirical benchmarks. Evidence does not grant operational
authorization.

Thought experiments and counterexamples expose assumptions, contradictions,
boundaries, and hypotheses, but do not establish runtime behavior, performance,
environmental safety or correctness, or model capability. Direct evidence
supports claims only within its provenance and conditions. Deterministic checks
support mechanically decidable claims. Separately authorized pilot results
support claims only within bounded reversible trial conditions. Replicated
benchmarks support empirical claims only within reproduced conditions. Direct
evidence and deterministic checks have no fixed cost order.

Specific-model capability dependencies require predeclared, independently
reproduced evidence. For `DEFER`, name the unresolved claim and cheapest
sufficient evidence type. Require costlier evidence only when cheaper types
cannot resolve a capability-neutral claim.

### 2. Knowledge-status gate

Search existing proposals and available owning artifacts, including
instructions, skills, catalogs, rule packs, validation rules, and
project-local guidance. Classify the proposal, and individual units when needed:

- `KNOWN`: equivalent guidance already exists.
- `EXTENDS-KNOWN`: an existing owner exists, but the proposal materially
   corrects or extends it.
- `NEW`: no equivalent guidance exists in the searched scope.
- `MIXED`: units have different statuses.
- `UNRESOLVED`: evidence or comparison scope is insufficient.

For `EXTRACTED-SOURCE`, comment and exclude `KNOWN` or weak units; ABANDON when
nothing remains. PREPARE grounded `NEW` or `EXTENDS-KNOWN` units only when all
source gates pass. If comparison artifacts are unavailable, use `UNRESOLVED`:
DEFER when evidence or actionability is unresolved, but PREPARE may proceed when
only destination comparison is unavailable and evidence, actionability, and
safety pass. Mark that candidate `Destination comparison: REQUIRED` and do not
claim known or new.

For `CANDIDATE-FIT`, compare every unit with destination content before deciding.
ABANDON `KNOWN` units, MERGE only material extensions, and ADOPT only genuinely
new coherent content. For `MIXED`, decide per unit without duplication. DEFER
`UNRESOLVED` units with the exact missing comparison.

For `GENERIC-ENGINE`, ABANDON `KNOWN` guidance without material improvement;
update an existing owner for `EXTENDS-KNOWN` only when all gates pass. Exclude
known units from `MIXED`. DEFER `UNRESOLVED`. `NEW` still passes every gate.

### 3. Scope gate

Check whether proposal is one coherent concept.
For extracted knowledge, prepare at most one candidate per coherent concept and
never duplicate a unit. Otherwise split conceptually when safe or DEFER.

### 4. Route gate

Apply the canonical Route contract. `GENERIC-ENGINE` uses its normal carry-back
and adoption locations. `EXTRACTED-SOURCE` may review
`.aet/proposals/<export|local>/` and write only to matching
`.aet/content-candidates/<export|local>/`. `CANDIDATE-FIT` may review an EXPORT
candidate only after human transfer into the destination content-pack workspace;
a KEEP-LOCAL candidate remains in its source project.

If an EXTRACTED-SOURCE EXPORT proposal cannot be sanitized without losing
meaning, choose `DEFER` when fresh KEEP-LOCAL capture can resolve it, otherwise
choose `ABANDON`. Record `Recapture route: KEEP-LOCAL` and the needed evidence
in `Follow-up`; do not reroute the proposal or use `LOCAL` or `RETURN`.

### 5. Consumer gate

Apply the [canonical consumer vocabulary](../propose-improvement/SKILL.md#content-workflow-exception).
`PREPARE`, `MERGE`, `ADOPT`, and generic `LOCAL` require a plausible non-`none`
consumer, but no existing named artifact. For EXTRACTED-SOURCE KEEP-LOCAL
content, choose `PREPARE` and write only under
`.aet/content-candidates/local/`. Record any separate EXPORT recapture need in
`Follow-up`; never reroute private evidence in place. Choose `ABANDON` when no
practical use exists.

### 6. Ownership gate

Every accepted knowledge unit requires one owning artifact. Apply the
[canonical type and owner mappings](../propose-improvement/SKILL.md#content-workflow-exception)
for engine and CONTENT destinations.

An extracted proposal may prepare one candidate per coherent concept. A
selection basis of `all` may map recurring units to one patterns catalog and
unique units to one solutions catalog. Content candidates and destination
content owners remain CONTENT; never place them in a canonical engine catalog.
Reference related files instead of duplicating rules.

### 7. Actionability gate

Accepted guidance must be explicit and testable. Require an applies-when trigger,
do/do-not rule, metadata or output shape when relevant, downstream consumer
behavior, and false-positive or ambiguity handling when relevant.

## Actions

**Idempotency:** reconcile an existing proposal, candidate, or owner instead of
creating a competing version.

### EXTRACTED-SOURCE

- Use only `ABANDON`, `PREPARE`, or `DEFER`; never use `LOCAL` or `RETURN`.
- Record one status and action per unit. Comment and exclude known or weak units.
- For `PREPARE`, write one minimal candidate per coherent concept under the
   route-matching `.aet/content-candidates/<export|local>/` folder.
- Sanitize EXPORT candidates at source. Never write an unsafe candidate or move
   KEEP-LOCAL content out of its source.
- Preserve applies-when triggers, actionable content, consumer, and a compact
   evidence summary. Omit raw private evidence from EXPORT candidates.
- Set `Destination comparison: REQUIRED` when destination artifacts were not
   available. PREPARE remains valid but noncanonical.
- Verify candidate files exist, then append source-review notes to the proposal.

### CANDIDATE-FIT

- Before comparison, require the complete workflow-matching candidate schema
   below. Choose
   `DEFER` for any missing candidate or unit field, a bare catalog body, or a
   candidate whose route and workspace violate the Route contract. A transferred
   KEEP-LOCAL artifact is not a candidate; direct a fresh EXPORT recapture and
   source review in the source project. Do not relabel or reconstruct it at the
   destination.
- Require human-transferred EXPORT candidates to be in the destination
   content-pack workspace. Review KEEP-LOCAL candidates only in their source.
- Compare every candidate unit with all plausible destination content owners.
- For `MERGE`, draft only the material delta to an existing content catalog or
   content instruction. For `ADOPT`, draft one new coherent content owner.
- Start [AET Review](../../agents/aet-review.agent.md) on each draft for both routes
   only after the owner returns `Status: complete`, the done-condition, and
   verification evidence under
   [implementation readiness](../../agents/aet-orchestrator.agent.md#approach).
   A blocked or incomplete handoff returns to the owner and stops before either
   gate. On a valid `MERGEABLE: NO`, return all findings to the owning
   implementer; rerun Review only after owner-local repairs and a new complete
   handoff satisfy readiness. After Review runs, return a missing or invalid
   [Review packet](../../validation/gate-report-contract.md) to Review for a valid
   replacement without rewriting or synthesizing it. For packet-only correction
   with unchanged artifacts, reuse the same verified implementation evidence;
   no new owner handoff is required. Do not invoke Validation until a complete
   valid `MERGEABLE: YES` packet is available.
- For both routes, pass only the complete valid `MERGEABLE: YES` Review packet
   unchanged to [AET Validation](../../agents/aet-validation.agent.md) through
   [Quality Gate](../quality-gate/SKILL.md). Supply per-artifact scope and policy evidence
   separately; Validation independently resolves scope and consumes Review's
   packet under the canonical gate contracts. KEEP-LOCAL requires applicable
   source-policy checks, blocks credentials, secrets, PII, and transfer out of
   the source, and permits project-specific content only when source policy
   allows it. EXPORT requires full public sanitization, including evidence and
   metadata. Save `.aet/reports/<candidate-name>-quality.md`.
- Integrate only after `PASS` and required human review. Otherwise leave
   destination content unchanged and report the blocker.
- Keep the prepared candidate unchanged. Record candidate-fit decisions only in
   the separate adoption report; keep the quality report distinct. For extracted
   candidates, key every unit decision by `Candidate ID` and `Unit ID`.
   Canonical content must omit candidate IDs, unit IDs, provenance, source-review,
   route, safety, comparison, and other workflow metadata.
- Write the adoption report before drafting, update it after quality and human
  review, then integrate. Verify destination owner, quality report, and adoption
  report exist; do not append candidate-fit notes to the candidate.

### GENERIC-ENGINE

- For `ADOPT`, resolve the canonical engine owner using the
   [type and owner mappings](../propose-improvement/SKILL.md#content-workflow-exception).
   A generic `catalog` must use the CONTENT path.
- Before drafting an engine instruction, record its human-accepted destination
   owner and frontmatter in the Review decision using the conditional fields
   below. Missing, blank, unknown, or unaccepted inputs block drafting until
   proposal review completes them; only `applyTo` may be explicitly `OMIT`.
- Draft minimal owner content; use [Generate Instruction](../generate-instruction/SKILL.md)
   only for an engine instruction.
- Start [AET Review](../../agents/aet-review.agent.md) only after the owner returns
   `Status: complete`, the done-condition, and verification evidence under
   [implementation readiness](../../agents/aet-orchestrator.agent.md#approach).
   A blocked or incomplete handoff returns to the owner and stops before either
   gate. On a valid `MERGEABLE: NO`, return all findings to the owning
   implementer; rerun Review only after owner-local repairs and a new complete
   handoff satisfy readiness. After Review runs, return a missing or invalid
   [Review packet](../../validation/gate-report-contract.md) to Review for a valid
   replacement without rewriting or synthesizing it. For packet-only correction
   with unchanged artifacts, reuse the same verified implementation evidence;
   no new owner handoff is required. Do not invoke Validation until a complete
   valid `MERGEABLE: YES` packet is available.
- Pass only a complete valid `MERGEABLE: YES` Review packet unchanged to
   [AET Validation](../../agents/aet-validation.agent.md) through
   [Quality Gate](../quality-gate/SKILL.md), and save `.aet/reports/<proposal-name>-quality.md`.
- Write canonical owners only after `PASS` and required human review, then verify
   owner and report paths and append proposal notes.
- For `LOCAL`, require KEEP-LOCAL route and recorded human approval. Apply the
   same gates before writing project-local engine owners under `.aet/`.
- If local evidence or consumer clarity is insufficient, retain decision notes
   only and DEFER.

For `ABANDON`, create no owner and state the exact reason. For
`GENERIC-ENGINE` `RETURN`, record the upstream destination without local
adoption. For `DEFER`, state the exact missing evidence or comparison and the
future check that resolves it.

## Output format

When reviewing one proposal, write or update review notes:

For the toolkit EXPORT inbox, these notes are transient: AET Steward may delete
handled proposal files after completing the recorded action or triage. Keep
project-local review notes with their proposal unless project policy says
otherwise.

```md
## Review decision
- Review path: GENERIC-ENGINE | EXTRACTED-SOURCE | CANDIDATE-FIT
- Decision: {one decision allowed by the selected Review path}
- Route mode: EXPORT | KEEP-LOCAL
- Workspace context: toolkit repository | source project | content-pack workspace
- Reviewed artifact:
- Human approval: RECORDED | N/A
- Reason:
- Evidence quality: high | medium | low
- Knowledge status: KNOWN | EXTENDS-KNOWN | NEW | MIXED | UNRESOLVED
- Unit decisions:
- Existing owner(s): {paths or none}
- Destination comparison: COMPLETE | REQUIRED | N/A
- Route decision:
- Intended consumer:
- Candidate artifact(s):
- Destination owner(s):
- Quality report:
- Action taken:
- Follow-up: none | Recapture route: EXPORT | KEEP-LOCAL; Evidence needed: {gap}
```

For `GENERIC-ENGINE` instruction adoption, including a `LOCAL` engine
instruction, record one human-accepted instruction path in `Destination owner(s)`
and add this owner-specific section to the Review decision before drafting:

```md
### Accepted instruction inputs
- Accepted description: {exact nonblank one-sentence quoted YAML string}
- Accepted applyTo: {exact quoted YAML string | OMIT}
```

`OMIT` is accepted only for `applyTo` and records intentional absence, not an
unknown value; `OMIT` for description blocks drafting. Both frontmatter
decisions and the destination owner must be recorded and human-accepted.
Missing, blank, unknown, or unaccepted inputs block drafting until proposal
review completes them. Drafts must preserve the recorded owner, values, and
accepted `applyTo` omission.
Keep these inputs in the Review decision, not project configuration. Omit this
section for other artifact types and review paths.

Allowed decision values:

- `GENERIC-ENGINE`: `ABANDON | ADOPT | LOCAL | RETURN | DEFER`
- `EXTRACTED-SOURCE`: `ABANDON | PREPARE | DEFER`
- `CANDIDATE-FIT`: `ABANDON | MERGE | ADOPT | DEFER`

For `PREPARE` with `Workflow: extracted-code-knowledge`, write each candidate
with this structure:

```md
# Content Candidate: {concept}

- Candidate ID: {synthetic public-safe identifier}
- Source proposal ID: {Proposal ID from the extracted proposal}
- Source review marker: {stable public-safe review identifier}
- Workflow: extracted-code-knowledge
- Content class: CONTENT
- Candidate type: catalog | instruction
- Route: EXPORT | KEEP-LOCAL
- Public-safety result: PASS | KEEP-LOCAL
- Knowledge status: KNOWN | EXTENDS-KNOWN | NEW | MIXED | UNRESOLVED
- Destination comparison: REQUIRED | COMPLETE
- Intended consumer: {canonical consumer value}

## Purpose

## Applies when

## Candidate content

### {unit name}

- Unit ID: {unchanged proposal-scoped Unit ID}
- Basis: recurring | unique
- Value signal: {unchanged extraction value signal}
- Evidence summary: {scope-permitted extraction evidence summary; sanitized for EXPORT}
- Source knowledge status: KNOWN | EXTENDS-KNOWN | NEW | UNRESOLVED
- Source action: PREPARE
- Consumer: {canonical consumer value}
- Destination hint: {scope-permitted owner class or destination; public-safe for EXPORT}

{prepared actionable content}

(repeat per included unit)

## Source review

{decision, reason, and marker matching the candidate header}
```

Every listed field is required. Preserve each included unit's ID, basis, value
signal, scope-permitted evidence summary, consumer, and destination hint from
the proposal; record its source knowledge status and action. Ordinary KEEP-LOCAL
host CONTENT may retain necessary authorized nonpersonal identifiers under the
Public Safety Guide; baseline protections still apply. For EXPORT, candidate
and proposal identifiers, review markers, provenance summaries, and destination
hints must exclude private paths, repository, project, or user names, and
source-system identifiers. `Public-safety result: PASS` is required.

For `PREPARE` with `Workflow: workspace-file-knowledge-discovery`, preserve the
proposal's native sections and write this candidate schema:

```md
# Content Candidate: {concept}

- Candidate ID: {synthetic public-safe identifier}
- Workflow: workspace-file-knowledge-discovery
- Content class: CONTENT
- Candidate type: catalog | instruction
- Route: EXPORT | KEEP-LOCAL
- Public-safety result: PASS | KEEP-LOCAL
- Knowledge status: KNOWN | EXTENDS-KNOWN | NEW | MIXED | UNRESOLVED
- Destination comparison: REQUIRED | COMPLETE
- Intended consumer: {canonical consumer value}

## Purpose
## Applies when
## File-card schema
## File clusters
## Theme presence map
## Adaptive read-depth rules
## Downstream routing rules
## Safety and routing notes
## Name-content mismatches
## Outliers and ambiguity
## Source review

{decision, reason, and public-safe review marker}
```

Every listed field and section is required. Preserve applicable discovery
content without adding extraction Unit IDs, basis, value signals, or extraction
evidence fields. Sanitize EXPORT content and require
`Public-safety result: PASS`.

At `CANDIDATE-FIT`, run this schema preflight before destination comparison. A
complete packet with every required field proceeds to comparison. Otherwise
choose `DEFER`, identify each missing or invalid field, and request the complete
workflow-matching candidate packet for its existing route. Preserve EXPORT or
KEEP-LOCAL during recovery; a KEEP-LOCAL candidate reviewed at source does not
require EXPORT recapture. State that bare catalog bodies are not candidates.
For a transferred KEEP-LOCAL artifact, require fresh EXPORT recapture and source
review at source; never relabel or reconstruct the transferred artifact.

For `CANDIDATE-FIT`, write
`.aet/reports/<candidate-name>-adoption.md` separately from
`.aet/reports/<candidate-name>-quality.md`:

```md
# Candidate Adoption Report
- Candidate ID:
- Candidate artifact:
- Workflow: extracted-code-knowledge | workspace-file-knowledge-discovery
- Route: EXPORT | KEEP-LOCAL
- Workspace context: source project | content-pack workspace
- Overall decision: ABANDON | MERGE | ADOPT | DEFER
- Destination comparison: COMPLETE | REQUIRED
- Destination owner(s): {paths or none}
- Quality report: {path or n/a}
- Quality result: PASS | FAIL | UNCERTAIN | NOT-RUN
- Human approval: RECORDED | N/A | PENDING
- Integration status: COMPLETE | NOT-WRITTEN
- Reason:
- Follow-up: {exact missing evidence or none}

## Unit decisions
### {Candidate ID} / {Unit ID}
- Decision: ABANDON | MERGE | ADOPT | DEFER
- Knowledge status: KNOWN | EXTENDS-KNOWN | NEW | UNRESOLVED
- Compared owner(s): {paths or none}
- Reason:
- Intended destination: {path or none}
```

For extracted candidates, include one Unit decisions entry per Unit ID. For
workspace-discovery candidates, omit `Unit decisions` and record the coherent
candidate decision in the header. Write the initial report after schema preflight
and destination comparison with quality `NOT-RUN`, approval `PENDING` when
required, and integration `NOT-WRITTEN`. Draft without changing the candidate,
run review and quality gate, update quality and approval fields, then integrate
only after `PASS` and required approval. Finally set integration status and
verify both reports and each written owner.

Retain received Review and Validation packets unchanged as separate evidence in
the quality report, including their exact terminal fields; never synthesize or
relabel gate results. Set `Quality result` to Validation's exact `VERDICT` when
available; use `NOT-RUN` only when Validation has not run. A `FAIL`, `UNCERTAIN`,
missing or invalid gate packet, or pending required human approval keeps
`Integration status: NOT-WRITTEN` and destination content unchanged. Record the
blocker and required follow-up without replacing a completed `UNCERTAIN` result
with `FAIL` or `NOT-RUN`.

Chat response must be one concise summary line:

```text
Reviewed {artifact-path}: {DECISION} — {reason}.
Artifacts: {paths or none}. Quality report: {.aet/reports/... or n/a}.
```

## Notes

- Do not adopt proposals without a plausible consumer.
- Do not export unsafe details.
- Do not treat PREPARE as adoption.
- Do not put extracted catalogs in the engine.
- Do not create broad instruction files for narrow rules.
- Do not rewrite project source.
- Prefer small explicit artifacts over large vague guidance.

Length justification: this portable skill keeps all three review paths,
decision gates, and write contracts together so path constraints remain
independently enforceable.
