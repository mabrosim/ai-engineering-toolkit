---
description: "AI agent collaboration rules and behavior constraints for all tasks."
applyTo: "**"
---
# AI Collaboration Rules

Rules for working effectively with AI assistants in this repository.

---

## General Rules

- Treat AI output as a first draft, not a final answer
- Always review AI-generated code before committing
- Do not rely on AI for security-sensitive decisions without review
- Keep prompts explicit and short for consistent results

---

## Prompt Rules

- State the desired output format explicitly
- Provide context at the top of the prompt
- Use numbered instructions for multi-step tasks
- Specify constraints (e.g., "no external libraries", "Python 3.11+")

---

## Review Rules

- Check AI output against the relevant style guide
- Verify that AI-generated code passes linting and tests
- Check for NDA and public-safety compliance before committing
- Remove placeholder comments and TODO stubs before merging

---

## Interaction Rules

- Break large tasks into small, focused prompts
- If output quality is low, simplify the prompt
- Prefer deterministic prompts over open-ended requests
- Re-use proven prompts from `/prompts/` before writing new ones

---

## Context Injection

- Provide file context explicitly when needed
- Do not assume the model has memory of prior sessions
- Include relevant type hints and function signatures

---

## Prohibited Uses

- Do not use AI to generate credentials or secrets
- Do not use AI to bypass security reviews
- Do not commit AI output with company-specific data
- Do not use AI output without understanding it

---

## Model Compatibility

- Prompts in this repository target both strong and weak models
- Weak-model-safe: short prompts, numbered steps, no ambiguity
- Strong-model: may use longer context, chained reasoning
