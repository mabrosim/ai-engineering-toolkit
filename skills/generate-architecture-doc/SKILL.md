---
description: "Investigate a repository and draft a full architecture reference or compact onboarding overview grounded in inspected evidence."
name: generate-architecture-doc
user-invocable: true
disable-model-invocation: true
---

# Generate Architecture Doc

## Invocation and ownership

Use only on explicit human invocation. AET Orchestrator owns coordination;
execute inline there, otherwise hand off to that agent with this skill and the
request. If unavailable, stop and report degraded capability; never
self-delegate. Draft owners and independent gates retain their existing roles.
Skill metadata does not select an agent or enforce read-only tools.

Investigate a software project as a black box and draft an Architecture Design
Document for engineers who need to understand, maintain, extend, or review the
system.

The project may be any language, framework, or architectural style (monolith,
service, pipeline, library, CLI, API backend, data or ML pipeline, etc.). Do not
assume a stack.

Read-only through step 8. Ground every claim in inspected evidence; mark
anything unclear as `Unknown / needs confirmation` instead of inventing it.

## Purpose

Produce a persisted reference document — not a task plan — that engineers and
AI coding agents use to onboard, plan changes, and evaluate proposals against
the system's actual structure.

This complements [Assess Project](../assess-project/SKILL.md): run that skill when the goal is
"what should I fix first" (produces a prioritized action plan); run this one
when the goal is "what does this system look like" (produces a reference doc).

## Output profiles

Before investigating, ask the user to select one output:

- **Full Architecture Design Document** — detailed reference for maintenance,
  extension, and architecture review (recommended).
- **Compact Architecture Overview** — 600–900-word onboarding reference.
- **Both** — both documents from one investigation.

Do not infer the selection or start investigation until the user answers.

The compact profile uses the same investigation, evidence, safety, and human
confirmation workflow as the full profile. It compresses the findings into
exactly this structure:

```text
# Project Overview
## Purpose
## System Context
## Architecture Diagram
## Repository Structure
## Execution Flow
## Key Domain Concepts
## Main Entrypoints
## Dependencies & Infrastructure
## Design Constraints & Important Rules
## Confidence & Assumptions
```

For the compact profile:

- Keep the document between 600 and 900 words.
- Use one Mermaid architecture diagram.
- Use tables for Repository Structure and Key Domain Concepts.
- Cover major inputs, outputs, external systems, entry points, orchestration,
  end-to-end flow, dependencies, constraints, and visible design decisions.
- Distinguish high-confidence findings, medium-confidence findings, and
  assumptions in Confidence & Assumptions.
- Write `Not found` when evidence is absent. Do not add sections.

## Document structure

```text
# Architecture Design Document
## 1. Executive Summary — purpose, key characteristics, top risks
## 2. System Context — external systems/APIs/users, I/O boundaries, deployment context
## 3. High-Level Architecture — style, major modules, interactions, Mermaid diagram
## 4. Codebase Map — table: module/directory | responsibility | key files | depends-on | role
## 5. Runtime Flows — main execution paths (startup, request, pipeline, batch/CLI);
     trigger, steps, modules, inputs/outputs, error handling per flow
## 6. Data Architecture — models, formats, storage, caching, validation, lifecycle,
     sensitive data if visible
## 7. Dependency Architecture — key third-party libs, internal coupling, direction, cycles
## 8. Configuration & Environment — config mechanism, env vars, secrets handling, profiles
## 9. Cross-Cutting Quality — table: dimension | current state | evidence | risk | improvement
     dimensions: observability (logging/metrics/tracing), security, performance/
     scalability, testing, deployment/operations
## 10. Key Architecture Decisions — ADR-style per visible decision: status, context,
     decision, alternatives (mark inferred ones), consequences, evidence
## 11. Risks & Recommendations — table: risk/gap | impact | evidence | recommendation |
     term (short/medium/long) | priority
## 12. Open Questions — every `Unknown / needs confirmation` mark raised in §1-§11
## 13. Appendix — files inspected, sampling strategy if repo was too large to cover
     fully, suggested additional diagrams
```

Use tables for §4, §9, and §11 — do not expand them into per-item prose
subsections. Include Mermaid diagrams for the architecture (§3) and at least
one runtime flow (§5).

## Procedure

Before drafting or classifying evidence, independently resolve the intended
audience, destination, and governing policy under the
[scope contract](../../docs/public-safety.md#scope), including on direct invocation.
Reuse project-owned defaults and supplied handoffs after verifying them against
available evidence; ask only when needed to resolve an unclear boundary or
authorize further work under that contract.

1. Ask the user to select the full profile, compact profile, or both, then
  confirm project size. If too large to read directly, use only nonwriting
   [discovery steps 1-5](../discover-workspace-file-knowledge/SKILL.md#1-inventory-without-body-reads):
   inventory, fingerprinting, adaptive read-depth selection, preliminary
   file cards, and clustering/theme-presence mapping. Use these results to
   focus investigation; do not invoke proposal routing, proposal writing,
   or adoption.
2. Investigate evidence-first: entry points, config, dependency manifests,
  tests, CI/deploy files, docs. Use
  [adaptive read depth](../discover-workspace-file-knowledge/SKILL.md#3-adaptive-read-depth-decision);
  do not deep-read everything.
3. Draft the selected profile or profiles from inspected evidence only. Mark
  unclear full profile items `Unknown / needs confirmation`; use `Not found`
  in the compact profile. Never invent detail.
4. Produce the diagrams required by each selected profile.
5. For the full profile, draft §9 and §11 as tables, one row per dimension or
  risk, each citing a file or module as evidence.
6. For the full profile, draft §10 with one ADR per visible major decision and
  tag inferred alternatives as inferred. For the compact profile, summarize
  visible decisions under Design Constraints & Important Rules.
7. For the full profile, compile §12 from every
  `Unknown / needs confirmation` mark. For the compact profile, collect weak
  evidence under Confidence & Assumptions.
8. Run the applicable [safety checklist](../../validation/nda-safety-checklist.md)
  on each draft, including the mandatory baseline. Apply the scope contract's
  disclosure rules for known public/external destinations; revalidate when
  draft content, policy, audience, or destination changes.
9. Give each draft a proposed path (e.g. `docs/architecture.md`) and gate it under
  [implementation readiness](../../agents/aet-orchestrator.agent.md#approach):
  start [AET Review](../../agents/aet-review.agent.md) only after the draft owner
  returns `Status: complete`, the done-condition, and verification evidence.
  A blocked or incomplete handoff returns to the owner and stops before either
  gate. On a valid `MERGEABLE: NO`, return all findings to the owning
  implementer; rerun Review only after owner-local repairs and a new complete
  handoff satisfy readiness. After Review runs, return a missing or invalid
  [Review packet](../../validation/gate-report-contract.md) to Review for a valid
  replacement without rewriting or synthesizing it. For packet-only correction
  with unchanged artifacts, reuse the same verified implementation evidence;
  no new owner handoff is required. Stop before Validation until a complete
  valid `MERGEABLE: YES` packet is available; pass it unchanged to
  [AET Validation](../../agents/aet-validation.agent.md). Present the validated
  drafts and proposed paths.
  Wait for `PASS` and human confirmation before writing files.

## Canonical references

- [skills/discover-workspace-file-knowledge/SKILL.md](../discover-workspace-file-knowledge/SKILL.md) - repo mapping and
  adaptive read-depth for large projects
- [skills/assess-project/SKILL.md](../assess-project/SKILL.md) - companion skill for a prioritized
  action plan instead of a reference document
- [validation/nda-safety-checklist.md](../../validation/nda-safety-checklist.md) — mandatory safety pass before saving
  (step 8)
- [validation/markdown-quality-rules.md](../../validation/markdown-quality-rules.md) — heading levels, tables, fenced
  Mermaid blocks
- [validation/compactness-rules.md](../../validation/compactness-rules.md) — keep prose tight; prefer the tables over
  expanded subsections

## Notes

- Read-only through step 8. No file is written until the human confirms the
  destination in step 9.
- If the repository is too large to map exhaustively, state the sampling
  strategy used (which directories/clusters were sampled vs skipped) in the
  Appendix for the full profile or Confidence & Assumptions for the compact
  profile.
- Do not fabricate ADR alternatives, metrics, or risks — every entry needs a
  cited file, module, or pattern as evidence.
