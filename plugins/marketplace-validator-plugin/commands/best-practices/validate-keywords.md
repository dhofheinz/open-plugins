## Operation: Validate Keywords

Validate keyword selection for relevance, count, and quality against OpenPlugins standards.

### Parameters from $ARGUMENTS

- **keywords**: Comma-separated keyword list (required)
- **min**: Minimum keyword count (optional, default: 3)
- **max**: Maximum keyword count (optional, default: 7)
- **context**: Plugin context for relevance checking (optional, JSON or description)

### OpenPlugins Keyword Standards

**Count Requirements**:
- Minimum: 3 keywords
- Maximum: 7 keywords
- Optimal: 5-6 keywords

**Quality Requirements**:
- Relevant to plugin functionality
- Searchable terms users would use
- Mix of functionality, technology, and use-case
- No generic marketing terms
- No duplicate category names

### Keyword Categories

**Functionality Keywords** (what it does):
- `testing`, `deployment`, `formatting`, `linting`, `migration`
- `generation`, `automation`, `analysis`, `monitoring`, `scanning`

**Technology Keywords** (what it works with):
- `python`, `javascript`, `docker`, `kubernetes`, `postgresql`
- `react`, `vue`, `typescript`, `bash`, `terraform`

**Use-Case Keywords** (how it's used):
- `ci-cd`, `code-review`, `api-testing`, `performance`
- `tdd`, `bdd`, `refactoring`, `debugging`, `profiling`

### Good Keywords Examples

**Well-balanced sets**:
- `["testing", "pytest", "automation", "tdd", "python"]`
- `["deployment", "kubernetes", "ci-cd", "docker", "helm"]`
- `["linting", "javascript", "eslint", "code-quality", "automation"]`
- `["database", "postgresql", "migration", "schema", "sql"]`

**Poor keyword sets**:
- `["plugin", "tool", "awesome"]` - Generic/marketing terms
- `["test", "testing", "tester", "tests"]` - Redundant variations
- `["development"]` - Only category name, too few
- `["a", "b", "c", "d", "e", "f", "g", "h"]` - Too many, non-descriptive

### Workflow

1. **Extract Keywords from Arguments**
   ```
   Parse $ARGUMENTS to extract keywords parameter
   Split by comma, trim whitespace
   Normalize to lowercase
   Remove duplicates
   ```

2. **Execute Keyword Analyzer**
   ```bash
   Execute .scripts/keyword-analyzer.py "$keywords" "$min" "$max" "$context"

   Exit codes:
   - 0: Valid keyword set
   - 1: Count violation (too few or too many)
   - 2: Quality issues (generic terms, duplicates)
   - 3: Missing required parameters
   ```

3. **Validate Count**
   ```
   count = number of keywords
   IF count < min: FAIL (too few)
   IF count > max: FAIL (too many)
   ```

4. **Check for Generic Terms**
   ```
   Generic blocklist:
   - plugin, tool, utility, helper, awesome
   - best, perfect, great, super, amazing
   - code, software, app, program

   Flag any generic terms found
   ```

5. **Analyze Quality**
   ```
   Check for:
   - Duplicate category names
   - Redundant variations (test, testing, tests)
   - Single-character keywords
   - Non-descriptive terms
   ```

6. **Calculate Relevance Score**
   ```
   Base score: 10 points

   Deductions:
   - Generic term: -2 per term
   - Too few keywords: -5
   - Too many keywords: -3
   - Redundant variations: -2 per redundancy
   - Non-descriptive: -1 per term

   Final score: max(0, base - deductions)
   ```

7. **Return Analysis Report**
   ```
   Format results:
   - Status: PASS/FAIL/WARNING
   - Count: <number> (valid range: min-max)
   - Quality: <score>/10
   - Issues: <list of problems>
   - Suggestions: <improved keyword set>
   - Score impact: +10 points (if excellent), +5 (if good)
   ```

### Examples

```bash
# Valid keyword set
/best-practices keywords keywords:"testing,pytest,automation,tdd,python"
# Result: PASS - 5 keywords, well-balanced, relevant

# Too few keywords
/best-practices keywords keywords:"testing,python"
# Result: FAIL - Only 2 keywords (minimum: 3)

# Too many keywords
/best-practices keywords keywords:"a,b,c,d,e,f,g,h,i,j"
# Result: FAIL - 10 keywords (maximum: 7)

# Generic terms
/best-practices keywords keywords:"plugin,tool,awesome,best"
# Result: FAIL - Contains generic/marketing terms

# With custom range
/best-practices keywords keywords:"ci,cd,docker" min:2 max:5
# Result: PASS - 3 keywords within custom range
```

### Error Handling

**Missing keywords parameter**:
```
ERROR: Missing required parameter 'keywords'

Usage: /best-practices keywords keywords:"keyword1,keyword2,keyword3"

Example: /best-practices keywords keywords:"testing,automation,python"
```

**Empty keywords**:
```
ERROR: Keywords cannot be empty

Provide 3-7 relevant keywords describing your plugin.

Good examples:
- "testing,pytest,automation"
- "deployment,kubernetes,ci-cd"
- "linting,javascript,code-quality"
```

### Output Format

**Success (Excellent Keywords)**:
```
✅ Keyword Validation: PASS

Keywords: testing, pytest, automation, tdd, python
Count: 5 (optimal range: 3-7)
Quality Score: 10/10

Analysis:
✅ Balanced mix of functionality, technology, and use-case
✅ All keywords relevant and searchable
✅ No generic or marketing terms
✅ Good variety without redundancy

Breakdown:
- Functionality: testing, automation, tdd
- Technology: pytest, python
- Use-case: tdd

Quality Score Impact: +10 points

Excellent keyword selection for discoverability!
```

**Failure (Count Violation)**:
```
❌ Keyword Validation: FAIL

Keywords: testing, python
Count: 2 (required: 3-7)
Quality Score: 5/10

Issues Found:
1. Too few keywords (2 < 3 minimum)
2. Missing technology or use-case keywords

Suggestions to improve:
Add 1-3 more relevant keywords such as:
- Functionality: automation, unit-testing
- Use-case: tdd, ci-cd
- Specific tools: pytest, unittest

Recommended: testing, python, pytest, automation, tdd

Quality Score Impact: 0 points (fix to gain +10)
```

**Failure (Generic Terms)**:
```
❌ Keyword Validation: FAIL

Keywords: plugin, tool, awesome, best, helper
Count: 5 (valid range)
Quality Score: 2/10

Issues Found:
1. Generic terms detected: plugin, tool, helper
2. Marketing terms detected: awesome, best
3. No functional or technical keywords

These keywords don't help users find your plugin.

Better alternatives:
Instead of generic terms, describe WHAT it does:
- Replace "plugin" → testing, deployment, formatting
- Replace "tool" → specific functionality
- Replace "awesome/best" → actual features

Suggested keywords based on common patterns:
- testing, automation, ci-cd, docker, python
- deployment, kubernetes, infrastructure, terraform
- linting, formatting, code-quality, javascript

Quality Score Impact: 0 points (fix to gain +10)
```

**Warning (Minor Issues)**:
```
⚠️  Keyword Validation: WARNING

Keywords: testing, tests, test, automation, ci-cd
Count: 5 (valid range)
Quality Score: 7/10

Issues Found:
1. Redundant variations: testing, tests, test
2. Consider consolidating to single term

Suggestions:
- Keep: testing, automation, ci-cd
- Remove: tests, test (redundant)
- Add: 2 more specific keywords (e.g., pytest, junit)

Recommended: testing, automation, ci-cd, pytest, unit-testing

Quality Score Impact: +7 points (good, but could be better)

Your keywords are functional but could be more diverse.
```

### Keyword Quality Checklist

**PASS Requirements**:
- 3-7 keywords total
- No generic terms (plugin, tool, utility, helper)
- No marketing terms (awesome, best, perfect)
- No redundant variations
- Mix of functionality and technology
- Relevant to plugin purpose
- Searchable by target users

**FAIL Indicators**:
- < 3 or > 7 keywords
- Contains generic terms
- Contains marketing fluff
- All keywords same type (only technologies, only functionality)
- Single-character keywords
- Category name duplication

### Best Practices

**Do**:
- Use specific functionality terms
- Include primary technologies
- Add relevant use-cases
- Think about user search intent
- Balance breadth and specificity

**Don't**:
- Use generic words (plugin, tool, utility)
- Add marketing terms (best, awesome, perfect)
- Duplicate category names exactly
- Use redundant variations
- Add irrelevant technologies
- Use abbreviations without context

### Quality Scoring Matrix

**10/10 - Excellent**:
- 5-6 keywords
- Perfect mix of functionality/technology/use-case
- All highly relevant
- Great search discoverability

**7-9/10 - Good**:
- 3-7 keywords
- Good mix with minor issues
- Mostly relevant
- Decent discoverability

**4-6/10 - Fair**:
- Count issues OR some generic terms
- Imbalanced mix
- Partial relevance
- Limited discoverability

**0-3/10 - Poor**:
- Severe count violations OR mostly generic
- No functional keywords
- Poor relevance
- Very poor discoverability

**Request**: $ARGUMENTS
