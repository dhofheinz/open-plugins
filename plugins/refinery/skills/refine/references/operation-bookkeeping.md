# Reference: Operation Bookkeeping

Every mode that writes to the artifact graph must preserve three invariants:

- **File integrity** — no artifact is ever left in a partially-written state.
- **Graph integrity** — parent-child links stay bidirectional; frontmatter counts match body content.
- **Audit integrity** — every meaningful change produces a Changelog row an auditor can trace.

This reference defines the procedures that uphold those invariants. Mode files cite sections by number (`§N`) and supply mode-specific parameters (operation name, Changelog reason text, status values); the procedures themselves are canonical.

**Scope.** This file defines procedures. Data formats live elsewhere: Changelog row grammar in `document-format.md §2.3`, convergence metrics in `convergence.md §2`, iteration log structure in `convergence.md §6`, ticket schema in `ticket-format.md`, agent handoff schemas in `agent-handoffs.md`.

## 1. Atomic writes

Every write to an artifact is all-or-nothing:

- Rewriting both frontmatter and body in one operation → use `Write` with the full file content; do not split into "header update" and "body append" steps.
- Appending to Changelog or Iteration Log → read the full current file into memory, compute the new content, then `Write` the complete result. Never emit a partial file and "fix it later."
- Multi-file operations (e.g., child creation updates both new artifact and parent) → if any file write fails, report the inconsistency rather than retrying silently. A parent that points at a child file that didn't land, or vice versa, is an INV-001 violation the user must see.

NFR-R-004 formalizes this discipline.

## 2. Status transitions (single-artifact state change)

Three steps:

1. **Update frontmatter.** Set the new `status` value and `last_updated` timestamp. Add any mode-specific fields (e.g., `superseded_by: <path>` when transitioning to `superseded`).
2. **Append a Changelog row** per `document-format.md §2.3`. For pure status changes (no body edits), use section bucket `(status)`.
3. **Atomic write** per §1.

The target transition must be legal per `document-format.md §7` (status compatibility matrix). Modes refuse illegal transitions rather than forcing them.

### 2.1 Parameters each mode supplies

| Parameter | Description |
|-----------|-------------|
| new status | The target status value |
| additional frontmatter | Optional mode-specific fields alongside status/last_updated |
| Changelog change | One-line summary of what transitioned |
| Changelog reason | Why the transition happened |
| operation name | Mode identifier for the Changelog row's operation column |

## 3. Graph mutation (creating a child artifact)

Every new artifact with a parent touches two files: the new artifact itself and the parent. The procedure:

### 3.1 Initialize the new artifact's frontmatter

Required on creation:

```yaml
artifact: <type>
scope: <scope>
feature: <inherited from parent, or project name for seeds>
stage: <stage>
iteration: 0
last_updated: <now>
status: draft                        # or mode-specific (e.g., tickets jumps to finalized)
parent: <relative path to parent>    # null only for seed principles
children: []
references: []
convergence:
  questions_stable_count: 0
  open_questions_count: <count of initial OQs>
  high_confidence_ratio: <computed>
plugin_version: <current refinery version>
```

Mode-specific frontmatter layers on top (e.g., tickets artifacts carry `ticket_count`, `wave_count` — see `ticket-format.md`).

### 3.2 Update the parent's frontmatter

Two mutations:

1. Append the new artifact's relative path to the parent's `children` list — this is the INV-001 bidirectional-graph link.
2. Set the parent's `last_updated` to now.

### 3.3 Append a Changelog row to the parent

Per `document-format.md §2.3`, with section bucket `(graph)`:

```
| <date> | (graph) | Added child: <new-artifact-relative-path> | <mode-specific reason> | <operation> |
```

### 3.4 Atomic writes (both files)

Per §1. If the parent write fails after the new artifact write succeeded, the graph is temporarily asymmetric (child uplinked, parent missing the link) — report the asymmetry rather than proceeding.

### 3.5 Parameters each mode supplies

| Parameter | Example (from `mode-advance`) |
|-----------|--------------------------------|
| new artifact type + scope + template | `spec` / `system` / `templates/spec.md` |
| initial status | `draft` |
| parent Changelog reason | `New stage advanced` |
| operation name | `advance` |

`mode-tickets` and the `feature-spec` creation path use the same procedure with their own parameters.

## 4. Child-drift propagation

When a mode modifies a parent in a way that may invalidate its children, the children are flagged as `drifted` so users know to re-review them. Applies to `mode-update` (all modification categories) and `mode-archive` (terminal-state transitions affect all non-terminal children).

### 4.1 Which children to flag

Two independent dimensions decide:

**Parent-type matrix** — which child types are structurally at risk:

| Parent modified | Children flagged |
|-----------------|------------------|
| `principles` | All descendants (principles changes are maximally disruptive) |
| `design` | `stack`, `spec`, `plan` |
| `spec` | `feature-spec` descendants, `plan`, `tickets` |
| `feature-spec` | `plan`, `tickets`, nested `feature-spec` children |
| `plan` | `tickets` |
| `stack` | (rarely affects others) |
| Any non-terminal → `archived`/`superseded` | All non-terminal children |

**Change-category matrix** (applies to `mode-update` only; `mode-archive` unconditionally flags):

| Category | Children flagged? |
|----------|-------------------|
| Additive (new content added, existing untouched) | No — optional review |
| Modificative (statement changed) | Yes — flag as drifted |
| Subtractive ([DELETED]) | Yes — flag + surface the deleted ID's dependents |
| Corrective (typo/clarification) | No — no semantic change |

### 4.2 Confirmation (per FR-005)

Before flagging any child, prompt via `AskUserQuestion`:

```
Question: "Parent change may affect <N> children. Flag them as drifted?"
Options:
  - "Yes, flag all <N>"
  - "No, leave as-is"
  - "Per-file (let me choose)"
  - "Cancel"
```

Mode-specific prompt text is permitted; this is the default shape.

### 4.3 Per-flagged-child procedure

For each child the user consents to flag:

1. Apply §2 (status transition) on the child with:
   - new status: `drifted`
   - Changelog change: `Status → drifted`
   - Changelog reason: `Parent <parent-path> <operation> on <date>: <change summary>`
   - operation name: `<operation> (parent propagation)`

### 4.4 Record un-flagged children

For each child the user opts NOT to flag (or that the category matrix exempted), append a row to the parent's Changelog per `document-format.md §2.3`:

```
| <date> | (propagation) | Child <path> not flagged despite parent change | <reason — "user chose no" or "change was Additive"> | <operation> |
```

This leaves an audit trail even when the decision is "no action."

### 4.5 Parameters each mode supplies

| Parameter | Example (from `mode-update`) |
|-----------|-------------------------------|
| change category | Modificative |
| change summary (for child Changelog rows) | `add rate limiting requirement` |
| operation name | `update` |
| prompt text variant | See `mode-update.md` Phase 4 |

## 5. Post-write validation

After any write, verify the invariants that could be violated. Fail loud; do not silently correct.

### 5.1 Always-on

Run these after every write regardless of what the mode did:

- **Frontmatter required fields** present and non-null (per `document-format.md §1`): `artifact`, `scope`, `feature`, `stage`, `iteration`, `last_updated`, `status`, `parent`, `children`, `references`, `convergence`, `plugin_version`.
- **Status compatibility** with artifact type (per `document-format.md §7` matrix).
- **Bidirectional graph integrity** (INV-001): every `children:` entry has a reciprocal `parent:` back-link.
- **Universal sections present:** Open Questions, Iteration Log, Changelog.

### 5.2 On-demand

Modes opt into these when the change could introduce the specific violation. Running them on every write is too expensive.

- **ID discipline** (INV-004) — no deleted IDs reused. Relevant when the mode added or modified tracked items.
- **Convergence integrity** (INV-002, INV-003) — frontmatter convergence matches body recomputation. Relevant when the mode edited the body.
- **Cross-reference resolution** (INV-005) — every `source_documents.<NN>.path` resolves. Relevant when `source_documents` was touched.
- **Iteration log monotonicity** (INV-006) — iteration entries are non-decreasing. Relevant when the mode appended to the Iteration Log.

Modes that never mutate body content (e.g., the `status` read-only fast-path) skip §5.2 entirely.

### 5.3 Failure handling

If any check fails, **refuse the write** (or, for post-hoc detection, flag the artifact and surface the discrepancy to the user). Silent correction is never acceptable — the user must see what went wrong so the state machine's authority is preserved.

## 6. Confirmation gates (FR-005)

Before modifying an artifact whose current status is `finalized` or `implemented`, modes prompt via `AskUserQuestion`. The prompt is mode-specific; this section only mandates its presence. Default shape:

```
AskUserQuestion: "Target is in <status> status. <Mode-specific implication>. Proceed?"
Options:
  - "Yes, proceed"
  - "No, cancel"
```

Modes with a reason argument (like `mode-archive`'s `--reason`) surface it in the prompt text so the user confirms the specific action. Modes that auto-propagate to children (`mode-update`) offer the auto-flag option in this same prompt rather than in a separate one.

`mode-mark-implemented` is an exception: transitioning **from** `finalized` **to** `implemented` is the canonical forward move through the state machine, so no confirmation is required for the primary case. Re-marking an already-`implemented` artifact requires `--force`, and `--force` itself is the confirmation.
