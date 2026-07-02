# Repository Rules

Concrete, source-repository-only rules for maintaining the AET source
repository. This document is nonportable and does not govern repositories where
the AET engine is installed.

Project intent lives in the [AET philosophy](philosophy.md).
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
- Skills
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
- Skills use `skills/<name>/SKILL.md`, with a folder-matching frontmatter `name`.
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
- `skills/` — engine workflow skills, one directory per workflow
- `validation/` — safety and quality checks
- `docs/` — philosophy, rules, decisions, usage
- `scripts/` — installer and maintenance scripts

## Change Rules

Primary change types:

- `docs`
- `rules`
- `agents`
- `skills`
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

## History and Markdown Authority

- `CHANGELOG.md` owns curated release notes; Git history is raw change evidence.
- `.markdownlint-cli2.yaml` owns mechanically enforced Markdown rules.
- `validation/markdown-quality-rules.md` owns semantic Markdown quality criteria.
- Authoring instructions reference these authorities and do not override them.

## Portability and Export

- `scripts/aet-manifest.txt` solely owns membership in the portable AET bundle.
- `scripts/aet-self-manifest.txt` solely owns the source-only `--self` Steward
  profile; it is never portable bundle membership.
- Normative local Markdown dependencies in portable artifacts use relative
  Markdown links to other portable artifacts.
- Portable artifacts must not depend on omitted source-only governance,
  including this document.

## Commit Rules

- Use Conventional Commits.
- Keep one logical change per commit.
- Do not commit secrets, credentials, PII, debug artifacts, caches, temporary files, or raw mined content.
- Commit messages must not reveal private project context.

## Content Safety Rules

All AET source-repository content must be NDA-safe and public-safe.

See the [Public Safety Guide](public-safety.md) for the full blocked-content
list, example-safety guidance, and incident process.

## Validation and Review

Run `bash scripts/test-install.sh` for changes to installer behavior, the
manifest, installation layout, portable dependency closure, packaging, or the
test harness. Do not run or update it for prose-only agent, skill, or governance
edits with an unchanged installation contract. Keep the suite focused on
installer behavior and consumed bundle integrity, not exact guidance wording.
Relevant lint and mandatory change-scoped Review, then Validation still apply.

Optional periodic semantic consistency audits belong to
[Reevaluate Toolkit](../skills/reevaluate-toolkit/SKILL.md), on explicit request
only; they are not per-edit checks or substitutes for required gates.

Before public release or major changes, run the acceptance check in the
[Public Safety Guide](public-safety.md#acceptance-check).
