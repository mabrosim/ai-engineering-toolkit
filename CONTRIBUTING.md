# Contributing

Contributions to generic **engine** agents, skills, instructions, validation,
documentation, and maintenance scripts are welcome. Project-derived conventions
belong in separately reviewed CONTENT, not engine instruction files.

## Before You Start

Read the [Public Safety Guide](docs/public-safety.md) before local setup or
checks. All source-repository artifacts require public sanitization, including
examples, issue reports, and PR evidence; use generic examples, not private logs
or source excerpts. Follow its narrowly verified public-identity exception,
never an assumed exception for host identities.

Follow the [source bootstrap](AGENTS.md), [repository rules](docs/repository-rules.md),
and [philosophy](docs/philosophy.md) for maintenance scope and mechanics.

## How to Contribute

1. Fork the repository and create a branch from `main`.
2. Make your changes. Keep each PR focused on a single concern.
3. Apply the [NDA safety checklist](validation/nda-safety-checklist.md) to new
  or modified artifacts before other checks.
4. With `pre-commit` available locally, run configured hooks:
  `pre-commit run --all-files`.
5. Complete owner changes and verification evidence; correctness-bearing changes
  require [AET Review](agents/aet-review.agent.md), then
  [AET Validation](agents/aet-validation.agent.md), under the
  [required gate routing](agents/aet-orchestrator.agent.md#approach).
6. Open a pull request with a clear description of the change and its rationale.

Hook success is not Review or Validation approval and does not replace required
human review or disclosure authorization.

## Standards

- Commit messages follow [Conventional Commits](https://www.conventionalcommits.org/).
- Markdown must pass the repository's [configured linter](.markdownlint-cli2.yaml)
  and [semantic quality criteria](validation/markdown-quality-rules.md).
- Follow [documentation style](instructions/documentation-style.instructions.md)
  and [change-scoped executable checks](docs/repository-rules.md#validation-and-review).

## What Does Not Belong

- Tech-specific instruction packs (Python style, PySpark, etc.) — these are
  content and live in your own private instructions repo.
- Company-specific rules or proprietary patterns.
- Generated or temporary files.

## Questions

Open an issue or see [docs/repository-rules.md](docs/repository-rules.md).
