# plugin-quickstart-generator

Generate production-ready Claude Code plugin structures for OpenPlugins marketplace with guided interactive setup.

## Overview

**plugin-quickstart-generator** is the official scaffolding tool for creating Claude Code plugins that meet OpenPlugins marketplace standards. It provides an interactive, guided workflow that generates complete plugin structures with all required files, comprehensive documentation, and test marketplaces—enabling developers to focus on implementing functionality rather than setting up boilerplate.

### Key Features

- **Interactive Setup**: Guided prompts collect metadata with validation and helpful defaults
- **Complete Structure**: Generates all required and recommended files following OpenPlugins standards
- **Quality Templates**: Production-ready templates for commands, agents, and documentation
- **Test Marketplace**: Automatically creates local marketplace for testing before submission
- **Validation**: Built-in checks ensure generated plugins meet quality standards
- **Best Practices**: Enforces naming conventions, metadata completeness, and security requirements
- **Comprehensive Documentation**: Generated READMEs include installation, usage, examples, and troubleshooting

### What Gets Generated

Every generated plugin includes:
- ✅ Complete `.claude-plugin/plugin.json` manifest with all metadata
- ✅ Template command with frontmatter and usage examples
- ✅ Optional specialist agent with comprehensive system prompt
- ✅ Professional README with installation, usage, and troubleshooting sections
- ✅ LICENSE file (MIT, Apache, GPL, or BSD)
- ✅ CHANGELOG.md with version history
- ✅ .gitignore for plugin development
- ✅ Test marketplace structure for local validation

## Installation

### From OpenPlugins Marketplace

```bash
/plugin marketplace add dhofheinz/open-plugins
/plugin install plugin-quickstart-generator@open-plugins
```

### From GitHub

```bash
/plugin marketplace add github:dhofheinz/open-plugins
/plugin install plugin-quickstart-generator@open-plugins
```

### From Local Directory (Development)

```bash
# Clone the repository
git clone https://github.com/dhofheinz/open-plugins.git
cd open-plugins

# Add local marketplace
/plugin marketplace add .

# Install plugin
/plugin install plugin-quickstart-generator@open-plugins
```

## Usage

### Command: /quickstart-plugin

Generate a new plugin with interactive setup.

**Syntax**:
```bash
/quickstart-plugin <plugin-name> [category]
```

**Arguments**:
- `<plugin-name>` (required): Plugin name in lowercase-hyphen format (e.g., `code-formatter`)
- `[category]` (optional): Plugin category (development, testing, deployment, etc.)

**Interactive Prompts**:

The command will guide you through:
1. **Description**: 50-200 character description of functionality
2. **Author Information**: Name, email, and optional URL (defaults from git config)
3. **License**: MIT, Apache-2.0, GPL-3.0, or BSD-3-Clause
4. **Category**: Choose from 10 standard categories with descriptions
5. **Keywords**: 3-7 searchable terms for plugin discovery
6. **Agent Option**: Whether to include a specialist agent

**Validation**:
- Plugin name format (lowercase-hyphen)
- Description length (50-200 characters)
- Category selection (valid category)
- Keyword count (3-7 keywords)
- JSON syntax (all generated manifests)

### Agent: plugin-generator

Expert agent for plugin architecture guidance and OpenPlugins standards.

**Automatic Invocation**: The agent is invoked when you:
- Express intent to "create a plugin"
- Ask about plugin architecture or design
- Request help with plugin structure
- Need guidance on OpenPlugins standards

**Explicit Invocation**:
```
Use the plugin-generator agent to help me design a testing plugin
```

**Capabilities**:
- plugin-scaffolding
- metadata-validation
- template-generation
- marketplace-integration
- quality-assurance
- architecture-guidance

**What the Agent Does**:
- Helps choose appropriate plugin components (commands, agents, hooks, MCP)
- Validates plugin names, descriptions, and metadata
- Recommends architecture patterns based on complexity
- Ensures compliance with OpenPlugins quality standards
- Provides security guidance (no hardcoded secrets, input validation)
- Guides testing and marketplace submission process

## Examples

### Example 1: Create a Simple Code Formatting Plugin

```bash
/quickstart-plugin code-formatter development
```

**Interactive Session**:
```
Enter a brief description (50-200 characters):
> Automate code formatting using Prettier with project-specific configurations

Author name (from git config: John Doe):
> [Press Enter to use default]

Author email (from git config: john@example.com):
> [Press Enter to use default]

Author URL (optional):
> https://github.com/johndoe

Choose license (default: MIT):
1. MIT
2. Apache-2.0
3. GPL-3.0
4. BSD-3-Clause
> 1

Category: development (auto-selected from argument)

Enter 3-7 keywords (comma-separated):
> formatting, prettier, javascript, code-quality, automation

Include a specialist agent? (y/n, default: n):
> n

✅ Plugin "code-formatter" generated successfully!
```

### Example 2: Create a Testing Plugin with Agent

```bash
/quickstart-plugin test-generator
```

**Interactive Session**:
```
Enter a brief description (50-200 characters):
> Generate comprehensive test suites for Python functions with pytest integration

[... metadata prompts ...]

Category:
1. development
2. testing
3. deployment
[...]
> 2

Enter 3-7 keywords (comma-separated):
> testing, python, pytest, test-generation, tdd

Include a specialist agent? (y/n, default: n):
> y

Enter agent capabilities (comma-separated):
> test-generation, code-analysis, pytest-integration, coverage-reporting

✅ Plugin "test-generator" generated successfully!
✅ Agent "test-generator" included with 4 capabilities
```

### Example 3: Quick Plugin with Defaults

```bash
/quickstart-plugin deploy-automation deployment
```

For users who want to accept most defaults, the process is streamlined while still ensuring quality metadata.

## Generated Plugin Structure

### Directory Layout

```
<plugin-name>/
├── .claude-plugin/
│   └── plugin.json              # Complete manifest with metadata
├── commands/
│   └── example.md               # Template command with frontmatter
├── agents/                      # Only if agent requested
│   └── example-agent.md         # Specialist agent with system prompt
├── README.md                    # Comprehensive documentation
├── LICENSE                      # Full license text
├── CHANGELOG.md                 # Version history (v1.0.0)
└── .gitignore                   # Standard exclusions

<plugin-name>-test-marketplace/
├── .claude-plugin/
│   └── marketplace.json         # Test marketplace configuration
```

### File Contents

#### plugin.json
Complete manifest with:
- Required fields: name, version, description, author, license
- Optional fields: repository, homepage, keywords (recommended)
- Proper JSON formatting with escaping

#### commands/example.md
Template includes:
- Frontmatter with description and argument hints
- Usage section with syntax examples
- Implementation guidelines
- Argument parsing examples
- Tool integration examples
- Error handling patterns
- Best practices

#### agents/example-agent.md (if requested)
Agent template includes:
- Frontmatter with name, description, capabilities, tools
- Role definition and expertise areas
- Invocation triggers (proactive and explicit)
- Methodology and approach
- Best practices
- Error handling
- Output format guidelines

#### README.md
Comprehensive documentation with:
- Overview and key features
- Installation instructions (multiple methods)
- Usage guide for commands and agents
- Multiple usage examples
- Configuration options (if applicable)
- Troubleshooting section with common issues
- Development guide with testing instructions
- Contributing guidelines
- Resources and support links

#### CHANGELOG.md
Version history following [Keep a Changelog](https://keepachangelog.com/):
- Initial v1.0.0 release entry
- Sections for Added, Changed, Fixed, etc.
- Dates in YYYY-MM-DD format

#### LICENSE
Full license text based on selection:
- MIT (default, most permissive)
- Apache-2.0 (patent protection)
- GPL-3.0 (copyleft)
- BSD-3-Clause (permissive with attribution)

#### .gitignore
Standard exclusions for:
- Node modules and Python environments
- IDE configurations
- OS-specific files
- Test artifacts and temporary files
- Secrets and credentials

#### Test Marketplace
marketplace.json with:
- Marketplace metadata
- Single plugin entry referencing generated plugin
- Proper relative path (../plugin-name)

## Testing Your Generated Plugin

### Step 1: Review Generated Files

```bash
cd <plugin-name>

# Check plugin.json
cat .claude-plugin/plugin.json | python3 -m json.tool

# Review command template
cat commands/example.md

# Check agent (if generated)
cat agents/example-agent.md

# Review documentation
cat README.md
```

### Step 2: Implement Functionality

```bash
# Edit command template with actual logic
code commands/example.md

# Add more commands as needed
code commands/another-command.md

# Customize agent system prompt (if applicable)
code agents/example-agent.md
```

### Step 3: Update Documentation

```bash
# Replace README placeholders with real content
code README.md

# Update CHANGELOG if you made significant changes
code CHANGELOG.md
```

### Step 4: Test Locally

```bash
# Navigate to test marketplace
cd ../<plugin-name>-test-marketplace

# Add test marketplace to Claude Code
/plugin marketplace add .

# Install plugin locally
/plugin install <plugin-name>@<plugin-name>-test

# Test your commands
/<example-command> test-args

# Test agent invocation (if applicable)
# "Use the <agent-name> agent to test functionality"

# Uninstall for iteration
/plugin uninstall <plugin-name>
```

### Step 5: Iterate and Refine

Make changes to your plugin, then reinstall to test:

```bash
# Make changes to plugin
cd ../<plugin-name>
# Edit files...

# Reinstall to test
cd ../<plugin-name>-test-marketplace
/plugin uninstall <plugin-name>
/plugin install <plugin-name>@<plugin-name>-test
```

## Configuration

This plugin requires no additional configuration. It works out of the box with sensible defaults:

- Author information defaults to git config (user.name, user.email)
- License defaults to MIT (most permissive)
- Agent is optional (defaults to no)
- Test marketplace is automatically generated

## Validation

The generator performs automatic validation:

### Plugin Name Validation

**Required Format**: `^[a-z][a-z0-9-]*[a-z0-9]$`

✅ **Valid Examples**:
- `code-formatter`
- `test-runner`
- `deploy-tool`
- `my-plugin`

❌ **Invalid Examples**:
- `Code-Formatter` (uppercase)
- `test_runner` (underscore)
- `Deploy Tool` (spaces)
- `-plugin` (starts with hyphen)
- `plugin-` (ends with hyphen)

### Description Validation

- **Length**: 50-200 characters
- **Content**: Specific, not generic
- **Purpose**: Clearly states what the plugin does

✅ **Good Descriptions**:
- "Automate Python test generation with pytest integration and coverage reporting"
- "Deploy applications to Kubernetes with zero-downtime rolling updates"

❌ **Bad Descriptions**:
- "A useful plugin" (too vague, too short)
- "Plugin for stuff" (not descriptive)

### Category Validation

Must be one of 10 standard categories:
- development, testing, deployment, documentation, security
- database, monitoring, productivity, quality, collaboration

### Keyword Validation

- **Count**: 3-7 keywords
- **Type**: Functionality, technology, or use-case terms
- **Avoid**: Generic terms (plugin, tool, utility)

### JSON Validation

All generated JSON files are validated:
- plugin.json syntax
- marketplace.json syntax
- Proper escaping of special characters
- Required fields present

## Troubleshooting

### Issue: Plugin name rejected

**Symptoms**: Error message about invalid plugin name format

**Solution**:
1. Use only lowercase letters, numbers, and hyphens
2. Start with a letter
3. End with a letter or number
4. No consecutive hyphens

**Example Fix**:
```bash
# ❌ Wrong
/quickstart-plugin My_Plugin

# ✅ Correct
/quickstart-plugin my-plugin
```

### Issue: Description too short or long

**Symptoms**: Error about description length

**Solution**:
1. Ensure description is 50-200 characters
2. Be specific about functionality
3. Avoid generic phrases

**Example Fix**:
```
# ❌ Too short (35 characters)
"A plugin for code formatting"

# ✅ Good length (89 characters)
"Automate code formatting using Prettier with project-specific configuration support"
```

### Issue: Invalid category

**Symptoms**: Category not in approved list

**Solution**:
1. Choose from the 10 standard categories
2. If argument provided, ensure it's spelled correctly
3. If prompted, select number from list

**Valid Categories**:
development, testing, deployment, documentation, security, database, monitoring, productivity, quality, collaboration

### Issue: Insufficient keywords

**Symptoms**: Error about keyword count

**Solution**:
1. Provide 3-7 keywords
2. Separate with commas
3. Focus on functionality and technology
4. Avoid generic terms

**Example Fix**:
```bash
# ❌ Insufficient (2 keywords)
testing, python

# ✅ Good (5 keywords)
testing, python, pytest, automation, tdd
```

### Issue: Command not found after installation

**Symptoms**: `/quickstart-plugin` returns "command not found"

**Solution**:
1. Verify plugin is installed: `/plugin list`
2. Check plugin is enabled: `/plugin info plugin-quickstart-generator`
3. Restart Claude Code to reload plugins
4. Ensure marketplace was added: `/plugin marketplace list`

### Issue: Generated plugin won't install

**Symptoms**: Test installation fails

**Solution**:
1. Verify test marketplace structure:
   ```bash
   ls <plugin-name>-test-marketplace/.claude-plugin/
   # Should show marketplace.json
   ```
2. Validate marketplace.json syntax:
   ```bash
   cat <plugin-name>-test-marketplace/.claude-plugin/marketplace.json | python3 -m json.tool
   ```
3. Check source path in marketplace.json is correct (usually `../<plugin-name>`)
4. Ensure plugin directory exists and has plugin.json

### Issue: Permission denied when creating files

**Symptoms**: File creation fails with permission error

**Solution**:
1. Check directory permissions: `ls -la`
2. Verify you have write access to current directory
3. Try creating plugin in a directory you own
4. Check disk space: `df -h`

### Issue: Git config not found

**Symptoms**: Author defaults not working

**Solution**:
1. Set git config:
   ```bash
   git config --global user.name "Your Name"
   git config --global user.email "you@example.com"
   ```
2. Or provide author information manually when prompted

## Development

### Project Structure

```
plugin-quickstart-generator/
├── .claude-plugin/
│   └── plugin.json
├── commands/
│   └── quickstart-plugin.md
├── agents/
│   └── plugin-generator.md
├── README.md
├── LICENSE
├── CHANGELOG.md
└── .gitignore
```

### Local Testing

Test the generator itself:

```bash
# Create test marketplace for the generator
mkdir -p test-marketplace/.claude-plugin

# Add marketplace entry
cat > test-marketplace/.claude-plugin/marketplace.json <<'EOF'
{
  "name": "test",
  "owner": {"name": "Test User"},
  "plugins": [{
    "name": "plugin-quickstart-generator",
    "source": "../plugin-quickstart-generator",
    "description": "Test"
  }]
}
EOF

# Add and install
/plugin marketplace add ./test-marketplace
/plugin install plugin-quickstart-generator@test

# Test generation
/quickstart-plugin test-plugin development
```

### Contributing

Contributions to improve the generator are welcome! To contribute:

1. Fork the [OpenPlugins repository](https://github.com/dhofheinz/open-plugins)
2. Create a feature branch (`git checkout -b improve-generator`)
3. Make your changes
4. Test thoroughly with various plugin types
5. Update documentation if needed
6. Submit a pull request

See [CONTRIBUTING.md](https://github.com/dhofheinz/open-plugins/blob/main/CONTRIBUTING.md) for detailed guidelines.

### Reporting Issues

Found a bug or have a suggestion?

- **Bugs**: [Open an issue](https://github.com/dhofheinz/open-plugins/issues) with:
  - Description of the problem
  - Steps to reproduce
  - Expected vs. actual behavior
  - Your environment (OS, Claude Code version)

- **Feature Requests**: [Start a discussion](https://github.com/dhofheinz/open-plugins/discussions) with:
  - Use case description
  - Proposed functionality
  - Examples of how it would work

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history.

## License

MIT License - see [LICENSE](LICENSE) file for details.

This plugin is open-source and free to use, modify, and distribute. Contributions are welcome!

## Resources

### Documentation
- [Claude Code Plugin Documentation](https://docs.claude.com/en/docs/claude-code/plugins)
- [Plugin Reference Guide](https://docs.claude.com/en/docs/claude-code/plugins/plugins-reference)
- [Plugin Marketplaces Guide](https://docs.claude.com/en/docs/claude-code/plugins/plugin-marketplaces)

### OpenPlugins
- [OpenPlugins Repository](https://github.com/dhofheinz/open-plugins)
- [Contributing Guide](https://github.com/dhofheinz/open-plugins/blob/main/CONTRIBUTING.md)
- [Quick Start Guide](https://github.com/dhofheinz/open-plugins/blob/main/QUICK_START.md)

### Community
- [GitHub Discussions](https://github.com/dhofheinz/open-plugins/discussions)
- [GitHub Issues](https://github.com/dhofheinz/open-plugins/issues)

### Standards
- [Semantic Versioning](https://semver.org/)
- [Keep a Changelog](https://keepachangelog.com/)
- [Choose a License](https://choosealicense.com/)

## Support

### Getting Help

- **Documentation**: Start with this README and linked resources
- **Examples**: Review the [examples section](#examples) above
- **Troubleshooting**: Check the [troubleshooting section](#troubleshooting)
- **Community**: Ask in [GitHub Discussions](https://github.com/dhofheinz/open-plugins/discussions)
- **Issues**: Report bugs via [GitHub Issues](https://github.com/dhofheinz/open-plugins/issues)

### Frequently Asked Questions

**Q: Can I use this generator for private plugins?**
A: Yes! Generated plugins work in any marketplace (public, private, local, or team).

**Q: Can I modify generated templates?**
A: Absolutely! Templates are starting points. Customize to fit your needs.

**Q: Does this support hooks and MCP servers?**
A: Currently generates commands and agents. You can manually add hooks/MCP servers using the generated structure.

**Q: Can I generate multiple commands at once?**
A: The generator creates one template command. Add more commands by creating additional .md files in the commands/ directory.

**Q: What if my plugin doesn't fit OpenPlugins categories?**
A: Choose the closest category. Categories help discovery but don't limit functionality.

**Q: Can I change the license later?**
A: Yes, but be aware of legal implications. Consult legal advice for license changes.

**Q: How do I update my plugin version?**
A: Update version in plugin.json, add entry to CHANGELOG.md, tag with git, and submit updated marketplace entry.

---

**Made for [OpenPlugins](https://github.com/dhofheinz/open-plugins)** - Fostering a vibrant ecosystem of Claude Code plugins

**First Plugin in OpenPlugins** - Setting the standard for quality and ease of use
