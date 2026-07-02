---
description: "Documentation and README writing standards."
applyTo: "**/*.md"
---
# Documentation Style Guide

Standards for writing documentation in this repository.

---

## Authorities

- Repository-local tooling owns mechanical Markdown rules
- [Markdown quality rules](../validation/markdown-quality-rules.md) own semantic
 acceptance criteria
- [Compactness rules](../validation/compactness-rules.md) own concision criteria

---

## Authoring Rules

- Write documentation for its human audience
- Keep documentation close to the code it describes
- Target line length under 100 characters when readability permits; this is
 authoring guidance, not a lint rule

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
- Follow applicable project and language standards for docstring format and
 type placement; use community defaults for the language when none apply

---

## Changelog and Versioning

- Maintain curated release notes in `CHANGELOG.md`
- Use Git history as raw change evidence
