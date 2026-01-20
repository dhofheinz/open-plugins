---
name: research-codebase
description: Search the codebase to answer specific questions from the ambiguity analysis. Returns findings with confidence levels.
context: fork
allowed-tools: Glob, Grep, Read
user-invocable: false
agent: code-archaeologist
---

# Research Codebase - Targeted Code Investigation

You are researching the codebase to answer specific questions about the feature specification.

**Input**: $ARGUMENTS contains the ambiguity analysis report with search strategies.

## Research Approach: Hybrid Priority

Execute research in two phases:

### Phase A: Pattern-Seeking (Context Building)

First, build understanding of relevant codebase areas:

1. **Find Similar Features**
   ```
   Glob: **/*{related_feature}*
   Grep: similar functionality keywords
   ```

2. **Identify Project Conventions**
   - File organization patterns
   - Naming conventions
   - Common abstractions used

3. **Map Relevant Architecture**
   - Entry points (routes, controllers, handlers)
   - Data flow patterns
   - Shared utilities and helpers

### Phase B: Question-Driven (Targeted Answers)

For each RESEARCH_NEEDED item from the ambiguity analysis:

1. Execute the suggested search strategies
2. Read relevant files discovered
3. Extract specific answers
4. Assess confidence level

## Confidence Assessment Criteria

### HIGH Confidence (promote to spec)
- Direct code evidence (function exists, pattern used)
- Explicit comments or documentation
- Multiple consistent examples
- Standard framework/library behavior

### MEDIUM Confidence (note but verify)
- Single example found (might be exception)
- Inferred from related code
- Convention appears consistent but not documented
- Third-party dependency behavior

### LOW Confidence (keep as question)
- No direct evidence found
- Contradictory examples
- Requires human judgment call
- Involves external systems not in codebase

## Research Execution

For each research target:

```
## Researching: {ambiguity description}

### Search Executed
- Glob: {pattern} → {n} files found
- Grep: {pattern} → {n} matches
- Files read: {list}

### Findings
{What was discovered}

### Evidence
File: {path}:{line}
```{code snippet}```

### Confidence: {HIGH|MEDIUM|LOW}
Rationale: {why this confidence level}

### Suggested Spec Update
{How this should update the specification}
```

## Special Research Cases

### When Nothing Found
- Note the absence as meaningful data
- Suggest this might be new territory for the project
- Recommend human decision on approach

### When Contradictions Found
- Document all variations
- Note which appears more recent/prevalent
- Flag for human resolution

### When Scope Expands
- If research reveals the feature is larger than expected
- Note the expansion but don't pursue rabbit holes
- Flag for orchestrator to handle

## Output Format

```
RESEARCH COMPLETE
Questions Investigated: {n}
High Confidence Answers: {n}
Medium Confidence Answers: {n}
Still Open: {n}

## Findings by Question

### Q1: {original question}
**Confidence**: HIGH
**Answer**: {clear answer}
**Evidence**: {file:line references}
**Spec Update**: Add to High Confidence section: "{suggested text}"

### Q2: {original question}
**Confidence**: MEDIUM
**Answer**: {tentative answer}
**Evidence**: {file:line references}
**Spec Update**: Add to Medium Confidence section: "{suggested text}"

### Q3: {original question}
**Confidence**: LOW
**Answer**: Could not determine
**Searched**: {what was tried}
**Spec Update**: Keep in Open Questions, add context: "{additional info}"

## New Questions Discovered
During research, these new questions emerged:
1. {question surfaced while investigating}
2. {another emergent question}

## Relevant Files for Future Reference
- {path}: {why it's relevant}
- {path}: {why it's relevant}
```

## Constraints

- Do NOT modify any files - read only
- Do NOT pursue tangential research
- Stay focused on the specific questions provided
- Time-box each question - don't exhaust search on one item
- If a question would require extensive research, note it and move on
