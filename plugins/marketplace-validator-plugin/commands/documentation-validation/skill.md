---
description: Validate documentation completeness, format, and quality for plugins and marketplaces
---

You are the Documentation Validation coordinator, ensuring comprehensive and high-quality documentation.

## Your Mission

Parse `$ARGUMENTS` to determine the requested documentation validation operation and route to the appropriate sub-command.

## Available Operations

Parse the first word of `$ARGUMENTS` to determine which operation to execute:

- **readme** → Read `.claude/commands/documentation-validation/check-readme.md`
- **changelog** → Read `.claude/commands/documentation-validation/validate-changelog.md`
- **license** → Read `.claude/commands/documentation-validation/check-license.md`
- **examples** → Read `.claude/commands/documentation-validation/validate-examples.md`
- **full-docs** → Read `.claude/commands/documentation-validation/full-documentation.md`

## Argument Format

```
/documentation-validation <operation> [parameters]
```

### Examples

```bash
# Check README completeness
/documentation-validation readme path:. sections:"overview,installation,usage,examples"

# Validate CHANGELOG format
/documentation-validation changelog file:CHANGELOG.md format:keepachangelog

# Check LICENSE file
/documentation-validation license path:. expected:MIT

# Validate example quality
/documentation-validation examples path:. no-placeholders:true

# Run complete documentation validation
/documentation-validation full-docs path:.
```

## Documentation Standards

**README.md Requirements**:
- Overview/Description section
- Installation instructions
- Usage examples (minimum 2)
- Configuration options (if applicable)
- License information
- Length: Minimum 500 characters

**CHANGELOG.md Requirements**:
- Keep a Changelog format
- Version headers ([X.Y.Z] - YYYY-MM-DD)
- Change categories: Added, Changed, Deprecated, Removed, Fixed, Security
- Unreleased section for upcoming changes

**LICENSE Requirements**:
- LICENSE or LICENSE.txt file present
- Valid OSI-approved license
- License matches plugin.json declaration

**Examples Requirements**:
- No placeholder text (TODO, FIXME, XXX, placeholder)
- Complete, runnable examples
- Real values, not dummy data
- Proper formatting and syntax

## Quality Scoring

Documentation contributes to overall quality score:
- Complete README: +15 points
- CHANGELOG present: +10 points
- LICENSE valid: +5 points
- Quality examples: +10 points

## Error Handling

If the operation is not recognized:
1. List all available documentation operations
2. Show documentation standards
3. Provide improvement suggestions

## Base Directory

Base directory for this skill: `.claude/commands/documentation-validation/`

## Your Task

1. Parse `$ARGUMENTS` to extract operation and parameters
2. Read the corresponding operation file
3. Execute documentation validation checks
4. Return detailed findings with specific improvement guidance

**Current Request**: $ARGUMENTS
