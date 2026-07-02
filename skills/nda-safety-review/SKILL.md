---
description: "NDA and public-safety review: flag confidential data, secrets, or internal details."
name: nda-safety-review
user-invocable: true
disable-model-invocation: false
---
# NDA Safety Review

## Invocation and ownership

Activate only for an explicit safety review or a required safety step in an
active workflow. For standalone use, require the host's read-only chat mode;
if unavailable, stop and report degraded capability. Skill metadata cannot
select the former Ask mode or restrict tools.
For internal safety checks, the active workflow owner executes this read-only
substep inline under its existing authority, then resumes only if the result
permits it. Do not edit, execute mutating commands, or disclose content during
review. This is task authority, not a tool sandbox or a change of agent.
If evidence cannot be read safely, report UNCERTAIN.
This result does not replace independent Review or Validation or human approval.

Use this skill to check AI-generated content for NDA compliance.

---

## Prompt

```text
Review the following content for NDA and public safety compliance.

Instructions:
1. Apply `docs/public-safety.md` and `validation/nda-safety-checklist.md` in full.
2. Review only content actually provided or loaded.
3. For each finding, state: [CATEGORY] Description — Location in content.
4. Return PASS only when evidence establishes compliance.
5. Return FAIL when evidence establishes a violation.
6. Return UNCERTAIN when required content, evidence, or classification is
 unavailable or unresolved. Uncertainty blocks public use.

Return only the findings list. No preamble.
End with: RESULT: PASS | FAIL | UNCERTAIN.

Content:
<paste content here>
```

---

## Notes

- Run this before any public commit or share.
- Human review is still required after AI output.
- [docs/public-safety.md](../../docs/public-safety.md) owns public-safety policy.
- [validation/nda-safety-checklist.md](../../validation/nda-safety-checklist.md) owns the procedural checklist.
