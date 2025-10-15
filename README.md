# OpenPlugins - Community Claude Code Marketplace

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Plugins](https://img.shields.io/badge/plugins-4-blue.svg)](https://github.com/dhofheinz/open-plugins)
[![Contributions Welcome](https://img.shields.io/badge/contributions-welcome-brightgreen.svg)](CONTRIBUTING.md)

**OpenPlugins** is a AI-curated marketplace of high-quality, open-source plugins for [Claude Code](https://docs.claude.com/en/docs/claude-code). Our mission is to foster a vibrant ecosystem of productivity tools, development utilities, and specialized agents that extend Claude Code's capabilities.

## Overview

This marketplace provides carefully curated plugins across multiple categories:

- **Development Tools** - Code scaffolding, refactoring, and project setup utilities
- **Testing & Quality** - Test generation, coverage analysis, and code review tools
- **Deployment & DevOps** - CI/CD integration, infrastructure automation, and release management
- **Documentation** - API docs, README generation, and knowledge base tools
- **Security** - Vulnerability scanning, secret detection, and security auditing
- **Database** - Schema design, migration management, and query optimization
- **Monitoring & Observability** - Performance analysis and logging utilities
- **Productivity** - Workflow automation and task management
- **Collaboration** - Team coordination and communication tools

## Installation

### Adding the Marketplace

To add OpenPlugins marketplace to your Claude Code environment:

```bash
/plugin marketplace add dhofheinz/open-plugins
```

Or use the GitHub raw URL directly:

```bash
/plugin marketplace add https://raw.githubusercontent.com/dhofheinz/open-plugins/main/.claude-plugin/marketplace.json
```

### Installing Plugins

Once the marketplace is added, install any plugin with:

```bash
/plugin install <plugin-name>@open-plugins
```

Example:
```bash
/plugin install code-formatter@open-plugins
```

### Viewing Available Plugins

List all plugins in the marketplace:

```bash
/plugin marketplace list open-plugins
```

## Featured Plugins

> Note: OpenPlugins is newly launched. Featured plugins will be showcased here as the community grows.

<!--
Placeholder for featured plugins section:

### Essential Tools
- **plugin-name** - Brief description
- **plugin-name** - Brief description

### Popular Utilities
- **plugin-name** - Brief description
-->

## Plugin Quality Standards

All plugins in OpenPlugins meet rigorous quality criteria:

### Required Standards

- **Complete Metadata**: Valid `plugin.json` with all required fields (name, version, description, author, license)
- **Documentation**: Comprehensive README with usage examples and installation instructions
- **Semantic Versioning**: Strict adherence to [semver](https://semver.org/) (MAJOR.MINOR.PATCH)
- **License**: Open-source license (MIT, Apache 2.0, GPL, etc.)
- **Testing**: Evidence of testing (test instructions, examples, or test suite)
- **Security**: No hardcoded secrets, safe input handling, minimal permissions

### Recommended Standards

- **Changelog**: Maintain CHANGELOG.md following [Keep a Changelog](https://keepachangelog.com/)
- **Examples**: Include example use cases and command demonstrations
- **Error Handling**: Graceful error handling with helpful messages
- **Best Practices**: Follow [Claude Code plugin best practices](https://docs.claude.com/en/docs/claude-code/plugins)
- **Maintenance**: Active maintenance commitment with timely issue responses

### Categories

Plugins are organized into standard categories:

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

## Contributing Plugins

We welcome high-quality plugin contributions from the community!

### Submission Process

1. **Review Guidelines**: Read [CONTRIBUTING.md](CONTRIBUTING.md) for detailed submission requirements
2. **Prepare Your Plugin**: Ensure it meets all quality standards above
3. **Test Locally**: Verify plugin works correctly in Claude Code
4. **Open Pull Request**: Submit PR adding your plugin to `marketplace.json`
5. **Community Review**: Maintainers and community review your submission
6. **Approval & Merge**: Once approved, your plugin becomes available to all users

### Quick Submission Checklist

- [ ] Valid `plugin.json` with complete metadata
- [ ] Comprehensive README.md documentation
- [ ] Open-source license (MIT recommended)
- [ ] No security vulnerabilities or exposed secrets
- [ ] Tested in Claude Code environment
- [ ] Semantic version number
- [ ] PR follows [template](.github/PULL_REQUEST_TEMPLATE.md)

### Plugin Entry Format

Add your plugin to `marketplace.json` in this format:

```json
{
  "name": "your-plugin-name",
  "version": "1.0.0",
  "description": "Brief description of plugin functionality",
  "author": {
    "name": "Your Name",
    "email": "you@example.com",
    "url": "https://github.com/yourusername"
  },
  "source": "github:yourusername/your-plugin-repo",
  "license": "MIT",
  "keywords": ["keyword1", "keyword2", "keyword3"],
  "category": "development",
  "homepage": "https://github.com/yourusername/your-plugin-repo",
  "repository": {
    "type": "git",
    "url": "https://github.com/yourusername/your-plugin-repo"
  }
}
```

## Maintenance & Support

### Reporting Issues

- **Plugin-Specific Issues**: Report to the individual plugin repository
- **Marketplace Issues**: Open issue at [dhofheinz/open-plugins/issues](https://github.com/dhofheinz/open-plugins/issues)

### Community Support

- **Discussions**: Join conversations at [GitHub Discussions](https://github.com/dhofheinz/open-plugins/discussions)
- **Questions**: Ask in the Q&A section of Discussions
- **Feature Requests**: Submit enhancement ideas via Issues

### Plugin Deprecation Policy

Plugins may be deprecated if:
- Unmaintained for 6+ months with critical issues
- Security vulnerabilities remain unpatched
- Incompatible with current Claude Code versions
- Author requests removal

Deprecated plugins remain in marketplace for 90 days with deprecation notice before removal.

## Governance

OpenPlugins is community-driven with transparent governance:

- **Maintainers**: Volunteer maintainers review submissions and ensure quality
- **Decision Making**: Community input via Discussions, consensus-based decisions
- **Transparency**: All decisions documented in Issues/Discussions
- **Code of Conduct**: Respectful, inclusive community (see CODE_OF_CONDUCT.md)

## Resources

### Official Documentation
- [Claude Code Plugins Reference](https://docs.claude.com/en/docs/claude-code/plugins)
- [Plugin Marketplaces Guide](https://docs.claude.com/en/docs/claude-code/plugin-marketplaces)
- [Plugin Architecture Overview](https://docs.claude.com/en/docs/claude-code/plugins-reference)

### Community Resources
- [Example Plugins](https://github.com/anthropics/claude-code)
- [Plugin Development Guide](https://aitmpl.com/plugins)
- [Agent Examples](https://github.com/wshobson/agents)

### Tools
- [JSON Validator](https://jsonlint.com/)
- [Regex Tester](https://regex101.com/)
- [Semantic Versioning](https://semver.org/)

## Version History

See [CHANGELOG.md](CHANGELOG.md) for marketplace version history.

## License

This marketplace structure and documentation are released under the [MIT License](LICENSE).

Individual plugins have their own licenses - always check plugin documentation.

---

**Built with ❤️ by the Claude Code community**

[Add Plugin](CONTRIBUTING.md) | [Report Issue](https://github.com/dhofheinz/open-plugins/issues) | [Discussions](https://github.com/dhofheinz/open-plugins/discussions)
