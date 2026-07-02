---
description: "Quality gate: NDA safety, compactness, markdown quality, code review. Run on any output before finalizing."
agent: "ask"
---
# Quality Gate Prompt

Run this prompt on any generated output to check NDA safety, compactness, markdown quality, and code correctness before finalizing.

---

## Prompt

```text
Validate the following output against the repository's gates.

Precondition — load before judging:
- Validate only content actually in context. If the output is a file path or
  reference, read the real content first.
- Never speculate. Every finding must cite a concrete location in the actual
  content; no guessed or "may contain" findings.
- If the content cannot be loaded, STOP and say so. Do not emit findings or a verdict.

Run checks in this order:
1. NDA / public safety: company or client names, internal systems, URLs, PII, secrets, proprietary logic.
2. Compactness: filler, preamble, repetition, over-long prose.
3. Markdown quality: heading levels, fenced code languages, blank-line spacing, single H1.
4. Code review (if code): correctness, security, style, error handling, tests.
5. Duplication: content that restates rules already owned elsewhere in the repo.
   Do not flag agent return contracts (e.g. MERGEABLE, VERDICT lines) or a prompt's
   own paste-able procedure as duplication — those are owned interfaces, not restated rules.

For each finding: [SEVERITY] Category — Description — Location — Suggested fix.
Severity: CRITICAL, HIGH, MEDIUM, LOW, INFO.
If clean, respond: "No issues detected."

End with one line: VERDICT: PASS or VERDICT: FAIL.

Output:
<paste output here>
```

---

## Canonical rules

- `validation/nda-safety-checklist.md`
- `validation/compactness-rules.md`
- `validation/markdown-quality-rules.md`
- `validation/code-review-rules.md`
- `validation/ai-output-validation.md`

---

## Notes

- The NDA / public-safety check is mandatory and runs first.
- This is the dogfood procedure for the AET Validation agent.
- Human review is still required after AI output.
