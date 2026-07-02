# Repository Rules

Rules that govern how this repository is maintained and extended.

---

## File Rules

- Every file must have a clear, single purpose
- File names use `kebab-case`
- Markdown files use `.md` extension
- Python files use `.py` extension
- No file should exceed 200 lines without a strong reason

---

## Directory Rules

- Each directory contains files of one type or concern
- New directories require a documented purpose
- Empty directories must have a `.gitkeep` file

| Directory | Purpose |
|---|---|
| `agents/` | Agent definitions |
| `instructions/` | Engine-level instruction files (auto-loaded or agent-loaded) |
| `prompts/` | Engine workflow prompts |
| `validation/` | NDA-safety and quality checklists |
| `docs/` | Philosophy, rules, decisions, usage guides |
| `scripts/` | Installer and maintenance scripts |

---

## Commit Rules

- Commit messages use Conventional Commits format
- One logical change per commit
- Do not commit secrets, credentials, or PII
- Do not commit debug artifacts or temporary files

---

## Content Rules

- All content must be NDA-safe and public-safe
- No company names, client names, or project codenames
- No internal system references
- Examples use synthetic or generic data only

---

## Change Rules

- Small, focused changes preferred over large batches
- Breaking changes must be documented
- Deprecated content must be removed, not left in place

---

## Naming Conventions

| Type | Convention | Example |
|---|---|---|
| Files | kebab-case | `python-style.md` |
| Python modules | snake_case | `data_utils.py` |
| Python functions | snake_case | `process_records()` |
| Python classes | PascalCase | `DataProcessor` |
| Constants | UPPER_SNAKE_CASE | `MAX_RETRIES` |
