# Markdown Quality Rules

Rules for writing high-quality Markdown in this repository.

---

## Structure Rules

- Use one `#` H1 per file, at the top
- Use `##` for major sections, `###` for subsections
- Do not skip heading levels (H1 → H3 without H2)
- End files with a newline

---

## Formatting Rules

- Use `**bold**` for emphasis, not ALL CAPS
- Use `_italic_` for terms being defined or introduced
- Use `code` for all code, commands, filenames, and paths
- Use fenced code blocks (` ``` `) with a language tag

---

## List Rules

- Use `-` for unordered lists (not `*` or `+`)
- Use `1.` for ordered lists
- Indent nested lists with 2 spaces
- Do not mix ordered and unordered lists at the same level

---

## Link Rules

- Use descriptive link text, not "click here" or "link"
- Verify links before committing
- Use relative paths for internal repository links

---

## Table Rules

- Include a header row with `---` separator
- Align columns consistently
- Keep table content short — wrap in code blocks if needed

---

## Anti-Patterns

- No trailing spaces on lines
- No multiple consecutive blank lines
- No HTML tags inside Markdown unless unavoidable
- No bare URLs — wrap in `<>` or use `[text](url)` format
