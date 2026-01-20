# Convergence Criteria Reference

This document defines when automated refinement loops should terminate.

## Overview

The spec-refine skill uses a **hybrid convergence** approach:
- Minimum iterations ensure adequate research depth
- Maximum iterations prevent runaway loops
- Early termination when automated research has exhausted its value

## Iteration Limits

| Limit | Value | Rationale |
|-------|-------|-----------|
| Minimum | 2 | At least 2 passes to build research momentum |
| Maximum | 5 | Cap to prevent excessive automated cycling |

## Convergence Conditions

Stop automated phase early (after minimum iterations) if **ANY** condition is met:

### 1. Question Stability

```yaml
condition: questions_stable_count >= 2
```

**What it measures**: Open Questions count unchanged for 2 consecutive iterations.

**Why it matters**: If the agent can't reduce or expand the question set, it has reached its research limit. Either questions need human input, or they're truly unanswerable from the codebase.

**Tracked via**: `convergence.questions_stable_count` in spec frontmatter

### 2. Low Question Count

```yaml
condition: open_questions_count <= 3
```

**What it measures**: Few enough open questions that human review is efficient.

**Why it matters**: With ≤3 questions, the overhead of another automated iteration outweighs potential gains. Human can resolve these quickly.

**Tracked via**: `convergence.open_questions_count` in spec frontmatter

### 3. High Confidence Ratio

```yaml
condition: high_confidence_ratio > 0.80
```

**What it measures**: Ratio of High Confidence items to total specification items.

**Calculation**:
```
ratio = high_confidence_items / (high + medium + open_questions)
```

**Why it matters**: When 80%+ of the spec is verified against codebase, diminishing returns on further automated research. The remaining 20% likely needs human judgment.

**Tracked via**: `convergence.high_confidence_ratio` in spec frontmatter

## Decision Flow

```
After each iteration:
│
├─ iteration < 2?
│   └─ YES → Continue (minimum not met)
│
├─ iteration >= 5?
│   └─ YES → Stop (maximum reached)
│
├─ questions_stable_count >= 2?
│   └─ YES → Stop (research exhausted)
│
├─ open_questions_count <= 3?
│   └─ YES → Stop (few enough for human)
│
├─ high_confidence_ratio > 0.80?
│   └─ YES → Stop (spec mostly verified)
│
└─ Otherwise → Continue
```

## Metric Updates

After each iteration, the integrate-findings skill updates metrics:

### questions_stable_count
- **Increment** if `open_questions_count` unchanged from previous iteration
- **Reset to 0** if count changed (up or down)

### open_questions_count
- Simple count of items in Open Questions section
- Includes items marked `[DEFERRED]` or `[NEW]`

### high_confidence_ratio
- Recalculated fresh each iteration
- Count items in each section (excluding headers, empty lines)
- Apply formula above

## Edge Cases

### Oscillating Questions
If questions toggle between N and N+1 repeatedly:
- `questions_stable_count` keeps resetting
- Maximum iterations will eventually trigger
- This is expected behavior for genuinely difficult specs

### All Questions Resolved Early
If iteration 2 resolves all questions:
- `open_questions_count = 0` meets threshold
- Early termination is correct
- Human review may still add new questions

### Confidence Ratio Drops
If research reveals more unknowns:
- `high_confidence_ratio` may decrease
- This is healthy - better to know what we don't know
- Continue iterating until other criteria met

## Tuning

These values are reasonable defaults. Adjust in orchestrator if needed:

| Parameter | Conservative | Balanced (Default) | Aggressive |
|-----------|--------------|-------------------|------------|
| Min Iterations | 3 | 2 | 1 |
| Max Iterations | 7 | 5 | 3 |
| Stability Threshold | 3 | 2 | 2 |
| Questions Threshold | 2 | 3 | 5 |
| Confidence Threshold | 0.90 | 0.80 | 0.70 |

## Verbose Mode Logging

When `--verbose` flag is set, log convergence checks:

```
CONVERGENCE CHECK (Iteration 3)
├─ Minimum met: YES (3 >= 2)
├─ Maximum reached: NO (3 < 5)
├─ Questions stable: NO (count: 1, need: 2)
│   └─ Previous: 7, Current: 5, Changed: YES
├─ Low questions: NO (5 > 3)
├─ High confidence: NO (0.65 < 0.80)
│   └─ High: 13, Medium: 4, Open: 5
└─ DECISION: CONTINUE
```
