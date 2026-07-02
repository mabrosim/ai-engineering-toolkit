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

## Delegation Brief

When delegating, give the specialist one focused brief:

- **Objective and goals**: one-sentence objective, concrete goals, and an observable done condition.
- **Context**: anchor paths, available evidence, scope exclusions, and relevant constraints.
- **Artifact scope**: for each artifact, give its engine/content role, audience, destination,
  governing policy evidence, applicable checks (with reasons for `N/A`), and unresolved boundaries.
- **Authority**: specify no-edit or authorized-change scope, permitted environment, and side-effect
  limits. For evidence-only diagnostics, state the question to answer.
- **Stop condition**: the effort limit, evidence threshold, or decision that ends the assignment.
- **Expected output and communication budget**: name the deliverable, format, and detail level.
  Keep summaries to key paths, decisions, and blockers; preserve complete artifacts, required
  evidence, and the specialist's mandatory output.

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
