---
description: Run comprehensive quality audit on plugin with scoring and recommendations
---

# Full Plugin Quality Audit

## Parameters

**Required**:
- `plugin`: Plugin name or path to plugin directory

**Optional**:
- `strict`: Enable strict mode for marketplace submission (format: true|false, default: false)
- `report_format`: Output format (format: text|json|markdown, default: markdown)

## Workflow

### Step 1: File Structure Validation

Check directory structure compliance:
```bash
.scripts/structure-checker.sh "{plugin_path}"
```

**Checks**:
- ✅ `.claude-plugin/plugin.json` exists
- ✅ `README.md` exists and not empty
- ✅ `LICENSE` file exists
- ✅ `commands/` directory exists
- ✅ At least one command file present
- ✅ Proper naming: lowercase-hyphen format
- ✅ No invalid file types in root

**Score**: 0-20 points

### Step 2: Metadata Validation

Validate plugin.json completeness:
```bash
python3 -m json.tool "{plugin_path}/.claude-plugin/plugin.json"
```

**Checks**:
- ✅ Valid JSON syntax
- ✅ Required fields present: name, version, description, author, license
- ✅ Name format correct (lowercase-hyphen)
- ✅ Version valid semver
- ✅ Description 50-200 characters
- ✅ Author has name (email optional)
- ✅ License is standard (MIT, Apache-2.0, etc.)
- ✅ Keywords present (3-7 recommended)
- ✅ Category valid (one of 10 categories)
- ✅ Repository URL if provided is valid

**Score**: 0-25 points

### Step 3: Security Scan

Scan for security issues:
```bash
.scripts/secret-scanner.sh "{plugin_path}"
```

**Checks**:
- ✅ No hardcoded API keys
- ✅ No exposed passwords or tokens
- ✅ No AWS/GCP credentials
- ✅ No private keys
- ✅ No database connection strings
- ✅ Environment variables used for secrets
- ✅ No eval() or exec() in scripts
- ✅ No unvalidated user input
- ✅ HTTPS for external URLs
- ✅ Safe file path handling

**Score**: 0-25 points (Critical: -50 if secrets found)

### Step 4: Documentation Quality

Validate documentation completeness:
```bash
.scripts/doc-validator.py "{plugin_path}/README.md"
```

**Checks**:
- ✅ README has title matching plugin name
- ✅ Description section present
- ✅ Installation instructions (at least one method)
- ✅ Usage section with examples
- ✅ No placeholder text ("TODO", "Add description here")
- ✅ Concrete examples (not generic)
- ✅ Parameters documented
- ✅ License referenced
- ✅ Links are valid (no 404s)
- ✅ Code blocks properly formatted

**Score**: 0-20 points

### Step 5: Functional Validation

Check command/agent functionality:

**Commands**:
- ✅ All commands have description frontmatter
- ✅ Clear usage instructions
- ✅ Parameter documentation
- ✅ Error handling mentioned
- ✅ Examples provided

**Agents** (if present):
- ✅ Name field present
- ✅ Description describes when to invoke
- ✅ Capabilities listed
- ✅ Tools specified or inherited

**Score**: 0-10 points

### Step 6: Calculate Overall Score

**Total Score**: 0-100 points

**Grade Bands**:
- 90-100: Excellent (A) - Marketplace ready
- 80-89: Good (B) - Minor improvements needed
- 70-79: Satisfactory (C) - Several improvements needed
- 60-69: Needs Work (D) - Major issues to address
- 0-59: Failing (F) - Not ready for submission

### Step 7: Generate Audit Report

Provide comprehensive report with:
- Overall score and grade
- Category scores breakdown
- Passed checks list
- Failed checks list
- Warnings
- Recommendations prioritized
- Pre-submission checklist status

## Output Format

```markdown
# Plugin Quality Audit Report

## Overall Score: {score}/100 ({grade})

**Status**: {Marketplace Ready|Needs Minor Improvements|Needs Major Improvements|Not Ready}

---

## Category Scores

### File Structure: {score}/20 ✅|⚠️|❌
{Detailed findings}

### Metadata Quality: {score}/25 ✅|⚠️|❌
{Detailed findings}

### Security: {score}/25 ✅|⚠️|❌
{Detailed findings}

### Documentation: {score}/20 ✅|⚠️|❌
{Detailed findings}

### Functionality: {score}/10 ✅|⚠️|❌
{Detailed findings}

---

## Validation Results

### ✅ Passed Checks ({count})
- {check 1}
- {check 2}
...

### ❌ Failed Checks ({count})
- {check 1}: {issue description}
  - **Fix**: {how to fix}
- {check 2}: {issue description}
  - **Fix**: {how to fix}

### ⚠️ Warnings ({count})
- {warning 1}: {description}
- {warning 2}: {description}

---

## Recommendations

### Critical (Fix Before Submission)
1. {critical issue 1}
   - Current: {what's wrong}
   - Required: {what's needed}
   - Example: {how to fix}

### Important (Strongly Recommended)
1. {important issue 1}
   - Impact: {why it matters}
   - Suggestion: {how to improve}

### Nice to Have (Optional Enhancements)
1. {enhancement 1}
   - Benefit: {what it adds}

---

## Pre-Submission Checklist

- [{✅|❌}] Plugin name follows lowercase-hyphen format
- [{✅|❌}] Description is 50-200 characters and specific
- [{✅|❌}] All required metadata fields present
- [{✅|❌}] README has real content (no placeholders)
- [{✅|❌}] LICENSE file included
- [{✅|❌}] At least one functional command
- [{✅|❌}] No hardcoded secrets or credentials
- [{✅|❌}] Examples are concrete and realistic
- [{✅|❌}] Documentation complete and accurate
- [{✅|❌}] Category correctly selected

---

## Next Steps

{Prioritized action items based on audit results}

1. **Immediate**: {must-do items}
2. **Short-term**: {should-do items}
3. **Enhancement**: {nice-to-have items}

---

## Resources

- Fix Common Issues: https://github.com/dhofheinz/open-plugins/blob/main/CONTRIBUTING.md
- Quality Standards: https://github.com/dhofheinz/open-plugins/blob/main/QUALITY.md
- Examples: Browse OpenPlugins marketplace for reference implementations

---

**Audit completed**: {timestamp}
**Plugin**: {plugin_name} v{version}
**Auditor**: plugin-quality skill
```

## Error Handling

- **Plugin not found** → Check path and plugin name
- **Invalid plugin structure** → Must have .claude-plugin/plugin.json
- **Permission errors** → Check file permissions
- **Script execution fails** → Report specific script and error

## Examples

### Example 1: High Quality Plugin

**Input**: `/plugin-quality full-audit plugin:test-generator`

**Output**: Score 92/100 (A) - Marketplace ready with minor suggestions

### Example 2: Plugin Needs Work

**Input**: `/plugin-quality full-audit plugin:my-plugin strict:true`

**Output**: Score 65/100 (D) - Multiple issues identified with detailed fixes

**Request**: $ARGUMENTS
