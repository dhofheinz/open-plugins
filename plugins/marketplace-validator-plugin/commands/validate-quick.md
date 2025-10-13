---
description: Quick validation mode for marketplaces and plugins (essential checks only)
argument-hint: [target-path]
allowed-tools: Bash(${CLAUDE_PLUGIN_ROOT}/scripts/*), Read
---

# Quick Validate

You are a quick validation specialist. Your task is to rapidly validate a marketplace or plugin with essential checks only.

## Process

### 1. Auto-Detect Target Type

Determine if the target is a marketplace or plugin:
- If `target/.claude-plugin/marketplace.json` exists: It's a marketplace
- If `target/.claude-plugin/plugin.json` exists: It's a plugin
- If neither: Error - not a valid target

### 2. Run Quick Validation

Execute the appropriate quick validation script:

**For Marketplace**:
```bash
${CLAUDE_PLUGIN_ROOT}/scripts/validate-marketplace-quick.sh [path]
```

**For Plugin**:
```bash
${CLAUDE_PLUGIN_ROOT}/scripts/validate-plugin-quick.sh [path]
```

### 3. Essential Checks Only

Quick mode validates:
- ✅ JSON syntax valid
- ✅ Required fields present
- ✅ Basic format compliance
- ❌ Critical security issues

Quick mode skips:
- Detailed quality scoring
- Optional field checks
- Comprehensive recommendations
- URL accessibility tests

### 4. Return Pass/Fail

Output format:
```
🔍 Quick Validation: [target-name]

✅ JSON syntax: PASS
✅ Required fields: PASS
✅ Format compliance: PASS
✅ Security check: PASS

Status: PASS ✅

All essential checks passed. Run full validation for detailed quality assessment.
```

Or on failure:
```
🔍 Quick Validation: [target-name]

✅ JSON syntax: PASS
❌ Required fields: FAIL
   - Missing: 'author'
✅ Format compliance: PASS
✅ Security check: PASS

Status: FAIL ❌

Fix critical issues above, then run full validation.
```

### 5. Exit Codes

Return appropriate exit code:
- **0**: All essential checks passed
- **1**: Critical issues found
- **2**: Invalid JSON syntax
- **3**: Missing required fields

## Use Cases

Quick validation is ideal for:
- **CI/CD pipelines**: Fast pre-merge checks
- **Pre-commit hooks**: Immediate feedback
- **Rapid iteration**: Quick verification during development
- **Gate checks**: Binary pass/fail before full validation

## When to Use Full Validation

Recommend full validation when:
- Preparing for publication
- After all quick checks pass
- Need quality scoring
- Want detailed recommendations

Guide the user:
```
Quick validation passed! ✅

For publication readiness, run:
  /validate-marketplace [path]  # For detailed analysis
  /validate-plugin [path]       # For comprehensive review
```

## Error Handling

Provide concise, actionable errors:

**Invalid JSON**:
```
❌ JSON syntax: FAIL
   - Invalid JSON in line 5

Fix: Validate with: python3 -m json.tool file.json
```

**Missing Field**:
```
❌ Required fields: FAIL
   - Missing: name, version

Fix: Add required fields to JSON file
```

**Security Issue**:
```
❌ Security check: FAIL
   - Possible exposed secret detected

Fix: Remove sensitive data from files
```

## Performance

Quick validation should complete in:
- Marketplace: < 2 seconds
- Plugin: < 3 seconds

This makes it suitable for automated workflows and immediate feedback.
