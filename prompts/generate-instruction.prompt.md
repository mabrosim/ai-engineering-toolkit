---
description: "Draft a new canonical instruction file from a rule candidate."
agent: "agent"
---
# Generate Instruction Prompt

Use this prompt to draft a new `instructions/` file in the repository's house style.

---

## Prompt

```text
Draft a new instruction file for the following standard.

Frontmatter:
- Tech-specific packs (Python, SQL, financial, etc.) must omit `applyTo` — they are agent-loaded, not globally injected.
- Only set `applyTo: "**"` when the rule must apply to every file in a project.
- `description` must be one sentence naming the domain covered.

Requirements:
1. One file, one purpose. Do not mix unrelated concerns.
2. Open with a one-line statement of what the file governs.
3. Express rules as short, explicit, testable bullet points.
4. Group related rules under H2 headers separated by `---`.
5. Prefer imperative voice ("Use", "Do not"). No rationale essays.
6. Do not restate rules owned by another instruction file — reference it.
7. Keep it scannable; a weak model must be able to apply it.
8. Open each rule group with a bold **Use when:** line — one sentence stating the trigger condition.
9. Code examples must use Google-style docstrings and explicit type annotations. No bare-function examples without signatures.
10. Do not include a fixed top-level import block. Show imports at point of use, inside each snippet.
11. Reference only sibling files that are guaranteed to ship in the same bundle. Do not reference files that may be absent.

Return only the markdown file content. No explanation.

Standard to capture:
<describe the standard or paste source rules here>
```

---

## Canonical references

- `instructions/communication-style.instructions.md` — house style for prose
- `instructions/documentation-style.instructions.md` — markdown and docs conventions
- `docs/philosophy.md` — modularity and explicitness principles

---

## Notes

- Use when a proposal review (`prompts/review-proposal.prompt.md`) identifies a candidate as ADOPT.
- Run `quality-gate.prompt.md` on the draft before committing.
- The generated frontmatter must match the owning-artifact decision recorded in the proposal's review-decision block. If they diverge, the generate step is wrong — reconcile before saving.
