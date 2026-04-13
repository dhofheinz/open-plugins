# Reference: Requirement Syntax

Canonical definition of EARS patterns, Given/When/Then acceptance criteria, RFC 2119 language, and ID conventions used in every Refinery artifact. This is the **single source of truth** for how requirements and acceptance criteria are written.

The companion `specification-writing` skill (preloaded by the spec-writer agent) contains the same content in skill form. This file is the canonical reference for mode/stage files that don't run inside spec-writer.

## 1. EARS — Easy Approach to Requirements Syntax

EARS provides six patterns for unambiguous functional requirements. Every functional requirement (`FR-NNN`) MUST use one of the six patterns.

### 1.1 Ubiquitous (always active)

```
The <system> shall <required behavior>.
```

**When to use:** A behavior that holds at all times.

**Example:** "The system shall maintain audit logs for all administrative actions."

### 1.2 Event-Driven (responds to a trigger)

```
When <trigger>, the <system> shall <required behavior>.
```

**When to use:** A behavior that responds to a discrete event.

**Example:** "When a user submits a login form, the system shall validate the credentials within 200ms."

### 1.3 State-Driven (active during a state)

```
While <state>, the <system> shall <required behavior>.
```

**When to use:** A behavior that holds during a specific operational state.

**Example:** "While the database is in maintenance mode, the system shall reject all write requests with HTTP 503."

### 1.4 Unwanted Behavior (defensive)

```
If <unwanted condition>, then the <system> shall <required behavior>.
```

**When to use:** A behavior that handles error or exceptional conditions.

**Example:** "If the upstream API returns a 5xx response, then the system shall retry up to three times with exponential backoff."

### 1.5 Optional Feature (conditional capability)

```
Where <feature is included>, the <system> shall <required behavior>.
```

**When to use:** A behavior that exists only when a feature is enabled or a condition holds.

**Example:** "Where the multi-tenant feature is enabled, the system shall scope all queries by tenant_id."

### 1.6 Complex (multiple triggers)

```
When <trigger1> and while <state> and if <condition>, the <system> shall <behavior>.
```

**When to use:** A behavior with compound preconditions. Use sparingly — prefer decomposition into multiple atomic requirements when possible.

**Example:** "When a payment is submitted and while the merchant account is verified and if the amount exceeds the daily limit, the system shall require additional authentication."

### 1.7 EARS anti-patterns

| Anti-pattern | Why it fails | Fix |
|--------------|--------------|-----|
| "The system should…" | "Should" = preference, not requirement | Use "shall" for mandatory; "may" for optional |
| "The system handles X" | Not testable; "handle" is unclear | Specify the observable behavior: "logs", "rejects", "retries", "returns" |
| Compound: "The system shall validate and store and notify…" | Three requirements masquerading as one | Split into FR-A (validate), FR-B (store), FR-C (notify) |
| "The system shall be fast" | Unmeasurable | Specify the threshold: "within 200ms p95" |
| "The system shall support many users" | Unmeasurable | Specify the scale: "shall support 10,000 concurrent users" |

## 2. Given/When/Then (Gherkin) — Acceptance Criteria

Every functional requirement (`FR-NNN`) MUST have at least one acceptance criterion (`AC-FR-NNN-N`) in Given/When/Then format.

### 2.1 Structure

```gherkin
Given <precondition>
  And <additional precondition>     # optional
When <action>
Then <observable outcome>
  And <additional outcome>          # optional
```

### 2.2 Rules

- **Atomic:** One clear action per scenario. If you need multiple `When`s, you have multiple scenarios.
- **Deterministic:** Given the same Given + When, the Then must always be the same outcome.
- **Observable:** The Then must be testable from outside the system (HTTP response, file written, log entry, database row, exception thrown).
- **Concrete:** Use specific values where possible ("within 200ms", "HTTP 200", "user role 'admin'") rather than vague qualifiers.
- **Independent:** Each AC stands alone; tests don't depend on other AC's side effects.

### 2.3 Examples

**Good:**

```gherkin
Given a user with role "admin" and a valid session token
When the user submits POST /api/users with valid payload
Then the response status is 201
  And the response body contains the new user's id
  And the new user appears in GET /api/users within 1 second
```

**Bad** (vague, not deterministic, multi-action):

```gherkin
Given an admin user
When the user creates a new user
Then it should work
```

### 2.4 Edge case patterns

For every primary AC ("happy path"), consider:

- **Negative case:** What happens when preconditions fail?
- **Boundary case:** What happens at the edge of valid input ranges?
- **Concurrent case:** What happens when two operations race?
- **Error case:** What happens when an upstream dependency fails?

Acceptance criteria should cover all four where applicable.

## 3. RFC 2119 (System-Level Specs)

System-level `spec` artifacts (`scope: system`) use RFC 2119 keywords for normative requirements. Feature-level `feature-spec` artifacts use EARS exclusively (RFC 2119 keywords appear only in cross-references to system requirements).

| Keyword | Meaning |
|---------|---------|
| **MUST**, **REQUIRED**, **SHALL** | Absolute requirement |
| **MUST NOT**, **SHALL NOT** | Absolute prohibition |
| **SHOULD**, **RECOMMENDED** | Strong recommendation; deviations require justification |
| **SHOULD NOT**, **NOT RECOMMENDED** | Strong recommendation against; deviations require justification |
| **MAY**, **OPTIONAL** | Truly optional |

**Convention in Refinery:**

- Use **uppercase** for RFC 2119 keywords (`MUST`, `SHALL`, etc.)
- Use lowercase `shall` for EARS patterns (per EARS standard)
- Pair every `SHOULD` with rationale: "The system SHOULD use cached results when available, because cache invalidation is handled by the upstream service."

## 4. Numbering Conventions

(See `references/document-format.md §5` for the complete numbering table.)

Quick reference:

- `FR-NNN` — Functional Requirement (per artifact, never reused)
- `NFR-<CATEGORY>-NNN` — Non-Functional Requirement (categories: P, S, SC, R, A, U, M, C)
- `INV-NNN` — Invariant
- `RD-NNN` — Resolved Design Decision
- `R-NNN` — Risk
- `AC-<REQ-ID>-N` — Acceptance Criterion (scoped to its parent requirement)
- `OQ-NNN` — Open Question
- `FM-NNN` — Failure Mode (design artifacts)
- `P-NNN` — Principle (principles artifacts)
- `T-NN` — Ticket (tickets artifacts)
- `SD-NNN` — Source Document (per artifact's source_documents list)

## 5. Quality Checklist

Before any artifact transitions to `finalized`, verify:

- [ ] **Atomicity:** One requirement per FR-NNN. No compound requirements with implicit `AND`.
- [ ] **EARS compliance:** Every FR-NNN uses one of the six EARS patterns (or RFC 2119 for system specs).
- [ ] **Specificity:** No weasel words ("should", "might", "could", "generally", "typically") where "shall" is expected.
- [ ] **Testability:** Every requirement could be verified by writing a test or running an observation.
- [ ] **Necessity:** Every requirement traces to a stated need (user, upstream artifact, regulation, principle).
- [ ] **AC coverage:** Every FR has ≥1 AC; every AC's Given/When/Then is atomic, deterministic, observable.
- [ ] **Confidence + Evidence:** Every tracked claim has a Confidence tier and either Evidence (file:line or upstream reference) or appears in Open Questions.
- [ ] **No orphans:** No FR without AC, no AC without parent FR, no upstream reference to a non-existent artifact.
- [ ] **No dangling deletes:** All cross-references to `[DELETED]` items either point to their replacement or are themselves marked obsolete.
- [ ] **Glossary discipline:** Every domain term used is defined either in the artifact's Glossary appendix, in `_glossary.md`, or in an upstream artifact.
