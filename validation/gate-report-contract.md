# Gate Report Contract

Shared syntax and packet rules for read-only Review and Validation gates.
Role-specific rules own terminal fields, result precedence, and authorization.

## Finding Syntax

Each finding is one line:

```text
[SEVERITY] [FAILED|UNRESOLVED|ADVISORY] [CATEGORY] Description — Location — Suggested fix
```

- `SEVERITY` uses `CRITICAL`, `HIGH`, `MEDIUM`, `LOW`, or `INFO` and
  communicates impact only.
- `FAILED` means evidence establishes that an applicable criterion is violated.
- `UNRESOLVED` means evidence needed to decide an applicable criterion is
  unavailable or inconclusive.
- `ADVISORY` means no applicable criterion is failed or unresolved; its
  suggestion is outside current acceptance.
- `CATEGORY` identifies the applicable criterion or checklist area.
- `Description` states the evidence-backed issue.
- `Location` identifies concrete evidence in the reviewed artifact. For
  unavailable input, cite its supplied path or the reference that requires it.
- `Suggested fix` describes a possible resolution.

Severity does not determine progression. A suggested fix does not change a
finding's disposition or terminal result and creates no action, owner, retry,
or orchestration obligation.

## Ordering And Empty Output

- Emit each separately attributable finding before terminal fields.
- When no findings exist, emit exactly `No findings.` before terminal fields.
- `No findings.` and finding lines are mutually exclusive.
- Emit terminal fields after all findings in the order defined by the role's
  contract.

## Packet Validity

A packet is valid only when:

- Every nonterminal line is either one conforming finding or `No findings.`.
- Every required role-owned terminal field appears exactly once.
- No unknown terminal field appears.
- Every terminal name, value, and order conforms to the applicable role
  contract.
- The terminal result is consistent with all finding dispositions under the
  applicable role contract.

Missing, unknown, duplicate, out-of-order, or contradictory terminal fields
make the packet invalid. Mixed prose, malformed findings, invalid empty output,
and findings after terminal fields also make it invalid.

## Consumer Behavior

- If a gate stops at setup, halt until setup is restored. That gate issued no packet;
  do not request packet or artifact repair. A Review setup stop has no `MERGEABLE` and
  cannot advance to Validation, even for a baseline or final aggregate.
- Validate a complete source packet before routing or aggregation.
- Retain the complete valid source packet unchanged as evidence when routing or
  aggregation requires it.
- Keep retained source evidence separate from the consuming gate's emitted
  packet. Source findings remain only in the retained evidence; do not forward
  them or source terminal fields into the consuming packet.
- Emit only the consuming role's terminal fields. In particular, a Validation
  packet never emits Review's `MERGEABLE` terminal.
- Reject an invalid packet and return it to its source gate.
- Never rewrite or synthesize a source gate's terminal result.
- Apply the consuming role's existing fail-closed result when a required source
  packet is missing or invalid.

Human authorization remains separate from technical gate results.
