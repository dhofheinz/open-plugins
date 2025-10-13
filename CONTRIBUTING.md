# Contributing to OpenPlugins

Thank you for your interest in contributing to OpenPlugins! This guide will help you submit high-quality plugins to our community marketplace.

## Table of Contents

- [Before You Submit](#before-you-submit)
- [Plugin Requirements](#plugin-requirements)
- [Submission Process](#submission-process)
- [Plugin Entry Specification](#plugin-entry-specification)
- [Review Process](#review-process)
- [Post-Submission](#post-submission)
- [Maintenance Expectations](#maintenance-expectations)
- [Community Guidelines](#community-guidelines)

## Before You Submit

### Is Your Plugin Ready?

Ensure your plugin meets these prerequisites:

- [ ] Plugin is complete and functional
- [ ] Tested in Claude Code environment
- [ ] Documentation is comprehensive
- [ ] No known critical bugs
- [ ] License is open-source compatible
- [ ] No security vulnerabilities
- [ ] Ready for public distribution

### Choose the Right Marketplace

OpenPlugins focuses on:
- General-purpose development tools
- Widely applicable utilities
- Community-maintained plugins
- Open-source contributions

Consider other marketplaces if your plugin is:
- Company-specific or internal
- Requires paid services or API keys
- Highly specialized for niche use cases
- Not ready for public distribution

## Plugin Requirements

### Required Components

Your plugin repository MUST include:

1. **Plugin Manifest** (`.claude-plugin/plugin.json`)
   ```json
   {
     "name": "plugin-name",
     "version": "1.0.0",
     "description": "Clear, concise description",
     "author": {
       "name": "Your Name",
       "email": "you@example.com"
     },
     "license": "MIT"
   }
   ```

2. **README.md** with:
   - Plugin overview and purpose
   - Installation instructions
   - Usage examples
   - Configuration options (if any)
   - Troubleshooting guide
   - License information

3. **LICENSE** file
   - MIT, Apache 2.0, GPL, or other OSI-approved license

4. **At least one functional component**
   - Commands (`commands/*.md`)
   - Agents (`agents/*.md`)
   - Hooks (`hooks/hooks.json`)
   - MCP Servers (`.mcp.json`)

### Quality Standards

#### Metadata Completeness
- All required fields in `plugin.json`
- Meaningful description (not generic)
- Valid semantic version (MAJOR.MINOR.PATCH)
- Working repository URL
- Valid homepage URL

#### Documentation Quality
- Clear installation steps
- Concrete usage examples
- Parameter documentation
- Error handling guidance
- Contribution guidelines (if applicable)

#### Code Quality
- No hardcoded secrets or credentials
- Proper error handling
- Input validation
- Follows Claude Code best practices
- Minimal required permissions

#### Security Requirements
- No exposed API keys, tokens, or passwords
- Safe handling of user input
- HTTPS for external resources
- No suspicious or malicious code
- Dependencies from trusted sources

#### Testing Evidence
Provide ONE of:
- Test suite with instructions
- Manual test scenarios
- Example usage demonstrations
- Test results or screenshots

### Recommended Enhancements

These are not required but improve plugin quality:

- **CHANGELOG.md** - Version history following [Keep a Changelog](https://keepachangelog.com/)
- **Examples directory** - Sample configurations or use cases
- **Screenshots/GIFs** - Visual demonstrations
- **Badges** - License, version, status badges
- **Contributing guide** - For community contributions
- **.gitignore** - Proper Git exclusions

## Submission Process

### Step 1: Prepare Your Plugin

1. Clone your plugin repository locally
2. Test installation via local marketplace:
   ```bash
   # Create test marketplace
   mkdir test-marketplace/.claude-plugin
   # Add your plugin to test marketplace.json
   # Test installation
   /plugin marketplace add ./test-marketplace
   /plugin install your-plugin@test-marketplace
   ```

3. Verify all functionality works
4. Review against quality standards checklist

### Step 2: Fork OpenPlugins Repository

```bash
# Fork on GitHub, then clone
git clone https://github.com/YOUR-USERNAME/open-plugins.git
cd open-plugins
```

### Step 3: Add Your Plugin Entry

Edit `.claude-plugin/marketplace.json`:

```json
{
  "plugins": [
    // ... existing plugins ...
    {
      "name": "your-plugin-name",
      "version": "1.0.0",
      "description": "Brief but informative description of what your plugin does",
      "author": {
        "name": "Your Name",
        "email": "you@example.com",
        "url": "https://github.com/yourusername"
      },
      "source": "github:yourusername/your-plugin-repo",
      "license": "MIT",
      "keywords": [
        "relevant",
        "searchable",
        "keywords"
      ],
      "category": "development",
      "homepage": "https://github.com/yourusername/your-plugin-repo",
      "repository": {
        "type": "git",
        "url": "https://github.com/yourusername/your-plugin-repo"
      }
    }
  ]
}
```

**Important**:
- Add your entry to the END of the plugins array
- Maintain proper JSON formatting (commas, brackets)
- Use lowercase-hyphen naming (e.g., `code-formatter`)
- Choose appropriate category from list
- Include 3-7 relevant keywords

### Step 4: Validate Your Changes

```bash
# Validate JSON syntax
cat .claude-plugin/marketplace.json | python3 -m json.tool > /dev/null && echo "Valid JSON"

# Test locally
/plugin marketplace add ./
/plugin install your-plugin-name@open-plugins
```

### Step 5: Commit and Push

```bash
git checkout -b add-your-plugin-name
git add .claude-plugin/marketplace.json
git commit -m "feat: add your-plugin-name to marketplace

- Plugin purpose: Brief description
- Category: development
- License: MIT
- Tested: Yes
"
git push origin add-your-plugin-name
```

### Step 6: Create Pull Request

1. Go to your fork on GitHub
2. Click "Compare & pull request"
3. Fill out the PR template completely
4. Submit the pull request

## Plugin Entry Specification

### Required Fields

```json
{
  "name": "string",              // lowercase-hyphen format
  "version": "string",           // semver: MAJOR.MINOR.PATCH
  "description": "string",       // 50-200 characters
  "author": {
    "name": "string",            // Your name or organization
    "email": "string"            // Contact email
  },
  "source": "string",            // github:user/repo or URL
  "license": "string"            // OSI-approved license
}
```

### Optional But Recommended

```json
{
  "keywords": ["string"],        // 3-7 searchable terms
  "category": "string",          // From approved categories
  "homepage": "string",          // Plugin homepage URL
  "repository": {
    "type": "git",
    "url": "string"              // Git repository URL
  },
  "author": {
    "url": "string"              // Author's website/GitHub
  }
}
```

### Source Formats

Choose the appropriate source format:

- **GitHub**: `github:username/repo` (recommended)
- **GitLab**: `https://gitlab.com/user/repo.git`
- **Direct Git**: `https://git.example.com/repo.git`
- **ZIP Archive**: `https://example.com/plugin.zip`

### Categories

Select ONE category that best fits your plugin:

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

### Keywords

Include 3-7 relevant keywords:

**Good keywords**:
- Functionality-based: `testing`, `deployment`, `refactoring`
- Technology-based: `python`, `javascript`, `docker`
- Use-case-based: `automation`, `code-review`, `ci-cd`

**Avoid**:
- Generic terms: `plugin`, `tool`, `utility`
- Duplicate category names
- Marketing terms: `best`, `awesome`, `perfect`

## Review Process

### What We Review

1. **Compliance**: Meets all required standards
2. **Quality**: Code quality, documentation, testing
3. **Security**: No vulnerabilities or secrets
4. **Functionality**: Plugin works as described
5. **Uniqueness**: Not duplicating existing plugins
6. **Maintenance**: Evidence of ongoing support

### Review Timeline

- **Initial Review**: Within 5 business days
- **Follow-up**: 2-3 business days per iteration
- **Approval**: 1-2 business days after final approval

### Review Outcomes

- **Approved**: Merged and immediately available
- **Changes Requested**: Specific improvements needed
- **Needs Discussion**: Unclear aspects requiring clarification
- **Declined**: Does not meet standards (with explanation)

### Common Issues

- Incomplete or missing documentation
- Invalid JSON syntax in plugin.json
- Missing required metadata fields
- Security vulnerabilities
- Broken repository links
- License incompatibility
- Poor code quality
- Insufficient testing

## Post-Submission

### After Approval

Once merged:
1. Plugin becomes available in marketplace
2. Users can install with `/plugin install your-plugin@open-plugins`
3. Listed in marketplace catalog
4. Searchable by keywords

### Updating Your Plugin

To update plugin version:

1. Update plugin in your repository
2. Tag new version: `git tag v1.1.0`
3. Submit new PR updating version in marketplace.json
4. Include changelog in PR description

### Promoting Your Plugin

- Share in Claude Code communities
- Link to marketplace in your repository
- Include installation badge in README
- Announce in GitHub Discussions

## Maintenance Expectations

### Ongoing Responsibilities

As a plugin author, you commit to:

- **Respond to Issues**: Within 2 weeks for critical bugs
- **Update Dependencies**: Keep plugin compatible with Claude Code
- **Security Patches**: Address vulnerabilities promptly
- **Version Management**: Use semantic versioning correctly
- **Communication**: Notify if plugin becomes unmaintained

### Inactive Plugin Policy

Plugins may be marked deprecated if:
- No response to critical issues for 6+ months
- Incompatible with current Claude Code version
- Unpatched security vulnerabilities
- Author requests removal

Deprecated plugins remain 90 days before removal.

### Transferring Ownership

To transfer plugin ownership:
1. Open issue requesting transfer
2. Provide new maintainer contact
3. Update author field in plugin.json
4. Submit PR with changes

## Community Guidelines

### Code of Conduct

- Be respectful and inclusive
- Provide constructive feedback
- Welcome newcomers
- Focus on collaboration
- Assume good intentions

### Communication Channels

- **Pull Requests**: Plugin submissions and updates
- **Issues**: Bugs, improvements, marketplace issues
- **Discussions**: Questions, ideas, community chat

### Getting Help

Need assistance?
- Review [plugin documentation](https://docs.claude.com/en/docs/claude-code/plugins)
- Ask in [GitHub Discussions](https://github.com/dhofheinz/open-plugins/discussions)
- Check [existing issues](https://github.com/dhofheinz/open-plugins/issues)

---

## Quick Checklist

Before submitting, verify:

- [ ] Plugin repository is public and accessible
- [ ] `plugin.json` has all required fields
- [ ] README.md is comprehensive
- [ ] LICENSE file exists
- [ ] Plugin tested in Claude Code
- [ ] No security vulnerabilities
- [ ] JSON syntax is valid
- [ ] Category is appropriate
- [ ] Keywords are relevant
- [ ] PR template is complete

Ready? [Submit your plugin!](https://github.com/dhofheinz/open-plugins/compare)

---

**Questions?** Open a [Discussion](https://github.com/dhofheinz/open-plugins/discussions) or [Issue](https://github.com/dhofheinz/open-plugins/issues).
