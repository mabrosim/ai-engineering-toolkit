# AET Source Repository Instructions

This file is source-only and nonportable. External repositories own their own
instructions; do not include this file in the portable AET bundle.

Before any task, read:

- [AET Philosophy](docs/philosophy.md)
- [Repository Rules](docs/repository-rules.md)
- [Public Safety Guide](docs/public-safety.md)

Route authority concisely:

- Philosophy defines intent.
- Repository rules define mechanics.
- Agent files define workflow.
- Public safety has highest priority.

Route inward AET maintenance through AET Steward when available.

Preserve engine/content separation. Exclude private material from public engine
artifacts.

## Initial Release Workflow

This sole-maintainer repository uses one publish commit, amended by the
maintainer. Until the maintainer explicitly changes this release model, all
changes belong to the initial public release. Do not add per-task changelog
entries, an `Unreleased` section, or new release sections to
[CHANGELOG.md](CHANGELOG.md). This source-only policy specializes the general
changelog guidance; it does not authorize agents to commit, amend, or rewrite
history.

Run applicable executable checks. Correctness-bearing changes require Review,
then Validation. Follow the canonical files above and the applicable agent and
validation files for details; do not duplicate their rules here.
