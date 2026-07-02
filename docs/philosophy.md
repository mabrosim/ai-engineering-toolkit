# Repository Philosophy

Core intent, boundaries, and trade-off priorities for this repository.

This document defines the "why" of the project.
Operational rules live in `repository-rules.md`.
Agent workflow lives in agent and instruction files.

## Purpose

This repository is an AI-engineering toolkit for capturing a developer's tacit expertise into explicit, reusable, NDA-safe instructions and workflows.

It exists to:

- Store reusable AI instructions, prompts, and agent definitions
- Preserve engineering judgment in loadable form
- Define workflows for AI-assisted generation, review, and validation
- Support safe public publishing of reusable artifacts
- Accumulate useful toolkit pieces incrementally

The default first source of knowledge is the maintainer's own experience, code, and decisions, scrubbed before reuse.

## Role of This Document

This document is a decision guide, not an execution manual.

Use it to decide:

- What belongs in this repository
- What should stay out
- How trade-offs are resolved
- Whether a proposed rule fits the project

Do not duplicate mechanical rules here.
File layout, naming, and review rules belong in `repository-rules.md`.

## Engine vs Content

This repository separates two concerns.

### Engine

The engine is the reusable, public-safe core:

- Agent definitions
- Prompts
- Instructions
- Validation workflows
- Maintenance utilities
- Export and installation support

The engine must remain generic, public-safe, and independent of private project context.

The engine is the publishable product.

### Content

Content is mined or authored guidance:

- Personal style preferences
- Language-specific conventions
- Pattern catalogs
- Project-derived lessons
- Domain-specific examples

Content is personal, opinionated, and private by default.

Content may be shared only by deliberate choice.
Private content must never be required for the public engine to work.

### Boundary Rule

The engine operates on content.
The engine must not depend on private content.
Content may depend on engine workflows.

If a contribution blurs this boundary, split it.

## Decision Priority

When principles conflict, prefer this order:

1. Public safety
2. Correctness
3. Engine/content separation
4. Simplicity
5. Reusability
6. Convenience
7. Completeness

Reject convenience that weakens safety.
Split reusable machinery from private content.
Defer completeness that adds speculative complexity.

## Principles

### Public Safety

Everything intended for this repository must be safe to publish.

Safety and correctness gates are not optional.

See `docs/public-safety.md` for the full blocked-content list and review process.

### Modularity

Every artifact should have one clear purpose.

Split content when it mixes responsibilities, repeats concepts, or becomes hard to review.
Do not split only to create structure.

Prefer one authoritative location per concept.
Reference it elsewhere instead of copying it.

### Incrementalism

Build what is needed now.

Avoid speculative abstractions.
Add extension points only when they solve a current, visible need.

Prefer small complete changes over broad redesigns.

### Explicitness

Prefer explicit decisions over implicit assumptions.

### AI Compatibility

Instructions and prompts must work with weak models, not just strong ones.

If a prompt requires a top-tier model to work, it is too complex. Simplify it.

### Dogfooding

Use this repository's own agents, prompts, instructions, and validation to do its own work.

Running our tools on ourselves surfaces gaps and drift before external users hit them.
If a prompt or rule is too weak to rely on here, fix it.
