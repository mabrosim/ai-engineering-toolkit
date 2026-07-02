---
description: "Capture a toolkit improvement as a structured proposal doc."
agent: "agent"
---
# Propose Improvement Prompt

Use this prompt to capture a reusable lesson from a project engagement as a
proposal document for the ai-engineering-toolkit.

---

## Prompt

```text
Capture an improvement proposal from this engagement.

Steps:
1. Identify one concrete gap observed while working: a missing rule, a weak
   prompt, a noisy or missing validation check, or a structural problem.
2. Anchor it — name the investigation topic (the question or subject you were
   exploring) and carry it into the proposal so the thread is not lost.
3. State the proposed change as a single, explicit, testable statement.
4. Give evidence (pattern or file role).
5. Route it:
   - EXPORT — generalizes beyond this project AND is public-safe. Run the
     NDA/public-safety check on the draft; if it cannot be sanitized without
     losing its point, make it KEEP-LOCAL instead.
   - KEEP-LOCAL — real and useful but project-bound (proprietary framework,
     license dialect, internal naming); belongs in this project's own
     instructions, never exported.
6. Suggest a destination and a triage hint for whoever owns it (Steward for
   EXPORT; this project's instruction set for KEEP-LOCAL).
7. Skip anything one-off or already covered by an existing rule.

Write one Markdown proposal per concept under .aet/proposals/export/ or
.aet/proposals/local/. No preamble.
```

---

## Canonical references

- `prompts/review-proposal.prompt.md` — the Steward's triage procedure EXPORT proposals feed
- `prompts/nda-safety-review.prompt.md` — the public-safety gate to run before EXPORT
- `docs/philosophy.md` — ADOPT vs LOCAL fit test
- `instructions/documentation-style.instructions.md` — proposal formatting

---

## Notes

- This is the outward capture step; AET Steward triages EXPORT proposals inward.
- Triage happens at the source: route EXPORT vs KEEP-LOCAL where the NDA context
  lives, so proprietary lessons stay with the project and only public-safe ones leave.
- EXPORT proposals are inputs, not decisions — the Steward adopts, localizes,
  returns, or discards.
- Used by the optional `aet-proposal` agent; not part of the standalone installer.
