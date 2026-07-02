---
description: "Correctness and technical mergeability review against AET rules."
name: code-review
user-invocable: true
disable-model-invocation: false
---
# Code Review

## Invocation and ownership

Activate only for a requested review or a required Review gate. AET Review owns
execution and its packet; run inline only in that agent. Otherwise hand off to
AET Review with this skill and the evidence. If unavailable, stop and report
degraded capability; never substitute an inline self-review.
Remain read-only. Skill text does not restrict tools; the host must provide a
read-only execution boundary. Do not delegate recursively to the owning agent.

Before handoff, identify the target from the request. If pasted material has
no identifiable real or proposed path, ask for one; do not invent a location.

---

## Prompt

```text
Review the identified code or governance artifacts.

Inputs (supply what applies):
- Change: target paths and a diff or readable comparison baseline.
- Draft or snippet: supplied text and its real or proposed path.
- Standalone file or repository baseline: path(s) and review boundaries; no diff needed.
- Evidence: audience, destination, policy, and relevant verification results or references.
  Supply a prior packet and supporting baseline only if requesting coverage reuse.

Instructions:
1. Independently resolve per-artifact scope under `docs/public-safety.md`,
   including on direct entry. Verify supplied audience, destination, role, and
   policy evidence; apply applicable safety checks before other checks. Retain
   scope and applicability evidence outside the Review packet.
2. Inspect the targets and evidence before judging correctness or logic. If a
   required check cannot be decided, report it as UNRESOLVED; do not guess.
3. Check for security issues (injection, hardcoded secrets, input validation).
4. Check for style issues (naming, formatting, structure).
5. Check for missing error handling.
6. Check for missing or incorrect docstrings.
7. Return a Review packet conforming to
   `validation/gate-report-contract.md`. Cite the real or proposed path plus a
   line, heading, or symbol; for unavailable input, cite its path or reference.

Severity levels: CRITICAL, HIGH, MEDIUM, LOW, INFO.

Return only the packet. No preamble. No summary.
Apply the merge criteria in `validation/code-review-rules.md`. End with
`MERGEABLE: YES` only when every criterion passes; otherwise end with
`MERGEABLE: NO`.

Review inputs:
<identified targets and applicable evidence>
```

---

## Canonical rules

- [docs/public-safety.md](../../docs/public-safety.md#scope) — artifact scope and applicable safety checks
- [validation/code-review-rules.md](../../validation/code-review-rules.md) — review criteria and merge bar
- [validation/gate-report-contract.md](../../validation/gate-report-contract.md) — shared finding and packet rules
- Any `*.instructions.md` files loaded in the workspace — style compliance. Check what is available; do not assume specific files exist.

---

## Expected Output Format

```text
[HIGH] [FAILED] [CORRECTNESS] Function `process_data` does not handle empty input — src/example.py:20 — add early return for empty list.
[MEDIUM] [FAILED] [READABILITY] Variable `x` is not descriptive — src/example.py:31 — rename to `record_count`.
[LOW] [FAILED] [DOCUMENTATION] Missing docstring on `calculate_total` — src/totals.py:8 — add Google-style docstring.
MERGEABLE: NO
```
