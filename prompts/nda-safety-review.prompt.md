---
description: "NDA and public-safety review: flag confidential data, secrets, or internal details."
agent: "ask"
---
# NDA Safety Review Prompt

Use this prompt to check AI-generated content for NDA compliance.

---

## Prompt

```text
Review the following content for NDA and public safety compliance.

Instructions:
1. Identify any company names, client names, or project codenames.
2. Identify any internal system names, URLs, or endpoints.
3. Identify any PII (names, emails, phone numbers, addresses).
4. Identify any credentials, API keys, or secrets.
5. Identify any proprietary business logic or unreleased product information.
6. For each finding, state: [CATEGORY] Description — Location in content.
7. If nothing is found, respond with: "No NDA issues detected."

Return only the findings list. No preamble.

Content:
<paste content here>
```

---

## Categories

| Category | Meaning |
|---|---|
| COMPANY | Company or client name reference |
| SYSTEM | Internal system or infrastructure name |
| PII | Personally identifiable information |
| CREDENTIAL | Secret, key, token, or password |
| PROPRIETARY | Business logic or unreleased product detail |

---

## Notes

- Run this before any public commit or share.
- Human review is still required after AI output.
- See `validation/nda-safety-checklist.md` for the full checklist.
