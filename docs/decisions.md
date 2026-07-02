# Repository Decisions

Durable decisions that constrain repository implementation.

---

## Public Identity

- Apply the [deliberately public identity rule](public-safety.md#deliberately-public-identity)
  only to verified AET owner/repository identifiers and the rights-holder in
  [LICENSE](../LICENSE), when needed for ownership, contact, or legal attribution.
- This exception never transfers to host identities; treat other or unverifiable
  identities as `UNCERTAIN`.

## Private Reporting

- Use separate confidential routes for security and conduct.
- Plan GitHub private vulnerability reporting for security.
- Plan a verified private maintainer contact through GitHub for conduct.
- Neither route is verified; retain current [security](../SECURITY.md) and
  [conduct](../CODE_OF_CONDUCT.md) notices without claiming private reporting is
  available. Availability requires configuration and testing.

## Release Distribution

- Resolve the latest stable release dynamically; exclude drafts and prereleases.
- Sign the release bundle and checksum manifest with Sigstore keyless GitHub OIDC.
- Verify exact release-workflow identity and SHA-256 before extraction.
- Fail closed when release or verification evidence is missing.
- [Release contracts](installer-release-contracts.md#release-artifact-contract)
  own asset inventory, verification order, and archive repeatability limits.

## Installer Collisions

- Use one authoritative [package manifest](../scripts/aet-manifest.txt).
- Preserve existing data: require explicit force for changed managed engine
  files; reject unmanaged and content-over-engine collisions.
- [Collision policy](installer-release-contracts.md#collision-policy) owns the
  write/skip matrix, preflight, and symlink handling.
- Do not require transactional rollback or automatic backups.

## Installer Managed-File Provenance

Retain installed path/SHA-256 provenance in `<dest>/.aet-managed-state` so
collaborators can distinguish managed files. The
[installer](../scripts/aet-install.sh) owns serialization;
[collision policy](installer-release-contracts.md#collision-policy) owns
fail-closed validation and atomic state replacement after engine writes.

## Installation Scope

- Use repo-local installation by default and recommend it for teams, reviewed
  and pinned behavior, and reproducible setup.
- Retain `--global` for one developer's personal VS Code extension-host use
  across workspaces configured with custom locations.
- Global setup is not Agent Host compatible; global updates affect every
  workspace using the configured locations.
- Keep `~/.aet/` unchanged. It is not a native user-skill discovery location;
  internal agent workflows read bundled skills directly. Do not recommend
  deprecated `chat.agentSkillsLocations` for new setup or edit host settings.
- Do not combine active global AET locations with a repo-local install because
  duplicate customization-name precedence is undocumented.
- Keep operational setup and scope-switching guidance in
  [installer and release contracts](installer-release-contracts.md#installation-scope).

## Portable Bundle Dependency Closure

- Ship [public safety](public-safety.md) as portable governance; it owns the
  portable [engine/content roles](public-safety.md#engine-and-content-roles)
  that installed artifacts apply. Installation alone does not submit unrelated
  host files for evaluation.
- Exclude source-only governance, including [AGENTS.md](../AGENTS.md),
  [philosophy](philosophy.md), [repository rules](repository-rules.md), and
  [Steward](../agents/aet-steward.agent.md). Philosophy guides changes to AET;
  portable artifacts embed its principles instead of loading it.
- Keep [Reevaluate Toolkit](../skills/reevaluate-toolkit/SKILL.md) source-only
  because it depends on Steward and repository rules.
- Normative portable dependencies must remain within the manifest; illustrative
  install-location paths are not normative dependencies. The
  [installer suite](../scripts/test-install.sh) checks bundle link closure.

## Workflow Skills

- Canonical workflows live at `skills/<name>/SKILL.md`; canonical `agents/` and
  `instructions/` remain in place. Source self-install copies them; see
  [Source Self-Install](#source-self-install).
- Skills require matching names, useful descriptions, and deliberate invocation
  metadata. Keep manual invocation available; permit model loading for required
  owning workflows without enabling unsolicited capture or adoption.
- Agent/model/tools prompt frontmatter is not skill routing. Each skill states
  its owner and fail-closed handoff; owners execute inline without self-delegation.
  Existing agents load required procedures directly from their selected bundle.
- Preserve host-enforced read-only gate boundaries and independent Review then
  Validation; do not imply skill text restricts tools or require forked context.
- Preserve legacy content-pack prompt copying. Old managed prompt state rejects
  upgrade without writes; use the documented
  [manual migration](installer-release-contracts.md#legacy-prompt-migration),
  never automatic deletion or provenance removal.

## Source Self-Install

- `--self` installs the source-only Steward profile into this clone's `.github/`
  for native host discovery; `--target` and `--global` remain outward modes.
- [The self manifest](../scripts/aet-self-manifest.txt) solely owns profile
  membership. It excludes AET Orchestrator and AET Investigator and never feeds
  the portable bundle or release archive.
- Installed copies are gitignored derived outputs; canonical root sources stay
  authoritative. Contracts live in
  [installer and release contracts](installer-release-contracts.md#self-mode).

## Source Repository Bootstrap

- Root [AGENTS.md](../AGENTS.md) owns the compact source-repository bootstrap when
  supplied by the host; agents read it as the fallback instead of
  duplicating its required standards.
- [Repository rules](repository-rules.md) own mechanics;
  [AET Steward](../agents/aet-steward.agent.md) owns inward workflow.
- Keep `AGENTS.md` out of the portable manifest because external projects own
  their instructions.

## Proposal Governance

- Install [AET Proposal](../agents/aet-proposal.agent.md) by default, with capture
  off until explicit opt-in; capture never constitutes adoption.
- [Propose Improvement](../skills/propose-improvement/SKILL.md#prompt) owns
  routes, locations, approval requirements, and engine review eligibility.
- Project-derived CONTENT remains separate from generic engine improvements.
  The [CONTENT exception](../skills/propose-improvement/SKILL.md#content-workflow-exception)
  owns source preparation, candidate transfer, and content destinations;
  KEEP-LOCAL never leaves source and PREPARE is not adoption.
- [Review Proposal](../skills/review-proposal/SKILL.md) owns review paths,
  decisions, accepted owners, and adoption gates. Only sanitized EXPORT
  candidates transferred by a human enter destination CONTENT review.

## Review and Validation

- [AET Review](../agents/aet-review.agent.md) owns correctness and `MERGEABLE`;
  [AET Validation](../agents/aet-validation.agent.md) consumes Review evidence
  and owns aggregate `VERDICT`. Both gates remain read-only.
- Correctness-bearing changes require Review, then Validation; the
  [orchestration contract](../agents/aet-orchestrator.agent.md#approach) owns
  implementation readiness, repairs, and baseline/final-aggregate exceptions.
- Gate agents own their direct-read dependency discovery and degraded-capability
  stops; optional skills cannot override their procedures, roles, or sequencing.
- The [Gate Report Contract](../validation/gate-report-contract.md) owns packet
  syntax, validity, unchanged evidence, and fail-closed consumer behavior.
- [AI Output Validation](../validation/ai-output-validation.md) owns correctness
  aggregation, result precedence, and human-review states.
- Human authorization remains separate from both technical results.

## Audience Default Ownership

- Keep durable audience defaults in existing project-owned guidance outside the
  managed AET engine, not in a separate configuration system.
- Use the [Public Safety Guide's scope contract](public-safety.md#scope) as the
  authority for scope resolution, mandatory checks, and disclosure boundaries.

## Engine Instructions

- Keep [communication](../instructions/communication-style.instructions.md) and
  [documentation](../instructions/documentation-style.instructions.md) instructions
  in the public engine.
- Keep project-derived conventions and catalogs in CONTENT under the
  [engine/content boundary](philosophy.md#engine-vs-content), not engine policy.

## Subagent Model Selection

- Omit `model` from subagent calls by default so the host uses its current
  picker or default model.
- Use an explicit `model` only when the human requests it or repository
  configuration records both the task-to-model mapping and its predeclared,
  independently reproduced benchmark evidence.
- Remove unsupported routing mappings without requiring a benchmark.
- Never infer quality, cost, or capability from a model name.
- If an explicit model is unavailable, do not guess a replacement name. Retry
  without `model` only when equivalent behavior is acceptable; otherwise
  report degraded capability.
- Treat AET Lightweight as a task and context constraint profile, not a vendor
  model or cost tier.

## Maintenance Authority

- [CHANGELOG.md](../CHANGELOG.md) owns curated release notes; Git history is raw
  evidence, subject to the source bootstrap's initial-release policy.
- [Markdown configuration](../.markdownlint-cli2.yaml) owns mechanical enforcement;
  [Markdown Quality Rules](../validation/markdown-quality-rules.md) own semantic quality.
