# Frequently Asked Questions

---

## Does AET work without GitHub Copilot?

Partially. The `.instructions.md` and `.prompt.md` formats are supported by
Cursor and Windsurf without Copilot. However, the agent picker integration
(selecting named agents like **AET Orchestrator**) is VS Code + Copilot-specific.
Manual prompts from `prompts/` paste into any assistant.

---

## Can I use this with ChatGPT or Claude directly?

Yes. The prompts in `prompts/` are plain markdown. Copy any prompt into your
chat window and paste your source files or summaries as context. You lose the
automated multi-step routing but keep the structured workflow.

---

## How is this different from Cursor rules or `.cursorrules`?

Cursor rules are a single global file. AET generates scoped
`.instructions.md` files that apply only to matching file types (controlled by
the `applyTo` glob in the frontmatter). You can have separate rules for Python,
TypeScript, tests, and SQL — all active simultaneously, each only when relevant.

---

## Can I use AET with my whole team?

Yes. Commit the generated `instructions/` files to a shared repository and
point everyone's `chat.instructionsFilesLocations` setting at that path.
Personal preferences stay in a private fork; shared conventions live in the
team repo. The AET engine itself is public and installs without setup.

---

## How do I keep my extracted rules private?

Run AET on your project; the output goes into your private instructions
repository, which you control. The AET engine (this repo) contains no mined
rules — only the workflow that produces them.

---

## Does AET modify my source code?

Only when you explicitly ask it to (e.g., `refactor module X`). Discover,
Extract, and Validate steps are read-only. Generate writes to your instructions
repo, not your source.

---

## The install script added files I didn't expect. What are they?

`aet-install.sh` copies the Orchestrator agent plus supporting instructions,
prompts, and validation checklists into `.github/`. Run with `--dry-run` first
to preview exactly what will be written before committing.
