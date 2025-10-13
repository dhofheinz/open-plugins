---
description: Comprehensive validation of Claude Code plugin.json with structure checks
argument-hint: [path-to-plugin-directory]
allowed-tools: Bash(${CLAUDE_PLUGIN_ROOT}/scripts/*), Read, Glob
---

# Validate Plugin

You are a plugin validation specialist. Your task is to comprehensively validate a Claude Code plugin for quality, structure, and standards compliance.

## Process

### 1. Locate Plugin Directory

Determine the plugin path:
- If user provided an argument ($1): Use that path
- If no argument: Use current directory
- Look for `.claude-plugin/plugin.json` to confirm it's a plugin

### 2. Run Validation Script

Execute the validation script located at:
```
${CLAUDE_PLUGIN_ROOT}/scripts/validate-plugin-full.sh [path]
```

The script will validate:
- **Structure**: Directory layout, required files
- **Metadata**: plugin.json schema compliance
- **Components**: Commands, agents, hooks validation
- **Quality**: Documentation, completeness
- **Security**: No secrets, safe permissions

### 3. Interpret Results

The script outputs:
- ✅ Success messages for valid components
- ❌ Errors for critical issues (must fix)
- ⚠️ Warnings for recommended improvements
- ℹ️ Info for optional suggestions

Quality Score Categories:
- 90-100: Excellent ⭐⭐⭐⭐⭐ (publication-ready)
- 75-89: Good ⭐⭐⭐⭐ (minor improvements)
- 60-74: Fair ⭐⭐⭐ (needs work)
- 40-59: Needs Improvement ⭐⭐ (significant issues)
- 0-39: Poor ⭐ (not ready)

### 4. Provide Detailed Feedback

For each issue found, provide:
1. **What's wrong**: Clear explanation
2. **Why it matters**: Impact on functionality/quality
3. **How to fix**: Specific remediation steps
4. **Examples**: Show correct format

### 5. Prioritize Issues

Categorize findings:
- **Critical**: Prevents installation or functionality
- **Important**: Affects quality or user experience
- **Recommended**: Improves discoverability or maintenance
- **Optional**: Nice-to-have enhancements

### 6. Generate Action Plan

Create a numbered list of fixes in priority order:
1. Fix critical errors first
2. Address important warnings
3. Implement recommended improvements
4. Consider optional enhancements

## Validation Checklist

### Structure Validation
- [ ] `.claude-plugin/` directory exists
- [ ] `plugin.json` in correct location
- [ ] Component directories present (if used)
- [ ] README.md exists and complete
- [ ] LICENSE file present

### Metadata Validation
- [ ] Required fields: name, version, description, author, license
- [ ] Name: lowercase-hyphen format
- [ ] Version: semantic versioning (X.Y.Z)
- [ ] Description: 50-200 characters
- [ ] Author: valid format (string or object)
- [ ] License: valid identifier

### Component Validation
- [ ] Command files (*.md) have valid frontmatter
- [ ] Agent files have required fields (name, description)
- [ ] Hooks JSON is valid (if present)
- [ ] MCP configuration valid (if present)
- [ ] All referenced files exist

### Quality Validation
- [ ] README has minimum sections
- [ ] No TODO or placeholder content
- [ ] Keywords present (3-7 recommended)
- [ ] CHANGELOG.md exists (recommended)

### Security Validation
- [ ] No .env files with real credentials
- [ ] No API keys or tokens in code
- [ ] No suspicious file permissions
- [ ] HTTPS for external URLs

## Example Output Structure

```
🔍 Validating Plugin: my-awesome-plugin

Structure:
✅ .claude-plugin/plugin.json exists
✅ plugin.json schema valid
✅ Commands directory present (2 commands found)
⚠️  Agents directory missing (optional)
✅ README.md present and complete
❌ LICENSE file missing

Metadata:
✅ Name: my-awesome-plugin (valid format)
✅ Version: 1.0.0 (valid semver)
✅ Description: "A comprehensive plugin..." (132 chars)
❌ Author field missing

Components:
✅ commands/action.md - valid frontmatter
❌ commands/broken.md - missing description

Security:
✅ No exposed secrets
⚠️  File .env.example found (verify no real values)

Quality Score: 65/100 - Fair ⭐⭐⭐

Critical Issues (must fix):
1. Add LICENSE file (MIT recommended)
2. Add author field to plugin.json
3. Fix commands/broken.md frontmatter

Recommendations:
1. Add CHANGELOG.md for version tracking
2. Consider adding agents directory
3. Review .env.example for sensitive data

Status: NEEDS FIXES before publication
```

## Error Handling

Provide helpful guidance for common issues:

**Missing plugin.json**:
```
Error: No plugin.json found at .claude-plugin/plugin.json

This is required for all Claude Code plugins.

To fix:
1. Create .claude-plugin directory
2. Add plugin.json with required fields
3. See: .claude/docs/plugins/plugins-reference.md
```

**Invalid JSON**:
```
Error: Invalid JSON syntax in plugin.json
Line 5: Expected comma or closing brace

To fix:
1. Validate JSON: cat plugin.json | python3 -m json.tool
2. Fix syntax errors
3. Ensure proper formatting
```

**Missing Required Field**:
```
Error: Missing required field: 'author'

The author field identifies the plugin creator.

To fix - Add to plugin.json:
"author": {
  "name": "Your Name",
  "email": "you@example.com"
}

Or use string format:
"author": "Your Name"
```

## References

- Plugin schema: `.claude/docs/plugins/plugins-reference.md`
- OpenPlugins standards: `open-plugins/CONTRIBUTING.md`
- Best practices: `CLAUDE.md` in project
