# Using AET on External Projects

A worked example of using **AET Orchestrator** to review, validate, and refactor
a real codebase — and how the work feeds improvements back into this toolkit.

The example uses three generic trading-style services. Substitute your own
projects; the workflow is the same. Keep all examples synthetic and public-safe.

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

Install the agent bundle into each repo (see the main
[README](../README.md#install)):

```bash
# shared team install — zero-config, commit to .github/
bash scripts/aet-install.sh

# or user-global install — available in every workspace
bash scripts/aet-install.sh --global
```

Re-open the repo in VSCode and select **AET Orchestrator** in the chat agent
picker. Rule modules land in `.github/instructions/`, `.github/validation/`,
and `.github/prompts/` (or under `.aet/` for a personal install).

---

## Step 1 — Describe the current state

Ask the Orchestrator to map the code before changing anything. It delegates to
`aet-review` (read-only) and returns a grounded summary, not a guess.

Prompt shape:

```text
Describe the current state of this repo: entry points, data flow, external
calls, tests, and the top risks. Do not change anything yet.
```

Expected output: a short architecture sketch, a risk list mapped to files, and
the gaps against the exported rules (for example, missing input validation in
`indicator-lambda` or an untyped contract between the two services).

---

## Step 2 — Validate what exists

Before refactoring, gate the current code through `aet-validation`:

- **NDA/public-safety** — no secrets, client names, or internal endpoints.
- **Correctness signals** — tests present and passing, deterministic behavior.
- **Quality** — complexity, dead code, and maintainability against
  `instructions/` standards.

This produces a pass/fail baseline. Fix any safety failures first — they block
everything else.

---

## Step 3 — Refactor, behavior preserved

The Orchestrator decomposes the work into small, sequenced subtasks and delegates
each to the right specialist, then routes results through review and validation.

Example plan for `indicator-lambda`:

1. Add a typed event model and input validation at the handler boundary
   (`aet-engineering`).
2. Extract indicator math into a pure, unit-testable module (`aet-engineering`).
3. Add docstrings and a usage README (`aet-documentation`).
4. Confirm behavior preserved — same outputs for the same inputs
   (`aet-review` + `aet-validation`).

Example plan for `signal-observer`:

1. Define an explicit client contract for calling `indicator-lambda` (timeouts,
   retries, error mapping).
2. Move signal thresholds into named configuration, not inline literals.
3. Add tests around the emit/skip decision boundary.

Example plan for `price-simulator`:

1. Vectorize or batch the price-generation loop (`aet-engineering` handles both
   general and Spark work).
2. Make the random seed explicit for reproducibility.
3. Define an output schema and validate it.

Rule of thumb: if a task needs an "and" to describe it, split it into two.

### Optional: propose a restructure

For long-lived or drifted projects, the Orchestrator may also propose a structural
reshape — folder layout, module boundaries, config placement. It writes the plan
to `.aet/proposals/restructure-<topic>.md` (current layout, proposed layout,
rationale, file-move map) and waits for your approval before moving anything.
Without approval the structure stays as-is.

---

For every change, the Orchestrator confirms behavior is preserved:

- Tests pass (add characterization tests first if coverage is thin).
- Same inputs produce the same outputs (or document any intended change).
- For data work, row counts and schemas match before and after.

Nothing merges until review and validation both pass.

---

## How improvements flow back into the toolkit

After each engagement, the Orchestrator automatically delegates to `aet-proposal`
(shipped with the standard bundle) to capture observed gaps. Then:

1. **Capture & route** — while the Orchestrator works the repo, `aet-proposal`
   records any observed gap (missing rule, weak prompt, noisy or missing check,
   structural problem) and triages it **at the source**, where the NDA context
   lives:
   - **EXPORT** → `.aet/proposals/export/` — generalizes beyond this project and
     is public-safe; NDA-checked here before it leaves.
   - **KEEP-LOCAL** → `.aet/proposals/local/` — real and useful but project-bound
     (proprietary framework, license dialect, internal naming); stays in this repo
     for its own instruction set, applied by the Orchestrator.

   It writes proposals only.
2. **Carry back** — copy only `export/` proposals into this toolkit's `proposals/`
   inbox. KEEP-LOCAL proposals never leave the project.
3. **Triage** — **AET Steward** processes the inbox with `prompts/review-proposal.prompt.md`:
   - **Fits the philosophy** → adopt into canonical `instructions/`; it exports
     to every project on the next install.
   - **Off-philosophy, public-safe, broadly reusable** → add to the personal
     content repo so it is available across projects via `--content-path`.
   - **Proprietary that slipped through** → RETURN to the owning project via the
     gitignored `.aet/proposals-for-externals/<project>/` for the maintainer to
     carry back.
   - **Not useful / unsafe** → discard with a one-line reason.
4. **Re-export** — re-run the installer in the external repo to pick up the
   improved rules.

Without `aet-proposal` present (older installs), the Orchestrator skips the
proposal pass silently. Re-run the installer to pick up the agent.

---

## Identifying improvements: a checklist

When deciding what to fix in an external project — and what to promote back into
the toolkit — look for:

- Repeated review comments across files → candidate for a new rule.
- A prompt that needed heavy hand-holding → the prompt is too weak; fix it here.
- A validation check that flagged noise or missed a real issue → tune the
  checklist.
- A pattern that recurs across all three services → promote to `instructions/`.
- A pattern unique to one service → keep it in that project's own instruction set.

---

## Summary

- Install the bundle, then **review → validate → refactor → verify**.
- The Orchestrator delegates and gates; you approve.
- Every engagement is a chance to sharpen the rules — route lessons through the
  Steward so the next project starts from a higher baseline.
