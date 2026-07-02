# Contributing

Contributions to the **engine** (agents, prompts, validation workflows, scripts)
are welcome. Content contributions (`instructions/`) must be generic, NDA-safe,
and broadly applicable — no company-specific or proprietary patterns.

## Before You Start

Read [docs/repository-rules.md](docs/repository-rules.md) and
[docs/philosophy.md](docs/philosophy.md). They define what belongs in this
repository and how it must be maintained.

## How to Contribute

1. Fork the repository and create a branch from `main`.
2. Make your changes. Keep each PR focused on a single concern.
3. Run pre-commit hooks: `pre-commit run --all-files`
4. Run the NDA safety checklist on any new or modified files:
   open `validation/nda-safety-checklist.md` and verify each item.
5. Open a pull request with a clear description of the change and its rationale.

## Standards

- Commit messages follow [Conventional Commits](https://www.conventionalcommits.org/).
- Markdown files must pass `markdownlint-cli2` (run `npx markdownlint-cli2 "**/*.md"`).
- No secrets, credentials, or PII in any file — ever.
- No company names, client names, or internal system references.

## What Does Not Belong

- Tech-specific instruction packs (Python style, PySpark, etc.) — these are
  content and live in your own private instructions repo.
- Company-specific rules or proprietary patterns.
- Generated or temporary files.

## Questions

Open an issue or see [docs/repository-rules.md](docs/repository-rules.md).
