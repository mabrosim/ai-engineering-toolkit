---
description: "Quality gate: safety, Review handoff, compactness, and Markdown quality before finalizing."
name: quality-gate
user-invocable: true
disable-model-invocation: false
---
# Quality Gate

## Invocation and ownership

Activate only for requested validation or a required Validation gate.
AET Validation owns execution and its packet; run inline only there.
Otherwise hand off to AET Validation with this skill and unchanged Review
evidence. If unavailable, stop and report degraded capability; never substitute
inline self-validation or delegate recursively from the owner.
Remain read-only under a host-enforced boundary; skill text does not restrict
tools. Preserve Review then Validation and the documented baseline exceptions.

Run this skill on generated output to check safety, Review handoff, compactness,
and Markdown quality before finalizing.

---

## Prompt

```text
Validate the following output against the repository's gates.

Precondition — load before judging:
- Independently resolve per-artifact scope using `docs/public-safety.md#scope`,
  including when invoked directly; verify scope handoff against its evidence.
- Retain scope, supporting evidence, and N/A reasons separately as validation
  input/evidence, never as prose or new fields in the gate packet.
- Validate only content actually in context. If the output is a file path or
  reference, read the real content first.
- Never speculate. Every finding must cite a concrete location in the actual
  content; no guessed or "may contain" findings.
- If required content or evidence cannot be loaded, emit an `UNRESOLVED`
  finding and stop only checks that depend on the missing material. Retain
  known applicable failures and apply the result precedence in
  `validation/ai-output-validation.md`: FAIL dominates UNCERTAIN.

Run checks in this order:
1. Safety: apply `validation/nda-safety-checklist.md` according to the resolved
  scope contract in `docs/public-safety.md`: baseline and applicable disclosure
  and public-sanitization checks first.
2. Public release: when output is being published or included in a public
  release, apply `validation/public-release-checklist.md` in full. Otherwise
  record N/A with the reason.
3. Correctness classification and handoff:
  - Correctness-bearing means a change to executable behavior, configuration,
    schemas or interfaces, tests or assertions, governance, rules, agent
    behavior, skills, or validation contracts.
  - Pure research or non-assertive records are not correctness-bearing; record
    N/A with the reason.
  - For correctness-bearing changes, consume AET Review's complete packet:
    findings with locations plus MERGEABLE. Validate it against
    `validation/gate-report-contract.md`. A valid MERGEABLE: NO means FAIL.
    Missing, invalid, or internally inconsistent required Review output means
    UNCERTAIN unless another applicable FAILED finding requires FAIL. Return
    invalid packets to Review; do not repair or reinterpret them. Retain Review
    packets and findings separately as source evidence;
    do not forward Review findings or MERGEABLE into the Validation packet.
    Emit the Validation-owned correctness/handoff finding defined by
    `validation/ai-output-validation.md` for NO, missing, or invalid evidence.
    Do not independently re-review correctness.
4. Compactness: filler, preamble, repetition, over-long prose.
5. Markdown quality: apply semantic criteria from `validation/markdown-quality-rules.md`; use host repository tooling for mechanical formatting checks.
6. Duplication: content that restates rules already owned elsewhere in the repo.
   Do not flag agent return contracts (e.g. MERGEABLE, VERDICT lines) or a skill's
   own paste-able procedure as duplication — those are owned interfaces, not restated rules.

Return findings and empty output exactly as defined by
`validation/gate-report-contract.md`.

Apply the result and human-review contract in
`validation/ai-output-validation.md`. End with one VERDICT line followed by one
HUMAN_REVIEW line.

Output:
<paste output here>
```

---

## Canonical rules

- [docs/public-safety.md](../../docs/public-safety.md)
- [validation/nda-safety-checklist.md](../../validation/nda-safety-checklist.md)
- [validation/public-release-checklist.md](../../validation/public-release-checklist.md)
- [validation/compactness-rules.md](../../validation/compactness-rules.md)
- [validation/markdown-quality-rules.md](../../validation/markdown-quality-rules.md)
- [validation/ai-output-validation.md](../../validation/ai-output-validation.md)
- [validation/gate-report-contract.md](../../validation/gate-report-contract.md)
- [agents/aet-review.agent.md](../../agents/aet-review.agent.md)

---

## Notes

- Resolve the [scope contract](../../docs/public-safety.md#scope) first, then run
  applicable safety checks before other checks.
- This is the dogfood procedure for [AET Validation](../../agents/aet-validation.agent.md).
- Human authorization remains separate from the technical `VERDICT`.
