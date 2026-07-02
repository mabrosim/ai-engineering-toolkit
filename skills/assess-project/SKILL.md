---
description: "First-pass workspace assessment: discover, review against applicable guidance, validate baseline, produce prioritised plan."
name: assess-project
user-invocable: true
disable-model-invocation: false
---
# Assess Project

## Invocation and ownership

Activate only for a human assessment request or AET Orchestrator's automatic
broad-request kickoff. AET Orchestrator owns this read-only workflow. If already
running there, execute inline; otherwise hand off to that agent with this skill
and the task. If unavailable, stop and report degraded capability.
Do not delegate to another Orchestrator from the owning agent.
Skill metadata and prose do not enforce tool restrictions; preserve the owner's
constraints and the independent Review then Validation passes below.

First-pass kickoff. The AET Orchestrator runs this for broad assessment
requests: map the project, review it against applicable guidance, validate a
safety and quality baseline, and produce a prioritized improvement plan. It is
read-only — it changes nothing and waits for human approval before any edit.

---

## Procedure

```text
Assess the current workspace against applicable instructions, skills, and
installed AET guidance. Change nothing.

0. Confirm agents — check that aet-review and aet-validation are available.
   If a required subagent is unavailable, stop and report degraded capability;
   do not replace the required independent pass with inline review.
   Load a prior assessment or explicit finding-ID map when one is supplied.
   Match unchanged findings by tier, normalized rule, normalized location, and
   normalized finding text; preserve their IDs and assign new IDs after the
   highest used number in each tier. Without prior state, sort findings by that
   same key, then assign sequential IDs for this run. Do not claim those IDs are
   stable across runs.

1. Discover — map the project:
   - entry points, data flow, external calls, config, and tests
   - the structure and the main modules
    - loaded guidance: inventory applicable `*.instructions.md` files and skills
       already exposed by the host. Read files only from the current workspace
       and declared AET install-relative locations; do not traverse other search
       paths. For each detected language or framework, note whether matching
       style guidance exists. Missing guidance is an INFO finding ("No <lang>
         style guidance loaded; propose project-owned CONTENT authoring or reuse
         through applicable project review workflows.").
      For extracted evidence, recommend the existing CONTENT capture, source
      preparation, and candidate-fit workflows; do not invent extraction evidence
      for authored guidance. Do not route language-specific CONTENT to Generate
      Instruction or public engine promotion.
      Reserve Generate Instruction for accepted GENERIC-ENGINE instruction
      adoption with a human-accepted destination owner and frontmatter inputs
      recorded in proposal review.
   Keep a compact map (paths + one-line notes), not file dumps.

2. Review against guidance — delegate a read-only review to aet-review.
   If Review stops at setup, stop the assessment before Validation.
   Map each finding to a specific applicable instruction, skill, or validation
   rule. Preserve its cited location in both outputs: path plus line, heading,
   or symbol; for unavailable input, keep the supplied path or reference.
   Include a documentation pass: review named doc artifacts — `README.md`
   (and nested READMEs), agent-instruction files (`copilot-instructions.md`,
   `AGENTS.md`, `*.instructions.md`), architecture/design docs, and
   behavior- or schema-asserting docstrings — for clarity, validity, and drift
   against the code. A doc claim that contradicts code is a drift finding,
   never below MEDIUM (see `validation/code-review-rules.md`).

3. Validate baseline — delegate to aet-validation. Give it AET Review's complete
   packet unchanged, plus the list of all text and source files in the project.
   It runs two passes:
   a. NDA/public-safety: scan every file for secrets, credentials, internal
      URLs, client names, or confidential data. CRITICAL findings are blockers.
   b. Quality signals: compactness, markdown hygiene, code review flags.
   Surface the full VERDICT (PASS/FAIL/UNCERTAIN) and every CRITICAL/HIGH finding
   verbatim in the assessment output — do not summarise them away.
   If Review and Validation evidence conflict, preserve both results, set the
   baseline to UNCERTAIN, and stop before prioritization or planning.

4. Prioritize — group findings Critical / High / Medium / Low / Info. For each: the rule it
   breaks, the location, and the smallest safe first step to fix it.

5. Plan — propose a sequenced improvement plan. Pick the highest-value,
   lowest-risk item as the first step. Note any safety failures as blockers
   that come first.

6. Present the assessment and await the human's pick. Do not edit anything.
```

---

## Canonical guidance

- Applicable workspace instructions and skills — project-specific guidance
- Installed `instructions/*.instructions.md` — reusable AET guidance
- [validation/code-review-rules.md](../../validation/code-review-rules.md) — review criteria and merge bar
- [validation/nda-safety-checklist.md](../../validation/nda-safety-checklist.md) — mandatory safety gate (runs first)
- [Extract Code Knowledge](../extract-code-knowledge/SKILL.md) - CONTENT capture from code evidence
- [Source preparation](../review-proposal/SKILL.md#extracted-source) and
   [candidate-fit review](../review-proposal/SKILL.md#candidate-fit) - extracted CONTENT review
- [Generate Instruction](../generate-instruction/SKILL.md) - accepted
   [GENERIC-ENGINE adoption](../review-proposal/SKILL.md#generic-engine) with
   [accepted instruction inputs](../review-proposal/SKILL.md#output-format)

---

## Expected Output Format

```text
[!] DEGRADED — <missing required capability>   (omit line if none)

## Map
- <entry point / module> — <one-line note> (path)

## Risks (prioritized)
[C1][CRITICAL] <rule broken> — <finding> — <location> — <smallest safe first step>
[H1][HIGH] <rule broken> — <finding> — <location> — <smallest safe first step>
[M1][MEDIUM] ...
[L1][LOW] ...
[I1][INFO] ...

Each finding carries an ID with a tier prefix (C#, H#, M#, L#, I#), the rule it
breaks, the cited location, the smallest safe first step, and a status (default
open). With a supplied prior assessment or ID map, preserve IDs for unchanged
matched findings so they can be tracked across sessions and PRs. Otherwise IDs
are deterministic only for the current run.

## Findings (machine-readable, YAML)
- {id: H1, tier: HIGH, rule: <rule broken>, finding: <normalized finding text>, location: <location>, fix: <smallest safe first step>, status: open}

## Baseline
Validation: PASS | FAIL | UNCERTAIN
[CRITICAL|HIGH] <finding> — <file> — <fix>   (every CRITICAL/HIGH, verbatim from aet-validation)

## Plan
1. <first step — highest value, lowest risk>
2. ...

## Next step
<what the human should approve to begin>
```

---

## Notes

- Read-only. No edits until the human approves a step from the plan.
- Safety failures are blockers — they come before any quality work.
- Multi-agent by design: discovery by the Orchestrator, review by `aet-review`,
  baseline by `aet-validation`. This is the dogfood kickoff for the Orchestrator.
- If a required specialist subagent is unavailable, stop and emit the
   `DEGRADED` banner; do not replace the required independent pass inline.
