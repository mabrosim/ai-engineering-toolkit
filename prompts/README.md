# Runnable Task Prompts

`.prompt.md` files that define specific, reusable workflows: code review, rule
extraction, commit messages, quality gates, and more.

Invoked via the VS Code slash-command picker or by agents when executing structured
tasks. Each prompt is self-contained with a clear input/output contract.

Examples: `code-review`, `commit-message`, `quality-gate`, `assess-project`,
`generate-architecture-doc`.

## Running on any base size

These prompts are base-agnostic: the same workflow runs on a few files or on
hundreds. Scale is handled at run time, not baked into the prompt.

The cost driver on a large base is **read volume** (how many file bodies enter
context), not model reasoning. The discovery and extraction prompts already bound
this with a cheap-first pass and adaptive read-depth. Capability is rarely the
limit: the prompts are procedural and step-chunked, so a weak or mid-tier model
runs them fine.

### Large-base run recipe

1. Run `discover-workspace-file-knowledge` first. Let adaptive read-depth force
   the bulk to `metadata-only`/`head-tail`; reserve `full-read` for cluster
   exemplars. Produce the theme-presence map.
2. Run `extract-code-knowledge` per theme **and** per context in separate passes,
   not one giant run. Use the theme-presence map to scope each run to only the
   clusters that contain the theme.
3. Sample representatives — read one or two exemplars per cluster rather than
   every file in it.
4. Batch by subsystem or directory to keep each run inside a comfortable context
   budget; long single passes invite drift on mid-tier models.
5. Reserve high reasoning effort for extraction and normalization. The
   inventory, fingerprint, and classification passes are mechanical — run them
   cheaper, and split model tiers when the orchestrator can route them.

### Small-base run

Skip the batching. On a small project, deep-read directly and run a single
extraction pass — the narrowing steps add no value when the whole base fits in
context.
