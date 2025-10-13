# Operation: Detect Commit Patterns

**Purpose:** Identify project-specific commit message patterns, conventions, and formatting standards from commit history.

## Parameters

From `$ARGUMENTS` (after operation name):
- `count:N` - Number of commits to analyze (default: 50)
- `branch:name` - Branch to analyze (default: current branch)
- `format:json|text` - Output format (default: text)
- `detailed:true|false` - Include detailed pattern breakdown (default: false)

## Workflow

### 1. Validate Repository

```bash
# Verify git repository
if ! git rev-parse --git-dir >/dev/null 2>&1; then
    echo "Error: Not in a git repository"
    exit 1
fi
```

### 2. Execute Pattern Detection

Invoke the pattern-detector.py utility script:

```bash
./.scripts/pattern-detector.py --count <count> --branch <branch> [--detailed]
```

The script analyzes:
- **Format Patterns:** Message structure and formatting
- **Convention Patterns:** Conventional commits, semantic versioning references
- **Content Patterns:** Imperative mood, capitalization, punctuation
- **Metadata Patterns:** Issue references, co-authors, sign-offs
- **Body Patterns:** Bullet points, wrapping, section structure

### 3. Pattern Categories Analyzed

**A. Format Patterns**
```python
patterns = {
    'conventional_commits': 0,      # type(scope): subject
    'simple_subject': 0,             # Just a subject line
    'prefixed': 0,                   # [PREFIX] subject
    'tagged': 0,                     # #tag subject
    'other': 0
}
```

**B. Convention Patterns**
```python
conventions = {
    'imperative_mood': 0,            # "add" vs "added"
    'capitalized_subject': 0,        # First letter capitalized
    'no_period_end': 0,              # No period at end
    'blank_line_before_body': 0,     # Proper body separation
    'wrapped_body': 0,               # 72-char wrap
    'has_footer': 0                  # Breaking changes, issues
}
```

**C. Content Patterns**
```python
content = {
    'references_issues': 0,          # #123, Closes #456
    'mentions_breaking': 0,          # BREAKING CHANGE:
    'has_co_authors': 0,             # Co-authored-by:
    'signed_off': 0,                 # Signed-off-by:
    'includes_rationale': 0,         # "because", "to", "for"
    'mentions_impact': 0             # "affects", "impacts", "changes"
}
```

### 4. Pattern Analysis Algorithm

The pattern-detector.py script implements:

```python
def analyze_commit_patterns(commits):
    """
    Analyze commit messages for patterns.
    Returns pattern frequencies and confidence scores.
    """
    patterns = initialize_pattern_counters()

    for commit in commits:
        # Parse commit structure
        subject, body, footer = parse_commit(commit)

        # Detect format pattern
        if is_conventional_commit(subject):
            patterns['format']['conventional_commits'] += 1
        elif has_prefix(subject):
            patterns['format']['prefixed'] += 1
        # ... more checks

        # Detect conventions
        if is_imperative_mood(subject):
            patterns['conventions']['imperative_mood'] += 1
        if is_capitalized(subject):
            patterns['conventions']['capitalized_subject'] += 1
        # ... more checks

        # Detect content patterns
        if references_issues(commit):
            patterns['content']['references_issues'] += 1
        # ... more checks

    # Calculate percentages
    return calculate_pattern_percentages(patterns, len(commits))
```

### 5. Output Structure

**Text Format (default):**
```
Commit Pattern Analysis
=======================

Commits Analyzed: 50
Branch: main

FORMAT PATTERNS
---------------
Conventional Commits: 87% (44/50)  ✓ DOMINANT
  Example: feat(auth): implement OAuth2
Simple Subject:       10% (5/50)
  Example: Update documentation
Prefixed:             3% (1/50)
  Example: [HOTFIX] Fix critical bug

CONVENTION PATTERNS
-------------------
Imperative Mood:      92% (46/50)   ✓ STRONG
Capitalized Subject:  94% (47/50)   ✓ STRONG
No Period at End:     88% (44/50)   ✓ STRONG
Blank Line Before Body: 100% (17/17) ✓ PERFECT
Body Wrapped at 72:   94% (16/17)   ✓ STRONG
Has Footer:           26% (13/50)   ○ MODERATE

CONTENT PATTERNS
----------------
References Issues:    67% (34/50)   ✓ COMMON
Mentions Breaking:    8% (4/50)     ○ OCCASIONAL
Has Co-Authors:       2% (1/50)     ✗ RARE
Signed-Off:          12% (6/50)     ○ OCCASIONAL
Includes Rationale:   45% (23/50)   ○ MODERATE
Mentions Impact:      31% (16/50)   ○ MODERATE

DETECTED CONVENTIONS
--------------------
✓ Project uses conventional commits format
✓ Strong imperative mood usage
✓ Consistent capitalization and punctuation
✓ Frequent issue references
○ Moderate footer usage
○ Occasional breaking change mentions

PATTERN CONSISTENCY
-------------------
Overall Score: 85/100 (GOOD)
  Format:      High (87% conventional)
  Conventions: High (90%+ adherence)
  Content:     Moderate (varied usage)

RECOMMENDATIONS
---------------
• Continue using conventional commits format
• Maintain imperative mood in subject lines
• Consider more consistent footer usage
• Document rationale in commit bodies when complex
```

**JSON Format:**
```json
{
  "analysis_type": "pattern_detection",
  "commits_analyzed": 50,
  "branch": "main",
  "patterns": {
    "format": {
      "conventional_commits": {"count": 44, "percentage": 87, "strength": "dominant"},
      "simple_subject": {"count": 5, "percentage": 10, "strength": "rare"},
      "prefixed": {"count": 1, "percentage": 3, "strength": "rare"}
    },
    "conventions": {
      "imperative_mood": {"count": 46, "percentage": 92, "strength": "strong"},
      "capitalized_subject": {"count": 47, "percentage": 94, "strength": "strong"},
      "no_period_end": {"count": 44, "percentage": 88, "strength": "strong"}
    },
    "content": {
      "references_issues": {"count": 34, "percentage": 67, "strength": "common"},
      "mentions_breaking": {"count": 4, "percentage": 8, "strength": "occasional"}
    }
  },
  "consistency_score": 85,
  "dominant_pattern": "conventional_commits",
  "recommendations": [
    "Continue using conventional commits format",
    "Maintain imperative mood in subject lines"
  ]
}
```

### 6. Pattern Strength Classification

```
PERFECT:    95-100% - Universal usage
STRONG:     80-94%  - Very consistent
DOMINANT:   65-79%  - Clear preference
COMMON:     45-64%  - Regular usage
MODERATE:   25-44%  - Occasional usage
OCCASIONAL: 10-24%  - Infrequent usage
RARE:       1-9%    - Seldom used
ABSENT:     0%      - Not used
```

### 7. Detailed Pattern Breakdown

When `detailed:true` is specified, include:

**Per-Pattern Examples:**
```
IMPERATIVE MOOD (92%)
  ✓ "Add user authentication"
  ✓ "Fix null pointer exception"
  ✓ "Update API documentation"
  ✗ "Added new feature"
  ✗ "Updated dependencies"
```

**Timeline Analysis:**
```
Pattern Evolution (most recent 10 commits):
  Conventional Commits: 10/10 (100%) - Improving ↑
  Imperative Mood:      9/10 (90%)  - Stable →
  Issue References:     8/10 (80%)  - Improving ↑
```

## Error Handling

**No git repository:**
- Return: "Error: Not in a git repository"
- Exit code: 1

**No commits:**
- Return: "Error: No commit history to analyze"
- Exit code: 1

**Insufficient commits:**
- Warning: "Only X commits available (requested Y)"
- Proceed with available commits

**Pattern detection fails:**
- Return partial results with warning
- Indicate which patterns couldn't be detected

## Integration Usage

**By commit-assistant agent:**
```
Agent: Determine project conventions
  → Invoke: /history-analysis detect-patterns
  → Learn: Project uses conventional commits (87%)
  → Apply: Use conventional format for new commits
```

**By message-generation skill:**
```
Before generating:
  → Detect dominant patterns
  → Extract format preferences
  → Match project conventions
```

**By commit-best-practices skill:**
```
When reviewing commits:
  → Compare against detected patterns
  → Flag deviations from project norms
  → Suggest consistency improvements
```

## Success Criteria

Operation succeeds when:
- [x] All pattern categories analyzed
- [x] Frequencies calculated accurately
- [x] Strength classifications assigned
- [x] Consistency score computed
- [x] Dominant pattern identified
- [x] Recommendations generated
- [x] Output formatted correctly

## Performance

- **Analysis Time:** ~2-3 seconds for 50 commits
- **Memory Usage:** Low (streaming analysis)
- **Accuracy:** High (>95% pattern detection accuracy)
