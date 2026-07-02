---
description: "Documentation and README writing standards."
applyTo: "**/*.md"
---
# Documentation Style Guide

Standards for writing documentation in this repository.

---

## General Rules

- Write documentation for humans, not for tools
- Keep documentation close to the code it describes
- Update documentation when code changes
- Prefer short, scannable documents over long essays

---

## Markdown Rules

- Use ATX headers (`#`, `##`, `###`)
- Leave one blank line before and after headers
- Use fenced code blocks with language tags
- Use `---` for horizontal rules between major sections
- Keep line length under 100 characters

---

## README Files

Every module or major directory should have a `README.md` with:

1. Purpose — one sentence describing what this does
2. Usage — minimal example
3. Requirements — dependencies or setup steps
4. Notes — important caveats or limitations

---

## Inline Code Comments

- Comment the *why*, not the *what*
- Use full sentences for multi-line comments
- Use inline comments sparingly

---

## Docstrings

- All public functions must have docstrings
- Use Google-style format
- Include type information in the signature, not in the docstring

---

## Changelog and Versioning

- Use commit messages for change history

---

## Anti-Patterns

- No outdated documentation left in place — update or delete
- No duplicate documentation across files
- No auto-generated documentation without review
- No documentation that just restates the code
