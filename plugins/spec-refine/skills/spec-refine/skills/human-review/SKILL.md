---
name: human-review
description: Present open questions to human for resolution using batched AskUserQuestion prompts, then update the specification with answers.
context: fork
allowed-tools: Read, Edit, AskUserQuestion
user-invocable: false
---

# Human Review - Interactive Question Resolution

You are facilitating human review of the specification's open questions.

**Input**: $ARGUMENTS contains path to spec document

## Step 1: Read and Analyze Open Questions

Read the specification and extract all Open Questions.

Categorize each question by:
- **Complexity**: Simple (yes/no, pick one) vs Complex (requires explanation)
- **Topic**: Group related questions together
- **Dependencies**: Some questions may depend on answers to others

## Step 2: Plan Question Batches

Create batches following these rules:

### Batch Composition
- Maximum 4 questions per AskUserQuestion call
- Group by topic when possible
- Put dependent questions in later batches
- Complex questions may be asked alone for focus

### Batch Types

**Simple Batch**: 3-4 related simple questions
```
Topic: Authentication
Q1: Should sessions expire after inactivity?
Q2: Support "remember me" functionality?
Q3: Require re-auth for sensitive operations?
```

**Complex Batch**: 1-2 complex questions
```
Topic: Data Architecture
Q1: How should user preferences be stored?
   - Option A: In user table (simple, coupled)
   - Option B: Separate preferences table (flexible, more complex)
   - Option C: JSON column (schemaless, harder to query)
```

**Mixed Batch**: 1 complex + 2 simple
```
Topic: Error Handling
Q1 (complex): What should happen when external API fails?
Q2 (simple): Show technical error details to users?
Q3 (simple): Log all errors to monitoring service?
```

## Step 3: Execute Question Batches

For each batch, use AskUserQuestion:

```
AskUserQuestion:
  questions:
    - question: "{full question text}"
      header: "{Topic}"  # max 12 chars
      options:
        - label: "{Option A}"
          description: "{What this means}"
        - label: "{Option B}"
          description: "{What this means}"
      multiSelect: {true if multiple valid}
```

### Option Design Guidelines
- 2-4 options per question
- First option can be recommended: "Option A (Recommended)"
- Include trade-offs in descriptions
- User can always select "Other" for custom input

## Step 4: Process Answers

For each answered question:

### Clear Answer → High Confidence
If user gave definitive answer:
- Add to High Confidence section
- Format: `- {statement based on answer} (per human review)`
- Remove from Open Questions

### Partial Answer → Medium Confidence
If user gave tentative or conditional answer:
- Add to Medium Confidence section
- Note the condition or uncertainty
- May keep related follow-up in Open Questions

### Deferred Answer
If user says "decide later" or "not sure yet":
- Keep in Open Questions
- Add note: `[DEFERRED: {reason}]`

### New Questions Raised
If answer raises new questions:
- Add to Open Questions
- Tag as: `[FROM REVIEW]`

## Step 5: Update Specification

After all batches complete:

1. Edit spec to reflect all answers
2. Update Open Questions section (remove answered, add new)
3. Update convergence metrics
4. Add to Iteration Log:

```markdown
### Human Review ({date})
- **Questions Presented**: {n}
- **Resolved**: {n}
- **Deferred**: {n}
- **New Questions**: {n} raised during review
- **Remaining Open**: {n}
```

## Step 6: Check Completion

After human review:
- If Open Questions ≤ 0: Phase complete
- If Open Questions > 0 but all marked [DEFERRED]: Phase complete
- If new questions added: May need another review pass

## Output Summary

```
HUMAN REVIEW COMPLETE
Spec: {path}
Phase: {what-human|how-human}

## Questions Processed
- Total presented: {n}
- Resolved to High Confidence: {n}
- Resolved to Medium Confidence: {n}
- Deferred: {n}
- New questions raised: {n}

## Remaining Open Questions
{list any remaining}

## Recommendation
{COMPLETE: ready for next phase | CONTINUE: more review needed}
```

## Interaction Guidelines

- Be respectful of human's time - batch efficiently
- Provide enough context for informed decisions
- Don't ask questions that were already answered
- If human seems frustrated, offer to defer remaining questions
- Acknowledge when questions are difficult or uncertain
