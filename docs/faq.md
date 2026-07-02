# Frequently Asked Questions

---

## Does AET work without GitHub Copilot?

AET targets VS Code with GitHub Copilot. Host discovery, settings, tools, and
model behavior affect execution; the documentation does not establish runtime
reliability or compatibility with other environments.

---

## Can I use this with ChatGPT or Claude directly?

Markdown is readable as text, but pasting a prompt does not provide its file
dependencies, tools, specialists, or gates. Text reuse is not an AET installation
or evidence of equivalent behavior. Use the complete bundle for AET workflows;
never paste private source into an environment unauthorized by project policy.

---

## How does AET scope instructions?

After the host discovers an instruction file, its `applyTo` glob selects matching
file paths. The glob does not configure discovery or guarantee compliance. See
[installation scope](installer-release-contracts.md#installation-scope) for
location requirements; reviewed CONTENT can target project-specific conventions.

---

## Can I use AET with my whole team?

Install the complete [manifest bundle](../scripts/aet-manifest.txt) per repo.
Review and commit only exact `[aet-install] share:` entries, including governed
`.github/docs/` files, `.github/LICENSE`, and `.github/.aet-managed-state`, not
whole directories. Review and authorize sharing of CONTENT separately; a shared
content repository and its host configuration remain team-managed.

---

## How do I keep my extracted rules private?

[Discovery](../skills/discover-workspace-file-knowledge/SKILL.md) and
[extraction](../skills/extract-code-knowledge/SKILL.md) first write CONTENT
proposals under the source project's `.aet/proposals/<export|local>/`.
[Source review](../skills/review-proposal/SKILL.md#extracted-source) may
`ABANDON`, `DEFER`, or `PREPARE` noncanonical candidates under route-matching
`.aet/content-candidates/<export|local>/`; it cannot adopt them.

KEEP-LOCAL proposals and candidates stay in the source project under its policy.
Only a human may transfer sanitized, prepared EXPORT candidates to a content-pack
workspace. [Candidate-fit review](../skills/review-proposal/SKILL.md#candidate-fit)
compares destination owners before adoption or merge, subject to Review,
Validation, and required human approval. KEEP-LOCAL fit review stays at source.

AET does not create a private instructions repository or automatically adopt
output. Extracted proposals go neither directly to a content pack nor to the
toolkit's engine-proposal inbox.

---

## Does AET modify my source code?

Writes depend on task authority and the selected workflow: assessment is
nonwriting; CONTENT discovery and extraction persist proposals without changing
project source or configuration. Proposal review can prepare candidates or
integrate approved guidance; the Review and Validation gate agents are read-only.

[Generate Instruction](../skills/generate-instruction/SKILL.md) is engine-only:
it requires an accepted GENERIC-ENGINE review with an accepted owner, description,
and `applyTo` value (or explicit `OMIT`). It is not a project CONTENT generator.

---

## The install script added files I didn't expect. What are they?

The installer copies manifest-listed agents, skills, instructions, validation
rules, governance, and LICENSE, then writes managed state. Keep this complete
dependency set; do not install isolated files.

Use `--dry-run` to preview without destination writes; standalone preview still
downloads, verifies, and extracts in temporary storage. See
[preview behavior](installer-release-contracts.md#options) and
[tool requirements](installer-release-contracts.md#requirements), including
SHA-256 tooling for local installs.
