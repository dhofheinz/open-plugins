# Plugin Addition: [Plugin Name]

## Plugin Information

**Plugin Name**:
**Version**:
**Author**:
**Category**:
**License**:
**Repository**:

## Description

<!-- Brief description of what this plugin does -->


## Changes Made

<!-- Describe the changes in this PR -->

- [ ] Added plugin entry to `marketplace.json`
- [ ] Verified JSON syntax is valid
- [ ] Plugin entry follows required format
- [ ] Category is appropriate
- [ ] Keywords are relevant

## Pre-Submission Checklist

### Plugin Requirements

- [ ] Plugin repository is public and accessible
- [ ] `plugin.json` exists with all required fields
- [ ] README.md is comprehensive with examples
- [ ] LICENSE file exists and is open-source
- [ ] No hardcoded secrets or credentials
- [ ] Plugin tested in Claude Code environment
- [ ] Semantic versioning used (MAJOR.MINOR.PATCH)

### Quality Standards

- [ ] Documentation includes installation instructions
- [ ] Documentation includes usage examples
- [ ] Error handling is implemented
- [ ] Input validation is performed
- [ ] No known security vulnerabilities
- [ ] Test instructions or test suite provided

### Marketplace Entry

- [ ] Plugin name uses lowercase-hyphen format
- [ ] Description is clear and concise (50-200 chars)
- [ ] Source format is correct (github:, https://, etc.)
- [ ] Category selected from approved list
- [ ] 3-7 relevant keywords included
- [ ] JSON syntax validated locally

### Testing

How did you test this plugin?

<!-- Describe your testing process -->

```bash
# Example test commands
/plugin marketplace add ./open-plugins
/plugin install plugin-name@open-plugins
# ... test functionality ...
```

## Validation Results

<!-- Show validation output -->

```bash
# JSON validation
cat .claude-plugin/marketplace.json | python3 -m json.tool

# Local testing results
# ...
```

## Plugin Entry JSON

<!-- Paste your plugin entry here for easy review -->

```json
{
  "name": "plugin-name",
  "version": "1.0.0",
  "description": "...",
  "author": {
    "name": "...",
    "email": "..."
  },
  "source": "github:username/repo",
  "license": "MIT",
  "keywords": ["..."],
  "category": "development"
}
```

## Maintenance Commitment

I commit to:

- [ ] Respond to critical issues within 2 weeks
- [ ] Keep plugin compatible with Claude Code
- [ ] Address security vulnerabilities promptly
- [ ] Update plugin version in marketplace when releasing updates
- [ ] Notify community if plugin becomes unmaintained

## Additional Notes

<!-- Any additional information for reviewers -->


---

## For Reviewers

- [ ] JSON syntax is valid
- [ ] Plugin entry follows schema
- [ ] Plugin repository is accessible
- [ ] Documentation is comprehensive
- [ ] Plugin works as described
- [ ] No security concerns
- [ ] Category and keywords appropriate
- [ ] Meets quality standards
