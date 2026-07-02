---
description: "Periodically reevaluate AET against evidenced LLM capabilities, or explicitly request a scoped content/workflow consistency review."
name: reevaluate-toolkit
user-invocable: true
disable-model-invocation: true
---
# Reevaluate Toolkit

## Invocation and ownership

Use only on explicit human invocation in the AET source repository.
AET Steward owns execution; run inline there or hand off to Steward with this
skill and the request. Stop and report degraded capability if unavailable;
never self-delegate. This skill and Steward are source-only, not portable
dependencies. Remain read-only; skill metadata does not enforce tool limits.

Read-only, AET Steward-owned review; specialists provide read-only evidence and
validation. Change no files. All recommendations require human approval.

Default to full capability-driven reevaluation using Inputs, Scorecard, Procedure,
and Report Format below; use the optional scoped mode instead only when requested.

## Content/Workflow Consistency

- Use this mode only on explicit request; never run it automatically per edit.
- Limit review to requested artifacts and necessary canonical owners; no full
  inventory, capability profile, scorecard, or prior report is required.
- Apply [philosophy](../../docs/philosophy.md) and [repository rules](../../docs/repository-rules.md).
- Compare roles, permissions, delegation, and implementation readiness with owning agent workflows.
- Check evidence ownership, handoffs, and packet semantics against the
  [gate contract](../../validation/gate-report-contract.md) and role-owned Review and Validation rules.
- Check scope, audience, engine/CONTENT, and EXPORT separation against
  [public safety](../../docs/public-safety.md#scope).
- Check proposal routing and schemas against [routing](../propose-improvement/SKILL.md),
  workflow-specific producers, and [proposal review](../review-proposal/SKILL.md).
- Assess meaning and contradictions, not exact wording; distinguish static
  consistency findings from untested runtime behavior.
- Use full reevaluation for capability-driven recommendations, retaining its evidence restrictions.
- Report scope, evidence-backed findings, unknowns, and next actions using step 8's gate lifecycle.
- This optional audit never replaces mandatory change-scoped Review and Validation.

## Inputs

Record a dated current capability profile with claims about reasoning,
instruction following, context use, tool use, planning, and self-correction.
For each claim record an ID, provenance, test conditions, result, known limits,
and confidence. Classify evidence as:

- `independent` — an empirical external source with published method and result,
  or a separate reproduction performed outside this review without its outputs
- `observed` — a reproducible result produced during this review
- `assumed` — a claim that qualifies as neither `independent` nor `observed`

Do not infer capability from model name, release date, vendor claims, or successor
status. Capability-driven `MODIFY`, `MERGE`, `REPLACE`, or `REMOVE` recommendations
require an `independent` evidence ID. An `observed` ID never satisfies this gate;
separate replication creates a new ID with its own provenance and conditions.

## Scorecard

Score each dimension from 0 to 2. Higher scores mean stronger justification:

| Group | Dimension | 0 | 1 | 2 |
|---|---|---|---|---|
| Logic | Purpose | unclear or misaligned | partial or mixed | explicit and bounded |
| Logic | Consistency | contradictory or unusable | material gaps | sound and executable |
| Logic | Efficiency | cost exceeds value | value is uncertain | cost matches evidenced value |
| Existence | Necessity | no current need | contingent or unproven | current need demonstrated |
| Existence | Uniqueness | duplicates authority | overlaps authority | distinct authority |
| Existence | Irreplaceability | removal preserves outcomes | trade-offs are uncertain | removal harms required outcomes |
| Evolution | Capability fit | evidence conflicts | mixed or unproven | supported or capability-neutral |
| Evolution | Robustness | obsolete or capability-fragile | unsupported capability dependency | capability-neutral or evidence-supported |

Calculate `Logic /6`, `Existence /6`, and `Evolution /4`. Record safety as
`PASS`, `FAIL`, or `UNCERTAIN`; `FAIL` or `UNCERTAIN` blocks finalization.

Choose one recommended decision per artifact:

- `KEEP` — no material defect or unjustified complexity
- `MODIFY` — the authority remains valid but needs a bounded correction
- `MERGE` — authority is duplicated and one target can preserve outcomes
- `SPLIT` — independent responsibilities prevent clear ownership
- `REPLACE` — the outcome is required but the mechanism is unsound
- `REMOVE` — need, unique value, and removal impact all score 0
- `INVESTIGATE` — safety, capability, or architectural evidence is unresolved

## Procedure

1. Load the baseline and constraints: `docs/philosophy.md`,
  `docs/repository-rules.md`, `docs/public-safety.md`, and `agents/aet-steward.agent.md`.
  Load the current profile and prior report data from inputs or a supplied checkpoint;
  use `no prior baseline` only if neither supplies one, and apply repository priorities.
2. Build the complete artifact inventory and relationship map.
   - Prefer repository-tracked files; otherwise inventory visible files.
   - Exclude only version-control metadata, dependencies, caches, and generated
     output, and report every exclusion.
   - Preserve known ID/path mappings; assign IDs to new paths using the inventory
     fields in Checkpoint below.
   - Record the reproducible fingerprint defined below, including uncommitted content.
   - On resume, verify checkpoint completeness, scope, baseline, profile, and
     recomputed fingerprint before continuing at its recorded phase and cursor.
   - On mismatch or missing state, return `BLOCKED`; require a complete compatible
     checkpoint or a fresh run without reused evaluations.
3. Review stable batches of at most 12 artifacts, grouped by shared
   responsibility/dependency contracts and risk/uncertainty; treat 12 as a
   ceiling, not a filling target.
   - Give each specialist toolkit purpose/constraints, the compact global
     inventory and relationship map, its assigned batch, the full scorecard,
     and relevant baseline/capability evidence.
   - Limit detailed reads to assigned artifacts, their governing owners, and
     dependencies/consumers needed to verify contracts; expand only to resolve
     an unknown relevant to the batch.
   - Keep unrelated prior-batch recommendations with the Steward until
     reconciliation; supply specialists relevant facts and constraints instead.
   - Use the Steward's routing rules; keep the Steward accountable for synthesis.
   - If a non-validation specialist is unavailable, stop that pass and report
     `DEGRADED`; do not silently omit it.
4. Evaluate every artifact independently and in context.
   - Populate Artifact Context and Artifact Scorecard fields below, including
     all eight dimension scores and evidence-based rationales.
   - Cite repository evidence as `path:line` and capability evidence by ID.
   - Evaluate whether a rational architect would create it now; estimate
     removable logic as a range; keep batch decisions provisional until reconciliation.
5. Emit a response-only checkpoint after each batch; never persist it to the repository.
   - Include accumulated state using the schema below for continuation without prior responses.
   - When coverage is incomplete, return only the common envelope and checkpoint
     with `INCOMPLETE` or `BLOCKED`; omit every full-coverage section.
6. Reconcile only after complete inventory coverage.
   - Resolve cross-batch dependencies, duplicated authority, recommendation
     conflicts, and score inconsistencies against the global relationship map.
   - Identify strengths, gaps, hidden coupling, and capability compensations.
   - Classify capability-coupled mechanisms: `still necessary`, `simplifiable`, `obsolete`, or `unproven`.
7. Produce evidence-backed architecture options and recommendations.
   - Compare the current design with the smallest design that preserves public
     safety, correctness, engine/content separation, and AI-facing usability.
   - For each recommendation record benefit, risk, effort, evidence, affected
     IDs, and the smallest reversible first step.
   - Rank at most 10 recommendations by `BLOCKER`, `HIGH`, `MEDIUM`, or `LOW`
     priority, then value from 0 to 2.
   - Compute capability, inventory, score, and recommendation deltas from reconciled
     results and the prior baseline; use `N/A` for prior states and deltas without one.
   - Require human approval before every implementation or adoption action.
8. Route the completed assessment under
   [Steward's Validation Rules and Orchestration Flow](../../agents/aet-steward.agent.md)
   and the [gate contract](../../validation/gate-report-contract.md).
   - On failed Review, stop and return all findings to the owning implementer;
     skip Validation unless explicitly requested for baseline/final aggregation.
     Reevaluation alone grants no exception.
   - Set `BLOCKED` for safety `FAIL`/`UNCERTAIN` or failed, invalid, missing, or
     unavailable required gates; mark unavailable gates `DEGRADED`.
   - Verify coverage, evidence, no file changes, and independent evidence for
     every capability-driven reductive recommendation.
9. Return the report below with a refreshed checkpoint after reconciliation and gates.
   - Sort artifact rows by path; express rankings as artifact IDs and scores.
   - Keep each rationale and recommendation field to one sentence.

## Report Format

```text
**Goal**: <reevaluation objective and current capability profile>
**Scope**: <size, inventory source, fingerprint, artifact count, exclusions>
**Plan**: <batch IDs, assigned specialists, and completion state>

**Results**
Status: COMPLETE | INCOMPLETE | BLOCKED
Degradation: NONE | DEGRADED — <missing capability or none>
Capability profile: <profile ID; YYYY-MM-DD>
Coverage: <reviewed>/<total>

### Checkpoint
Baseline: <ID and prior profile, inventory, scores, recommendations; or no prior baseline>
Profile: <dated capability profile with all Inputs claim fields>
Inventory: <every ID/path, type, purpose/consumer, dependencies, overlaps; source; exclusions>
Fingerprint: <scope; hash method/value over sorted inventory IDs/paths/content, profile, baseline>
Progress: <phase; reviewed/remaining IDs; next batch or None>
Evaluations: <all reviewed artifacts' full Context and Scorecard fields, including dimension scores>
Evidence: <summaries with references; complete valid gate packets, if any>
Open: <unresolved relationships; safety/gate blockers; next action>
Deltas: <pending until step 7; then capability, inventory, score, recommendation comparisons or N/A>

The following sections require complete inventory coverage; `COMPLETE` also
requires successful required gates and no safety blockers:

### Capability Deltas
| ID | Dimension | Claim | Class | Provenance | Conditions | Result | Limits | Confidence | Prior state | Delta |

### Artifact Deltas
| ID | Inventory delta | Score delta | Recommendation delta |

### Artifact Context
| ID | Type | Dependencies | Overlapping authorities | Failure modes | AI-facing use | Capability assumptions |

### Artifact Scorecard
| ID | Path | Purpose/consumer | Logic /6 | Existence /6 | Evolution /4 | Safety | Strength | Weakness | Removal impact | Merge target | Compression | Create today? | Recommendation | Evidence |

### Rankings
Logical quality: <artifact IDs with scores, descending>
Existence justification: <artifact IDs with scores, descending>

### Architecture Findings
Strengths: <evidence-backed findings or None>
Weaknesses and gaps: <findings or None>
Redundancy and coupling: <findings or None>
Capability-driven simplification: <findings or None>

### Architecture Options
Minimal viable: <components, retained safeguards, and trade-offs>
Recommended current: <components, responsibilities, and trade-offs>

### Recommendations
| ID | Priority | Value | Change | Artifact IDs | Benefit | Risk | Effort | Evidence | First step |

**Score**: <philosophy fit /16 and category scores>
**Validation**: PASS | FAIL | UNCERTAIN — <findings or blockers>
**Triage**: not applicable — this is not proposal triage
**Next step**: <human decision required; no automatic edits>
```

Length justification: the source-only reevaluation procedure, scorecard, and
resumable report contract remain together for complete, bounded execution.
