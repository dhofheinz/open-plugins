# Stage: spec

**Pipeline position:** Stage 4 (system-level). Translates design into formal, testable, system-wide requirements with traceability.

## Inputs

- Parent artifact (a `finalized` or `reviewed` `design` artifact) — required
- Optional input: stack artifact (recommended but not required; informs interface contracts and constraints)
- Output path (default: `<working-dir>/<project>-spec.md`)

## Agent

`refinery:spec-writer` (model: `${user_config.spec_writer_model}` or `opus`)

## Template

`${CLAUDE_SKILL_DIR}/templates/spec.md`

## Procedure

### Phase 1: Read parents

Read the design artifact in full. If a stack artifact exists in the working directory, read it too.

Extract:

- Subsystems and their responsibilities (drives FR scoping)
- Failure modes (drive defensive FRs and AC error cases)
- Performance/scalability targets (drive NFR-P-NNN)
- Security model (drives NFR-S-NNN and FRs around authn/authz)
- External integrations (drive interface contracts)
- Stack technology choices (constrain interface details and constraints)

### Phase 2: Spawn spec-writer

Spawn agent `refinery:spec-writer` with prompt:

```
You are filling the system spec template. Your output is the formal, testable contract that implementers and reviewers refer to.

# Inputs
- Parent (design): <parent path>
- Stack (if exists): <stack path or "not yet specified">
- Project name: <project>
- Template path: ${CLAUDE_SKILL_DIR}/templates/spec.md
- Output path: <output-path>
- Reference: ${CLAUDE_SKILL_DIR}/references/document-format.md
- Reference: ${CLAUDE_SKILL_DIR}/references/requirement-syntax.md (RFC 2119 + EARS — system specs primarily use RFC 2119)

# Constraints

1. **Every FR/NFR has ID + priority + source + testable statement.**
   - ID per `references/document-format.md §5` (FR-NNN, NFR-<CAT>-NNN, INV-NNN, RD-NNN, R-NNN)
   - Priority: Must / Should / Could / Won't (MoSCoW)
   - Source: cites design section, principle, or explicit user decision
   - Statement: RFC 2119 keywords (MUST/SHALL/SHOULD/MAY) for system specs

2. **No ambiguous quantifiers.** "fast" → "within 200ms p95"; "many" → "10,000 concurrent". Every quantifier has units.

3. **Traceability matrix complete** (Appendix A). Every requirement maps to a design section and a test strategy.

4. **No implementation details.** "The system shall validate JWTs" is good; "The system shall use jose-jwt v4.15" is not (that's stack).

5. **Confidence on every claim.** High when derived directly from design; Medium when extrapolated; Low when speculative.

6. **Resolved Design Decisions (RD-NNN)** capture choices made during spec authoring that resolved an Open Question or trade-off — recorded for posterity.

7. **Risk Register (R-NNN)** captures known risks with Likelihood + Impact + Mitigation.

# Workflow

1. Read parent design (and stack if present).
2. Read template at ${CLAUDE_SKILL_DIR}/templates/spec.md.
3. For each design section, derive corresponding requirements:
   - Subsystems → FRs about behavior at subsystem boundaries
   - Failure modes → defensive FRs + risks
   - Performance targets → NFR-P-NNN
   - Security → NFR-S-NNN + FRs about authn/authz
   - Integrations → System Interfaces section + FRs about contracts
4. For each FR, write at least one acceptance criterion in Given/When/Then format (numbered AC-FR-NNN-N).
5. Build the Traceability Matrix in Appendix A.
6. Set frontmatter (artifact: spec, scope: system, parent: <design path>, etc.).
7. Universal sections.

# Output

Write to <output-path>. Return summary: counts of FRs, NFRs (per category), invariants, RDs, risks, ACs.
```

### Phase 3: Quality checks

| Check | Description |
|-------|-------------|
| Q1 | Every FR/NFR has ID + Priority + Source + Confidence + statement using RFC 2119 |
| Q2 | No ambiguous quantifiers (no "fast", "many", "soon" without explicit thresholds) |
| Q3 | Traceability Matrix complete (every FR/NFR has design source + test strategy) |
| Q4 | Every FR has ≥1 AC in Given/When/Then |
| Q5 | No technology references (those belong to stack/plan) |
| Q6 | Risk Register populated with at least 3 risks (every spec has risks) |
| Q7 | Universal sections present, frontmatter valid |

### Phase 4: Set graph

Per mode-advance Phase 6.
