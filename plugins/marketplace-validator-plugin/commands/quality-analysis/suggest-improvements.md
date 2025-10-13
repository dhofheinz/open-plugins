## Operation: Suggest Improvements

Generate actionable improvement suggestions based on current quality score with effort estimates and expected impact.

### Parameters from $ARGUMENTS

Extract these parameters from `$ARGUMENTS`:

- **path**: Target path to analyze (required)
- **score**: Current quality score (required)
- **target**: Target score to achieve (default: 90)
- **context**: Path to validation context JSON file (optional)

### Improvement Suggestion Algorithm

```
gap = target_score - current_score
improvements_needed = ceiling(gap / 5)  # Approximate improvements needed

FOR each validation layer:
  IF layer has issues:
    Generate specific, actionable improvements
    Estimate score impact (+points)
    Assign priority based on blocking status and impact
    Estimate effort (low/medium/high)

SORT by:
  1. Priority (P0 first)
  2. Score impact (highest first)
  3. Effort (lowest first - quick wins)

LIMIT to top 10 most impactful improvements
```

### Workflow

1. **Calculate Score Gap**
   ```
   gap = target - current_score

   IF gap <= 0:
     Return "Already at or above target!"

   IF gap <= 5:
     Focus on quick wins (low effort, high impact)

   IF gap > 20:
     Focus on critical issues first
   ```

2. **Analyze Validation Context**
   ```
   IF context provided:
     Load validation results from JSON file
     Extract issues from each layer:
     - Schema validation issues
     - Security scan findings
     - Documentation gaps
     - Best practices violations

   Categorize by:
   - Severity (P0/P1/P2)
   - Score impact
   - Effort required
   ```

3. **Generate Improvement Suggestions**
   ```
   For each issue, create suggestion:
   - Title (brief, actionable)
   - Score impact (+X points)
   - Priority (High/Medium/Low)
   - Effort estimate with time
   - Detailed fix instructions
   - Expected outcome

   Sort by effectiveness:
   effectiveness = score_impact / effort_hours
   ```

4. **Create Improvement Roadmap**
   ```
   Group suggestions into phases:
   - Quick Wins (< 30 min, +5-15 pts)
   - This Week (< 2 hours, +10-20 pts)
   - This Sprint (< 1 day, +20+ pts)

   Calculate cumulative score after each phase
   ```

### Examples

```bash
# Get improvements for low score
/quality-analysis improve path:. score:65

# Target excellent status
/quality-analysis improve path:. score:78 target:95

# Use validation context for detailed suggestions
/quality-analysis improve path:. score:70 context:"@validation-results.json"
```

### Error Handling

- **Missing score**: Request current score or run calculate-score first
- **Invalid score range**: Score must be 0-100
- **Invalid target**: Target must be higher than current score
- **Context file not found**: Continue with basic suggestions
- **No improvements possible**: Congratulate on perfect score

### Output Format

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
IMPROVEMENT RECOMMENDATIONS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Current Score: 65/100 ⭐⭐⭐ (Fair)
Target Score: 90/100 ⭐⭐⭐⭐⭐ (Excellent)
Gap: 25 points

To reach your target, implement these improvements:

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
QUICK WINS (Total: +15 pts, 45 minutes)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. [+10 pts] Add CHANGELOG.md with version history
   Priority: High
   Effort: Low (15 minutes)
   Impact: Improves version tracking and transparency

   HOW TO FIX:
   ```bash
   cat > CHANGELOG.md <<'EOF'
   # Changelog

   All notable changes to this project will be documented in this file.

   ## [1.0.0] - 2025-10-13
   ### Added
   - Initial release
   - Core functionality
   EOF
   ```

   WHY IT MATTERS:
   Users need to track changes between versions. CHANGELOG.md is a
   best practice for professional plugins.

2. [+3 pts] Add 2 more relevant keywords to plugin.json
   Priority: Medium
   Effort: Low (5 minutes)
   Impact: Improved discoverability in marketplace

   HOW TO FIX:
   ```json
   {
     "keywords": ["existing", "keywords", "automation", "workflow"]
   }
   ```

   SUGGESTION: Based on your plugin's functionality, consider:
   - "automation" (if you automate tasks)
   - "productivity" (if you improve efficiency)
   - "validation" (if you validate data)

3. [+2 pts] Add repository URL to plugin.json
   Priority: Medium
   Effort: Low (2 minutes)
   Impact: Users can view source and report issues

   HOW TO FIX:
   ```json
   {
     "repository": {
       "type": "git",
       "url": "https://github.com/username/plugin-name"
     }
   }
   ```

After Quick Wins: 80/100 ⭐⭐⭐⭐ (Good)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
THIS WEEK (Total: +12 pts, 90 minutes)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

4. [+5 pts] Expand README with 3 more usage examples
   Priority: Medium
   Effort: Medium (30 minutes)
   Impact: Better user onboarding and adoption

   HOW TO FIX:
   Add examples showing:
   - Basic usage (simple case)
   - Advanced usage (complex scenario)
   - Common workflows (real-world use)
   - Error handling (what to do when things fail)

   TEMPLATE:
   ```markdown
   ## Examples

   ### Basic Usage
   /your-command simple-task

   ### Advanced Usage
   /your-command complex-task param:value

   ### Common Workflow
   1. /your-command init
   2. /your-command process
   3. /your-command finalize
   ```

5. [+5 pts] Add homepage URL to plugin.json
   Priority: Low
   Effort: Low (5 minutes)
   Impact: Professional appearance, marketing

   HOW TO FIX:
   ```json
   {
     "homepage": "https://your-plugin-docs.com"
   }
   ```

6. [+2 pts] Improve description in plugin.json
   Priority: Low
   Effort: Medium (10 minutes)
   Impact: Better first impression in marketplace

   HOW TO FIX:
   Make description:
   - Concise (1-2 sentences)
   - Action-oriented (starts with verb)
   - Benefit-focused (what user gains)

   BEFORE: "A plugin for validation"
   AFTER: "Automatically validate your code quality with comprehensive
   checks for security, performance, and best practices"

After This Week: 92/100 ⭐⭐⭐⭐⭐ (Excellent)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
SUMMARY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Path to Excellence:
- Start with Quick Wins (45 min) → 80/100 ⭐⭐⭐⭐
- Complete This Week items (90 min) → 92/100 ⭐⭐⭐⭐⭐
- Total effort: 2 hours 15 minutes
- Total improvement: +27 points

Priority Order:
1. Fix P0 blockers (none currently)
2. Implement quick wins for fast progress
3. Address documentation improvements
4. Polish with recommended enhancements

Your plugin will be publication-ready after Quick Wins!
Excellence status achievable within one week.
```

### Improvement Categories

**Documentation**
- Add/expand README
- Create CHANGELOG.md
- Add LICENSE file
- Include usage examples
- Add architecture documentation

**Metadata**
- Add repository URL
- Add homepage URL
- Expand keywords (3-7 recommended)
- Improve description
- Add author details

**Code Quality**
- Fix naming conventions
- Improve error handling
- Add input validation
- Optimize performance
- Remove code smells

**Security**
- Remove exposed secrets
- Validate user input
- Use HTTPS for all URLs
- Set correct file permissions
- Add security documentation

**Best Practices**
- Follow semantic versioning
- Use lowercase-hyphen naming
- Select appropriate category
- Include test coverage
- Add CI/CD configuration

### Integration Notes

This operation is invoked by:
- `full-analysis.md` to provide actionable next steps
- `validation-orchestrator` after comprehensive validation
- Direct user invocation for improvement planning

Suggestions are based on:
- Current quality score and target
- Validation layer findings
- Industry best practices
- Effort vs impact analysis

**Request**: $ARGUMENTS
