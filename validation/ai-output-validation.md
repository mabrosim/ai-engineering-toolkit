# AI Output Validation

Rules for validating AI-generated content before use.

Validation findings and packets follow
[gate-report-contract.md](gate-report-contract.md).

---

## Step 0 — Resolve Scope and Load Content

- [ ] Independently resolve each artifact's scope under the canonical
      [scope contract](../docs/public-safety.md#scope), including direct invocation
- [ ] Retain scope, evidence, and applicability reasons separately as validation
      input/evidence, never as prose or extra fields in the emitted gate packet
- [ ] Validate only content actually in context — read file paths/references first
- [ ] No speculative findings: every finding cites a concrete location in the real content
- [ ] If required content or evidence cannot be loaded, record `UNCERTAIN` and stop
      checks that depend on it

---

## Step 1 — Safety Check

Apply [nda-safety-checklist.md](nda-safety-checklist.md) according to the resolved
scope contract: baseline and applicable disclosure/public-sanitization checks
run before all remaining checks.

---

## Steps 2–5 — Correctness Evidence

For correctness-bearing changes in the AET workflow, these steps are handoff
and aggregation requirements. Consume the complete AET Review packet: all
findings with locations and its `MERGEABLE` result. Retain that complete packet
unchanged as source evidence; do not emit its `MERGEABLE` terminal in the
Validation packet. Keep Review findings only in that source evidence; do not
forward them into the Validation packet. Do not independently repeat Review's
accuracy, style, quality, or test analysis.

- [ ] Review packet is present and internally consistent
- [ ] Review packet conforms to the shared gate report contract
- [ ] Every Review finding includes a concrete location
- [ ] `MERGEABLE: NO` produces `FAIL`
- [ ] Missing, invalid, or inconsistent required Review evidence produces an
                  `UNRESOLVED` correctness/handoff finding and `UNCERTAIN`

Aggregate the correctness/handoff check as follows:

- A valid `MERGEABLE: YES` packet satisfies the check and creates no Validation
      finding.
- A valid `MERGEABLE: NO` packet violates the check. Emit
      `[HIGH] [FAILED] [CORRECTNESS/HANDOFF] Required Review handoff criterion failed — Retained AET Review packet — Resolve Review findings and rerun Review`
      and produce `FAIL` through Validation's normal precedence.
- A missing Review packet leaves the check unresolved. Emit
      `[MEDIUM] [UNRESOLVED] [CORRECTNESS/HANDOFF] Required Review evidence is missing — AET Review handoff input — Provide a complete valid Review packet`
      and produce `UNCERTAIN` unless another Validation-owned `FAILED` finding
      requires `FAIL`.
- An invalid or internally inconsistent Review packet leaves the check
      unresolved. Retain the received packet separately as rejected source
      evidence, return it to Review unchanged, emit
      `[MEDIUM] [UNRESOLVED] [CORRECTNESS/HANDOFF] Required Review evidence is invalid or internally inconsistent — Rejected AET Review packet — Correct the packet at Review and provide a valid replacement`
      and produce `UNCERTAIN` unless another Validation-owned `FAILED` finding
      requires `FAIL`.

These aggregation findings are Validation-owned. Do not copy Review findings
or terminal fields into them, and do not repair, reinterpret, or synthesize
Review's findings or terminal result.

When a human uses this checklist directly and no AET Review handoff is required,
Steps 2–5 may instead be evaluated manually as written below. Record that direct
mode and the evidence used.

### Step 2 — Accuracy Check

- [ ] Output answers the actual question asked
- [ ] No hallucinated function names or API calls
- [ ] No fabricated library features
- [ ] Code runs without errors

---

### Step 3 — Style Compliance

Apply [code-review-rules.md](code-review-rules.md) "Style Compliance" criteria.

---

### Step 4 — Quality Check

- [ ] No unnecessary complexity
- [ ] No dead code or unused variables
- [ ] No TODO stubs left unresolved
- [ ] Docstrings present where required

---

### Step 5 — Test Check

- [ ] Generated code is testable
- [ ] Tests (if generated) are correct and runnable
- [ ] Edge cases are handled

---

## Result Contract

Determine whether each check applies before evaluating it.

- `PASS`: evidence establishes that an applicable check is satisfied
- `FAIL`: evidence establishes that an applicable check is violated
- `UNCERTAIN`: required content, evidence, or classification is unavailable or unresolved
- `N/A`: the check's trigger is demonstrably false; record the reason

Safety applicability and permitted `N/A` follow the
[scope contract](../docs/public-safety.md#scope), not the action label alone.
Represent violated applicable checks as `FAILED` findings and unavailable or
inconclusive required evidence as `UNRESOLVED` findings. Suggestions outside
current acceptance may be `ADVISORY` findings. Ignore justified `N/A` checks
when creating findings.

Emit `VERDICT: FAIL` when any `FAILED` finding exists. Emit `VERDICT: UNCERTAIN`
when at least one `UNRESOLVED` finding and no `FAILED` finding exists. Emit
`VERDICT: PASS` only when neither exists. `ADVISORY` findings do not change a
positive result.

Safety failures, unresolved scope, and changed scope govern progression and
revalidation under the [scope contract](../docs/public-safety.md#scope).

Human authorization is separate from the technical result. Record
`HUMAN_REVIEW: PENDING`, `HUMAN_REVIEW: COMPLETE`, or `HUMAN_REVIEW: N/A`.
Emit exactly one `VERDICT` terminal followed by exactly one `HUMAN_REVIEW`
terminal. A technical `PASS` does not authorize an action while required human
review is pending.

---

## Common AI Failure Modes

| Failure Mode | What to Check |
|---|---|
| Hallucinated API | Verify function exists in official docs |
| Over-engineering | Simplify before committing |
| Missing error handling | Add explicit exception handling |
| Stale patterns | Verify against current language version |
| Verbose output | Apply compactness rules |

---

## Sign-Off

AI-generated content is approved for use when:

- The overall technical result is `PASS`
- Required human review is `COMPLETE`
- The output is understood, not just trusted
- Intended use is authorized under the resolved scope contract
