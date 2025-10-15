---
description: Comprehensive code review with specialized focus areas (security, performance, quality, accessibility, PRs)
---

# Code Review Skill Router

Orchestrates comprehensive code reviews with specialized operations for different focus areas and review types.

## Available Operations

- **full** - Comprehensive review covering all categories (security, performance, quality, architecture, a11y)
- **security** - Security-focused review (auth, validation, injection, dependencies, OWASP Top 10)
- **performance** - Performance-focused review (database, backend, frontend, network optimization)
- **quality** - Code quality review (organization, patterns, testing, documentation)
- **pr** - Pull request review with git integration and change analysis
- **accessibility** - Accessibility review (a11y, ARIA, keyboard nav, screen readers)

## Argument Format

Expected: `operation [scope:"..."] [depth:"quick|standard|deep"] [focus:"..."]`

Examples:
```
/review full scope:"src/auth module" depth:"deep"
/review security scope:"payment processing" depth:"deep"
/review performance scope:"dashboard component" depth:"standard"
/review quality scope:"src/utils" depth:"quick"
/review pr scope:"PR #123" depth:"standard"
/review accessibility scope:"checkout flow" depth:"deep"
```

## Routing Logic

Parse $ARGUMENTS to extract:
1. **Operation** (first word): Determines review type
2. **Scope**: What to review (files, modules, features, PR)
3. **Depth**: Review thoroughness (quick/standard/deep)
4. **Focus**: Additional focus areas (optional)

**Router Implementation:**

```
Request: $ARGUMENTS
Base directory: /home/danie/projects/plugins/architect/open-plugins/plugins/10x-fullstack-engineer/commands/review
```

### Routing Table

| Operation | Instruction File | Purpose |
|-----------|-----------------|---------|
| full | review/full.md | Comprehensive review (all categories) |
| security | review/security.md | Security-focused review |
| performance | review/performance.md | Performance-focused review |
| quality | review/quality.md | Code quality review |
| pr | review/pr.md | Pull request review |
| accessibility | review/accessibility.md | Accessibility review |

### Execution Flow

1. **Parse Arguments**:
   - Extract operation name (first word)
   - Extract remaining parameters (scope, depth, focus)
   - Validate operation is recognized

2. **Route to Operation**:
   - Read corresponding .md file from review/ directory
   - Pass remaining arguments to operation
   - Execute review workflow

3. **Error Handling**:
   - Unknown operation → List available operations with descriptions
   - Missing scope → Request scope specification
   - Invalid depth → Default to "standard"

### Example Routing

**Input**: `/review security scope:"auth module" depth:"deep"`
- Operation: `security`
- Route to: `review/security.md`
- Parameters: `scope:"auth module" depth:"deep"`

**Input**: `/review pr scope:"PR #456"`
- Operation: `pr`
- Route to: `review/pr.md`
- Parameters: `scope:"PR #456" depth:"standard"` (default depth)

**Input**: `/review unknown`
- Error: Unknown operation
- Response: List available operations with usage examples

## Review Depth Levels

All operations support three depth levels:

**Quick** (5-10 minutes):
- High-level code scan
- Critical issues only
- Obvious bugs and anti-patterns
- Major concerns in focus area

**Standard** (20-30 minutes):
- Thorough review
- All major categories covered
- Testing and documentation check
- Moderate depth per area

**Deep** (45-60+ minutes):
- Comprehensive analysis
- All categories in detail
- Architecture and design patterns
- Scalability considerations
- Complete audit in focus area

## Common Parameters

All review operations accept:

- **scope**: What to review (required)
  - Examples: "PR #123", "src/auth", "payment feature", "recent changes"

- **depth**: Review thoroughness (optional, default: "standard")
  - Values: "quick", "standard", "deep"

- **focus**: Additional areas to emphasize (optional)
  - Examples: "security", "performance", "testing", "documentation"

## Usage Examples

**Comprehensive Review**:
```bash
/review full scope:"authentication feature" depth:"deep"
```

**Security Audit**:
```bash
/review security scope:"payment processing module" depth:"deep"
```

**Performance Analysis**:
```bash
/review performance scope:"dashboard rendering" depth:"standard"
```

**Code Quality Check**:
```bash
/review quality scope:"src/utils" depth:"quick"
```

**Pull Request Review**:
```bash
/review pr scope:"PR #789 - Add user permissions" depth:"standard"
```

**Accessibility Review**:
```bash
/review accessibility scope:"checkout flow" depth:"deep"
```

## Agent Integration

All review operations leverage the **10x-fullstack-engineer** agent for:
- Cross-stack expertise
- Pattern recognition
- Best practices knowledge
- Constructive feedback
- Architectural understanding

## Now Execute

**Received Request**: `$ARGUMENTS`

1. Parse the operation from the first word
2. Read the corresponding instruction file from `review/` directory
3. Pass remaining arguments to the operation
4. Execute the review workflow
5. Provide structured feedback

If operation is unrecognized, list available operations with examples.
