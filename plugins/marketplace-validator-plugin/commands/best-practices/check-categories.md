## Operation: Check Categories

Validate category assignment against OpenPlugins standard category list.

### Parameters from $ARGUMENTS

- **category**: Category name to validate (required)
- **suggest**: Show similar categories if invalid (optional, default: true)

### OpenPlugins Standard Categories

OpenPlugins defines **exactly 10 approved categories**:

1. **development** - Code generation, scaffolding, refactoring
2. **testing** - Test generation, coverage, quality assurance
3. **deployment** - CI/CD, infrastructure, release automation
4. **documentation** - Docs generation, API documentation
5. **security** - Vulnerability scanning, secret detection
6. **database** - Schema design, migrations, queries
7. **monitoring** - Performance analysis, logging
8. **productivity** - Workflow automation, task management
9. **quality** - Linting, formatting, code review
10. **collaboration** - Team tools, communication

### Category Selection Guidance

**development**:
- Code generators
- Project scaffolding
- Refactoring tools
- Boilerplate generation

**testing**:
- Test generators
- Test runners
- Coverage tools
- QA automation

**deployment**:
- CI/CD pipelines
- Infrastructure as code
- Release automation
- Environment management

**documentation**:
- README generators
- API doc generation
- Changelog automation
- Architecture diagrams

**security**:
- Secret scanning
- Vulnerability detection
- Security audits
- Compliance checking

**database**:
- Schema design
- Migration tools
- Query builders
- Database testing

**monitoring**:
- Performance profiling
- Log analysis
- Metrics collection
- Alert systems

**productivity**:
- Task automation
- Workflow orchestration
- Time management
- Note-taking

**quality**:
- Linters
- Code formatters
- Code review tools
- Complexity analysis

**collaboration**:
- Team communication
- Code review
- Knowledge sharing
- Project management

### Workflow

1. **Extract Category from Arguments**
   ```
   Parse $ARGUMENTS to extract category parameter
   If category not provided, return error
   Normalize to lowercase
   ```

2. **Execute Category Validator**
   ```bash
   Execute .scripts/category-validator.sh "$category"

   Exit codes:
   - 0: Valid category
   - 1: Invalid category
   - 2: Missing required parameters
   ```

3. **Check Against Approved List**
   ```
   Compare category against 10 approved categories
   Use exact string matching (case-insensitive)
   ```

4. **Suggest Alternatives (if invalid)**
   ```
   IF category invalid AND suggest:true:
     Calculate similarity scores
     Suggest closest matching categories
     Show category descriptions
   ```

5. **Return Validation Report**
   ```
   Format results:
   - Status: PASS/FAIL
   - Category: <provided-category>
   - Valid: yes/no
   - Description: <category-description> (if valid)
   - Suggestions: <list> (if invalid)
   - Score impact: +5 points (if valid)
   ```

### Examples

```bash
# Valid category
/best-practices categories category:development
# Result: PASS - Valid OpenPlugins category

# Invalid category (typo)
/best-practices categories category:developement
# Result: FAIL - Did you mean: development?

# Invalid category (plural)
/best-practices categories category:tests
# Result: FAIL - Did you mean: testing?

# Invalid category (custom)
/best-practices categories category:utilities
# Result: FAIL - Not in approved list
# Suggestions: productivity, quality, development

# Case insensitive
/best-practices categories category:TESTING
# Result: PASS - Valid (normalized to: testing)
```

### Error Handling

**Missing category parameter**:
```
ERROR: Missing required parameter 'category'

Usage: /best-practices categories category:<category-name>

Example: /best-practices categories category:development
```

**Empty category**:
```
ERROR: Category cannot be empty

Choose from 10 approved OpenPlugins categories:
development, testing, deployment, documentation, security,
database, monitoring, productivity, quality, collaboration
```

### Output Format

**Success (Valid Category)**:
```
✅ Category Validation: PASS

Category: development
Valid: Yes

Description: Code generation, scaffolding, refactoring

Use Cases:
- Code generators
- Project scaffolding tools
- Refactoring utilities
- Boilerplate generation

Quality Score Impact: +5 points

The category is approved for OpenPlugins marketplace.
```

**Failure (Invalid Category)**:
```
❌ Category Validation: FAIL

Category: developement
Valid: No

This category is not in the OpenPlugins approved list.

Did you mean?
1. development - Code generation, scaffolding, refactoring
2. deployment - CI/CD, infrastructure, release automation

All Approved Categories:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1.  development    - Code generation, scaffolding
2.  testing        - Test generation, coverage
3.  deployment     - CI/CD, infrastructure
4.  documentation  - Docs generation, API docs
5.  security       - Vulnerability scanning
6.  database       - Schema design, migrations
7.  monitoring     - Performance analysis
8.  productivity   - Workflow automation
9.  quality        - Linting, formatting
10. collaboration  - Team tools, communication

Quality Score Impact: 0 points (fix to gain +5)

Choose the most appropriate category from the approved list.
```

**Failure (Multiple Matches)**:
```
❌ Category Validation: FAIL

Category: code-tools
Valid: No

This category is not approved. Consider these alternatives:

Best Matches:
1. development - Code generation, scaffolding, refactoring
2. quality - Linting, formatting, code review
3. productivity - Workflow automation, task management

Which fits your plugin best?
- If generating/scaffolding code → development
- If analyzing/formatting code → quality
- If automating workflows → productivity

Quality Score Impact: 0 points (fix to gain +5)
```

### Category Decision Tree

Use this to select the right category:

```
Does your plugin...

Generate or scaffold code?
  → development

Run tests or check quality?
  → testing (if running tests)
  → quality (if analyzing/formatting code)

Deploy or manage infrastructure?
  → deployment

Generate documentation?
  → documentation

Scan for security issues?
  → security

Work with databases?
  → database

Monitor performance or logs?
  → monitoring

Automate workflows or tasks?
  → productivity

Improve code quality?
  → quality

Facilitate team collaboration?
  → collaboration
```

### Common Mistakes

**Using plural forms**:
- ❌ `tests` → ✅ `testing`
- ❌ `deployments` → ✅ `deployment`
- ❌ `databases` → ✅ `database`

**Using generic terms**:
- ❌ `tools` → Choose specific category
- ❌ `utilities` → Choose specific category
- ❌ `helpers` → Choose specific category

**Using multiple categories**:
- ❌ `development,testing` → Choose ONE primary category
- Use keywords for additional topics

**Using custom categories**:
- ❌ `api-tools` → ✅ `development` or `productivity`
- ❌ `devops` → ✅ `deployment`
- ❌ `ci-cd` → ✅ `deployment`

### Compliance Criteria

**PASS Requirements**:
- Exact match with one of 10 approved categories
- Case-insensitive matching accepted
- Single category only (not multiple)

**FAIL Indicators**:
- Not in approved list
- Plural forms
- Custom categories
- Multiple categories
- Empty or missing

**Request**: $ARGUMENTS
