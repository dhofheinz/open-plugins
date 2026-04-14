# Mode: tickets

**Purpose:** Decompose a `plan`, `spec`, or `feature-spec` into dispatch-compatible tickets organized by dependency waves. Output is dual-audience (humans use as sprint backlog; agent dispatchers use as work-queue items).

## Inputs

- Target artifact path (required first argument) — must be a `plan`, `spec`, or `feature-spec`
- Optional `--output <path>` (defaults to `<target-basename-without-extension>-tickets.md` in same directory)

## Procedure

### Phase 1: Validate target

Read target. Confirm artifact type is one of: `plan`, `spec`, `feature-spec`. Refuse for `principles`, `design`, `stack`, `tickets` (a tickets-from-tickets re-decomposition is a different operation; not in v1).

Confirm status is `finalized` (preferred) or `reviewed` (with confirmation). If `draft` or `iterating`, refuse with: "Tickets should derive from a `finalized` artifact. Run `/refine finalize <target>` first, or `--force` to override (not recommended)."

### Phase 2: Spawn ticket-architect

Spawn agent `refinery:ticket-architect` via the `Agent` tool with:

- Full target artifact content
- Reference: `${CLAUDE_SKILL_DIR}/references/ticket-format.md`
- Project root path (for codebase context — the architect may glob to verify file paths exist)
- Instruction to:
  1. Identify natural ticket boundaries (single component, single endpoint+tests, single migration, single config change, etc.)
  2. Establish dependencies (what must exist before what)
  3. Group into dependency waves (Wave 1 = no dependencies; Wave N = depends on N-1 or earlier)
  4. Generate tickets with full schema (per `references/ticket-format.md §1`):
     - id, title, wave, size (S/M/L/XL), layer, depends_on, blocks, spec_ref, files, acceptance, convention_recipe, technical_notes, anti_patterns
  5. Identify any **blocked tickets** (per `references/ticket-format.md §6`) if open questions in the source artifact prevent full specification
  6. Recommend a starting ticket (typically a Wave 1 root, smallest size, lowest risk)
  7. Per FR-034, no ticket should span more than ~3 files unless natural cohesion requires more (e.g., implementation + test files for a single component); document the exception in `technical_notes` when it applies
  8. Per FR-032, any size: XL ticket should emit a warning to the artifact's Open Questions section suggesting decomposition

Receive the tickets artifact content (full markdown).

### Phase 3: Validate ticket integrity

Per `references/ticket-format.md §9`:

- All `depends_on` references resolve (no dangling — every ID referenced exists in this artifact)
- No circular dependencies (DAG check via topological sort)
- All requirements/items in source artifact map to at least one ticket (no orphaned spec items)
- At least one ticket has empty `depends_on` (Wave 1 root must exist)
- All tickets have `size` in {S, M, L, XL}
- All tickets have non-empty `files` list with valid `status` markers (NEW/MODIFY/EXISTS)
- All tickets have non-empty `acceptance` list with independently-testable assertions
- All tickets have `spec_ref` pointing to source artifact items

If any validation fails:

- Re-spawn ticket-architect with the specific failure(s) and request a revision
- Maximum 2 revision attempts; if still failing, surface the failures to the user and refuse the write

### Phase 4: Write tickets artifact

Apply the graph-mutation procedure per `${CLAUDE_SKILL_DIR}/references/operation-bookkeeping.md §3` for the **new-artifact-initialization** half (§3.1). Tickets-specific frontmatter fields layer on top of the universal fields:

```yaml
---
artifact: tickets
scope: <inherited from target>
feature: <inherited>
parent: <target path>
status: finalized                    # tickets jump directly to finalized (no iterating/reviewed)
last_updated: <now>
plugin_version: <version>
ticket_count: N
wave_count: N
flash_eligible_count: N
core_required_count: N
blocked_count: N
recommended_starting_ticket: T-NN
---
```

The parent-update portion of §5 runs in Phase 5 below (not here — Phase 4 writes the tickets file; Phase 5 updates the target).

Body sections per `references/ticket-format.md §10` (Summary block) and `§4` (wave organization):

```markdown
# Tickets: <Feature/System Name>

## 1. Summary
(table of metrics)

## 2. Dependency Graph
(textual graph)

## 3. Wave 1: <theme>
(all Wave 1 tickets, full format)

## 4. Wave 2: <theme>
(all Wave 2 tickets)

## 5. Wave N: ...

## Appendix A: Ticket Index
(quick-reference table: ID, title, size, layer, status)

## Appendix B: Blocked Tickets
(full format of any BLOCKED tickets, with "What unblocks this")

## Open Questions
(empty unless XL warnings or other ticket-level questions)

## Iteration Log
### Iteration 0 — Initial draft (YYYY-MM-DD)
- **Created via:** tickets <target>

## Changelog
| YYYY-MM-DD | (created) | Initial decomposition from <target> | tickets |
```

Atomic write per `${CLAUDE_SKILL_DIR}/references/operation-bookkeeping.md §1`.

### Phase 5: Update target artifact

Apply the parent-update half of the graph-mutation procedure per `${CLAUDE_SKILL_DIR}/references/operation-bookkeeping.md §3.2–§3.4`, with these parameters:

- **Parent:** the target artifact (plan / spec / feature-spec that sourced this tickets run)
- **New child path:** the tickets artifact's relative path
- **Parent Changelog reason:** `<N> tickets generated`
- **Operation name:** `tickets`

### Phase 6: Report

```
[Refinery] tickets complete.
[Refinery] Wrote: <output-path>
[Refinery]   <T> tickets, <W> waves
[Refinery]   Sizes: S=<S>, M=<M>, L=<L>, XL=<XL>  (XL warnings: <X>)
[Refinery]   Layers: frontend=<F>, backend=<B>, data=<D>, infra=<I>, docs=<DC>, test=<TT>
[Refinery]   FLASH-eligible: <FL>, CORE-required: <CR>, Blocked: <BL>
[Refinery]   Recommended starting ticket: <T-NN> (<title>)

Compatible with: /dispatch (or any compatible agent dispatcher)

Suggested next:
  /dispatch <T-NN>                        (start with recommended ticket; via dispatch plugin)
  /refine status                          (verify graph integrity)
  /refine update <tickets-path> "..."     (refine specific tickets if needed)
```

Commit hint:

```
spec(<basename>): tickets (<T> across <W> waves)
```

## Edge Cases

- **Source artifact has open questions that block tickets:** The ticket-architect emits BLOCKED tickets per `references/ticket-format.md §6`. They appear in Appendix B with a "What unblocks this" pointer.
- **Source artifact has [DELETED] requirements:** Skip them entirely (they don't generate tickets).
- **Re-run `/refine tickets` after source artifact changes:** The new tickets artifact is a new file (or overwrites with confirmation if filename collision). Compare with the previous version to identify which tickets changed (use git diff).
- **Source artifact has multi-feature coverage (rare):** Generate tickets per feature, with cross-feature dependencies as `depends_on` edges. Wave organization is global.
- **Source artifact has only one phase / one ticket worth of work:** Generate the single ticket; emit a note that decomposition was minimal.
- **Target is a `feature-spec` with sub-feature children (per OQ-010):** Tickets should cover the parent feature-spec's requirements; child feature-specs get their own `/refine tickets <child-path>` invocations. Cross-reference between ticket artifacts is not supported (per `references/ticket-format.md §8`).

## Performance

The ticket-architect agent is the heaviest in this mode (it processes the full source artifact and generates structured output). Forking the agent's context keeps the orchestrator clean. Output validation in Phase 3 is local (DAG check, schema validation) and fast.
