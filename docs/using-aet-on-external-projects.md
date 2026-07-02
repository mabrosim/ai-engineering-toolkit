# Using AET on External Projects

A synthetic example of using **AET Orchestrator** for authorized project work,
with separate paths for project knowledge and generic engine improvements.

The three trading-style services below are illustrative, not toolkit defaults.
Resolve real project scope and policy before applying any workflow.

---

## The example projects

| Project | Role | Typical issues to look for |
|---|---|---|
| `indicator-lambda` | AWS Lambda that computes trading indicators on demand | Cold-start cost, untyped event parsing, no input validation, heavy deps |
| `signal-observer` | Invokes the indicator service, decides whether to emit a signal | Tight coupling to the Lambda, hidden thresholds, no retry/timeout policy |
| `price-simulator` | Generates synthetic price history over time | Slow loops, non-deterministic seeds, no schema for output |

These are independent services with one dependency edge: `signal-observer` calls
`indicator-lambda`. Treat them as separate engagements that share a rule set.

---

## Step 0 — Install the toolkit

Install the complete [manifest bundle](../scripts/aet-manifest.txt) into each
repo; isolated agents or partial directory copies omit required dependencies.
Check [installer requirements](installer-release-contracts.md#requirements),
including SHA-256 tooling for local installs. From the local AET clone:

```bash
bash scripts/aet-install.sh --target /path/to/project-example --dry-run
bash scripts/aet-install.sh --target /path/to/project-example
```

Preview makes no destination writes; standalone mode still downloads, verifies,
and extracts in temporary storage. Review and share only exact emitted
`[aet-install] share:` entries, including governed `.github/docs/` files,
`.github/LICENSE`, and `.github/.aet-managed-state`. Do not stage whole
directories; review content-pack files separately.

Open the target repo in VS Code and select **AET Orchestrator** after the host
discovers the installed locations. For personal `--global` setup, host limits,
and scope switching, follow
[installation scope](installer-release-contracts.md#installation-scope);
do not activate global AET locations alongside a repo-local install.

---

## Step 1 — Describe the current state

Request a nonwriting [assessment](../skills/assess-project/SKILL.md) against
applicable project guidance. The Orchestrator owns the assessment summary;
AET Review owns formal correctness findings, not general discovery output.

Prompt shape:

```text
Assess this repo: entry points, data flow, external
calls, tests, and the top risks. Do not change anything yet.
```

Requested output: a short architecture sketch, risks mapped to files, and gaps
against applicable guidance, such as an undocumented inter-service contract.

---

## Step 2 — Validate what exists

Resolve each artifact's audience, destination, and governing policy under the
[Public Safety Guide's scope contract](public-safety.md#scope). Set the intended
audience once in existing project-owned guidance, such as the host project's
root `AGENTS.md`, outside the managed AET engine. Reuse that default without
repeated audience questions; repository visibility alone does not establish scope.

Generic durable-default example:

```text
Ordinary host work defaults to internal/private use by authorized project
maintainers, subject to governing project policy. This default grants no
publication or external-sharing authority and does not relax baseline checks
or public-safety requirements for AET engine or EXPORT material.
```

The Orchestrator carries per-artifact scope, policy evidence, and check
applicability separately from gate packets. Specialists, including direct
Validation invocations, independently verify scope against available evidence.

When explicitly requesting a baseline, use [AET Review](../agents/aet-review.agent.md)
and [AET Validation](../agents/aet-validation.agent.md) under the
[gate routing contract](../agents/aet-orchestrator.agent.md#approach).
Ordinary factual analysis does not automatically require both gates.
Apply safety checks first; neither an internal nor public-safe `PASS` grants
external-sharing authority. The scope contract owns blockers and revalidation.

---

## Step 3 — Refactor, behavior preserved

Size work by coherent verifiable outcomes, ownership, shared contracts,
dependencies, integration risk, and uncertainty, not words or conjunctions.
Group related same-owner work sharing tests; split at independently verifiable
outcomes, authority boundaries, or material risk. See
[Scope Sizing](../agents/aet-orchestrator.agent.md#scope-sizing).

Example engineering outcomes:

| Outcome | Verification |
|---|---|
| Isolate indicator calculations while preserving the handler contract | Characterization tests for accepted inputs, outputs, and errors |
| Make the observer's client contract explicit | Contract tests across observer and indicator service |
| Optimize simulation without changing declared results | Fixed-seed fixtures and output-schema checks |

Keep related implementation and tests with **AET Engineering**; route semantic
documentation to **AET Documentation**. Sequence cross-service work around its
shared contract and integration check, rather than treating each file as a task.

New rejection rules, retries, or seed defaults can change behavior; obtain
explicit authorization for those changes instead of calling them pure refactors.

### Optional: propose a restructure

The Orchestrator's [project-structuring procedure](../agents/aet-orchestrator.agent.md#project-structuring)
owns the KEEP-LOCAL plan at `.aet/proposals/local/restructure-<topic>.md`.
No structural moves occur without human approval.

---

After a complete owner handoff with verification evidence, correctness-bearing
changes require Review, then Validation, and required human approval before
integration. Follow the linked gate routing contract; do not treat an intended
workflow or passing example as proof of behavior preservation.

---

## How improvements and knowledge flow

### Generic engine improvements

Proposal capture is off by default. After the human explicitly enables it for
the engagement or workspace, the Orchestrator delegates to `aet-proposal`
(shipped with the bundle) to capture observed engine gaps. The
[Route contract](../skills/propose-improvement/SKILL.md#prompt) owns
classification and review eligibility; capture is not adoption.

Humans carry only sanitized generic engine EXPORT proposals from
`.aet/proposals/export/` to toolkit `proposals/`. **AET Steward** applies
[Review Proposal](../skills/review-proposal/SKILL.md) there. KEEP-LOCAL stays
in its source project and retains the route owner's approval requirements.
Private evidence must never be carried into toolkit governance.

### Extracted code knowledge

Language, framework, and domain guidance is project CONTENT even when several
services share it. [Discovery](../skills/discover-workspace-file-knowledge/SKILL.md)
and [extraction](../skills/extract-code-knowledge/SKILL.md) own source capture;
[Review Proposal](../skills/review-proposal/SKILL.md) owns the two reviews:

1. Capture proposals under source `.aet/proposals/<export|local>/`.
2. Source review may `ABANDON`, `DEFER`, or `PREPARE` noncanonical candidates
   under route-matching `.aet/content-candidates/<export|local>/`.
3. A human transfers only sanitized, prepared EXPORT candidates to a
   content-pack workspace; KEEP-LOCAL proposals and candidates never leave source.
4. Candidate-fit review compares destination owners before `MERGE`, `ADOPT`,
   `ABANDON`, or `DEFER`, with required Review, Validation, and human gates.
   KEEP-LOCAL fit review occurs in the source project.

Processed CONTENT proposals go neither to the toolkit inbox nor directly to a
content pack; only prepared EXPORT candidates take the transfer path.

---

## Identifying improvements: a checklist

- Repeated project conventions or valuable unique solutions: propose CONTENT.
- An evidenced generic skill or validation defect: capture an engine proposal
  after opt-in, rather than silently changing installed policy.
- Existing guidance already covers the lesson: reuse its owner.
- Uncertain evidence, classification, or safety: resolve it before adoption or
  disclosure under the owning workflow.
