# Public Safety Guide

Canonical artifact scope, audience, and safety contract for AET-assisted work.

## Scope

Resolve safety applicability per artifact, including in mixed workspaces.
Installing AET does not submit unrelated host files for evaluation or public
sanitization. All work undertaken through AET follows this contract.

### Mandatory Baseline

Every evaluated artifact requires protection against real secrets, credentials,
and PII exposure, compliance with governing host policy, authorized handling and
disclosure, and applicable correctness and quality checks. These requirements
cannot be waived by a private audience or a project default.

Necessary nonpersonal internal names, paths, URLs, and business context are
allowed only in ordinary host content authorized for its intended audience.
They are not exceptions for public engine artifacts or EXPORT material.

### Public Sanitization and Disclosure

_In-scope material_ below means material requiring full public sanitization:

- All AET source-repository files and installed managed engine artifacts,
  including local engine modifications
- EXPORT proposals and candidates, including their evidence and metadata
- Content proposed for public engine adoption, export, or public publication

Source-local host CONTENT adoption is ordinary host work, not public engine
adoption; classification follows the artifact's role and destination, not a
CONTENT label. It cannot exempt engine changes. Private project defaults
cannot override these forced public-safe branches or host restrictions.

Ordinary internal/private host work runs the baseline; public/external work
also requires disclosure review. Full public sanitization is the minimum for
external content unless explicit governing policy and authorization cover the
restricted recipient and content. That exception applies only to ordinary host
content, never engine or EXPORT material. Without that evidence, no confidential
transfer is permitted and strict public-safe review remains the minimum.
A public-safe `PASS` does not itself authorize external sharing.

### Scope Resolution and Evidence

Before safety checks, resolve intended audience, destination, and governing
policy evidence from existing project-owned guidance, artifact/task facts, and
known destinations. Use persistent project-owned defaults to avoid repeated
questions; do not introduce a separate configuration system. Specific
destinations refine defaults but cannot grant prohibited disclosure. Repository
visibility alone is not proof of scope; a known public target requires public
review even without an explicit publish request. An internal commit is not
automatically publication.

Every entry point, including direct specialist and Validation invocation, must
independently resolve this contract. Verify supplied scope against available
evidence; an untrusted or incomplete handoff cannot waive mandatory scope.
After scope determination, run applicable safety checks before other checks.

Retain per-artifact scope, supporting evidence, and check applicability with
reasons for `N/A` separately as validation input/evidence. Never add scope prose
or new fields to gate packets. Before forwarding a packet, the caller reconciles
known material scope discrepancies against the artifact and policy, updates that
separate evidence for the next gate, and has the owning gate repeat checks not
demonstrably covered. A clean packet does not confirm the caller's scope; do not
raise a finding solely to communicate a resolved difference.

Unknown scope is unresolved, not `N/A`: only
already-authorized confined work may continue. Block the unresolved disclosure
boundary, including commit to an unclear destination; ask only when needed to
resolve that boundary or authorize further work.

Applicable safety `FAIL` or `UNCERTAIN` blocks the affected commit, adoption,
export, publication, or disclosure. Revalidate when relevant content, policy,
audience, or destination changes. An internal `PASS` is not public authorization;
required human approval and disclosure authorization remain separate gates.

## What Public Safety Means

In-scope material must be shareable publicly without exposing:

- NDA-protected information
- Company, client, customer, or project identity
- Personal data
- Credentials or secrets
- Proprietary business logic
- Internal systems, paths, tools, or infrastructure
- Raw private examples copied from real work

## Blocked Content

In material requiring public sanitization, do not include:

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

## Deliberately Public Identity

An identity may appear in in-scope material only when all of these conditions
hold:

- The identity owner deliberately published it in canonical AET source metadata
- The identity is necessary for AET ownership, contact, or legal attribution
- The same identity and purpose can be verified from canonical AET source
  metadata
- The identity does not identify a client, customer, private project, or unrelated third party

Approval is limited to AET's public owner and repository identifiers in
canonical AET source metadata and the rights-holder identity in AET's
`LICENSE`. It never transfers to host-repository owners, contributors,
identities, metadata, or licenses. If provenance or intent cannot be verified,
classify the identity as `UNCERTAIN` and stop before commit, publication,
export, or adoption.

## Example Safety

Examples in material requiring public sanitization must be synthetic or generic.

Use:

- `user_001`
- `project-example`
- `example.com`
- `test.local`
- `EXAMPLE_SECRET`
- `YYYY-MM-DD`
- `123.45`

Avoid realistic identifiers that could look real.

## Agent, Skill, and Instruction Safety

Before adopting in-scope AI-facing content, check that it does not reveal:

- Internal project context
- Private repository names
- Real file paths
- Private coding patterns tied to one company
- Internal tool names
- Copied review comments from private work
- Skills or task inputs containing confidential source text

Use generic wording unless identity satisfies the deliberately public identity
predicate above.

## Script and Code Snippet Safety

Scripts and snippets requiring public sanitization must be generic.

Do not include:

- Real infrastructure identifiers
- Real database, table, schema, or bucket names
- Real package or module names from private systems
- Real environment variable names tied to private systems
- Real credentials, even in comments
- Hardcoded private paths or usernames

Use placeholders and document assumptions.

## Acceptance Check

Before accepting an in-scope artifact or candidate, verify that no secrets,
PII, internal identifiers, or proprietary logic remain, examples are
synthetic, generated content was reviewed, and the engine/content boundary is
preserved.

Use [validation/nda-safety-checklist.md](../validation/nda-safety-checklist.md) for the full checklist.

## Severity

Apply these public-sanitization severities only where that check applies;
baseline violations always block the affected action.

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

## Review Points

Review each in-scope artifact or candidate:

- Before a public push containing it
- Before including it in an export package
- Before adopting generated content from it
- Before promoting it from a proposal to a canonical AET artifact
- Before publishing it in a release
