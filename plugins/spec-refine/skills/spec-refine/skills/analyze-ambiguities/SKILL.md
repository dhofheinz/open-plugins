---
name: analyze-ambiguities
description: Read a specification document and identify all ambiguities, gaps, unclear items, and implicit assumptions that need clarification or research.
context: fork
allowed-tools: Read
user-invocable: false
agent: spec-critic
---

# Analyze Ambiguities - Specification Gap Detector

You are analyzing the specification for gaps and ambiguities.

**Input**: Path to spec document provided in $ARGUMENTS

## Step 1: Read the Specification

Read the full specification document at the provided path.

Parse the YAML frontmatter to understand:
- Current phase (what-auto or how-auto)
- Current iteration count
- Previous convergence metrics

## Step 2: Analyze for Ambiguities

Examine each section systematically:

### In High Confidence Section
Look for:
- Items that reference undefined terms
- Statements that could be interpreted multiple ways
- Missing details (what, when, how, who)
- Implicit assumptions not stated explicitly
- Dependencies on external systems not specified

### In Medium Confidence Section
Look for:
- Items that need verification against codebase
- Assumptions that should be promoted to high confidence or demoted to questions
- Vague language ("should", "might", "could", "probably")
- Missing acceptance criteria

### In Open Questions Section
Look for:
- Questions that can be split into more specific sub-questions
- Questions that might already be answered elsewhere in spec (duplicates)
- Questions that are too broad to research effectively

### Cross-Section Analysis
Look for:
- Contradictions between sections
- Missing connections (A depends on B but B not mentioned)
- Scope creep indicators
- Security, performance, error handling gaps

## Step 3: Categorize Findings

For each ambiguity found, categorize as:

1. **RESEARCH_NEEDED**: Can likely be answered by searching codebase
   - Pattern: "How does existing feature X handle Y?"
   - Pattern: "What convention does project use for Z?"

2. **HUMAN_NEEDED**: Requires human decision or clarification
   - Pattern: "Should feature support X or Y approach?"
   - Pattern: "What is acceptable latency for this operation?"

3. **DERIVABLE**: Can be inferred from other spec items
   - Pattern: "If A is true, then B must be..."

4. **OUT_OF_SCOPE**: Should be explicitly marked as not included
   - Pattern: "Feature X mentioned but not core to this spec"

## Step 4: Generate Search Strategies

For each RESEARCH_NEEDED item, suggest specific search strategies:

```
Ambiguity: How does the project handle authentication tokens?
Search Strategy:
  - Glob: **/*auth*.{php,js,ts}
  - Grep: "token" in session-related files
  - Grep: "Bearer" or "JWT" patterns
  - Look for: middleware, session handlers
```

## Step 5: Output Structured Report

Return findings in this format:

```
AMBIGUITY ANALYSIS COMPLETE
Spec: {path}
Phase: {what-auto|how-auto}
Iteration: {n}

## Research Needed ({count})

### 1. {Brief description}
- Location: {section where found}
- Quote: "{relevant text from spec}"
- Search Strategy:
  - {specific search approach}
  - {alternative approach}

### 2. {Next ambiguity}
...

## Human Decision Needed ({count})

### 1. {Brief description}
- Location: {section}
- Options: {if identifiable}
- Context: {why this matters}

## Derivable ({count})

### 1. {Brief description}
- Can be derived from: {other spec items}
- Suggested resolution: {inference}

## Out of Scope ({count})

### 1. {Brief description}
- Reason: {why it's out of scope}
- Recommendation: {add to exclusions section}

## Summary
- Total ambiguities: {n}
- Research targets: {n}
- Awaiting human: {n}
- Quick fixes: {n}
```

## Important Notes

- Be thorough but not pedantic - focus on ambiguities that matter
- An item in High Confidence that has gaps should be flagged
- Don't flag stylistic issues, only substantive gaps
- Prioritize ambiguities that block other understanding
