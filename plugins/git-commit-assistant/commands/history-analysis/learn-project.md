# Operation: Learn Project

**Purpose:** Comprehensive project commit pattern learning - analyze all aspects of commit history to provide complete understanding of project conventions.

## Parameters

From `$ARGUMENTS` (after operation name):
- `count:N` - Number of commits to analyze (default: 100)
- `branch:name` - Branch to analyze (default: current branch)
- `format:json|text` - Output format (default: text)
- `save:path` - Save results to file (optional)
- `full:true|false` - Include detailed breakdown (default: false)

## Workflow

### 1. Validate Repository

```bash
if ! git rev-parse --git-dir >/dev/null 2>&1; then
    echo "Error: Not in a git repository"
    exit 1
fi

if ! git log -1 >/dev/null 2>&1; then
    echo "Error: No commit history found"
    exit 1
fi
```

### 2. Execute Comprehensive Analysis

This operation orchestrates all other history-analysis operations for complete project learning:

**Phase 1: Style Analysis**
```bash
echo "Phase 1/4: Analyzing commit style..."
./.scripts/style-analyzer.sh <count> <branch>
```

**Phase 2: Pattern Detection**
```bash
echo "Phase 2/4: Detecting conventions..."
./.scripts/pattern-detector.py --count <count> --branch <branch> --detailed
```

**Phase 3: Scope Extraction**
```bash
echo "Phase 3/4: Extracting scopes..."
./.scripts/scope-extractor.sh --count <count> --branch <branch> --min-frequency 2
```

**Phase 4: Convention Recommendations**
```bash
echo "Phase 4/4: Generating recommendations..."
./.scripts/convention-recommender.py --count <count> --branch <branch> --priority all
```

### 3. Aggregate and Synthesize Results

Combine all analysis data into comprehensive project profile:

```python
project_profile = {
    'metadata': {
        'project_name': get_repo_name(),
        'analysis_date': datetime.now(),
        'commits_analyzed': count,
        'branch': branch,
        'first_commit_date': get_first_commit_date(),
        'last_commit_date': get_last_commit_date()
    },
    'style': style_analysis_results,
    'patterns': pattern_detection_results,
    'scopes': scope_extraction_results,
    'recommendations': convention_recommendations,
    'confidence': calculate_confidence_score()
}
```

### 4. Generate Project Profile

**Output Structure:**

```
═══════════════════════════════════════════════════════════════
PROJECT COMMIT PROFILE
═══════════════════════════════════════════════════════════════

Repository: git-commit-assistant
Branch: main
Analysis Date: 2024-03-10 14:30:00
Commits Analyzed: 100 (from 2024-01-01 to 2024-03-10)

Overall Consistency Score: 85/100 (GOOD)
Confidence Level: HIGH (100 commits analyzed)

═══════════════════════════════════════════════════════════════
📊 EXECUTIVE SUMMARY
═══════════════════════════════════════════════════════════════

✓ Project uses conventional commits consistently (87%)
✓ Strong imperative mood usage (92%)
✓ Good issue reference practice (67%)
○ Moderate body usage (34%)
○ Occasional breaking change documentation (8%)

Recommended Actions:
  1. Maintain conventional commits format
  2. Increase body usage for complex changes
  3. Standardize breaking change documentation

═══════════════════════════════════════════════════════════════
📝 COMMIT STYLE ANALYSIS
═══════════════════════════════════════════════════════════════

Format Distribution:
  Conventional Commits: 87% ████████████████████████░░░
  Simple Subject:       10% ███░░░░░░░░░░░░░░░░░░░░░░░
  Other:                3%  █░░░░░░░░░░░░░░░░░░░░░░░░░

Subject Lines:
  Average Length:    47 characters (recommended: < 50)
  Standard Dev:      8 characters
  Exceeds 50 chars:  15% of commits

  Length Distribution:
    30-40 chars: ████████  (35%)
    41-50 chars: ██████████ (42%)
    51-60 chars: ████       (15%)
    61+ chars:   ██         (8%)

Body Usage:
  Has Body:          34% of commits
  Average Length:    120 characters
  Bullet Points:     89% of bodies
  Wrapping:          94% wrap at 72 chars

Footer Usage:
  Issue References:  67% ████████████████████░░░░░
  Breaking Changes:  8%  ██░░░░░░░░░░░░░░░░░░░░░░
  Co-Authors:        2%  ░░░░░░░░░░░░░░░░░░░░░░░░
  Signed-Off:        12% ███░░░░░░░░░░░░░░░░░░░░░

═══════════════════════════════════════════════════════════════
🎯 COMMIT TYPE ANALYSIS
═══════════════════════════════════════════════════════════════

Type Distribution (from 87 conventional commits):

 1. feat      35% ████████████████████ (30 commits)
    └─ New features and capabilities

 2. fix       30% ████████████████░     (26 commits)
    └─ Bug fixes and corrections

 3. docs      16% █████████░            (14 commits)
    └─ Documentation updates

 4. refactor  8%  ████░                 (7 commits)
    └─ Code restructuring

 5. test      5%  ███░                  (4 commits)
    └─ Test additions/updates

 6. chore     4%  ██░                   (3 commits)
    └─ Maintenance tasks

 7. perf      2%  █░                    (2 commits)
    └─ Performance improvements

Type Usage Timeline (last 20 commits):
  feat:     ████████    (8 commits)
  fix:      ██████      (6 commits)
  docs:     ███         (3 commits)
  refactor: ██          (2 commits)
  chore:    █           (1 commit)

═══════════════════════════════════════════════════════════════
🎨 SCOPE ANALYSIS
═══════════════════════════════════════════════════════════════

Scopes Found: 15 unique
Scoped Commits: 88% (76/87 conventional commits)

Top Scopes by Frequency:

 1. auth          23% ████████████████████ (20 commits)
    Category: Authentication
    Status: ACTIVE (used in last 10 commits)
    Examples:
      • feat(auth): implement OAuth2 authentication
      • fix(auth): handle session timeout correctly
      • refactor(auth): simplify middleware logic

 2. api           19% ████████████████     (17 commits)
    Category: Backend
    Status: ACTIVE
    Hierarchy: api/endpoints (7), api/middleware (5), api/validation (3)

 3. ui            15% █████████████        (13 commits)
    Category: Frontend
    Status: ACTIVE
    Hierarchy: ui/components (8), ui/styles (4)

 4. db            12% ██████████           (10 commits)
    Category: Database
    Status: ACTIVE

 5. docs          11% █████████            (9 commits)
    Category: Documentation
    Status: ACTIVE

 6-15. (core, config, test, ci, deploy, utils, types, scripts, docker, nginx)
       Combined: 20% (17 commits)

Scope Categories:
  Features:        45% (auth, payment, search, notifications)
  Backend:         32% (api, db, server, cache)
  Frontend:        19% (ui, components, styles)
  Infrastructure:  12% (ci, docker, deploy, nginx)
  Documentation:   11% (docs, readme, changelog)

═══════════════════════════════════════════════════════════════
🔍 CONVENTION PATTERNS
═══════════════════════════════════════════════════════════════

Writing Style:
  Imperative Mood:      92% ██████████████████████░░
  Capitalized Subject:  94% ██████████████████████░░
  No Period at End:     88% ████████████████████░░░
  Lowercase Scopes:     100% ████████████████████████

Message Structure:
  Blank Line Before Body:  100% (all 34 bodies)
  Body Wrapped at 72:      94% (32/34 bodies)
  Bullet Points in Body:   89% (30/34 bodies)
  Footer Separated:        100% (all 67 footers)

Issue References:
  Format: "Closes #123"    45% ████████████
  Format: "Fixes #456"     38% ██████████
  Format: "Refs #789"      17% █████

Breaking Changes:
  Format: "BREAKING CHANGE:" 100% (all 7 instances)
  Always in footer:          100%
  Includes description:      100%

═══════════════════════════════════════════════════════════════
💡 RECOMMENDATIONS (PRIORITIZED)
═══════════════════════════════════════════════════════════════

🔴 HIGH PRIORITY (Critical for Consistency)

1. ✓ Continue Using Conventional Commits
   Current: 87% adoption
   Target: Maintain 85%+
   Impact: HIGH - Enables automation

2. ✓ Maintain Imperative Mood
   Current: 92% compliance
   Target: Maintain 90%+
   Impact: HIGH - Readability and clarity

🟡 MEDIUM PRIORITY (Improve Quality)

3. ○ Increase Body Usage for Complex Changes
   Current: 34% of commits
   Target: 50% for multi-file changes
   Impact: MEDIUM - Better documentation

   When to add body:
   • Changes affect >3 files
   • Complex logic modifications
   • Breaking changes
   • Security-related changes

4. ○ Document Breaking Changes Consistently
   Current: 8% when applicable
   Target: 100% of breaking changes documented
   Impact: MEDIUM - User experience

🟢 LOW PRIORITY (Polish)

5. ○ Consider Co-Author Attribution
   Current: 2% usage
   Target: Use for pair programming
   Impact: LOW - Team recognition

6. ○ Add Signed-off-by for Compliance
   Current: 12% usage
   Target: If required by project policy
   Impact: LOW - Legal compliance

═══════════════════════════════════════════════════════════════
📚 PROJECT-SPECIFIC STYLE GUIDE
═══════════════════════════════════════════════════════════════

COMMIT MESSAGE FORMAT
---------------------
<type>(<scope>): <subject>          ← 50 chars max, imperative mood

<body>                               ← Optional, explain "why"
- Use bullet points                  ← Wrap at 72 characters
- Multiple lines OK
- Blank line before footer

<footer>                             ← Optional
BREAKING CHANGE: description
Closes #123

APPROVED TYPES (use these)
--------------------------
feat     - New feature (35% of project commits)
fix      - Bug fix (30% of project commits)
docs     - Documentation (16% of project commits)
refactor - Code restructuring (8%)
test     - Testing (5%)
chore    - Maintenance (4%)
perf     - Performance (2%)

STANDARD SCOPES (project-specific)
----------------------------------
auth     - Authentication/authorization
api      - Backend API endpoints
ui       - User interface
db       - Database operations
docs     - Documentation
core     - Core functionality
config   - Configuration
test     - Testing infrastructure
ci       - CI/CD pipelines
deploy   - Deployment

STYLE RULES
-----------
✓ Use imperative mood ("add" not "added")
✓ Capitalize first letter of subject
✓ No period at end of subject line
✓ Use lowercase for scopes
✓ Wrap body at 72 characters
✓ Separate body and footer with blank line
✓ Use bullet points in body (with - or •)
✓ Reference issues: "Closes #123", "Fixes #456"
✓ Document breaking changes in footer

REAL EXAMPLES FROM THIS PROJECT
--------------------------------
Example 1: Feature with body
  feat(auth): implement OAuth2 authentication

  - Add OAuth2 flow implementation
  - Support Google and GitHub providers
  - Include middleware for route protection
  - Add configuration management

  Closes #123

Example 2: Bug fix
  fix(api): handle null pointer in user endpoint

  The endpoint was not checking for null user objects
  before accessing properties, causing crashes when
  invalid user IDs were provided.

  Fixes #456

Example 3: Breaking change
  feat(api): change authentication flow

  Update authentication to use OAuth2 tokens instead
  of API keys for improved security.

  BREAKING CHANGE: API now requires OAuth tokens
  instead of API keys. Update all client applications
  to use the new authentication flow.

  Closes #789

═══════════════════════════════════════════════════════════════
🔧 IMPLEMENTATION GUIDE
═══════════════════════════════════════════════════════════════

1. SHARE WITH TEAM
   • Add style guide to CONTRIBUTING.md
   • Present in team meeting
   • Add to onboarding docs

2. CONFIGURE GIT
   Create .gitmessage template:

   # <type>(<scope>): <subject>
   #
   # <body>
   #
   # <footer>
   #
   # Types: feat, fix, docs, refactor, test, chore, perf
   # Scopes: auth, api, ui, db, docs, core, config

   Then: git config commit.template .gitmessage

3. ADD PRE-COMMIT HOOKS
   Install commitlint:
   npm install --save-dev @commitlint/cli @commitlint/config-conventional

   Configure commitlint.config.js:
   module.exports = {
     extends: ['@commitlint/config-conventional'],
     rules: {
       'scope-enum': [2, 'always', [
         'auth', 'api', 'ui', 'db', 'docs', 'core',
         'config', 'test', 'ci', 'deploy'
       ]]
     }
   };

4. ENABLE AUTOMATION
   • Automated changelog: standard-version
   • Semantic versioning: semantic-release
   • Commit linting: commitlint + husky

5. MONITOR COMPLIANCE
   Run this analysis monthly:
   /history-analysis learn-project count:100

═══════════════════════════════════════════════════════════════
📈 CONFIDENCE ASSESSMENT
═══════════════════════════════════════════════════════════════

Data Quality:     ████████████████████████ HIGH
Sample Size:      100 commits ✓ Sufficient
Time Range:       70 days ✓ Representative
Consistency:      85/100 ✓ Good
Pattern Clarity:  ████████████████████████ HIGH

Confidence Level: HIGH

This analysis is reliable for:
✓ Establishing project guidelines
✓ Onboarding new developers
✓ Configuring automation tools
✓ Team discussions and decisions

═══════════════════════════════════════════════════════════════
💾 SAVE OPTIONS
═══════════════════════════════════════════════════════════════

This analysis can be saved for reference:
  /history-analysis learn-project save:docs/commit-conventions.md

Or export as JSON for tooling:
  /history-analysis learn-project format:json save:commit-profile.json

═══════════════════════════════════════════════════════════════
Analysis Complete - Ready to Apply
═══════════════════════════════════════════════════════════════
```

### 5. Save to File (if requested)

If `save:path` parameter provided:

```bash
# Save text format
echo "$output" > "$save_path"

# Save JSON format
echo "$json_output" > "$save_path"

echo "✓ Analysis saved to: $save_path"
```

### 6. JSON Output Structure

```json
{
  "metadata": {
    "project_name": "git-commit-assistant",
    "analysis_date": "2024-03-10T14:30:00Z",
    "commits_analyzed": 100,
    "branch": "main",
    "date_range": {
      "first_commit": "2024-01-01",
      "last_commit": "2024-03-10"
    }
  },
  "scores": {
    "overall_consistency": 85,
    "style_consistency": 87,
    "pattern_consistency": 92,
    "content_consistency": 67,
    "confidence": "high"
  },
  "style_analysis": {
    "conventional_commits_percentage": 87,
    "average_subject_length": 47,
    "body_usage_percentage": 34,
    "footer_usage_percentage": 67
  },
  "types": [...],
  "scopes": [...],
  "patterns": {...},
  "recommendations": {
    "high_priority": [...],
    "medium_priority": [...],
    "low_priority": [...]
  },
  "style_guide": {
    "format": "<type>(<scope>): <subject>",
    "types": [...],
    "scopes": [...],
    "rules": [...]
  },
  "examples": [...],
  "automation": {
    "commitlint_config": {...},
    "changelog_generator": "standard-version",
    "semantic_release": true
  }
}
```

## Error Handling

**No git repository:**
- Error: "Not in a git repository"
- Guidance: Run from within git project directory

**Insufficient commits:**
- Warning: "Only X commits available (recommended: 50+)"
- Adjust: Analyze all available commits
- Note: Lower confidence level

**Analysis failure:**
- Partial results: Return what was successfully analyzed
- Error details: Indicate which phase failed
- Retry: Suggest re-running with different parameters

## Integration Usage

**New project setup:**
```
Developer: "What are the commit conventions?"
  → Run: /history-analysis learn-project
  → Get: Complete style guide
  → Configure: Git template and hooks
```

**Team standardization:**
```
Lead: "Let's review our commit practices"
  → Run: /history-analysis learn-project save:docs/conventions.md
  → Review: Recommendations with team
  → Implement: Top priorities
  → Document: In CONTRIBUTING.md
```

**Automation setup:**
```
DevOps: "Configure commit validation"
  → Run: /history-analysis learn-project format:json
  → Extract: Approved types and scopes
  → Configure: commitlint with project rules
  → Deploy: Pre-commit hooks
```

## Success Criteria

Operation succeeds when:
- [x] All 4 analysis phases complete
- [x] Results aggregated correctly
- [x] Comprehensive profile generated
- [x] Recommendations prioritized
- [x] Style guide created
- [x] Examples included
- [x] Implementation guidance provided
- [x] Confidence level assessed

## Performance

- **Phase 1 (Style):** ~2 seconds
- **Phase 2 (Patterns):** ~3 seconds
- **Phase 3 (Scopes):** ~2 seconds
- **Phase 4 (Recommendations):** ~1 second
- **Total:** ~8-10 seconds for 100 commits
