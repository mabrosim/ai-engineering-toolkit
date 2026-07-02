# Repository Rules

Concrete rules for maintaining this repository.

Project intent lives in `philosophy.md`.
Agent workflow lives in agent and instruction files.

## Authority

When guidance conflicts, use this order:

1. Public safety
2. `philosophy.md` for intent
3. `repository-rules.md` for mechanics
4. Agent files for workflow
5. Task request for local objective

If mechanics violate philosophy, update mechanics.
If workflow violates rules, update workflow.

## Technology Scope

This repository stores AI-engineering artifacts, not application source code.

Canonical content:

- Documentation
- Agent definitions
- Prompts
- Instructions
- Validation checklists
- Small maintenance or installation scripts
- Generic examples embedded in documentation

Do not add programming source files unless they directly support repository installation or maintenance.

Programming-language style rules belong in content packs or instruction files, not repository-wide rules.

## File and Directory Rules

- Every file has one clear purpose.
- File names use kebab-case unless tooling requires otherwise.
- Documentation uses `.md`.
- Agents use `.agent.md`.
- Prompts use `.prompt.md`.
- Instructions use `.instructions.md`.
- Files should stay under 200 lines unless justified.
- Split large files by concern, not arbitrary length.
- Review generated artifacts before making them canonical.
- Each directory has one concern.
- New directories need documented purpose.
- Empty directories contain `.gitkeep`.

Canonical directories:

- `agents/` — agent definitions
- `instructions/` — engine-level instruction files
- `prompts/` — engine workflow prompts
- `validation/` — safety and quality checks
- `docs/` — philosophy, rules, decisions, usage
- `scripts/` — installer and maintenance scripts

## Change Rules

Primary change types:

- `docs`
- `rules`
- `agents`
- `prompts`
- `validation`
- `instructions`
- `scripts`
- `maintenance`

Rules:

- Prefer small, focused changes.
- Use one logical concern per commit or PR.
- Split multi-concern changes when practical.
- Document breaking changes.
- Remove deprecated content.
- Avoid speculative abstractions.
- Preserve engine/content separation.
- Keep private content out of public engine artifacts.
- Document assumptions when proceeding without clarification.

## Commit Rules

- Use Conventional Commits.
- Keep one logical change per commit.
- Do not commit secrets, credentials, PII, debug artifacts, caches, temporary files, or raw mined content.
- Commit messages must not reveal private project context.

## Content Safety Rules

All repository content must be NDA-safe and public-safe.

See `docs/public-safety.md` for the full blocked-content list, example-safety guidance, and incident process.

## Validation and Review

Before public release or major changes, run the pre-commit check in `docs/public-safety.md`.
