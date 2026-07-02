---
description: "Draft a generic engine instruction from accepted proposal-review inputs."
name: generate-instruction
user-invocable: true
disable-model-invocation: false
---
# Generate Instruction

## Invocation and ownership

Activate only on explicit request or the accepted GENERIC-ENGINE drafting step.
The recorded destination's implementation owner drafts inline; the authorized
coordinator retains gate routing and human approval. If no owner is assigned,
return to proposal review; do not choose a
destination or adopt independently. Do not self-delegate or run your own
independent gates. Skill metadata grants no agent or tool permissions.

Use this skill only for generic engine instruction adoption in the
[GENERIC-ENGINE workflow](../review-proposal/SKILL.md#generic-engine).
Technology-specific CONTENT instructions remain in their source and
candidate-fit workflows.

Require the destination owner and
[accepted instruction inputs](../review-proposal/SKILL.md#output-format) to be
recorded and human-accepted before drafting. Missing, blank, unknown, or
unaccepted inputs block drafting; return to proposal review to complete them.
Draft only the recorded engine owner.

---

## Prompt

```text
Draft the generic engine instruction accepted in the proposal's Review decision.

Frontmatter:
- Copy the accepted nonblank one-sentence quoted YAML string exactly into description;
  block drafting if its accepted input is OMIT.
- Copy the accepted applyTo value exactly into applyTo; omit only applyTo when
  its accepted decision is explicitly OMIT.

Requirements:
1. One file, one purpose. Do not mix unrelated concerns.
2. Open with a one-line statement of what the file governs.
3. Express rules as short, explicit, testable bullet points.
4. Group related rules under H2 headers separated by `---`.
5. Prefer imperative voice ("Use", "Do not"). No rationale essays.
6. Do not restate rules owned by another instruction file — reference it.
7. Open each rule group with a bold **Use when:** line - one sentence stating the trigger condition.
8. Document public functions in code examples using applicable project and language standards; include complete signatures and language-appropriate type information.
9. Do not include a fixed top-level import block. Show imports at point of use, inside each snippet.
10. Use relative Markdown links to required dependencies guaranteed to ship in the same portable bundle; resolve paths from the generated file's directory.

Return only the markdown file content. No explanation.

Standard to capture:
<accepted standard from the proposal's Review decision>
```

---

## Canonical references

- [instructions/communication-style.instructions.md](../../instructions/communication-style.instructions.md) — house style for prose
- [instructions/documentation-style.instructions.md](../../instructions/documentation-style.instructions.md) — markdown and docs conventions
- [validation/compactness-rules.md](../../validation/compactness-rules.md) - instruction compactness limits

---

## Notes

- Follow [GENERIC-ENGINE readiness and gate routing](../review-proposal/SKILL.md#generic-engine).
  Start [AET Review](../../agents/aet-review.agent.md) only after a complete owner
  handoff with `Status: complete`, done-condition, and verification evidence.
  On a valid `MERGEABLE: NO`, return all findings to the owning implementer;
  rerun Review only after owner-local repairs and a new complete handoff
  satisfy readiness. After Review runs, return a missing or invalid
  [Review packet](../../validation/gate-report-contract.md) to Review for a valid
  replacement without rewriting or synthesizing it. For packet-only correction
  with unchanged artifacts, reuse the same verified implementation evidence;
  no new owner handoff is required. Stop before Validation until a complete
  valid `MERGEABLE: YES` packet is available; pass it unchanged to
  [Quality Gate](../quality-gate/SKILL.md).
- Write the owning file only after `PASS` and required human approval. Match the
  recorded destination, frontmatter values, and intentional omissions;
  reconcile any divergence in proposal review before saving.
