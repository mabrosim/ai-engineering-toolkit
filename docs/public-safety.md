# Public Safety Guide

How this repository ensures all content is safe for public sharing.

---

## What Public Safety Means

Public safety means that any file in this repository can be shared publicly without:

- Violating an NDA
- Exposing company information
- Exposing client information
- Exposing personal data
- Exposing credentials or secrets

---

## Pre-Commit Requirements

Before committing any file, verify:

1. No company or client names present
2. No internal project codenames
3. No internal system names or endpoints
4. No PII of any kind
5. No credentials, keys, or tokens
6. No proprietary business logic

Use `validation/nda-safety-checklist.md` to verify.

---

## Data Safety

- All example data must be synthetic
- Use placeholder names: `user_001`, `order_001`, `example@email.com`
- Use placeholder domains: `example.com`, `test.local`
- Use placeholder values for IDs, amounts, and dates

---

## Code Safety

- No real ARNs, account IDs, or resource names
- No real database names, table names, or schema names that could identify a company
- No internal package names in imports

---

## Credential Safety

- Use `os.environ.get("MY_SECRET")` patterns in examples
- Never show real values, even in comments
- `.env` files must be in `.gitignore`

---

## What To Do If Sensitive Content Is Found

1. Do not push the commit
2. Remove the sensitive content
3. Re-run the NDA safety checklist
4. If already committed, use `git rebase` to remove it from history

---

## Review Cadence

- Review content before every public push
- Run the NDA safety checklist prompt for any new or modified files
