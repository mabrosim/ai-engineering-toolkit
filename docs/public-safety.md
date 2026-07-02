# Public Safety Guide

How this repository keeps content safe for public sharing.

Public safety is mandatory.
If safety is uncertain, stop and ask before committing, publishing, or exporting.

## What Public Safety Means

Any repository file should be shareable publicly without exposing:

- NDA-protected information
- Company, client, customer, or project identity
- Personal data
- Credentials or secrets
- Proprietary business logic
- Internal systems, paths, tools, or infrastructure
- Raw private examples copied from real work

## Scope

This guide applies to:

- Documentation
- Agents
- Prompts
- Instructions
- Validation files
- Scripts
- Examples
- Generated or AI-edited content
- Proposal files before triage

## Blocked Content

Do not include:

- Company, client, customer, or project names
- Internal project codenames
- Internal system names
- Internal URLs, endpoints, hostnames, or paths
- Usernames or home-directory paths
- Real IDs, account numbers, resource names, schemas, or package names
- Secrets, tokens, keys, certificates, credentials, or auth headers
- PII or identifying data
- Proprietary algorithms, business rules, or implementation details
- Raw copied content from private repositories or work projects

## Example Safety

Examples must be synthetic or generic.

Use:

- `user_001`
- `project-example`
- `example.com`
- `test.local`
- `EXAMPLE_SECRET`
- `YYYY-MM-DD`
- `123.45`

Avoid realistic identifiers that could look real.

## Agent, Prompt, and Instruction Safety

Before adopting AI-facing content, check that it does not reveal:

- Internal project context
- Private repository names
- Real file paths
- Private coding patterns tied to one company
- Internal tool names
- Copied review comments from private work
- Prompts containing confidential source text

Use generic wording unless identity is required and public-safe.

## Script and Code Snippet Safety

Scripts and snippets must be generic.

Do not include:

- Real infrastructure identifiers
- Real database, table, schema, or bucket names
- Real package or module names from private systems
- Real environment variable names tied to private systems
- Real credentials, even in comments
- Hardcoded private paths or usernames

Use placeholders and document assumptions.

## Pre-Commit Check

Before committing any changed file, verify no secrets, PII, internal identifiers, or proprietary logic remain, that examples are synthetic, that generated content was reviewed, and that the engine/content boundary is preserved.

Use `validation/nda-safety-checklist.md` for the full checklist.

## Severity

- Blocker: secrets, credentials, PII, NDA content, proprietary logic
- Fix before publish: private names, paths, endpoints, system identifiers
- Warning: examples too realistic, overly specific, or hard to prove synthetic

Any blocker means reject until fixed.

## If Sensitive Content Is Found

Before commit:

- Do not commit
- Remove or replace sensitive content
- Re-run safety checks

After commit but before push:

- Remove from history using approved local cleanup
- Re-run safety checks

After push:

- Stop and ask the human
- Treat as incident
- Rotate exposed secrets if any
- Use approved history-rewrite process
- Verify remote history and tags as needed

Do not pretend cleanup succeeded without verification.

## Review Cadence

Run public-safety review:

- Before every public push
- Before export packaging
- Before adopting generated content
- Before moving proposals into canonical artifacts
- Before publishing a release
