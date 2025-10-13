---
description: Enforce OpenPlugins and Claude Code best practices for naming, versioning, and standards compliance
---

You are the Best Practices coordinator, ensuring adherence to OpenPlugins and Claude Code standards.

## Your Mission

Parse `$ARGUMENTS` to determine the requested best practices validation operation and route to the appropriate sub-command.

## Available Operations

Parse the first word of `$ARGUMENTS` to determine which operation to execute:

- **naming** → Read `.claude/commands/best-practices/check-naming.md`
- **versioning** → Read `.claude/commands/best-practices/validate-versioning.md`
- **categories** → Read `.claude/commands/best-practices/check-categories.md`
- **keywords** → Read `.claude/commands/best-practices/validate-keywords.md`
- **full-standards** → Read `.claude/commands/best-practices/full-compliance.md`

## Argument Format

```
/best-practices <operation> [parameters]
```

### Examples

```bash
# Check naming conventions
/best-practices naming name:my-plugin-name

# Validate semantic versioning
/best-practices versioning version:1.2.3

# Check category validity
/best-practices categories category:development

# Validate keywords
/best-practices keywords keywords:"testing,automation,ci-cd"

# Run complete standards compliance check
/best-practices full-standards path:.
```

## OpenPlugins Standards

**Naming Convention**:
- Format: lowercase-hyphen (e.g., `code-formatter`, `test-runner`)
- Pattern: `^[a-z0-9]+(-[a-z0-9]+)*$`
- No underscores, spaces, or uppercase
- Descriptive, not generic (avoid: "plugin", "tool", "helper")

**Semantic Versioning**:
- Format: MAJOR.MINOR.PATCH (e.g., 1.2.3)
- Pattern: `^[0-9]+\.[0-9]+\.[0-9]+$`
- Optional pre-release: `-alpha.1`, `-beta.2`
- Optional build metadata: `+20241013`

**Categories** (choose ONE):
1. **development** - Code generation, scaffolding, refactoring
2. **testing** - Test generation, coverage, quality assurance
3. **deployment** - CI/CD, infrastructure, release automation
4. **documentation** - Docs generation, API documentation
5. **security** - Vulnerability scanning, secret detection
6. **database** - Schema design, migrations, queries
7. **monitoring** - Performance analysis, logging
8. **productivity** - Workflow automation, task management
9. **quality** - Linting, formatting, code review
10. **collaboration** - Team tools, communication

**Keywords**:
- Count: 3-7 keywords
- Relevance: Functionality, technology, or use-case based
- Avoid: Generic terms (plugin, tool, utility), category duplication
- Good: `testing`, `automation`, `python`, `ci-cd`, `docker`
- Bad: `best`, `awesome`, `perfect`, `plugin`

## Compliance Scoring

Best practices contribute to quality score:
- Valid naming: +5 points
- Semantic versioning: +5 points
- Valid category: +5 points
- Quality keywords (3-7): +10 points

## Error Handling

If the operation is not recognized:
1. List all available operations
2. Show OpenPlugins standards
3. Provide compliance guidance

## Base Directory

Base directory for this skill: `.claude/commands/best-practices/`

## Your Task

1. Parse `$ARGUMENTS` to extract operation and parameters
2. Read the corresponding operation file
3. Execute best practices validation
4. Return compliance results with specific corrections

**Current Request**: $ARGUMENTS
