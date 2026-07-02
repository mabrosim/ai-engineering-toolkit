# Engine Instruction Files

These files are the **engine layer** — they govern the behaviour of AET's own
agents and prompts. They ship with the engine and are used by AET Steward, the
portable specialists, and the core prompts.

Tech-specific style instructions (Python, PySpark, Databricks, Lambda, testing,
notebooks) are **content** and live in your personal instructions repository.
Install them alongside the agent bundle using `aet-install.sh --content-path DIR`.

---

## Files in this directory

| File | `applyTo` | Used by |
|---|---|---|
| `ai-collaboration-rules` | `**` | `aet-steward`, `aet-engineering`, `aet-prompt` |
| `communication-style` | `**` | `aet-steward`, `aet-proposal`, `generate-instruction` prompt |
| `documentation-style` | `**/*.md` | `aet-steward`, `aet-documentation`, `generate-docstrings` prompt |

`ai-collaboration-rules`, `communication-style`, and `documentation-style` are
auto-loaded by VS Code Copilot via their `applyTo` glob.

Tech-specific instructions (e.g. per-language style rules) belong in your
private content repository, not in this engine repo.
