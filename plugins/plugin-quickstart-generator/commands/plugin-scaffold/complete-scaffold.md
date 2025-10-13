---
description: Generate complete plugin structure with all necessary files in one operation
---

# Complete Plugin Scaffolding

## Parameters

**Required**:
- `name`: Plugin name in lowercase-hyphen format
- `description`: Brief description (50-200 characters)
- `author`: Author name or "name:email" format
- `license`: License type (MIT|Apache-2.0|GPL-3.0|BSD-3-Clause)

**Optional**:
- `category`: OpenPlugins category (default: "development")
- `keywords`: Comma-separated keywords (default: auto-generated)
- `version`: Initial version (default: "1.0.0")
- `with_agent`: Include agent template (format: true|false, default: false)
- `with_hooks`: Include hooks template (format: true|false, default: false)

## Workflow

### Step 1: Validate Parameters

**Plugin Name Validation**:
- Must match pattern: `^[a-z][a-z0-9-]*$`
- Must be lowercase with hyphens only
- Cannot start with numbers
- Should be descriptive and memorable

Execute validation script:
```bash
.scripts/validate-name.sh "{name}"
```

**Description Validation**:
- Length: 50-200 characters
- Must be specific and actionable
- Should answer "What does this do?"

**Author Format**:
- Simple: "John Doe"
- With email: "John Doe <john@example.com>"
- Object format: handled automatically

### Step 2: Create Directory Structure

**Base Structure**:
```bash
mkdir -p {name}/.claude-plugin
mkdir -p {name}/commands
mkdir -p {name}/agents     # if with_agent:true
mkdir -p {name}/hooks      # if with_hooks:true
```

**Subdirectories Based on Pattern**:
- Simple plugin: No subdirectories needed
- Moderate plugin: May create command namespace directories
- Complex plugin: Create skill directories with .scripts/

### Step 3: Generate plugin.json

Create `.claude-plugin/plugin.json` with complete metadata:

```json
{
  "name": "{name}",
  "version": "{version}",
  "description": "{description}",
  "author": {
    "name": "{author_name}",
    "email": "{author_email}"
  },
  "license": "{license}",
  "repository": {
    "type": "git",
    "url": "https://github.com/{username}/{name}"
  },
  "homepage": "https://github.com/{username}/{name}",
  "keywords": [{keywords}],
  "category": "{category}"
}
```

Execute metadata generation script:
```bash
.scripts/generate-metadata.py --name "{name}" --author "{author}" --description "{description}" --license "{license}" --category "{category}"
```

### Step 4: Create README.md

Generate comprehensive README with sections:

1. **Title and Badge**
2. **Description** (expanded from metadata)
3. **Features** (bullet list)
4. **Installation** (multiple methods)
5. **Usage** (with examples)
6. **Configuration** (if applicable)
7. **Commands** (document each command)
8. **Agents** (if with_agent:true)
9. **Hooks** (if with_hooks:true)
10. **Examples** (multiple real scenarios)
11. **Troubleshooting**
12. **Development** (testing, contributing)
13. **Changelog** (link to CHANGELOG.md)
14. **License**
15. **Resources**

### Step 5: Add LICENSE File

Based on license parameter, add appropriate LICENSE file:

**MIT**:
```
MIT License

Copyright (c) {year} {author}

Permission is hereby granted, free of charge, to any person obtaining a copy...
```

**Apache-2.0**:
```
Apache License
Version 2.0, January 2004
http://www.apache.org/licenses/
...
```

**GPL-3.0**:
```
GNU GENERAL PUBLIC LICENSE
Version 3, 29 June 2007
...
```

**BSD-3-Clause**:
```
BSD 3-Clause License

Copyright (c) {year}, {author}
...
```

### Step 6: Create CHANGELOG.md

Initialize changelog with version 1.0.0:

```markdown
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - {date}

### Added
- Initial release
- {feature 1}
- {feature 2}
```

### Step 7: Create .gitignore

Add plugin development .gitignore:

```
# OS files
.DS_Store
Thumbs.db

# Editor directories
.vscode/
.idea/
*.swp
*.swo
*~

# Logs
*.log
npm-debug.log*

# Environment
.env
.env.local

# Dependencies
node_modules/
__pycache__/
*.pyc

# Build outputs
dist/
build/
*.egg-info/

# Test coverage
coverage/
.coverage
.nyc_output

# Temporary files
tmp/
temp/
*.tmp
```

### Step 8: Create Template Files

**If with_agent:true**, create `agents/specialist.md`:
```markdown
---
name: {name}-specialist
description: Expert in {domain}. Use when users need guidance with {functionality}.
capabilities: [capability1, capability2, capability3]
tools: Read, Write, Bash, Grep, Glob
model: inherit
---

# {Name} Specialist Agent

You are an expert in {domain}. Your role is to provide guidance and automation for {functionality}.

## When to Invoke

This agent is automatically invoked when users:
- {trigger condition 1}
- {trigger condition 2}

## Approach

{Agent's methodology and best practices}
```

**If with_hooks:true**, create `hooks/hooks.json`:
```json
{
  "PostToolUse": [
    {
      "matcher": "Write|Edit",
      "hooks": [
        {
          "type": "command",
          "command": "echo 'Hook triggered after file modification'"
        }
      ]
    }
  ]
}
```

**Create sample command** in `commands/example.md`:
```markdown
---
description: Example command demonstrating plugin functionality
---

# Example Command

This is a sample command. Replace with your actual implementation.

## Usage

/{name} [arguments]

## Parameters

- `arg1`: Description
- `arg2`: Description (optional)

## Implementation

{Implementation instructions}
```

### Step 9: Verify Structure

Run structure validation:
```bash
# Check all required files exist
test -f {name}/.claude-plugin/plugin.json && echo "✅ plugin.json" || echo "❌ plugin.json missing"
test -f {name}/README.md && echo "✅ README.md" || echo "✅ README.md" || echo "❌ README.md missing"
test -f {name}/LICENSE && echo "✅ LICENSE" || echo "❌ LICENSE missing"
test -f {name}/CHANGELOG.md && echo "✅ CHANGELOG.md" || echo "❌ CHANGELOG.md missing"
test -d {name}/commands && echo "✅ commands/" || echo "❌ commands/ missing"
```

### Step 10: Generate Success Report

Provide comprehensive report with:
- Structure created confirmation
- Files generated list
- Next steps for development
- Testing instructions
- Marketplace submission readiness checklist

## Output Format

```markdown
## ✅ Plugin Scaffolding Complete

### Generated Structure

```
{name}/
├── .claude-plugin/
│   └── plugin.json ✅
├── .gitignore ✅
├── CHANGELOG.md ✅
├── LICENSE ({license}) ✅
├── README.md ✅
├── commands/
│   └── example.md ✅
├── agents/ {if applicable}
│   └── specialist.md ✅
└── hooks/ {if applicable}
    └── hooks.json ✅
```

### Files Created

- ✅ **plugin.json**: Complete metadata with all required fields
- ✅ **README.md**: Comprehensive documentation template
- ✅ **LICENSE**: {license} license file
- ✅ **CHANGELOG.md**: Initialized with version 1.0.0
- ✅ **.gitignore**: Plugin development exclusions
- ✅ **commands/example.md**: Sample command template
{Additional files if created}

### Metadata Summary

**Name**: {name}
**Version**: {version}
**Description**: {description}
**Author**: {author}
**License**: {license}
**Category**: {category}
**Keywords**: {keywords}

### Next Steps

1. **Implement Functionality**
   - Edit `commands/example.md` with your actual implementation
   - Add more commands as needed
   - Implement agent logic if included

2. **Update Documentation**
   - Customize README.md with real examples
   - Document all parameters and usage
   - Add troubleshooting section

3. **Local Testing**
   ```bash
   # Create test marketplace
   mkdir -p test-marketplace/.claude-plugin
   # Add marketplace.json
   # Install and test plugin
   ```

4. **Prepare for Release**
   - Update CHANGELOG.md with features
   - Verify all documentation is complete
   - Run quality checks
   - Test all functionality

5. **Submit to OpenPlugins**
   - Fork OpenPlugins repository
   - Add plugin entry to marketplace.json
   - Create pull request

### Quality Checklist

Before submission, ensure:
- ✅ Plugin name follows lowercase-hyphen format
- ✅ Description is 50-200 characters
- ✅ All required metadata fields present
- ✅ README has real content (no placeholders)
- ✅ LICENSE file included
- ✅ At least one functional command
- ✅ No hardcoded secrets
- ✅ Examples are concrete and realistic

### Testing Commands

```bash
# Navigate to plugin directory
cd {name}

# Validate plugin.json
python3 -m json.tool .claude-plugin/plugin.json

# Check file structure
ls -la

# Initialize git repository
git init
git add .
git commit -m "Initial plugin structure"
```

### Resources

- Plugin Documentation: https://docs.claude.com/en/docs/claude-code/plugins
- OpenPlugins Guide: https://github.com/dhofheinz/open-plugins
- Submit Plugin: Fork repository and add to marketplace.json

---

**Plugin scaffolding complete!** Your plugin is ready for implementation.
```

## Error Handling

- **Invalid plugin name** → Show valid pattern and suggest correction
- **Directory exists** → Ask for confirmation to overwrite or use different name
- **Invalid license type** → List supported licenses: MIT, Apache-2.0, GPL-3.0, BSD-3-Clause
- **Missing required parameter** → Request parameter with expected format
- **Git not available** → Skip git initialization, provide manual instructions
- **File creation fails** → Report specific file and error, provide recovery steps

## Examples

### Example 1: Simple Plugin

**Input**:
```
/plugin-scaffold complete name:hello-world author:"Jane Smith" license:MIT description:"Simple greeting plugin for Claude Code"
```

**Output**: Complete plugin structure with all files

### Example 2: Plugin with Agent

**Input**:
```
/plugin-scaffold complete name:code-reviewer author:"John Doe <john@example.com>" license:Apache-2.0 description:"Automated code review with security analysis" with_agent:true category:quality
```

**Output**: Plugin structure including agent template

**Request**: $ARGUMENTS
