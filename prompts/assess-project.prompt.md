---
description: "First-pass project assessment: discover, review against rules, validate baseline, produce prioritised plan."
agent: "AET Orchestrator"
---
# Assess Project Prompt

First-pass kickoff. The AET Orchestrator runs this automatically on a new
engagement: map the project, review it against the exported rules, validate a
safety and quality baseline, and produce a prioritized improvement plan. It is
read-only — it changes nothing and waits for human approval before any edit.

---

## Procedure

```text
Assess this repository against the exported rules. Change nothing.

0. Confirm agents — check that aet-review and aet-validation are available.
   If a required subagent is unavailable, run that pass inline using the same
   canonical rules (never skip it) and flag the run as degraded.

1. Discover — map the project:
   - entry points, data flow, external calls, config, and tests
   - the structure and the main modules
   - loaded standards: list every `*.instructions.md` file visible in the
     workspace (check `.github/instructions/`, `instructions/`, and any path on
     the active instructions search path). For each detected language or
     framework, note whether a matching style instruction exists. Missing ones
     are INFO findings ("No <lang>-style instructions loaded — consider adding
     one from the content layer or authoring one with
     `prompts/generate-instruction.prompt.md`.").
   Keep a compact map (paths + one-line notes), not file dumps.

2. Review against rules — delegate a read-only review to aet-review.
   Map each finding to a specific exported rule and a file:line.
   Include a documentation pass: review named doc artifacts — `README.md`
   (and nested READMEs), agent-instruction files (`copilot-instructions.md`,
   `AGENTS.md`, `*.instructions.md`), architecture/design docs, and
   behavior- or schema-asserting docstrings — for clarity, validity, and drift
   against the code. A doc claim that contradicts code is a drift finding,
   never below MEDIUM (see validation/code-review-rules.md).

3. Validate baseline — delegate to aet-validation. Give it the list of all text
   and source files in the project. It runs two passes:
   a. NDA/public-safety: scan every file for secrets, credentials, internal
      URLs, client names, or confidential data. CRITICAL findings are blockers.
   b. Quality signals: compactness, markdown hygiene, code review flags.
   Surface the full VERDICT (PASS/FAIL) and every CRITICAL/HIGH finding
   verbatim in the assessment output — do not summarise them away.

4. Prioritize — group findings High / Medium / Low. For each: the rule it
   breaks, the location, and the smallest safe first step to fix it.

5. Plan — propose a sequenced improvement plan. Pick the highest-value,
   lowest-risk item as the first step. Note any safety failures as blockers
   that come first.

6. Present the assessment and await the human's pick. Do not edit anything.
```

---

## Canonical rules

- `instructions/*.md` — the exported coding standards being measured against
- `validation/code-review-rules.md` — review criteria and merge bar
- `validation/nda-safety-checklist.md` — mandatory safety gate (runs first)

---

## Expected Output Format

```text
[!] DEGRADED — <which passes ran inline / single-agent>   (omit line if none)

## Map
- <entry point / module> — <one-line note> (path)

## Risks (prioritized)
[H1][HIGH] <rule broken> — <finding> — <file:line> — <smallest safe first step>
[M1][MEDIUM] ...
[L1][LOW] ...

Each finding carries a stable ID with a tier prefix (C#, H#, M#, L#),
the rule it breaks, the file:line, the smallest safe first step, and a status
(default open). IDs are stable across runs so findings can be tracked and
closed across sessions and PRs.

## Findings (machine-readable, YAML)
- id: H1
  tier: HIGH
  rule: <rule broken>
  location: <file:line>
  fix: <smallest safe first step>
  status: open

## Baseline
Validation: PASS | FAIL
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
- If a specialist subagent is unavailable, run its pass inline against the same
  canonical rules and emit the `DEGRADED` banner so the human knows the result
  is single-agent and not independently validated.
