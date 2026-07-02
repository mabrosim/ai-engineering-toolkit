---
description: "Capture an exportable or project-local improvement as a structured proposal doc."
name: propose-improvement
user-invocable: true
disable-model-invocation: false
---
# Propose Improvement

## Invocation and ownership

Load the Route contract whenever another workflow requires it; reading policy
does not enable capture. For an explicit human capture request, run inline in
the current agent within its existing write authority; the request is opt-in
for that capture. AET Orchestrator owns restructuring plans under its Project
structuring workflow. Optional background self-improvement capture remains
off by default and is delegated by AET Orchestrator to AET Proposal only after
explicit human opt-in; if Proposal is absent, skip that optional pass silently.
Never self-delegate. Other authorized CONTENT producers consume this contract
under their own write limits. Skill metadata grants no tools, adoption
authority, or opt-in.

Use this skill to capture a reusable lesson as either an exportable toolkit
proposal or project-local guidance proposal.

---

## Prompt

```text
Capture an improvement proposal from the current project work.

Steps:
0. Confirm the human explicitly enabled proposal capture for this engagement or
   workspace. Otherwise stop without writing.
1. Identify one concrete gap observed while working: a missing rule, a weak
   skill, a noisy or missing validation check, or a structural problem.
2. Anchor it — name the investigation topic (the question or subject you were
   exploring) and carry it into the proposal so the thread is not lost.
3. State the proposed change as a single, explicit, testable statement.
4. Give evidence (pattern or file role).
5. Apply this Route contract:
    - EXPORT — generalizes beyond the current project and is public-safe. Run the
     NDA/public-safety check. Capture it under the current project's
     `.aet/proposals/export/`; its review destination is `proposals/` in the
     toolkit repository. Review or adoption is allowed only when the current
     workspace is the toolkit repository, the proposal is in `proposals/`, and
       toolkit-local governance passes. The extracted-code-knowledge exception
       below permits source review and candidate preparation, never adoption. If
       sanitization loses its point, route it KEEP-LOCAL. If safety is uncertain,
       stop and request human review.
    - KEEP-LOCAL — useful but project-bound. Keep it under the current project's
       `.aet/proposals/local/`. Generic engine proposal review or adoption is
       allowed only in that project after explicit human approval is supplied for
       the current review and recorded in proposal review notes before any quality
       report or owning artifact is written. Never export it. CONTENT workflows
       use the source PREPARE path below.
6. Record a candidate destination and intended consumer. Do not recommend or
   make an adoption decision.
7. For generic engine improvements, skip one-offs and guidance already covered
   by an existing owner. For `Workflow: extracted-code-knowledge` or `Workflow:
   workspace-file-knowledge-discovery`, use the specialized skill's
   authoritative schema; the generic AET Proposal schema does not apply. Retain
   grounded unique units during code-knowledge extraction.

Write one Markdown proposal per concept at the path selected by the Route
contract. For generic engine proposals, use the canonical generic-engine
proposal schema linked below. No preamble.
```

---

## Canonical references

- [skills/review-proposal/SKILL.md](../review-proposal/SKILL.md) - proposal review and adoption procedure
- [skills/nda-safety-review/SKILL.md](../nda-safety-review/SKILL.md) —
   the public-safety gate to run before EXPORT
- [Documentation style](../../instructions/documentation-style.instructions.md) —
   proposal formatting
- [agents/aet-proposal.agent.md](../../agents/aet-proposal.agent.md#output-format) - canonical
   generic-engine proposal schema
- [skills/extract-code-knowledge/SKILL.md](../extract-code-knowledge/SKILL.md) -
   extracted-code-knowledge schema
- [skills/discover-workspace-file-knowledge/SKILL.md](../discover-workspace-file-knowledge/SKILL.md) -
   workspace-file-knowledge-discovery schema

---

## CONTENT workflow exception

A proposal marked `Workflow: extracted-code-knowledge` or
`Workflow: workspace-file-knowledge-discovery` is CONTENT, not an engine
improvement. It may be reviewed in its source project to classify units and
prepare, but not adopt, candidate documents under:

- `.aet/content-candidates/export/` for sanitized portable content
- `.aet/content-candidates/local/` for content that never leaves the source

Human transfer of an EXPORT candidate to a content-pack workspace enables a
second candidate-fit review there. KEEP-LOCAL candidates remain in the source.
Engine skill, agent, instruction, rule, or validation improvements still use
the generic EXPORT carry-back path through toolkit `proposals/`.

Use these type and owner mappings:

- generic `rule` → engine `instructions/` or `skills/`
- generic `skill` → engine `skills/<name>/SKILL.md`
- generic `agent` → engine `agents/`
- generic `instruction` → engine `instructions/`
- generic `validation` → engine `validation/`
- generic `restructure` → project-local plan
- extracted EXPORT `catalog` → content candidate, then `catalogs/*.md` in a
   content pack
- extracted EXPORT `instruction` → content candidate, then
   `instructions/*.instructions.md` in a content pack
- extracted KEEP-LOCAL `catalog` → content candidate, then `.aet/catalogs/*.md`
   in its source project
- extracted KEEP-LOCAL `instruction` → content candidate, then
   `.aet/instructions/*.instructions.md` in its source project

Use only these intended-consumer values: `implementation workflow`,
`review workflow`, `refactoring workflow`, `architecture workflow`,
`validation workflow`, `proposal workflow`, `core agent`, or `none`.

---

## Notes

- This skill owns the Route contract.
- Route at the source, where NDA context is available.
- Proposals are inputs, not adoption decisions.
- Prepared content candidates are inputs, not canonical content.
- Used by the optional `aet-proposal` agent, which ships in the portable bundle.
