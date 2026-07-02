# Public Release Checklist

Use this checklist before making any content public (GitHub, blog, portfolio).

---

## Content Review

- [ ] NDA Safety Checklist passed
- [ ] No internal references remaining
- [ ] Examples use generic, synthetic data
- [ ] No references to internal tooling or infrastructure

---

## Code Quality

- [ ] Code is linted and formatted
- [ ] Tests pass
- [ ] No dead code or debug artifacts
- [ ] No `TODO` comments with sensitive context
- [ ] No commented-out code blocks left in place

---

## Documentation

- [ ] README exists and is accurate
- [ ] Usage examples are clear and runnable
- [ ] Dependencies are documented
- [ ] License is present and appropriate

---

## Repository Hygiene

- [ ] `.gitignore` covers secrets and local config files
- [ ] No large binary files committed
- [ ] No `.env` or config files with real values
- [ ] Commit history does not contain sensitive information

---

## Final Steps

- [ ] Reviewed by a second person or re-read after 24 hours
- [ ] Repository visibility confirmed (public vs private)
- [ ] License chosen and added
