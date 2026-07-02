---
description: "Generate a conventional commit message for staged changes."
agent: "ask"
---
# Commit Message Prompt

Use this prompt to generate a compact, well-structured commit message from staged changes.

---

## Prompt

```text
Write a commit message for the following staged changes.

Instructions:
1. If the repository has no prior commits, use the exact title `Initial commit`.
2. Otherwise, write a title in the form `<type>: <summary>` (max 50 chars).
3. Use one type: feat, fix, docs, refactor, test, chore, style, perf.
4. Title summary uses imperative mood ("add", not "added") and no trailing period.
5. Add a body only when the change needs context — wrap at 72 chars.
6. Body explains what changed and why, not how. Use bullet points.
7. No filler, no preamble, no "this commit" phrasing.

Return only the commit message. No explanation.

Staged diff:
<paste `git diff --staged` output here>
```

---

## Expected Output Format

```text
docs: tighten communication-style rules

- enumerate drop-list word classes
- separate prose terseness from code formatting
- add expand-when exceptions for low-context readers
```

---

## First Commit

When the repository has no commits yet, the message is simply:

```text
Initial commit
```
