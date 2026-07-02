# NDA Safety Checklist

Use this checklist before sharing, publishing, or committing any content.

---

## Pre-Commit Check

- [ ] No company names mentioned
- [ ] No client names mentioned
- [ ] No project codenames mentioned
- [ ] No internal system names (databases, clusters, queues)
- [ ] No internal URLs or endpoints
- [ ] No internal IP addresses
- [ ] No employee names or roles
- [ ] No organizational structure references
- [ ] No proprietary business logic
- [ ] No unreleased product information
- [ ] No absolute home-directory paths (e.g. `/Users/<name>/...`,
      `/home/<name>/...`, `C:\Users\<name>\...`) — they expose developer
      identity and internal filesystem layout. Replace with relative paths,
      env vars, or config parameters.

---

## Tooling & Instruction Files

Scan agent-instruction and config files for the same items as the code scan —
they are neither "code" nor "docs", so checklist-driven reviews routinely skip
them even though they embed internal resource names, regions, and developer
paths. Internal identifiers found here are the same severity as in source code.

- [ ] Agent-instruction files scanned (`copilot-instructions.md`, `AGENTS.md`,
      `*.instructions.md`)
- [ ] Editor/workspace settings and launch configs scanned
- [ ] CI/CD and packaging scripts scanned
- [ ] No internal system names, paths/URLs, account IDs/ARNs, region or
      datastore identifiers in any of the above

---

## Data Safety Check

- [ ] No real customer data
- [ ] No PII (names, emails, phone numbers, addresses)
- [ ] No financial data
- [ ] No health data
- [ ] All example data is synthetic or anonymized

---

## Credential Safety Check

- [ ] No API keys
- [ ] No passwords or tokens
- [ ] No private certificates
- [ ] No AWS account IDs or ARNs referencing real accounts
- [ ] No database connection strings

---

## Code Safety Check

- [ ] No hard-coded internal configuration values
- [ ] No internal package names or import paths exposed
- [ ] No proprietary algorithms without abstraction

---

## Final Approval

- [ ] Content reviewed by human before publishing
- [ ] NDA obligations checked against content
