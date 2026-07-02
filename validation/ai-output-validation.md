# AI Output Validation

Rules for validating AI-generated content before use.

---

## Step 0 — Load the Content

- [ ] Validate only content actually in context — read file paths/references first
- [ ] No speculative findings: every finding cites a concrete location in the real content
- [ ] If the content cannot be loaded, STOP — emit no findings and no verdict

---

## Step 1 — Accuracy Check

- [ ] Output answers the actual question asked
- [ ] No hallucinated function names or API calls
- [ ] No fabricated library features
- [ ] Code runs without errors

---

## Step 2 — Style Compliance

Apply [code-review-rules.md](code-review-rules.md) "Style Compliance" criteria.

---

## Step 3 — Safety Check

Apply [nda-safety-checklist.md](nda-safety-checklist.md) in full.

---

## Step 4 — Quality Check

- [ ] No unnecessary complexity
- [ ] No dead code or unused variables
- [ ] No TODO stubs left unresolved
- [ ] Docstrings present where required

---

## Step 5 — Test Check

- [ ] Generated code is testable
- [ ] Tests (if generated) are correct and runnable
- [ ] Edge cases are handled

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

- All validation steps pass
- A human reviewed the output
- The output is understood, not just trusted
