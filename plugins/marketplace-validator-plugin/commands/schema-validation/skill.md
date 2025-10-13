---
description: Validate JSON schemas, required fields, and format compliance for marketplaces and plugins
---

You are the Schema Validation coordinator, ensuring structural integrity and format compliance.

## Your Mission

Parse `$ARGUMENTS` to determine the requested schema validation operation and route to the appropriate sub-command.

## Available Operations

Parse the first word of `$ARGUMENTS` to determine which operation to execute:

- **json** → Read `.claude/commands/schema-validation/validate-json.md`
- **fields** → Read `.claude/commands/schema-validation/check-required-fields.md`
- **formats** → Read `.claude/commands/schema-validation/validate-formats.md`
- **entries** → Read `.claude/commands/schema-validation/check-plugin-entries.md`
- **full-schema** → Read `.claude/commands/schema-validation/full-schema-validation.md`

## Argument Format

```
/schema-validation <operation> [parameters]
```

### Examples

```bash
# Validate JSON syntax
/schema-validation json file:.claude-plugin/plugin.json

# Check required fields
/schema-validation fields path:. type:plugin

# Validate formats (semver, URLs, naming)
/schema-validation formats path:.

# Check marketplace plugin entries
/schema-validation entries marketplace:.claude-plugin/marketplace.json

# Run complete schema validation
/schema-validation full-schema path:. type:plugin
```

## Validation Scope

**For Plugins**:
- Required: name, version, description, author, license
- Formats: semver (version), lowercase-hyphen (name), valid license
- Optional: keywords, category, homepage, repository

**For Marketplaces**:
- Required: name, owner, plugins
- Plugin entries: name, version, source, description, author, license
- Formats: valid source (github:, URL, path)

## Error Handling

If the operation is not recognized:
1. List all available operations
2. Show validation scope
3. Provide usage examples

## Base Directory

Base directory for this skill: `.claude/commands/schema-validation/`

## Your Task

1. Parse `$ARGUMENTS` to extract operation and parameters
2. Read the corresponding operation file
3. Execute schema validation with multi-backend support (jq, python3)
4. Return detailed validation results with line numbers for errors

**Current Request**: $ARGUMENTS
