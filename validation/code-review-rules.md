# Code Review Rules

Checklist and rules owned by AET Review for correctness and technical
mergeability of code or governance changes.

Review findings follow [gate-report-contract.md](gate-report-contract.md).

---

## Review Coverage Reuse

- Retain prior coverage only where the review baseline and actual changes,
  including affected dependencies, support it. If baseline or evidence is
  insufficient, review the affected scope normally.
- Isolated finding repairs allow focused re-review. Changes to shared
  interfaces, helpers, schemas, trust boundaries, or tests widen review to
  affected consumers; passing tests or unchanged filenames alone are insufficient.
- Emit a complete gate packet with current aggregate findings and `MERGEABLE`
  result across retained and refreshed coverage, not only repaired findings.
  Keep reuse evidence separate from the packet, with no new fields or syntax;
  no separate persisted artifact is required.
- Reuse does not bypass mandatory Review then Validation or safety revalidation
  when relevant content, policy, audience, or destination changes.

---

## Readability

- [ ] Function names clearly describe what they do
- [ ] Variable names are descriptive, not abbreviated
- [ ] No magic numbers — use named constants
- [ ] Comments explain *why*, not *what*
- [ ] Functions are short and focused (single responsibility)

---

## Correctness

- [ ] Logic handles edge cases (empty input, null values)
- [ ] Error handling is present and specific
- [ ] No silent exception swallowing
- [ ] Outputs are validated where necessary

---

## Style Compliance

- [ ] Follows the relevant style guide (Python, PySpark, etc.)
- [ ] Linter passes with no errors
- [ ] Formatter applied
- [ ] Language / runtime lifecycle uses current authoritative evidence scoped
  to the version and assessment date; flag EOL as HIGH, approaching EOL
  (within ~6 months) as LOW

For decision-relevant volatile lifecycle, compatibility, or security claims,
use current authoritative evidence scoped to the relevant versions and dates.
Reuse supplied or repository evidence when sufficient; external lookup is not
required for every review. The caller may supply missing evidence. Missing
required evidence is `UNRESOLVED`, not a training-knowledge guess or optional
waiver.

---

## Security

- [ ] No hard-coded credentials
- [ ] No exposure of sensitive data in logs
- [ ] Input validation present at system boundaries
- [ ] No SQL injection or similar injection risks

---

## Tests

- [ ] New logic has corresponding tests
- [ ] Tests cover the main success and failure paths
- [ ] No test that relies on external state or network

---

## Documentation

- [ ] Public functions have docstrings
- [ ] README updated if behavior changed
- [ ] No stale comments or outdated TODO items
- [ ] Named doc artifacts checked for drift against code (`README.md` and nested
      READMEs, agent-instruction files, architecture/design docs, behavior- or
      schema-asserting docstrings)
- [ ] Model-tier or capability claims identify their evidence status
- [ ] Added or changed capability-based routing mappings cite a predeclared,
  independently reproduced benchmark; unsupported mapping removal is exempt

### Documentation-drift severity

Rate doc findings consistently. A doc claim that contradicts code is never below
MEDIUM.

- **HIGH** — doc actively misleads on safety, security, deployment, or data
  handling (e.g. claims no secrets/env vars are needed when they are; wrong
  deploy steps; wrong data-source behavior).
- **MEDIUM** — doc misstates behavior, schema, or API in a way that wastes
  contributor time but is not safety-relevant.
- **LOW** — cosmetic staleness: outdated file tree, dead links, renamed symbols,
  typos.

---

## Merge Criteria

Code is mergeable only if:

- All applicable checklist items pass
- Supplied CI and test evidence passes when applicable

Determine applicability from task and artifact evidence. Retain justified `N/A`
items and supporting evidence outside the gate packet; they do not waive
mandatory safety under the [Public Safety Guide](../docs/public-safety.md#scope).
Unknown applicability is `UNRESOLVED`, not `N/A`, and blocks mergeability.

Emit `MERGEABLE: NO` when any `FAILED` or `UNRESOLVED` finding exists. Emit
`MERGEABLE: YES` only when neither exists. `ADVISORY` findings do not change a
positive result.

`MERGEABLE` is Review's technical result. Human approval and Validation's
`VERDICT` are separate states.
