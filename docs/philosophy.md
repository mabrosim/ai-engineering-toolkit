# AET Philosophy

Core intent, boundaries, and trade-off priorities for AET and the installed AET
engine.

This document defines why AET exists. Its principles guide AET artifacts and
AET improvement decisions in both the source project and installed copies.

## Purpose

AET is an AI-engineering toolkit for capturing a developer's tacit expertise
as explicit, reusable, NDA-safe instructions and workflows.

It exists to:

- Store reusable AI instructions, skills, and agent definitions
- Preserve engineering judgment in loadable form
- Define workflows for AI-assisted generation, review, and validation
- Support safe public publishing of reusable artifacts
- Accumulate useful toolkit pieces incrementally

The default first source of knowledge is the maintainer's own experience, code, and decisions, scrubbed before reuse.

## Role of This Document

This document is a self-contained decision guide, not an execution manual.

Use it to decide:

- What belongs in the AET engine or AET content
- What should stay out
- How AET trade-offs are resolved
- Whether a proposed improvement fits AET

Installation and source-repository mechanics are outside this portable guide.

## Engine vs Content

AET separates two concerns.

### Engine

The engine is the reusable, public-safe core:

- Agent definitions
- Skills
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

The [Public Safety Guide](public-safety.md#scope) owns artifact scope,
audience, and safety applicability, including the distinction between public
engine/export adoption and source-local host CONTENT adoption.

Applicable safety and correctness gates are not optional.

See the [Public Safety Guide](public-safety.md) for the full blocked-content
list and review process.

### Proportionate Evidence

Match evidence effort to claim type, decision risk, and reversibility.
Use the cheapest sufficient evidence.

This principle does not weaken mandatory safety or correctness gates.
Dependencies on specific model capabilities remain governed by
[AI Compatibility](#ai-compatibility).

### Modularity

Every AET artifact should have one clear purpose.

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

Prefer explicit AET improvement decisions over implicit assumptions.

### AI Compatibility

Instructions and skills must remain clear and actionable across supported
model capabilities.

Do not require a specific model capability without predeclared, independently
reproduced evidence. Simplify unsupported capability dependencies.

### Dogfooding

During AET development, use AET's own agents, skills, instructions, and
validation for AET work.

Applying AET to its own development surfaces gaps and drift before external
users encounter them. Fix AET guidance that cannot support this use.
