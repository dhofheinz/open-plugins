# Operation: Extract Scopes

**Purpose:** Discover and analyze commonly used scopes in commit messages to understand project structure and component organization.

## Parameters

From `$ARGUMENTS` (after operation name):
- `count:N` - Number of commits to analyze (default: 50)
- `branch:name` - Branch to analyze (default: current branch)
- `format:json|text` - Output format (default: text)
- `min_frequency:N` - Minimum occurrences to include (default: 2)
- `top:N` - Show only top N scopes (default: 20)

## Workflow

### 1. Validate Repository

```bash
# Check git repository
if ! git rev-parse --git-dir >/dev/null 2>&1; then
    echo "Error: Not in a git repository"
    exit 1
fi
```

### 2. Execute Scope Extraction

Invoke the scope-extractor.sh utility script:

```bash
./.scripts/scope-extractor.sh --count <count> --branch <branch> --min-frequency <min>
```

The script will:
- Parse commit messages
- Extract scopes using regex patterns
- Count scope frequencies
- Analyze scope naming patterns
- Categorize scopes by type

### 3. Scope Extraction Algorithm

**Pattern Matching:**
```bash
# Primary pattern: type(scope): subject
^[a-z]+\(([^)]+)\):

# Examples:
feat(auth): add OAuth        → scope: "auth"
fix(api/users): handle null  → scope: "api/users"
docs(readme): update guide   → scope: "readme"
```

**Nested Scope Handling:**
```bash
# Hierarchical scopes
api/endpoints → parent: "api", child: "endpoints"
ui/components → parent: "ui", child: "components"
core/auth     → parent: "core", child: "auth"
```

**Multi-Scope Handling:**
```bash
# Comma-separated scopes
feat(api,docs): add endpoint → scopes: ["api", "docs"]
fix(ui, ux): button alignment → scopes: ["ui", "ux"]
```

### 4. Scope Analysis Categories

**A. Frequency Analysis**
```json
{
  "scope": "auth",
  "count": 23,
  "percentage": 18.1,
  "first_seen": "2024-01-15",
  "last_seen": "2024-03-10",
  "active": true
}
```

**B. Scope Hierarchy**
```json
{
  "api": {
    "count": 45,
    "children": {
      "endpoints": 12,
      "middleware": 8,
      "validation": 6
    }
  }
}
```

**C. Scope Categories**
```
Architecture:    core, utils, config
Features:        auth, payment, search
UI:             ui, components, styles
Backend:        api, db, server
Infrastructure: ci, docker, deploy
Documentation:  docs, readme, changelog
Testing:        test, e2e, unit
```

### 5. Output Structure

**Text Format (default):**
```
Scope Extraction Analysis
=========================

Commits Analyzed: 50
Branch: main
Scopes Found: 15 unique
Total Scoped Commits: 44/50 (88%)

TOP SCOPES BY FREQUENCY
-----------------------
 1. auth          23 (18.1%) ████████████████████
    └─ Authentication and authorization

 2. api           19 (14.9%) ████████████████
    ├─ endpoints   7
    ├─ middleware  5
    └─ validation  3

 3. ui            15 (11.8%) █████████████
    ├─ components  8
    └─ styles      4

 4. db            12 (9.4%)  ██████████
    └─ Database operations

 5. docs          11 (8.7%)  █████████
    └─ Documentation

 6. core          8 (6.3%)   ███████
    └─ Core functionality

 7. config        7 (5.5%)   ██████
    └─ Configuration

 8. test          6 (4.7%)   █████
    └─ Testing

 9. ci            5 (3.9%)   ████
    └─ CI/CD pipelines

10. deploy        4 (3.1%)   ███
    └─ Deployment

SCOPE CATEGORIES
----------------
Features (45%):      auth, payment, search
Backend (32%):       api, db, server
UI (19%):           ui, components, styles
Infrastructure (12%): ci, docker, deploy
Documentation (8%):  docs, readme

SCOPE PATTERNS
--------------
Naming Style:     lowercase, hyphen-separated
Hierarchy:        Uses / for nested scopes (api/endpoints)
Multi-Scope:      Occasional (3% of commits)
Active Scopes:    12/15 (used in last 10 commits)
Deprecated:       payment-v1, legacy-api

RECOMMENDATIONS
---------------
• Use 'auth' for authentication/authorization changes
• Use 'api' for backend API modifications
• Use 'ui' for user interface changes
• Consider hierarchical scopes for complex modules (api/endpoints)
• Active scopes: auth, api, ui, db, docs, core, config
• Avoid deprecated: payment-v1, legacy-api

RECENT SCOPE USAGE (last 10 commits)
------------------------------------
auth     ████ (4 commits)
api      ███  (3 commits)
ui       ██   (2 commits)
docs     █    (1 commit)
```

**JSON Format:**
```json
{
  "analysis_type": "scope_extraction",
  "commits_analyzed": 50,
  "branch": "main",
  "statistics": {
    "total_scopes": 15,
    "scoped_commits": 44,
    "scoped_percentage": 88,
    "active_scopes": 12,
    "deprecated_scopes": 2
  },
  "scopes": [
    {
      "name": "auth",
      "count": 23,
      "percentage": 18.1,
      "category": "feature",
      "description": "Authentication and authorization",
      "hierarchy": null,
      "first_seen": "2024-01-15",
      "last_seen": "2024-03-10",
      "active": true,
      "recent_usage": 4,
      "examples": [
        "feat(auth): implement OAuth2",
        "fix(auth): session timeout",
        "refactor(auth): simplify middleware"
      ]
    },
    {
      "name": "api",
      "count": 19,
      "percentage": 14.9,
      "category": "backend",
      "description": "API endpoints and logic",
      "hierarchy": {
        "endpoints": 7,
        "middleware": 5,
        "validation": 3
      },
      "active": true,
      "recent_usage": 3
    }
  ],
  "categories": {
    "feature": {"count": 45, "percentage": 45},
    "backend": {"count": 32, "percentage": 32},
    "ui": {"count": 19, "percentage": 19}
  },
  "patterns": {
    "naming_style": "lowercase_hyphen",
    "uses_hierarchy": true,
    "uses_multi_scope": true,
    "multi_scope_percentage": 3
  },
  "recommendations": [
    "Use 'auth' for authentication/authorization changes",
    "Use 'api' for backend API modifications",
    "Consider hierarchical scopes for complex modules"
  ]
}
```

### 6. Scope Categorization Logic

**Category Detection:**
```python
def categorize_scope(scope_name, usage_patterns):
    """Categorize scope based on name and usage"""

    # Authentication/Authorization
    if scope_name in ['auth', 'security', 'login', 'oauth']:
        return 'feature', 'Authentication'

    # API/Backend
    if scope_name in ['api', 'endpoint', 'backend', 'server']:
        return 'backend', 'API and backend'

    # UI/Frontend
    if scope_name in ['ui', 'component', 'style', 'frontend']:
        return 'ui', 'User interface'

    # Database
    if scope_name in ['db', 'database', 'schema', 'migration']:
        return 'backend', 'Database'

    # Infrastructure
    if scope_name in ['ci', 'cd', 'deploy', 'docker', 'k8s']:
        return 'infrastructure', 'Infrastructure'

    # Documentation
    if scope_name in ['docs', 'readme', 'changelog']:
        return 'documentation', 'Documentation'

    # Testing
    if scope_name in ['test', 'e2e', 'unit', 'integration']:
        return 'testing', 'Testing'

    # Default
    return 'other', 'Other'
```

### 7. Trend Analysis

**Activity Tracking:**
```
Scope Activity Timeline (last 30 days):

auth:  ████████████████ (very active)
api:   ████████████     (active)
ui:    ████████         (moderate)
db:    ████             (low)
test:  ██               (occasional)
docs:  █                (rare)
```

**Deprecated Scope Detection:**
```python
def is_deprecated(scope):
    """Detect if scope is deprecated"""
    # Not used in last 20 commits
    if scope.last_seen_commit_index > 20:
        return True

    # Explicitly marked as deprecated
    if 'legacy' in scope.name or 'v1' in scope.name:
        return True

    return False
```

## Error Handling

**No scopes found:**
- Warning: "No scopes detected in commit history"
- Suggestion: "Project may not use conventional commits format"
- Return: Empty scope list with explanation

**Minimal scopes:**
- Warning: "Only X scopes found with min_frequency threshold"
- Suggestion: "Lower min_frequency or analyze more commits"

**Malformed scopes:**
- Skip invalid entries
- Log: "Skipped N malformed scope entries"
- Continue with valid scopes

## Integration Usage

**By commit-assistant agent:**
```
User modifies auth files:
  → Invoke: /history-analysis extract-scopes
  → Find: 'auth' is common scope (18.1%)
  → Suggest: Use 'auth' scope for this commit
```

**By message-generation skill:**
```
Generating commit message:
  → Extract scopes from history
  → Check if current files match known scopes
  → Auto-suggest appropriate scope
```

**By identify-scope operation:**
```
Unknown scope needed:
  → Check extracted scopes
  → Find similar/related scopes
  → Recommend best match
```

## Success Criteria

Operation succeeds when:
- [x] All scopes extracted from commits
- [x] Frequencies calculated correctly
- [x] Hierarchies identified
- [x] Categories assigned accurately
- [x] Active/deprecated status determined
- [x] Recommendations generated
- [x] Output formatted properly

## Performance

- **Extraction Time:** ~1-2 seconds for 50 commits
- **Regex Matching:** ~0.02ms per commit
- **Memory:** Low (scope hash table only)
