# Code Review Rules

Checklist and rules for reviewing code in this repository.

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
- [ ] Language / runtime version is not EOL or approaching EOL — use your training
      knowledge of release schedules to judge; flag EOL as HIGH, approaching EOL
      (within ~6 months) as LOW

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

- All checklist items pass
- CI/CD passes (if applicable)
- At least one reviewer approved
