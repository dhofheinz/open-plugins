# Operation: Suggest Conventions

**Purpose:** Generate project-specific commit message convention recommendations based on historical analysis and best practices.

## Parameters

From `$ARGUMENTS` (after operation name):
- `count:N` - Number of commits to analyze (default: 50)
- `branch:name` - Branch to analyze (default: current branch)
- `format:json|text` - Output format (default: text)
- `include_examples:true|false` - Include example commits (default: true)
- `priority:high|medium|low|all` - Filter by recommendation priority (default: all)

## Workflow

### 1. Validate Repository

```bash
if ! git rev-parse --git-dir >/dev/null 2>&1; then
    echo "Error: Not in a git repository"
    exit 1
fi
```

### 2. Gather Historical Data

Execute analysis operations to collect data:

**A. Style Analysis:**
```bash
./.scripts/style-analyzer.sh <count> <branch>
```

**B. Pattern Detection:**
```bash
./.scripts/pattern-detector.py --count <count> --branch <branch>
```

**C. Scope Extraction:**
```bash
./.scripts/scope-extractor.sh --count <count> --branch <branch>
```

### 3. Execute Convention Recommender

Invoke the convention-recommender.py utility script:

```bash
./.scripts/convention-recommender.py --count <count> --branch <branch> --priority <priority>
```

The script will:
- Analyze aggregated historical data
- Identify current conventions and gaps
- Generate recommendations by priority
- Provide examples and implementation guidance
- Create project-specific guidelines

### 4. Recommendation Categories

**A. Format Recommendations**
- Commit message structure
- Subject line format
- Body organization
- Footer conventions

**B. Type Recommendations**
- Commonly used types
- Type selection guidance
- Project-specific type meanings

**C. Scope Recommendations**
- Standard scopes for the project
- Scope naming patterns
- When to use each scope

**D. Content Recommendations**
- Writing style (imperative mood, tense)
- Capitalization and punctuation
- Issue reference format
- Breaking change documentation

**E. Process Recommendations**
- Pre-commit validation
- Atomicity guidelines
- Review practices

### 5. Recommendation Priority Levels

**HIGH Priority (Critical for consistency):**
- Adopt conventional commits if not using (< 50% usage)
- Fix major inconsistencies (> 30% deviation)
- Establish missing critical patterns

**MEDIUM Priority (Improve quality):**
- Refine existing patterns (50-80% consistency)
- Add missing optional elements
- Enhance documentation practices

**LOW Priority (Nice-to-have):**
- Fine-tune minor details
- Advanced features (co-authors, trailers)
- Optimization opportunities

### 6. Output Structure

**Text Format (default):**
```
Project-Specific Commit Convention Recommendations
==================================================

Analysis: 50 commits on branch 'main'
Current Consistency: 85/100 (GOOD)
Generated: 2024-03-10

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔴 HIGH PRIORITY RECOMMENDATIONS

1. Continue Using Conventional Commits
   Status: ✓ Already adopted (87% usage)
   Action: Maintain current practice
   Benefit: Enables automated changelog, semantic versioning

   Format: <type>(<scope>): <subject>
   Example from project:
     ✓ feat(auth): implement OAuth2 authentication
     ✓ fix(api): handle null pointer in user endpoint

2. Standardize Subject Line Length
   Status: ○ Needs improvement (avg: 47 chars, σ=12)
   Action: Keep subject lines under 50 characters
   Current: 15% exceed limit
   Target: < 5% exceed limit

   ✓ Good: "feat(auth): add OAuth provider support"
   ✗ Too long: "feat(auth): implement OAuth2 authentication with support for multiple providers including Google and GitHub"
   ✓ Better: "feat(auth): add OAuth multi-provider support"

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🟡 MEDIUM PRIORITY RECOMMENDATIONS

3. Increase Body Usage for Complex Changes
   Status: ○ Moderate usage (34% of commits)
   Action: Add body for non-trivial changes
   Benefit: Better context for code review and history

   When to add body:
   • Multiple files changed (>3)
   • Complex logic changes
   • Breaking changes
   • Security-related changes

   Example from project:
     feat(auth): implement OAuth2 authentication

     - Add OAuth2 flow implementation
     - Support Google and GitHub providers
     - Include middleware for route protection
     - Add configuration management

4. Consistent Issue References
   Status: ✓ Good usage (67% of commits)
   Action: Reference issues consistently
   Current format: "Closes #123", "Fixes #456"
   Recommendation: Continue current practice

   Patterns detected in project:
     ✓ Closes #123  (45% of references)
     ✓ Fixes #456   (38% of references)
     ✓ Refs #789    (17% of references)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🟢 LOW PRIORITY RECOMMENDATIONS

5. Consider Adding Co-Author Attribution
   Status: ✗ Rare usage (2% of commits)
   Action: Add co-authors for pair programming
   Format: Co-authored-by: Name <email>

   Example:
     feat(api): add user management endpoint

     Co-authored-by: Jane Doe <jane@example.com>

6. Document Breaking Changes Explicitly
   Status: ○ Occasional (8% of commits)
   Action: Use BREAKING CHANGE footer when applicable

   Format:
     feat(api): change authentication flow

     BREAKING CHANGE: API now requires OAuth tokens
     instead of API keys. Update client applications.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📋 PROJECT-SPECIFIC STYLE GUIDE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

COMMIT MESSAGE FORMAT
---------------------
<type>(<scope>): <subject>

<body>

<footer>

TYPES (in order of frequency)
------------------------------
feat     - New features (35% of commits)
fix      - Bug fixes (30% of commits)
docs     - Documentation (16% of commits)
refactor - Code restructuring (8% of commits)
test     - Testing (5% of commits)
chore    - Maintenance (6% of commits)

COMMON SCOPES (use these)
-------------------------
auth     - Authentication/authorization (18%)
api      - Backend API (15%)
ui       - User interface (12%)
db       - Database (9%)
docs     - Documentation (9%)
config   - Configuration (6%)

STYLE RULES (current project standards)
----------------------------------------
✓ Use imperative mood ("add" not "added")
✓ Capitalize first letter of subject
✓ No period at end of subject
✓ Wrap body at 72 characters
✓ Blank line between subject and body
✓ Reference issues when applicable
✓ Use bullet points in body

EXAMPLES FROM THIS PROJECT
---------------------------
feat(auth): implement OAuth2 authentication

- Add OAuth2 flow implementation
- Support Google and GitHub providers
- Include middleware for route protection

Closes #123

---

fix(api): handle null pointer in user endpoint

The endpoint was not checking for null user objects
before accessing properties, causing crashes.

Fixes #456

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 CONSISTENCY METRICS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Format:         87% ████████████████████████░░░
Conventions:    92% ██████████████████████████░
Content:        67% ███████████████████░░░░░░░░
Overall:        85% █████████████████████░░░░░

NEXT STEPS
----------
1. Share this guide with team
2. Add to CONTRIBUTING.md
3. Configure git commit template
4. Set up pre-commit hooks
5. Review in team meeting

AUTOMATION OPPORTUNITIES
-------------------------
• Pre-commit hook to validate format
• Automated changelog generation
• Semantic version bumping
• Commit message linting (commitlint)
```

**JSON Format:**
```json
{
  "analysis_type": "convention_recommendations",
  "commits_analyzed": 50,
  "branch": "main",
  "consistency_score": 85,
  "generated_date": "2024-03-10",
  "recommendations": {
    "high_priority": [
      {
        "id": 1,
        "title": "Continue Using Conventional Commits",
        "status": "good",
        "current_usage": 87,
        "target_usage": 90,
        "action": "Maintain current practice",
        "benefit": "Enables automated tooling",
        "examples": [
          "feat(auth): implement OAuth2 authentication",
          "fix(api): handle null pointer"
        ]
      }
    ],
    "medium_priority": [...],
    "low_priority": [...]
  },
  "style_guide": {
    "format": "<type>(<scope>): <subject>",
    "types": [
      {"name": "feat", "percentage": 35, "description": "New features"},
      {"name": "fix", "percentage": 30, "description": "Bug fixes"}
    ],
    "scopes": [
      {"name": "auth", "percentage": 18, "description": "Authentication"},
      {"name": "api", "percentage": 15, "description": "Backend API"}
    ],
    "rules": [
      "Use imperative mood",
      "Capitalize first letter",
      "No period at end"
    ]
  },
  "automation": [
    "Pre-commit hook validation",
    "Automated changelog",
    "Semantic versioning"
  ]
}
```

### 7. Recommendation Generation Algorithm

```python
def generate_recommendations(analysis_data):
    """
    Generate prioritized recommendations based on analysis.
    """
    recommendations = {
        'high_priority': [],
        'medium_priority': [],
        'low_priority': []
    }

    # Check conventional commits usage
    if analysis_data['conventional_commits_pct'] < 50:
        recommendations['high_priority'].append({
            'title': 'Adopt Conventional Commits',
            'action': 'Migrate to conventional commits format',
            'reason': 'Low usage ({}%)'.format(
                analysis_data['conventional_commits_pct']
            )
        })
    elif analysis_data['conventional_commits_pct'] < 80:
        recommendations['medium_priority'].append({
            'title': 'Increase Conventional Commits Usage',
            'action': 'Encourage team to use format consistently'
        })

    # Check subject line length
    avg_length = analysis_data['avg_subject_length']
    if avg_length > 60:
        recommendations['high_priority'].append({
            'title': 'Reduce Subject Line Length',
            'action': 'Keep subjects under 50 characters',
            'current': avg_length
        })

    # Check imperative mood
    if analysis_data['imperative_mood_pct'] < 80:
        recommendations['high_priority'].append({
            'title': 'Use Imperative Mood Consistently',
            'action': 'Use "add" not "added", "fix" not "fixed"'
        })

    # More checks...

    return recommendations
```

## Error Handling

**Insufficient data:**
- Warning: "Limited data (< 20 commits), recommendations may be less accurate"
- Provide recommendations with confidence scores

**No patterns detected:**
- Return: "No clear patterns detected. Consider establishing conventions."
- Suggest: Standard conventional commits format as starting point

**Mixed conventions:**
- Identify: "Multiple convention styles detected (X% conventional, Y% other)"
- Recommend: "Migrate to single consistent style"

## Integration Usage

**By commit-assistant agent:**
```
New developer onboarding:
  → Invoke: /history-analysis suggest-conventions
  → Present: Project-specific style guide
  → Configure: Git commit template
```

**By team lead:**
```
Improving consistency:
  → Run: /history-analysis suggest-conventions
  → Review: High-priority recommendations
  → Implement: Top 3 improvements
  → Document: In CONTRIBUTING.md
```

## Success Criteria

Operation succeeds when:
- [x] All analysis data gathered
- [x] Recommendations prioritized correctly
- [x] Style guide generated
- [x] Examples provided
- [x] Actionable guidance included
- [x] Automation opportunities identified

## Performance

- **Analysis Time:** ~3-5 seconds for complete analysis
- **Recommendation Generation:** ~1 second
- **Total Time:** ~4-6 seconds
