---
description: Validate plugins against OpenPlugins quality standards with security scanning and documentation checks
---

# Plugin Quality Assurance Skill

Comprehensive quality validation for Claude Code plugins ensuring OpenPlugins marketplace standards.

## Operations

- **security** - Scan for hardcoded secrets and unsafe practices
- **docs** - Validate README completeness and documentation quality
- **structure** - Validate directory structure and file organization
- **metadata** - Lint JSON and frontmatter validation
- **full-audit** - Run complete quality audit with scoring

## Usage Examples

```bash
# Security scan
/plugin-quality security plugin:my-plugin

# Documentation check
/plugin-quality docs plugin:my-plugin

# Structure validation
/plugin-quality structure plugin:my-plugin

# Metadata validation
/plugin-quality metadata plugin:my-plugin

# Full quality audit
/plugin-quality full-audit plugin:my-plugin
```

## Router Logic

Parse operation from $ARGUMENTS and route to appropriate instruction file:
- "security" → `{plugin-path}/commands/plugin-quality/check-security.md`
- "docs" → `{plugin-path}/commands/plugin-quality/validate-documentation.md`
- "structure" → `{plugin-path}/commands/plugin-quality/check-structure.md`
- "metadata" → `{plugin-path}/commands/plugin-quality/lint-metadata.md`
- "full-audit" → `{plugin-path}/commands/plugin-quality/full-audit.md`

**Current request**: $ARGUMENTS
