# Mode: init

**Purpose:** Bootstrap project conventions — discover existing structure, create the working directory, generate template and convention files. First-run setup.

## Inputs

- Project root (current working directory)
- Optional `--output-dir <path>` flag to override the default working directory
- `${user_config.working_directory}` (if set; honored before the built-in default)

## Procedure

### Phase 1: Discover existing conventions

Scan the project for existing spec-like directories and pre-existing artifacts:

- Glob: `docs/specs/`, `docs/spec/`, `specs/`, `spec/`, `docs/refinery/`, `docs/refining/`, `requirements/`, `architecture/`
- Read any existing `_conventions.md`, `_glossary.md`, `README.md` in those directories
- Sample 1–3 existing artifacts (if any) to detect format conventions (frontmatter style, section structure, ID conventions)
- Glob source files (`src/**/*`, `lib/**/*`, `*.py`, `*.go`, `*.ts`, `*.tsx`, `*.rs`, etc.) at depth 3 to detect domain terminology — collect top-frequency nouns from filenames and directory names

If no source files exist, mark project as **greenfield** (this affects later stages).

### Phase 2: Decide working directory

Resolution order:

1. `--output-dir` flag → use it
2. `${user_config.working_directory}` → use it
3. If `docs/refinery/` already exists → use it (warn if non-empty)
4. If `docs/specs/` exists with compatible artifacts (have frontmatter with an `artifact:` field) → AskUserQuestion: "Coexist with existing docs/specs/ (default), use docs/specs/ as primary working directory, or create a new docs/refinery/?"
5. Otherwise → default to `docs/refinery/`

### Phase 3: Create directory structure

Ensure the resolved working directory exists. Ensure `<working-dir>/_templates/` exists.

If the directory was just created, report it. If it pre-existed, report it as "already present" with a count of any pre-existing `*.md` files.

### Phase 4: Generate convention files

If `<working-dir>/_conventions.md` does not exist:

- Read template from `${CLAUDE_SKILL_DIR}/templates/_conventions.md`
- Customize for detected project conventions (file naming style, indent style, programming language, framework hints from Phase 1's source-file scan)
- Write to `<working-dir>/_conventions.md`

If `<working-dir>/_glossary.md` does not exist:

- Read template from `${CLAUDE_SKILL_DIR}/templates/_glossary.md`
- Pre-populate with the top 10–20 domain terms discovered in Phase 1 (with empty `Definition` columns the user/spec-writer will fill later)
- Write to `<working-dir>/_glossary.md`

If either file already exists and the user chose "coexist" in Phase 2, **do not overwrite**. Report the existing files and their last-modified dates.

### Phase 5: Generate templates

Copy each artifact template to `<working-dir>/_templates/`:

- `principles.md`, `design.md`, `stack.md`, `spec.md`, `feature-spec.md`, `plan.md`, `tickets.md`

Copy from `${CLAUDE_SKILL_DIR}/templates/<name>.md` only if the destination file does not already exist (preserve user customizations).

### Phase 6: Verify

Validate the resulting working directory:

- All required template files present in `_templates/`
- `_conventions.md` and `_glossary.md` exist
- Working directory is writable

If any check fails, report and suggest remediation.

### Phase 7: Report

Report what was created (terse format):

```
[Refinery] init complete.
[Refinery] Working directory: <path>
[Refinery]   _conventions.md: <created | exists | customized>
[Refinery]   _glossary.md: <created | exists> (<N> terms pre-populated)
[Refinery]   _templates/: <N templates created | already present>
[Refinery] Project type: <greenfield | brownfield (<lang>, <framework hint>)>

Suggested next:
  /refine "<your idea>"               (start a new system pipeline)
  /refine <feature-name>              (document an existing feature)
  /refine status                      (view current state)
```

In `--verbose` mode, additionally print:

- Discovered domain terms
- Detected conventions (naming style, indent, etc.)
- Path to the user-config–resolved working directory and which precedence rule won

## Edge Cases

- **Working directory exists with non-Refinery artifacts:** Treat as coexistence. Don't overwrite anything not under `_templates/`, `_conventions.md`, or `_glossary.md`.
- **Working directory is a symlink:** Follow the symlink; warn the user.
- **No write permissions:** Report and refuse; suggest `chmod` or a different `--output-dir`.
- **Multiple existing spec directories** (e.g., both `docs/specs/` and `specs/`): AskUserQuestion to disambiguate.
- **`init` invoked when directory is already initialized:** Report "already initialized" with current file inventory; offer `--force` only if the user is explicit (and even then, never overwrite `_conventions.md` or `_glossary.md` without confirmation).

## Commit Hint

After successful init, suggest a commit (per `${CLAUDE_SKILL_DIR}/references/commit-protocol.md`):

```
spec: init refinery working directory

Created <working-dir>/ with _conventions.md, _glossary.md (<N> terms),
and 7 artifact templates.

Refinery-Op: init
```
