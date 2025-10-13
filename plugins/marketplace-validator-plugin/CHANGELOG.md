# Changelog

All notable changes to the Marketplace Validator Plugin will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-10-12

### Added

#### Commands
- `/validate-marketplace` - Comprehensive marketplace.json validation with quality scoring
- `/validate-plugin` - Full plugin validation with structure and component checks
- `/validate-quick` - Fast essential checks for CI/CD pipelines

#### Agent
- `marketplace-validator` - Proactive validation agent with automatic activation
  - Schema validation and compliance checking
  - Quality assessment with 0-100 scoring
  - Security scanning for vulnerabilities
  - Actionable recommendations with examples

#### Hooks
- Automatic validation on marketplace.json edits (PostToolUse)
- Automatic validation on plugin.json edits (PostToolUse)
- Non-blocking warnings with immediate feedback

#### Validation Features
- JSON syntax validation with detailed error reporting
- Required field verification (marketplace and plugin)
- Semantic versioning compliance checks
- Naming convention validation (lowercase-hyphen)
- Email and URL format validation
- Category validation (10 standard categories)
- Keywords validation (3-7 recommended)
- Source format validation (github:, URLs, paths)
- License identifier validation (SPDX)

#### Quality Scoring
- 0-100 point quality scoring system
- Five-tier rating scale (Excellent, Good, Fair, Needs Improvement, Poor)
- Star ratings (⭐⭐⭐⭐⭐)
- Detailed breakdown of issues and recommendations

#### Security Features
- Exposed secret detection (API keys, tokens, passwords)
- Malicious URL pattern detection
- .env file warnings
- File permission checks for hook scripts
- HTTPS preference enforcement

#### Scripts
- `validate-lib.sh` - Shared validation library with reusable functions
- `validate-marketplace-full.sh` - Comprehensive marketplace validation
- `validate-plugin-full.sh` - Comprehensive plugin validation
- `validate-marketplace-quick.sh` - Fast marketplace checks
- `validate-plugin-quick.sh` - Fast plugin checks
- `auto-validate-marketplace.sh` - Marketplace hook handler
- `auto-validate-plugin.sh` - Plugin hook handler

#### Documentation
- Comprehensive README with usage examples
- Installation instructions for multiple methods
- Detailed validation rules and standards
- CI/CD integration examples
- Troubleshooting guide
- Quality scoring system documentation

### Quality Standards
- All required OpenPlugins standards met
- Comprehensive README (>14,000 characters)
- MIT License included
- CHANGELOG following Keep a Changelog format
- Full test coverage for validation rules
- Security scanning enabled
- Hooks configured and tested

### Technical Details
- Multi-backend JSON parsing (jq, python3)
- Graceful degradation for missing tools
- Color-coded output for readability
- Exit codes for CI/CD integration
- Non-blocking hook execution
- CLAUDE_PLUGIN_ROOT variable support
- Cross-platform compatibility (Linux, macOS)

### Validation Coverage
- **Marketplace**: 15+ validation rules
- **Plugin**: 20+ validation rules
- **Security**: 8+ security checks
- **Quality**: 10+ quality criteria

[1.0.0]: https://github.com/dhofheinz/open-plugins/releases/tag/marketplace-validator-plugin-v1.0.0
