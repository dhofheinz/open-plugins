#!/bin/bash
# Dependency Checker - Analyze file dependencies
#
# Purpose: Check for dependencies between files to inform commit ordering
# Version: 1.0.0
# Usage: ./dependency-checker.sh [files...]
#   If no files specified, analyzes all changed files
# Returns:
#   Exit 0: Success
#   Exit 1: Error
#   Exit 2: Invalid parameters
#
# Dependencies: git, bash 4.0+, grep

set -euo pipefail

VERBOSE=false
OUTPUT_FORMAT="text"

# Parse options
while [[ $# -gt 0 ]]; do
    case "$1" in
        --verbose)
            VERBOSE=true
            shift
            ;;
        --format)
            OUTPUT_FORMAT="${2:-text}"
            shift 2
            ;;
        *)
            break
            ;;
    esac
done

# Logging
log() {
    if [[ "$VERBOSE" == "true" ]]; then
        echo "[DEBUG] $*" >&2
    fi
}

# Get changed files if not specified
FILES=()
if [[ $# -eq 0 ]]; then
    log "Getting changed files from git..."
    while IFS= read -r file; do
        [[ -n "$file" ]] && FILES+=("$file")
    done < <(git diff --cached --name-only; git diff --name-only)
else
    FILES=("$@")
fi

# Remove duplicates
mapfile -t FILES < <(printf '%s\n' "${FILES[@]}" | sort -u)

if [[ ${#FILES[@]} -eq 0 ]]; then
    echo "No files to analyze" >&2
    exit 1
fi

log "Analyzing ${#FILES[@]} files for dependencies..."

# Dependency storage
declare -A dependencies
declare -A file_types

# Detect file type
detect_file_type() {
    local file="$1"

    case "$file" in
        *.py)
            echo "python"
            ;;
        *.js|*.jsx)
            echo "javascript"
            ;;
        *.ts|*.tsx)
            echo "typescript"
            ;;
        *.go)
            echo "go"
            ;;
        *.java)
            echo "java"
            ;;
        *.rb)
            echo "ruby"
            ;;
        *.rs)
            echo "rust"
            ;;
        *.md|*.txt|*.rst)
            echo "docs"
            ;;
        *test*|*spec*)
            echo "test"
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

# Extract imports from Python file
extract_python_imports() {
    local file="$1"
    local content

    if [[ -f "$file" ]]; then
        content=$(cat "$file")
    else
        # Try to get from git
        content=$(git show :"$file" 2>/dev/null || echo "")
    fi

    # Match: import module, from module import
    echo "$content" | grep -E "^(import|from) " | sed -E 's/^(import|from) ([a-zA-Z0-9_.]+).*/\2/' || true
}

# Extract imports from JavaScript/TypeScript
extract_js_imports() {
    local file="$1"
    local content

    if [[ -f "$file" ]]; then
        content=$(cat "$file")
    else
        content=$(git show :"$file" 2>/dev/null || echo "")
    fi

    # Match: import from, require()
    {
        echo "$content" | grep -oE "import .* from ['\"]([^'\"]+)['\"]" | sed -E "s/.*from ['\"](.*)['\"].*/\1/" || true
        echo "$content" | grep -oE "require\(['\"]([^'\"]+)['\"]\)" | sed -E "s/.*require\(['\"]([^'\"]+)['\"]\).*/\1/" || true
    } | sort -u
}

# Extract imports from Go
extract_go_imports() {
    local file="$1"
    local content

    if [[ -f "$file" ]]; then
        content=$(cat "$file")
    else
        content=$(git show :"$file" 2>/dev/null || echo "")
    fi

    # Match: import "module" or import ( "module" )
    echo "$content" | grep -oE 'import +"[^"]+"' | sed -E 's/import +"([^"]+)".*/\1/' || true
    echo "$content" | sed -n '/^import (/,/^)/p' | grep -oE '"[^"]+"' | tr -d '"' || true
}

# Convert import path to file path
import_to_file() {
    local import_path="$1"
    local file_type="$2"

    case "$file_type" in
        python)
            # module.submodule -> module/submodule.py
            echo "$import_path" | tr '.' '/' | sed 's|$|.py|'
            ;;
        javascript|typescript)
            # Handle relative imports
            if [[ "$import_path" == ./* ]] || [[ "$import_path" == ../* ]]; then
                echo "$import_path"
            else
                # node_modules - not a local file
                echo ""
            fi
            ;;
        go)
            # Package imports - check if local
            if [[ "$import_path" == github.com/* ]]; then
                echo ""
            else
                echo "$import_path"
            fi
            ;;
        *)
            echo ""
            ;;
    esac
}

# Find dependencies for each file
log "Extracting imports and dependencies..."

for file in "${FILES[@]}"; do
    file_type=$(detect_file_type "$file")
    file_types["$file"]="$file_type"
    log "  $file: type=$file_type"

    case "$file_type" in
        python)
            imports=$(extract_python_imports "$file")
            ;;
        javascript|typescript)
            imports=$(extract_js_imports "$file")
            ;;
        go)
            imports=$(extract_go_imports "$file")
            ;;
        *)
            imports=""
            ;;
    esac

    if [[ -n "$imports" ]]; then
        log "    Imports:"
        while IFS= read -r import_path; do
            [[ -z "$import_path" ]] && continue
            log "      - $import_path"

            # Convert import to file path
            imported_file=$(import_to_file "$import_path" "$file_type")

            # Check if imported file is in our file list
            if [[ -n "$imported_file" ]]; then
                for other_file in "${FILES[@]}"; do
                    if [[ "$other_file" == *"$imported_file"* ]]; then
                        # file depends on other_file
                        if [[ -z "${dependencies[$file]:-}" ]]; then
                            dependencies["$file"]="$other_file"
                        else
                            dependencies["$file"]="${dependencies[$file]},$other_file"
                        fi
                        log "      Dependency: $file -> $other_file"
                    fi
                done
            fi
        done <<< "$imports"
    fi
done

# Detect test dependencies
log "Detecting test dependencies..."

for file in "${FILES[@]}"; do
    if [[ "${file_types[$file]}" == "test" ]]; then
        # Test file depends on implementation file
        impl_file="${file//test/}"
        impl_file="${impl_file//.test/}"
        impl_file="${impl_file//.spec/}"
        impl_file="${impl_file//tests\//}"
        impl_file="${impl_file//spec\//}"

        for other_file in "${FILES[@]}"; do
            if [[ "$other_file" == *"$impl_file"* ]] && [[ "$other_file" != "$file" ]]; then
                if [[ -z "${dependencies[$file]:-}" ]]; then
                    dependencies["$file"]="$other_file"
                else
                    dependencies["$file"]="${dependencies[$file]},$other_file"
                fi
                log "  Test dependency: $file -> $other_file"
            fi
        done
    fi
done

# Output results
if [[ "$OUTPUT_FORMAT" == "json" ]]; then
    echo "{"
    echo "  \"files\": ["
    local first=true
    for file in "${FILES[@]}"; do
        if [[ "$first" == "true" ]]; then
            first=false
        else
            echo ","
        fi
        echo -n "    {\"file\": \"$file\", \"type\": \"${file_types[$file]}\""
        if [[ -n "${dependencies[$file]:-}" ]]; then
            IFS=',' read -ra deps <<< "${dependencies[$file]}"
            echo -n ", \"depends_on\": ["
            local first_dep=true
            for dep in "${deps[@]}"; do
                if [[ "$first_dep" == "true" ]]; then
                    first_dep=false
                else
                    echo -n ", "
                fi
                echo -n "\"$dep\""
            done
            echo -n "]"
        fi
        echo -n "}"
    done
    echo ""
    echo "  ]"
    echo "}"
else
    echo "=== FILE DEPENDENCIES ==="
    echo ""
    echo "Files analyzed: ${#FILES[@]}"
    echo ""

    local has_dependencies=false
    for file in "${FILES[@]}"; do
        if [[ -n "${dependencies[$file]:-}" ]]; then
            has_dependencies=true
            echo "File: $file"
            echo "  Type: ${file_types[$file]}"
            echo "  Depends on:"
            IFS=',' read -ra deps <<< "${dependencies[$file]}"
            for dep in "${deps[@]}"; do
                echo "    - $dep"
            done
            echo ""
        fi
    done

    if [[ "$has_dependencies" == "false" ]]; then
        echo "No dependencies detected."
        echo "All files can be committed independently."
    else
        echo "Recommendation:"
        echo "  Commit dependencies before dependent files."
        echo "  Group dependent files in same commit if they form atomic unit."
    fi
fi

log "Dependency analysis complete"
exit 0
