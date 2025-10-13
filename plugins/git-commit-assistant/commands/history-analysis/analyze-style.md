# Operation: Analyze Commit Style

**Purpose:** Analyze recent commit history to learn the project's commit message style, conventions, and patterns.

## Parameters

From `$ARGUMENTS` (after operation name):
- `count:N` - Number of commits to analyze (default: 50)
- `branch:name` - Branch to analyze (default: current branch)
- `format:json|text` - Output format (default: text)

## Workflow

### 1. Validate Repository

```bash
# Check if in git repository
if ! git rev-parse --git-dir >/dev/null 2>&1; then
    echo "Error: Not in a git repository"
    exit 1
fi

# Check if has commits
if ! git log -1 >/dev/null 2>&1; then
    echo "Error: No commit history found"
    exit 1
fi
```

### 2. Execute Style Analysis Script

Invoke the style-analyzer.sh utility script:

```bash
./.scripts/style-analyzer.sh <count> <branch>
```

The script will:
- Fetch recent commits from git log
- Analyze commit message formats
- Calculate statistics (average length, type distribution, etc.)
- Detect conventional commits usage
- Identify common patterns

### 3. Process Analysis Results

The script returns JSON output with:

```json
{
  "project_style": {
    "uses_conventional_commits": true,
    "conventional_commits_percentage": 87,
    "average_subject_length": 47,
    "subject_length_stddev": 8,
    "common_types": [
      {"type": "feat", "count": 45, "percentage": 35.4},
      {"type": "fix", "count": 38, "percentage": 29.9},
      {"type": "docs", "count": 20, "percentage": 15.7}
    ],
    "common_scopes": [
      {"scope": "auth", "count": 23, "percentage": 18.1},
      {"scope": "api", "count": 19, "percentage": 14.9},
      {"scope": "ui", "count": 15, "percentage": 11.8}
    ],
    "imperative_mood_percentage": 92,
    "has_body_percentage": 34,
    "references_issues_percentage": 67,
    "consistency_score": 85,
    "sample_commits": [
      "feat(auth): implement OAuth2 authentication",
      "fix(api): handle null pointer in user endpoint",
      "docs: update API documentation"
    ]
  }
}
```

### 4. Generate Recommendations

Based on analysis results, provide:

**Style Recommendations:**
- Conventional commits adherence level
- Recommended message format
- Typical subject line length
- Body usage patterns
- Issue reference patterns

**Type Recommendations:**
- Most commonly used types
- Type usage frequency
- Recommended types for new commits

**Scope Recommendations:**
- Commonly used scopes
- Scope naming patterns
- When to use which scope

**Consistency Recommendations:**
- Areas of good consistency
- Areas needing improvement
- Specific guidance for better consistency

### 5. Format Output

**Text Format (default):**
```
Git Commit Style Analysis
=========================

Commits Analyzed: 50
Branch: main
Conventional Commits: 87% (43/50)
Consistency Score: 85/100

Subject Lines:
  Average Length: 47 characters
  Recommended: Keep under 50 characters

Common Types:
  1. feat  - 35.4% (45 commits) - New features
  2. fix   - 29.9% (38 commits) - Bug fixes
  3. docs  - 15.7% (20 commits) - Documentation

Common Scopes:
  1. auth  - 18.1% (23 commits) - Authentication/authorization
  2. api   - 14.9% (19 commits) - API endpoints
  3. ui    - 11.8% (15 commits) - User interface

Patterns Detected:
  ✓ Uses imperative mood (92%)
  ✓ References issues frequently (67%)
  ○ Body usage moderate (34%)

Recommendations:
  • Continue using conventional commits format
  • Consider 'auth' scope for authentication changes
  • Keep subject lines under 50 characters
  • Use imperative mood (e.g., "add" not "added")
  • Reference issues when applicable (#123)

Sample Commits (project style):
  feat(auth): implement OAuth2 authentication
  fix(api): handle null pointer in user endpoint
  docs: update API documentation
```

**JSON Format:**
```json
{
  "analysis_type": "commit_style",
  "commits_analyzed": 50,
  "branch": "main",
  "results": { ... },
  "recommendations": [ ... ],
  "confidence": "high"
}
```

## Error Handling

**No git repository:**
- Error: "Not in a git repository. Run this command from within a git project."
- Exit code: 1

**No commits:**
- Error: "No commit history found. This appears to be a new repository."
- Exit code: 1

**Branch doesn't exist:**
- Error: "Branch 'branch-name' not found. Check branch name and try again."
- Exit code: 1

**Insufficient commits:**
- Warning: "Only X commits found. Analysis may be less accurate."
- Proceed with available commits

**Git command fails:**
- Error: "Git command failed: {error message}"
- Provide troubleshooting steps

## Integration Usage

**By commit-assistant agent:**
```
User requests: "commit my changes"
  → Agent invokes: /history-analysis analyze-style
  → Learns: Project uses conventional commits, common scope: "auth"
  → Agent generates message matching project style
```

**By message-generation skill:**
```
Before generating message:
  → Invoke: /history-analysis analyze-style format:json
  → Extract: common_types, common_scopes, average_length
  → Use in: message generation to match project conventions
```

## Output Examples

**High Consistency Project (score: 95):**
```
✓ Excellent consistency across commits
✓ Strong conventional commits adherence (98%)
✓ Clear scope usage patterns
→ Continue current practices
```

**Medium Consistency Project (score: 65):**
```
○ Moderate consistency
○ Mixed conventional commits usage (64%)
○ Inconsistent scope patterns
→ Recommend adopting conventional commits
→ Define standard scopes for the project
```

**Low Consistency Project (score: 35):**
```
✗ Low consistency across commits
✗ Minimal conventional commits usage (12%)
✗ No clear patterns
→ Consider establishing commit message guidelines
→ Define project-specific conventions
→ Use this tool to enforce standards
```

## Success Criteria

Operation succeeds when:
- [x] Git repository validated
- [x] Commits successfully analyzed
- [x] Statistics calculated accurately
- [x] Patterns detected correctly
- [x] Recommendations generated
- [x] Output formatted properly
- [x] Results match project reality

## Performance

- **Analysis Time:** ~1-2 seconds for 50 commits
- **Memory Usage:** Minimal (processes line-by-line)
- **Git Operations:** Read-only, no modifications
