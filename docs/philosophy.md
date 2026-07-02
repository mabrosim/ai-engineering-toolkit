# Repository Philosophy

Core principles guiding this repository.

---

## Purpose

This repository is an engineering toolkit for capturing a developer's own tacit
expertise into explicit, loadable, NDA-safe instructions and solutions. It exists to:

- Store reusable AI instructions and prompts
- Define coding standards mined from real code, for consistent AI output
- Provide validation workflows for safe content publishing
- Use those standards both to generate new code and to check existing code
- Accumulate useful utilities incrementally

The default first input is the maintainer's own code, NDA-scrubbed before it lands.

---

## Engine vs Content

The repository separates two concerns that evolve at different speeds:

- **Engine** — the agnostic core: the orchestrator agents, the
  discover → extract → generate → validate workflow, and the NDA/quality gates.
  Language- and project-neutral. This is the publishable product.
- **Content** — the mined packs: per-language style instructions, on-demand skills,
  and named pattern catalogs distilled from a developer's own code. Structured as
  three tiers: always-on `instructions/` (file-type glob), on-demand `skills/`
  (agent-decided by task domain), and `catalogs/` (concrete named patterns linked
  from skills). Personal, opinionated, and private by default; shared only by
  deliberate choice.

The engine operates on content. Work on one without disturbing the others.

---

## Principles

### Modularity

Every file should serve exactly one purpose. No file should grow beyond its defined scope. When a file becomes too large, split it.

### Incrementalism

Do not design for the future. Build what is needed now. Extend when the need is clear.

### Explicitness

Prefer explicit over implicit. Name things clearly. Document decisions, not just implementations.

### Public Safety

Everything in this repository is designed to be public-safe. No company information, no PII, no secrets. Ever.

### Opinionated, Not Universal

Style and structure rules encode the maintainer's taste — adopt or fork them freely. Safety and correctness gates (NDA, security, public-release) are not a matter of taste and must never be forked away.

### AI Compatibility

Instructions and prompts must work with weak models, not just strong ones. If a prompt requires GPT-4 to work, it is too complex.

### Dogfooding

Use this repository's own prompts, instructions, and agents to do its own work. Running our tools on ourselves surfaces gaps and drift before external users hit them. If a prompt is too weak to rely on here, fix the prompt.

---

## What This Is Not

- Not a framework
- Not a production system
- Not a company-specific toolkit
- Not a one-size-fits-all solution

---

## Evolution

The repository evolves in phases. Each phase builds on the previous one without breaking it. New capabilities are added only when old ones are stable.
