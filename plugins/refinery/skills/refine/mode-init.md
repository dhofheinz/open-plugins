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

**Record canonical locations.** For each of (`_conventions.md`, `_glossary.md`), record the first matching path found in the scan as a **candidate canonical** for pointer-mode coexistence in Phase 4:

```
detected_canonicals = {
  glossary:    <first _glossary.md path found, or null>,
  conventions: <first _conventions.md path found, or null>,
}
```

Skip files that are already pointer files (frontmatter has `pointer: true`) — they resolve via their own `canonical:` field and must not be followed recursively.

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

The decision for each of (`_conventions.md`, `_glossary.md`) follows this precedence:

1. **Target file already exists in working directory** → do nothing. Report the existing file and its last-modified date. (Never overwrite user files without an explicit `--force` and confirmation, per Phase 6 edge cases.)
2. **User chose "coexist" in Phase 2 AND a canonical exists elsewhere** (i.e., `detected_canonicals.<kind>` from Phase 1 is set AND its path is outside the working directory) → **write a pointer file** pointing to the canonical. See §"Pointer Files" below for the format. Rationale: avoid fragmenting the glossary/conventions across directories; the canonical stays the single source of truth.
3. **Otherwise** → generate a full file from the template:
   - For `_conventions.md`: read `${CLAUDE_SKILL_DIR}/templates/_conventions.md`; customize for detected project conventions (file naming style, indent style, programming language, framework hints from Phase 1's source-file scan); write to `<working-dir>/_conventions.md`.
   - For `_glossary.md`: read `${CLAUDE_SKILL_DIR}/templates/_glossary.md`; pre-populate with the top 10–20 domain terms discovered in Phase 1 (with empty `Definition` columns); write to `<working-dir>/_glossary.md`.

#### Pointer Files

A **pointer file** is a stub that tells Refinery agents where the canonical `_conventions.md` or `_glossary.md` actually lives. It avoids the fragmentation problem where coexist mode otherwise creates parallel-but-drifting files in `docs/refinery/` and `docs/specs/`.

Write the pointer file to `<working-dir>/<kind>.md` (where `<kind>` is `_conventions` or `_glossary`) with this content:

```markdown
---
pointer: true
kind: <glossary|conventions>
canonical: <relative path to canonical file, from this file's directory>
generated_by: refinery init
---

# <Glossary|Conventions> (pointer)

**This file is a pointer.** The canonical <glossary|conventions> for this project lives at:

[`<canonical path>`](<canonical path>)

Refinery agents (`spec-writer`, `spec-critic`, `code-archaeologist`) MUST read the canonical file when reasoning about domain terminology or writing conventions. Do not add entries here — edit the canonical file directly, and all consumers will see the change.

To migrate away from the pointer pattern, copy the canonical file's contents over this file (replacing this pointer) and update downstream references.
```

Pointer file invariants:

- `pointer: true` — distinguishes from a normal convention/glossary file. `references/state-detection.md §2` already skips non-`artifact:` frontmatter; pointers inherit that skip.
- `canonical` — path relative to the pointer file's own directory, not to project root. Resolve via normal `Read` from the pointer's parent.
- `kind` — one of `glossary`, `conventions`. Used to validate agent-side consumption.
- Agents must **not** recurse on pointers: if the canonical path resolves to another file that is itself a pointer, abort with an error rather than following further. This protects against accidental cycles.

Pointer files are not Refinery artifacts (no `artifact:` field); they are infrastructure. `/refine init --force` may overwrite an existing pointer (to regenerate after the canonical moved); never silently overwrite a non-pointer file.

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
[Refinery]   _conventions.md: <created | pointer → <canonical> | exists | customized>
[Refinery]   _glossary.md: <created | pointer → <canonical> | exists> (<N> terms pre-populated, if created)
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
- **Existing pointer file in working directory:** treat as "already initialized" for that kind; do not overwrite. If `--force` is passed, regenerate the pointer (e.g., after the canonical moved).
- **Canonical path resolves to another pointer:** refuse to chain pointers. Report the cycle and suggest that the user flatten by copying the ultimate canonical into place.

## Commit Hint

After successful init, suggest a commit (per `${CLAUDE_SKILL_DIR}/references/commit-protocol.md`):

```
spec: init refinery working directory

Created <working-dir>/ with _conventions.md, _glossary.md (<N> terms),
and 7 artifact templates.

Refinery-Op: init
```
