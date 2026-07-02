---
description: "Code review against AET rules: correctness, security, style, error handling."
agent: "AET Orchestrator"
---
# Code Review Prompt

Use this prompt to request an AI code review.

---

## Prompt

```text
Review the following code.

Instructions:
1. Check for correctness and logic errors.
2. Check for security issues (injection, hardcoded secrets, input validation).
3. Check for style issues (naming, formatting, structure).
4. Check for missing error handling.
5. Check for missing or incorrect docstrings.
6. List each issue as: [SEVERITY] Description — Suggested fix.

Severity levels: CRITICAL, HIGH, MEDIUM, LOW, INFO.

Return only the issue list. No preamble. No summary.

Code:
<paste code here>
```

---

## Canonical rules

- `validation/code-review-rules.md` — review criteria and merge bar
- Any `*.instructions.md` files loaded in the workspace — style compliance. Check what is available; do not assume specific files exist.

---

## Expected Output Format

```text
[HIGH] Function `process_data` does not handle empty input — add early return for empty list.
[MEDIUM] Variable `x` is not descriptive — rename to `record_count`.
[LOW] Missing docstring on `calculate_total` — add Google-style docstring.
```
