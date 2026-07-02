---
description: "Investigate a repository and draft an Architecture Design Document: context, structure, runtime flows, decisions, risks, and open questions."
agent: "AET Orchestrator"
---

# Generate Architecture Doc Prompt

Investigate a software project as a black box and draft an Architecture Design
Document for engineers who need to understand, maintain, extend, or review the
system.

The project may be any language, framework, or architectural style (monolith,
service, pipeline, library, CLI, API backend, data or ML pipeline, etc.). Do not
assume a stack.

Read-only through step 8. Ground every claim in inspected evidence; mark
anything unclear as `Unknown / needs confirmation` instead of inventing it.

## Purpose

Produce a persisted reference document — not a task plan — that engineers use
to onboard, plan changes, and evaluate proposals against the system's actual
structure.

This complements `assess-project.prompt.md`: run that prompt when the goal is
"what should I fix first" (produces a prioritized action plan); run this one
when the goal is "what does this system look like" (produces a reference doc).

## Document structure

```text
# 1. Executive Summary — purpose, key characteristics, top risks
# 2. System Context — external systems/APIs/users, I/O boundaries, deployment context
# 3. High-Level Architecture — style, major modules, interactions, Mermaid diagram
# 4. Codebase Map — table: module/directory | responsibility | key files | depends-on | role
# 5. Runtime Flows — main execution paths (startup, request, pipeline, batch/CLI);
     trigger, steps, modules, inputs/outputs, error handling per flow
# 6. Data Architecture — models, formats, storage, caching, validation, lifecycle,
     sensitive data if visible
# 7. Dependency Architecture — key third-party libs, internal coupling, direction, cycles
# 8. Configuration & Environment — config mechanism, env vars, secrets handling, profiles
# 9. Cross-Cutting Quality — table: dimension | current state | evidence | risk | improvement
     dimensions: observability (logging/metrics/tracing), security, performance/
     scalability, testing, deployment/operations
# 10. Key Architecture Decisions — ADR-style per visible decision: status, context,
     decision, alternatives (mark inferred ones), consequences, evidence
# 11. Risks & Recommendations — table: risk/gap | impact | evidence | recommendation |
     term (short/medium/long) | priority
# 12. Open Questions — every `Unknown / needs confirmation` mark raised in §1-§11
# 13. Appendix — files inspected, sampling strategy if repo was too large to cover
     fully, suggested additional diagrams
```

Use tables for §4, §9, and §11 — do not expand them into per-item prose
subsections. Include Mermaid diagrams for the architecture (§3) and at least
one runtime flow (§5).

## Procedure

1. Scope: confirm project size. If too large to read directly, run
   `discover-workspace-file-knowledge.prompt.md` first and use its repo map and
   theme-presence output to focus investigation on the architecturally
   important areas.
2. Investigate evidence-first: entry points, config, dependency manifests,
   tests, CI/deploy files, docs. Use adaptive read depth from the referenced
   prompt — do not deep-read everything.
3. Draft §1-§8 from inspected evidence only. Mark unclear items
   `Unknown / needs confirmation`; never invent detail.
4. Produce the two required Mermaid diagrams.
5. Draft §9 and §11 as tables, one row per dimension or risk, each citing a
   file or module as evidence.
6. Draft §10: one ADR per visible major decision (framework choice, storage
   approach, sync/async, API style, packaging, error-handling strategy, etc.).
   Tag inferred alternatives as inferred.
7. Compile §12 from every `Unknown / needs confirmation` mark used above.
8. Safety pass: scan the draft for secrets, credentials, internal hostnames,
   or client/customer names pulled in as evidence; redact or generalize before
   proceeding (see `validation/nda-safety-checklist.md`).
9. Propose a destination path (e.g. `docs/architecture.md`) and present the
   draft. Wait for human confirmation before writing the file.

## Canonical references

- `prompts/discover-workspace-file-knowledge.prompt.md` — repo mapping and
  adaptive read-depth for large projects
- `prompts/assess-project.prompt.md` — companion prompt for a prioritized
  action plan instead of a reference document
- `validation/nda-safety-checklist.md` — mandatory safety pass before saving
  (step 8)
- `validation/markdown-quality-rules.md` — heading levels, tables, fenced
  Mermaid blocks
- `validation/compactness-rules.md` — keep prose tight; prefer the tables over
  expanded subsections

## Notes

- Read-only through step 8. No file is written until the human confirms the
  destination in step 9.
- If the repository is too large to map exhaustively, state the sampling
  strategy used (which directories/clusters were sampled vs skipped) in the
  Appendix rather than silently omitting areas.
- Do not fabricate ADR alternatives, metrics, or risks — every entry needs a
  cited file, module, or pattern as evidence.
