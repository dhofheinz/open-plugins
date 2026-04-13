---
artifact: stack
scope: system
feature: {{PROJECT_NAME}}
stage: stack
iteration: 0
last_updated: {{TIMESTAMP}}
status: draft
parent: {{DESIGN_PATH}}
children: []
references: []
convergence:
  questions_stable_count: 0
  open_questions_count: 0
  high_confidence_ratio: 0.0
plugin_version: 1.0.0
---

# Stack: {{PROJECT_NAME}}

## 1. Language, Runtime & Build

| Choice | Version | Why this | Gotchas |
|--------|---------|----------|---------|
| Language | {e.g., Go 1.22} | {design constraint(s)} | {known issues} |
| Runtime | {e.g., container, native binary} | {operational constraint} | {limitations} |
| Build system | {e.g., Make, Bazel, Gradle} | {team/ecosystem fit} | {pitfalls} |

**Confidence:** High / Medium / Low
**Source:** Design §X.Y constraint

## 2. Project Structure

```
<project-root>/
├── cmd/                   # Application entry points
├── internal/              # Private application code
│   ├── <subsystem-a>/     # Per design §1
│   └── <subsystem-b>/
├── pkg/                   # Reusable libraries (if any)
├── api/                   # API definitions (OpenAPI, proto, etc.)
├── tests/                 # Integration tests
└── ...                    # Per-stack conventions
```

**Convention:** {file naming, directory naming, package boundaries}

## 3. Core Dependencies

| Dependency | Version | Purpose | Why this | Gotchas |
|------------|---------|---------|----------|---------|
| {pkg-name} | {ver} | {what it does in this stack} | {alternatives considered, why this chosen — cite design constraint} | {known issues} |

**Confidence:** High / Medium / Low per row
**Source:** Per row, citing design or stack-level rationale

## 4. Internal Communication

{How subsystems talk to each other concretely. Library/protocol choices.}

| Boundary | Mechanism | Format | Constraint |
|----------|-----------|--------|------------|
| {A → B} | {sync HTTP / async event / direct call} | {JSON / Protobuf / Avro / etc.} | {latency / throughput / ordering} |

## 5. Serialization Strategy

{What format(s), where used, evolution policy.}

## 6. Testing Strategy

| Layer | Tool | Coverage target |
|-------|------|------------------|
| Unit | {e.g., Jest, pytest, go test} | {%} |
| Integration | {tool} | {scope} |
| End-to-end | {tool} | {scope} |
| Contract | {tool} | {scope — for external integrations} |

## 7. Observability

| Concern | Tool | Notes |
|---------|------|-------|
| Logs | {e.g., zap, slog, pino} | {format, sink} |
| Metrics | {e.g., Prometheus client} | {convention} |
| Traces | {e.g., OpenTelemetry} | {sampling policy} |
| Alerts | {tool — defer to ops if external} | — |

## 8. Configuration

| Config source | Use case | Format |
|---------------|----------|--------|
| Env vars | {runtime config} | {convention} |
| Config file | {static config} | {YAML / TOML / JSON} |
| Secrets store | {credentials} | {Vault / SOPS / cloud KMS — concrete choice} |

## 9. Deployment

```
{Topology diagram — how does this run in production?}

Example:
  Load balancer → N container replicas → managed Postgres
                                       → object storage (S3-compatible)
```

| Component | Runtime | Scaling | Constraints |
|-----------|---------|---------|-------------|
| {component} | {container / lambda / vm} | {horizontal / vertical} | {limits} |

**Deployment workflow:** {CI/CD tool, promotion path, rollback}

## 10. Dependency Summary

| Direct dependencies count | N |
| Total dependencies (with transitive) | N (best effort estimate) |
| Last updated | {date of stack synthesis} |

## 11. What We Build vs What We Buy

### Build (in-house)

| Component | Why build (not buy) | Maintenance burden |
|-----------|---------------------|--------------------|
| {component} | {no library exists / library doesn't fit / strategic differentiator} | {effort estimate} |

### Buy (external dependency)

| Component | Library/Service | Why buy (not build) |
|-----------|-----------------|---------------------|
| {component} | {choice} | {time-to-market / quality / compliance} |

## Open Questions

| ID | Question | Type | Added | Status |
|----|----------|------|-------|--------|
| OQ-001 | {question} | RESEARCHABLE \| HUMAN_NEEDED \| DERIVABLE \| OUT_OF_SCOPE | {date} | OPEN |

## Iteration Log

### Iteration 0 — Initial draft ({date})
- **Created via:** advance --stage=stack
- **Source:** {{DESIGN_PATH}}
- **Initial state:** {N tech choices, N gotchas surfaced, N open questions}

## Changelog

| Date | Section | Change | Reason | Operation |
|------|---------|--------|--------|-----------|
| {date} | (created) | Initial draft | derived from design | advance |
