# Compactness Rules

Rules for keeping AI prompts, instructions, and documentation compact.

---

## Why Compactness Matters

- Weak models perform better with shorter inputs
- Compact prompts reduce token cost
- Concise instructions are easier to follow
- Short files are easier to maintain

---

## Rules for Prompts

- Max 10 numbered instructions per prompt
- Remove redundant context
- One instruction = one action
- No explanations inside instructions — only directives
- Remove filler words: "please", "kindly", "make sure to"

---

## Rules for Instructions

- Max 30 bullet points per instruction file
- Group related rules under a header
- Remove rules that duplicate other files
- Use examples only when a rule is ambiguous

---

## Rules for Documentation

- README max 1 page (approx 50 lines)
- One concept per paragraph
- Remove sections that add no information
- Prefer tables over repeated list items

---

## Compactness Anti-Patterns

- Restating the question or task before answering
- Adding "As mentioned above..." cross-references
- Writing headers for single-item sections
- Using 3 words where 1 word works
- Padding with transitional phrases ("Furthermore...", "In addition...")

---

## Measurement

A document is compact if:

- Every sentence carries new information
- Removing a sentence loses meaning
- A new reader can scan it in under 60 seconds
