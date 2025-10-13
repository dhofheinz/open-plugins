# Marketplace Validator Plugin

> Comprehensive validation for Claude Code marketplaces and plugins with quality scoring, security scanning, and automated checks.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](https://github.com/dhofheinz/open-plugins)
[![Category](https://img.shields.io/badge/category-quality-green.svg)](https://github.com/dhofheinz/open-plugins)

## Overview

The Marketplace Validator Plugin is an essential quality assurance tool for the Claude Code plugin ecosystem. It ensures marketplaces and plugins meet OpenPlugins standards before publication, reducing maintainer burden and accelerating the review process.

### Key Features

- **Comprehensive Validation**: Schema compliance, quality scoring, and security scanning
- **Multiple Validation Modes**: Full, quick, and automatic validation
- **Quality Scoring**: 0-100 scale with star ratings (⭐⭐⭐⭐⭐)
- **Security Scanning**: Detect exposed secrets, malicious patterns, unsafe permissions
- **Automatic Hooks**: Validate on every marketplace.json or plugin.json edit
- **Actionable Feedback**: Specific recommendations with remediation steps
- **Proactive Agent**: Auto-validates when quality concerns are mentioned

### Why Use This Plugin?

**For Plugin Authors**:
- Validate before submission to avoid review delays
- Ensure quality standards are met
- Get immediate feedback during development
- Learn best practices through recommendations

**For Marketplace Maintainers**:
- Reduce manual review burden
- Enforce consistent quality standards
- Automate pre-merge validation
- Provide contributors clear feedback

## Installation

### From OpenPlugins Marketplace

```bash
# Add OpenPlugins marketplace (if not already added)
/plugin marketplace add https://github.com/dhofheinz/open-plugins

# Install the validator plugin
/plugin install marketplace-validator-plugin@open-plugins

# Restart Claude Code
# The plugin is now active!
```

### From Local Development

```bash
# Clone the repository
git clone https://github.com/dhofheinz/open-plugins.git
cd open-plugins

# Add as local marketplace
/plugin marketplace add ./

# Install the plugin
/plugin install marketplace-validator-plugin@open-plugins
```

## Commands

### `/validate-marketplace [path]`

Comprehensive marketplace.json validation with quality scoring.

**Usage**:
```bash
# Validate marketplace in current directory
/validate-marketplace

# Validate specific marketplace
/validate-marketplace /path/to/marketplace

# Validate OpenPlugins marketplace
/validate-marketplace ./open-plugins
```

**What It Validates**:
- ✅ JSON syntax and structure
- ✅ Required fields (name, owner, description, plugins)
- ✅ Optional recommended fields
- ✅ Plugin entry completeness
- ✅ Format compliance (semver, naming conventions)
- ✅ Security checks (exposed secrets, malicious URLs)
- ✅ Quality scoring (0-100 scale)

**Example Output**:
```
🔍 Validating Marketplace: open-plugins

✅ JSON syntax valid
✅ Required fields present
✅ 3 plugins found

Plugin Validation:
✅ plugin-quickstart-generator (v1.0.0) - Excellent ⭐⭐⭐⭐⭐
✅ marketplace-validator-plugin (v1.0.0) - Excellent ⭐⭐⭐⭐⭐
⚠️  example-plugin (v0.1.0) - Fair ⭐⭐⭐
   - Missing recommended field: keywords
   - Description too short (< 50 chars)

Overall Quality Score: 88/100 - Good ⭐⭐⭐⭐

Recommendations:
1. Add keywords to example-plugin for better discoverability
2. Expand description in example-plugin (min 50 chars)

Summary: 2 excellent, 1 fair - Address warnings before publication
```

### `/validate-plugin [path]`

Comprehensive plugin validation with structure, metadata, and component checks.

**Usage**:
```bash
# Validate plugin in current directory
/validate-plugin

# Validate specific plugin
/validate-plugin /path/to/my-plugin

# Validate before submission
/validate-plugin ./marketplace-validator-plugin
```

**What It Validates**:
- ✅ Directory structure (.claude-plugin/, components)
- ✅ plugin.json schema compliance
- ✅ Required fields (name, version, description, author, license)
- ✅ Required files (README.md, LICENSE)
- ✅ Command frontmatter validation
- ✅ Agent frontmatter validation
- ✅ Hooks configuration and script checks
- ✅ Security scanning
- ✅ Quality assessment

**Example Output**:
```
🔍 Validating Plugin: marketplace-validator-plugin

Structure:
✅ .claude-plugin/plugin.json exists
✅ plugin.json schema valid
✅ Commands directory present (3 commands)
✅ Agents directory present (1 agent)
✅ Hooks directory present
✅ README.md present and substantial
✅ LICENSE file present
✅ CHANGELOG.md present

Metadata:
✅ Name: marketplace-validator-plugin (valid format)
✅ Version: 1.0.0 (valid semver)
✅ Description: "Comprehensive validation..." (138 chars)
✅ Author: OpenPlugins Team
✅ License: MIT
✅ Keywords: 6 keywords (good)
✅ Repository: https://github.com/dhofheinz/open-plugins

Components:
✅ commands/validate-marketplace.md - valid frontmatter
✅ commands/validate-plugin.md - valid frontmatter
✅ commands/validate-quick.md - valid frontmatter
✅ agents/marketplace-validator.md - valid (name: marketplace-validator)

Security:
✅ No exposed secrets
✅ No suspicious files

Quality Score: 100/100 - Excellent ⭐⭐⭐⭐⭐

Status: EXCELLENT - Ready for publication ✅
```

### `/validate-quick [target]`

Fast essential checks for CI/CD pipelines and rapid iteration.

**Usage**:
```bash
# Auto-detect and validate (marketplace or plugin)
/validate-quick

# Quick marketplace check
/validate-quick ./open-plugins

# Quick plugin check
/validate-quick ./my-plugin
```

**What It Checks**:
- ✅ JSON syntax valid
- ✅ Required fields present
- ✅ Basic format compliance
- ❌ Critical security issues

**Performance**: Completes in < 3 seconds

**Example Output**:
```
🔍 Quick Validation: marketplace-validator-plugin

Plugin structure: PASS ✅
JSON syntax: PASS ✅
Required fields: PASS ✅
Format compliance: PASS ✅
Security check: PASS ✅

Status: PASS ✅

All essential checks passed. Run full validation for detailed quality assessment.
```

**When to Use Quick Validation**:
- Pre-commit hooks (immediate feedback)
- CI/CD pipelines (fast gate checks)
- Rapid development iteration
- Binary pass/fail verification

**When to Use Full Validation**:
- Preparing for publication
- Comprehensive quality assessment
- Detailed recommendations needed
- Final pre-submission check

## Agent

### marketplace-validator

The marketplace-validator agent provides proactive validation assistance.

**Automatic Activation**:
The agent automatically activates when you:
- Mention "validate", "check", or "review"
- Reference marketplace.json or plugin.json
- Ask about quality or standards
- Prepare for submission or publication

**Capabilities**:
- Schema validation and compliance checking
- Quality assessment with scoring
- Security scanning for vulnerabilities
- Best practices enforcement
- Automated recommendations with examples

**Example Interaction**:
```
You: Is my plugin ready to submit to OpenPlugins?

Agent: Let me validate your plugin to check publication readiness.

[Runs comprehensive validation]

Quality Assessment: 85/100 - Good ⭐⭐⭐⭐

Your plugin is nearly ready! Address these items:

Critical (must fix):
- None ✅

Recommended (should fix):
1. Add CHANGELOG.md for version tracking
2. Expand README with more usage examples
3. Add 2 more keywords for discoverability

After fixing, your plugin will be excellent and ready for submission!
```

## Hooks

The plugin includes automatic validation hooks that trigger on file edits:

### Marketplace Hook

**Trigger**: PostToolUse on marketplace.json edits
**Action**: Quick validation with immediate feedback

```json
{
  "matcher": "Write.*marketplace\\.json|Edit.*marketplace\\.json",
  "command": "${CLAUDE_PLUGIN_ROOT}/scripts/auto-validate-marketplace.sh"
}
```

### Plugin Hook

**Trigger**: PostToolUse on plugin.json edits
**Action**: Quick validation with immediate feedback

```json
{
  "matcher": "Write.*plugin\\.json|Edit.*plugin\\.json",
  "command": "${CLAUDE_PLUGIN_ROOT}/scripts/auto-validate-plugin.sh"
}
```

**Behavior**:
- Non-blocking (warnings don't fail edits)
- Immediate feedback on critical issues
- Suggests running full validation for details

## Quality Scoring System

### Score Calculation

```
Base Score: 100 points
- Required fields missing: -20 points each
- Warnings (format, recommendations): -10 points each
- Missing recommended fields: -5 points each
- Security issues: -30 points each

Final Score: max(0, Base - Deductions)
```

### Rating Scale

| Score Range | Rating | Stars | Meaning |
|-------------|--------|-------|---------|
| 90-100 | Excellent | ⭐⭐⭐⭐⭐ | Publication-ready |
| 75-89 | Good | ⭐⭐⭐⭐ | Minor improvements |
| 60-74 | Fair | ⭐⭐⭐ | Needs work |
| 40-59 | Needs Improvement | ⭐⭐ | Significant issues |
| 0-39 | Poor | ⭐ | Not ready |

### Quality Standards

**Excellent (90-100)**:
- All required and recommended fields present
- No critical issues or warnings
- Complete documentation
- Security checks pass
- Best practices followed

**Good (75-89)**:
- All required fields present
- Some recommended fields missing
- Minor warnings
- Ready with small improvements

**Fair (60-74)**:
- Required fields present
- Many recommended fields missing
- Multiple warnings
- Needs work before publication

## Validation Rules

### Marketplace Validation

#### Required Fields
- `name`: Lowercase-hyphen format (e.g., "open-plugins")
- `owner.name`: Owner identification
- `owner.email`: Contact email (recommended)
- `description`: 50-500 characters
- `plugins`: Array (can be empty)

#### Plugin Entry Requirements
- `name`: Lowercase-hyphen format
- `version`: Semantic versioning (X.Y.Z)
- `description`: 50-200 characters
- `author`: String or object with name field
- `source`: Valid format (github:, URL, or path)
- `license`: Valid SPDX identifier

#### Quality Criteria
- Keywords: 3-7 per plugin (recommended)
- Category: One of 10 standard categories
- Complete metadata (homepage, repository)
- No exposed secrets

### Plugin Validation

#### Required Fields
- `name`: Lowercase-hyphen format
- `version`: Semantic versioning (X.Y.Z)
- `description`: 50-200 characters
- `author`: String or object with name
- `license`: Valid identifier

#### Required Files
- `.claude-plugin/plugin.json`: Plugin manifest
- `README.md`: Comprehensive documentation (>500 bytes)
- `LICENSE`: License file

#### Component Validation
- **Commands** (*.md): Valid frontmatter with description
- **Agents** (*.md): Required fields (name, description)
- **Hooks** (hooks.json): Valid JSON, executable scripts
- **MCP** (.mcp.json): Valid configuration

#### Security Requirements
- No exposed secrets (API keys, tokens, passwords)
- No `.env` files with real credentials
- HTTPS for external resource URLs
- Safe file permissions on scripts

### Valid Categories

Plugins and marketplace entries must use one of these categories:
- `development` - Code generation, scaffolding, refactoring
- `testing` - Test generation, coverage, quality assurance
- `deployment` - CI/CD, infrastructure, release automation
- `documentation` - Docs generation, API documentation
- `security` - Vulnerability scanning, secret detection
- `database` - Schema design, migrations, queries
- `monitoring` - Performance analysis, logging
- `productivity` - Workflow automation, task management
- `quality` - Linting, formatting, code review
- `collaboration` - Team tools, communication

### Semantic Versioning

All versions must follow semver format: `MAJOR.MINOR.PATCH`

Examples:
- ✅ `1.0.0` - Valid
- ✅ `2.3.1` - Valid
- ✅ `0.1.0` - Valid (pre-release)
- ❌ `1.0` - Invalid (missing patch)
- ❌ `v1.0.0` - Invalid (no 'v' prefix)
- ❌ `1.0.0-beta` - Invalid (pre-release tags not supported)

### Naming Conventions

Plugin and marketplace names must use lowercase-hyphen format:

Examples:
- ✅ `marketplace-validator-plugin` - Valid
- ✅ `my-awesome-tool` - Valid
- ✅ `db-ops` - Valid
- ❌ `MyPlugin` - Invalid (camelCase)
- ❌ `my_plugin` - Invalid (underscores)
- ❌ `marketplace validator` - Invalid (spaces)

## CI/CD Integration

### GitHub Actions Example

```yaml
name: Validate Plugin
on: [pull_request, push]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Setup Claude Code
        run: |
          # Install Claude Code CLI
          curl -fsSL https://claude.ai/install.sh | sh

      - name: Install Validator Plugin
        run: |
          claude plugin marketplace add https://github.com/dhofheinz/open-plugins
          claude plugin install marketplace-validator-plugin@open-plugins

      - name: Validate Plugin
        run: |
          claude run /validate-quick .

      - name: Full Validation (on main)
        if: github.ref == 'refs/heads/main'
        run: |
          claude run /validate-plugin .
```

### Pre-commit Hook

```bash
#!/bin/bash
# .git/hooks/pre-commit

# Check if plugin.json or marketplace.json changed
if git diff --cached --name-only | grep -E '(marketplace|plugin)\.json$'; then
    echo "Validating changed JSON files..."

    # Use Claude Code to run quick validation
    if ! claude run /validate-quick .; then
        echo "❌ Validation failed. Fix issues before committing."
        exit 1
    fi

    echo "✅ Validation passed!"
fi

exit 0
```

## Troubleshooting

### Common Issues

#### "No JSON parsing tool available"

**Problem**: jq or python3 not installed

**Solution**:
```bash
# Install jq (recommended)
sudo apt-get install jq  # Ubuntu/Debian
brew install jq          # macOS

# Or ensure python3 is installed
sudo apt-get install python3
```

#### "Invalid JSON syntax"

**Problem**: Malformed JSON in marketplace.json or plugin.json

**Solution**:
```bash
# Validate JSON syntax
python3 -m json.tool file.json

# Or use jq
jq empty file.json
```

#### "Missing required field"

**Problem**: Required metadata field not present

**Solution**: Add the missing field to your JSON file. Example:
```json
{
  "name": "my-plugin",
  "version": "1.0.0",
  "description": "A comprehensive plugin...",
  "author": {
    "name": "Your Name",
    "email": "you@example.com"
  },
  "license": "MIT"
}
```

#### "Hook script not executable"

**Problem**: Hook scripts don't have execute permissions

**Solution**:
```bash
chmod +x scripts/*.sh
```

### Getting Help

If you encounter issues:

1. **Check Documentation**:
   - Plugin reference: `.claude/docs/plugins/plugins-reference.md`
   - Marketplace guide: `.claude/docs/plugins/plugin-marketplaces.md`

2. **Run Full Validation**: Get detailed error information
   ```bash
   /validate-plugin /path/to/plugin
   ```

3. **Open an Issue**: Report bugs or request features
   - [GitHub Issues](https://github.com/dhofheinz/open-plugins/issues)

4. **Join Discussions**: Ask questions and share feedback
   - [GitHub Discussions](https://github.com/dhofheinz/open-plugins/discussions)

## Development

### Project Structure

```
marketplace-validator-plugin/
├── .claude-plugin/
│   └── plugin.json          # Plugin manifest
├── commands/
│   ├── validate-marketplace.md  # Marketplace validation command
│   ├── validate-plugin.md       # Plugin validation command
│   └── validate-quick.md        # Quick validation command
├── agents/
│   └── marketplace-validator.md # Proactive validation agent
├── hooks/
│   └── hooks.json               # Hook configuration
├── scripts/
│   ├── validate-lib.sh              # Shared validation library
│   ├── validate-marketplace-full.sh # Full marketplace validation
│   ├── validate-plugin-full.sh      # Full plugin validation
│   ├── validate-marketplace-quick.sh # Quick marketplace validation
│   ├── validate-plugin-quick.sh     # Quick plugin validation
│   ├── auto-validate-marketplace.sh  # Marketplace hook handler
│   └── auto-validate-plugin.sh       # Plugin hook handler
├── README.md                # This file
├── LICENSE                  # MIT License
└── CHANGELOG.md            # Version history
```

### Testing

```bash
# Test marketplace validation
/validate-marketplace ./open-plugins

# Test plugin validation
/validate-plugin ./marketplace-validator-plugin

# Test quick validation
/validate-quick ./marketplace-validator-plugin

# Test hooks (edit a JSON file and observe automatic validation)
```

## Contributing

Contributions are welcome! To contribute:

1. Fork the OpenPlugins repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

See [CONTRIBUTING.md](../../CONTRIBUTING.md) for detailed guidelines.

## License

MIT License - see [LICENSE](./LICENSE) file for details.

## Acknowledgments

- Built for the [OpenPlugins](https://github.com/dhofheinz/open-plugins) marketplace
- Inspired by Claude Code's plugin architecture
- Follows OpenPlugins quality standards

## Support

- **Documentation**: [OpenPlugins Wiki](https://github.com/dhofheinz/open-plugins/wiki)
- **Issues**: [GitHub Issues](https://github.com/dhofheinz/open-plugins/issues)
- **Discussions**: [GitHub Discussions](https://github.com/dhofheinz/open-plugins/discussions)

---

**Made with ❤️ by the OpenPlugins Team**

*Ensuring quality in the Claude Code plugin ecosystem*
