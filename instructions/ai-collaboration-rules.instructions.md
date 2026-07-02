---
description: "Cross-cutting execution, review, safety, and evidence rules for AI-assisted work."
applyTo: "**"
---
# AI Collaboration Rules

Cross-cutting rules for AI-assisted work in the current workspace.

---

## Execution

- Ground work in relevant files, loaded instructions, and available evidence.
- Make material assumptions, constraints, and done-conditions explicit.
- Decompose broad work into small, verifiable steps.
- Complete requested work end to end unless blocked.
- Do not claim edits, checks, or outcomes without verifying them.
- Never call `exit` at top level in a persistent terminal. Use a child process
  for commands that may terminate the shell or need temporary environment or
  shell-option changes; let commands return their status naturally.
- In zsh, avoid `path` as a local or loop variable because writes also update
  `PATH`.

---

## Context and Review

- Read relevant context; do not assume prior-session memory.
- Request missing context only when it affects scope, safety, correctness, or
  reversibility.
- Review generated artifacts against applicable project rules before handoff.
- Run applicable checks and report their results accurately.
- Do not bypass required human, security, validation, or release gates.

---

## Safety

- Never generate or expose real credentials or secrets.
- Do not expose PII or move private workspace details into public or exportable
  artifacts.
- Do not leave placeholders or TODO stubs unless explicitly required.

---

## Model Compatibility

- Keep reusable AI-facing artifacts short, explicit, and independently
  actionable.
- Label model-tier and capability claims as evidence-backed or unverified.
- Add or change a capability-based routing mapping only after a predeclared
  benchmark is independently reproduced.
- Remove unsupported routing mappings without requiring a benchmark.
