#!/usr/bin/env bash

# ============================================================================
# OpenPlugins - GitHub Publication Script
# ============================================================================
# Purpose: Automates the process of publishing marketplace to GitHub
# Version: 2.0.0
# License: MIT
# ============================================================================

# ====================
# Strict Error Handling
# ====================
set -o errexit   # Exit on error
set -o nounset   # Exit on undefined variable
set -o pipefail  # Exit on pipe failure
# set -o xtrace  # Uncomment for debugging

# ====================
# Configuration
# ====================
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
readonly MARKETPLACE_JSON="${PROJECT_ROOT}/.claude-plugin/marketplace.json"
readonly VERSION="1.0.0"

# Default values
DEFAULT_REPO_NAME="open-plugins"
DEFAULT_BRANCH="main"
DEFAULT_DESCRIPTION="Community-curated marketplace of high-quality, open-source Claude Code plugins"

# Exit codes
readonly E_SUCCESS=0
readonly E_VALIDATION_FAILED=1
readonly E_GIT_ERROR=2
readonly E_GITHUB_ERROR=3
readonly E_USER_CANCELLED=4
readonly E_PREREQ_MISSING=5
readonly E_INVALID_INPUT=6

# ====================
# Color Output
# ====================
if [[ -t 1 ]]; then
    readonly RED='\033[0;31m'
    readonly GREEN='\033[0;32m'
    readonly YELLOW='\033[1;33m'
    readonly BLUE='\033[0;34m'
    readonly MAGENTA='\033[0;35m'
    readonly CYAN='\033[0;36m'
    readonly BOLD='\033[1m'
    readonly NC='\033[0m'
else
    readonly RED='' GREEN='' YELLOW='' BLUE='' MAGENTA='' CYAN='' BOLD='' NC=''
fi

# ====================
# Global State
# ====================
DRY_RUN=false
VERBOSE=false
SKIP_VALIDATION=false
FORCE=false
AUTO_YES=false
GITHUB_OWNER=""
REPO_NAME="${DEFAULT_REPO_NAME}"

# ====================
# Utility Functions
# ====================

# Print functions with consistent formatting
print_header() {
    echo -e "${BOLD}${BLUE}======================================${NC}"
    echo -e "${BOLD}${BLUE}$1${NC}"
    echo -e "${BOLD}${BLUE}======================================${NC}"
    echo ""
}

print_section() {
    echo -e "${BOLD}${CYAN}→ $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}" >&2
}

print_error() {
    echo -e "${RED}❌ $1${NC}" >&2
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_verbose() {
    if [[ "${VERBOSE}" == true ]]; then
        echo -e "${MAGENTA}[VERBOSE] $1${NC}" >&2
    fi
}

# Logging with timestamps
log() {
    local level="$1"
    shift
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] [${level}] $*" >&2
}

log_info() { log "INFO" "$@"; }
log_warn() { log "WARN" "$@"; }
log_error() { log "ERROR" "$@"; }

# Cleanup handler
cleanup() {
    local exit_code=$?
    if [[ ${exit_code} -ne 0 ]]; then
        print_error "Script failed with exit code ${exit_code}"
        log_error "Cleanup triggered with exit code ${exit_code}"
    fi
}

trap cleanup EXIT

# ====================
# Validation Functions
# ====================

# Validate we're in the correct directory
validate_directory() {
    print_verbose "Validating directory structure..."

    if [[ ! -f "${MARKETPLACE_JSON}" ]]; then
        print_error "marketplace.json not found at: ${MARKETPLACE_JSON}"
        print_info "Make sure you're running this script from the marketplace root"
        return 1
    fi

    if [[ ! -f "${PROJECT_ROOT}/README.md" ]]; then
        print_error "README.md not found - invalid marketplace structure"
        return 1
    fi

    print_verbose "Directory structure validated"
    return 0
}

# Validate marketplace JSON
validate_marketplace() {
    if [[ "${SKIP_VALIDATION}" == true ]]; then
        print_warning "Skipping validation (--skip-validation flag set)"
        return 0
    fi

    print_section "Validating marketplace..."

    local validator="${SCRIPT_DIR}/validate-marketplace.sh"
    if [[ ! -x "${validator}" ]]; then
        print_error "Validator script not found or not executable: ${validator}"
        return 1
    fi

    if ! "${validator}"; then
        print_error "Validation failed. Fix errors before publishing."
        print_info "Run: ./scripts/validate-marketplace.sh"
        return 1
    fi

    print_success "Validation passed"
    echo ""
    return 0
}

# Validate GitHub username/org (basic sanitization)
validate_github_owner() {
    local owner="$1"

    # GitHub username rules: alphanumeric, hyphens, max 39 chars
    if [[ ! "${owner}" =~ ^[a-zA-Z0-9][a-zA-Z0-9-]{0,38}$ ]]; then
        print_error "Invalid GitHub username/organization: ${owner}"
        print_info "Must be alphanumeric with hyphens, 1-39 characters"
        return 1
    fi

    # Can't end with hyphen
    if [[ "${owner}" =~ -$ ]]; then
        print_error "GitHub username cannot end with a hyphen"
        return 1
    fi

    return 0
}

# Validate repository name
validate_repo_name() {
    local name="$1"

    # GitHub repo name rules: alphanumeric, hyphens, underscores, dots
    if [[ ! "${name}" =~ ^[a-zA-Z0-9._-]+$ ]]; then
        print_error "Invalid repository name: ${name}"
        print_info "Must contain only alphanumeric, hyphens, underscores, or dots"
        return 1
    fi

    # Can't start with dot or hyphen
    if [[ "${name}" =~ ^[.-] ]]; then
        print_error "Repository name cannot start with . or -"
        return 1
    fi

    return 0
}

# Check prerequisites
check_prerequisites() {
    print_section "Checking prerequisites..."

    local missing_prereqs=()

    # Check git
    if ! command -v git &> /dev/null; then
        missing_prereqs+=("git")
    else
        print_verbose "git: $(git --version)"
    fi

    # Check jq (for JSON parsing)
    if ! command -v jq &> /dev/null; then
        print_warning "jq not found - JSON validation will be limited"
    else
        print_verbose "jq: $(jq --version)"
    fi

    # Check python3 (backup JSON validator)
    if ! command -v python3 &> /dev/null; then
        print_warning "python3 not found - using basic validation"
    else
        print_verbose "python3: $(python3 --version)"
    fi

    if [[ ${#missing_prereqs[@]} -gt 0 ]]; then
        print_error "Missing required tools: ${missing_prereqs[*]}"
        return 1
    fi

    print_success "All prerequisites met"
    echo ""
    return 0
}

# Check if GitHub CLI is available
check_github_cli() {
    if command -v gh &> /dev/null; then
        print_verbose "GitHub CLI: $(gh --version | head -n1)"

        # Check authentication
        if gh auth status &> /dev/null; then
            print_verbose "GitHub CLI authenticated"
            return 0
        else
            print_warning "GitHub CLI found but not authenticated"
            print_info "Run: gh auth login"
            return 1
        fi
    else
        return 1
    fi
}

# ====================
# Git Operations
# ====================

# Initialize git repository (idempotent)
init_git_repo() {
    print_section "Initializing Git repository..."

    if [[ -d "${PROJECT_ROOT}/.git" ]]; then
        print_warning "Git repository already initialized"
        return 0
    fi

    if [[ "${DRY_RUN}" == true ]]; then
        print_info "[DRY RUN] Would execute: git init"
        return 0
    fi

    cd "${PROJECT_ROOT}" || return 1

    if git init; then
        print_success "Git repository initialized"
    else
        print_error "Failed to initialize git repository"
        return 1
    fi

    echo ""
    return 0
}

# Stage files for commit
stage_files() {
    print_section "Staging files..."

    if [[ "${DRY_RUN}" == true ]]; then
        print_info "[DRY RUN] Would execute: git add ."
        print_info "[DRY RUN] Files that would be staged:"
        git status --short 2>/dev/null || true
        return 0
    fi

    cd "${PROJECT_ROOT}" || return 1

    if git add .; then
        print_success "Files staged"

        # Show what was staged
        if [[ "${VERBOSE}" == true ]]; then
            echo "Staged files:"
            git status --short
        fi
    else
        print_error "Failed to stage files"
        return 1
    fi

    echo ""
    return 0
}

# Create initial commit (idempotent)
create_initial_commit() {
    print_section "Creating initial commit..."

    cd "${PROJECT_ROOT}" || return 1

    # Check if there are already commits
    if git rev-parse HEAD &> /dev/null; then
        print_warning "Repository already has commits"

        # Check if there are uncommitted changes
        if ! git diff-index --quiet HEAD --; then
            print_warning "Uncommitted changes detected"
            if [[ "${FORCE}" != true ]] && [[ "${AUTO_YES}" != true ]]; then
                read -r -p "Commit changes? (y/N): " response
                if [[ ! "${response}" =~ ^[Yy]$ ]]; then
                    print_info "Skipping commit"
                    return 0
                fi
            fi

            if [[ "${DRY_RUN}" == true ]]; then
                print_info "[DRY RUN] Would create new commit"
                return 0
            fi

            git commit -m "chore: update marketplace files" || {
                print_error "Failed to commit changes"
                return 1
            }
            print_success "Changes committed"
        fi
        return 0
    fi

    if [[ "${DRY_RUN}" == true ]]; then
        print_info "[DRY RUN] Would create initial commit"
        return 0
    fi

    local commit_message
    commit_message="feat: initialize OpenPlugins marketplace

- Complete marketplace structure with metadata
- Comprehensive documentation (README, CONTRIBUTING, CODE_OF_CONDUCT)
- GitHub templates for issues and PRs
- Plugin quality standards and review process
- MIT License for marketplace structure
- Validation tools and scripts
- Initial version ${VERSION}

Ready for community plugin submissions."

    if git commit -m "${commit_message}"; then
        print_success "Initial commit created"
    else
        print_error "Failed to create initial commit"
        return 1
    fi

    echo ""
    return 0
}

# ====================
# GitHub Operations
# ====================

# Prompt for GitHub configuration
prompt_github_config() {
    print_section "GitHub repository configuration"
    echo ""

    # Get GitHub owner
    while true; do
        if [[ -n "${GITHUB_OWNER}" ]]; then
            break
        fi

        read -r -p "GitHub username or organization: " GITHUB_OWNER
        GITHUB_OWNER="${GITHUB_OWNER// /}" # Remove spaces

        if [[ -z "${GITHUB_OWNER}" ]]; then
            print_error "GitHub owner cannot be empty"
            continue
        fi

        if validate_github_owner "${GITHUB_OWNER}"; then
            break
        fi
    done

    # Get repository name
    echo ""
    read -r -p "Repository name [${DEFAULT_REPO_NAME}]: " input_repo
    REPO_NAME="${input_repo:-${DEFAULT_REPO_NAME}}"

    if ! validate_repo_name "${REPO_NAME}"; then
        print_error "Invalid repository name"
        return 1
    fi

    # Confirm configuration
    echo ""
    print_info "Configuration:"
    echo "  Owner: ${GITHUB_OWNER}"
    echo "  Repository: ${REPO_NAME}"
    echo "  Visibility: Public"
    echo "  URL: https://github.com/${GITHUB_OWNER}/${REPO_NAME}"
    echo ""

    if [[ "${AUTO_YES}" != true ]]; then
        read -r -p "Proceed with repository creation? (y/N): " confirm
        if [[ ! "${confirm}" =~ ^[Yy]$ ]]; then
            print_warning "Cancelled by user"
            return ${E_USER_CANCELLED}
        fi
    fi

    return 0
}

# Create GitHub repository using gh CLI
create_github_repo_cli() {
    print_section "Creating GitHub repository..."

    if [[ "${DRY_RUN}" == true ]]; then
        print_info "[DRY RUN] Would execute:"
        echo "  gh repo create ${GITHUB_OWNER}/${REPO_NAME} \\"
        echo "    --public \\"
        echo "    --description \"${DEFAULT_DESCRIPTION}\" \\"
        echo "    --homepage \"https://github.com/${GITHUB_OWNER}/${REPO_NAME}\""
        return 0
    fi

    # Check if repository already exists
    if gh repo view "${GITHUB_OWNER}/${REPO_NAME}" &> /dev/null; then
        print_warning "Repository already exists: ${GITHUB_OWNER}/${REPO_NAME}"
        if [[ "${FORCE}" != true ]]; then
            print_error "Use --force to continue anyway"
            return 1
        fi
        print_warning "Continuing with existing repository (--force flag set)"
        return 0
    fi

    if gh repo create "${GITHUB_OWNER}/${REPO_NAME}" \
        --public \
        --description "${DEFAULT_DESCRIPTION}" \
        --homepage "https://github.com/${GITHUB_OWNER}/${REPO_NAME}"; then
        print_success "Repository created"
    else
        print_error "Failed to create repository"
        print_info "You may need to:"
        echo "  - Authenticate with: gh auth login"
        echo "  - Check repository name availability"
        echo "  - Create the repository manually"
        return 1
    fi

    echo ""
    return 0
}

# Show manual repository creation instructions
show_manual_instructions() {
    print_warning "GitHub CLI not available"
    echo ""
    print_info "To publish to GitHub manually:"
    echo ""
    echo "1. Create repository on GitHub:"
    echo "   - Go to: https://github.com/new"
    echo "   - Repository name: ${REPO_NAME}"
    echo "   - Description: ${DEFAULT_DESCRIPTION}"
    echo "   - Visibility: Public"
    echo "   - Do NOT initialize with README/license/.gitignore"
    echo ""
    echo "2. Push to GitHub:"
    echo "   cd ${PROJECT_ROOT}"
    echo "   git remote add origin https://github.com/${GITHUB_OWNER}/${REPO_NAME}.git"
    echo "   git branch -M ${DEFAULT_BRANCH}"
    echo "   git push -u origin ${DEFAULT_BRANCH}"
    echo ""
    echo "3. Optionally create release:"
    echo "   git tag -a v${VERSION} -m \"Initial release\""
    echo "   git push origin v${VERSION}"
    echo ""
}

# Push to GitHub
push_to_github() {
    print_section "Pushing to GitHub..."

    cd "${PROJECT_ROOT}" || return 1

    local remote_url="https://github.com/${GITHUB_OWNER}/${REPO_NAME}.git"

    # Add remote (idempotent)
    if git remote get-url origin &> /dev/null; then
        local current_url
        current_url=$(git remote get-url origin)
        if [[ "${current_url}" != "${remote_url}" ]]; then
            print_warning "Remote 'origin' exists with different URL"
            print_info "Current: ${current_url}"
            print_info "Expected: ${remote_url}"

            if [[ "${FORCE}" != true ]] && [[ "${AUTO_YES}" != true ]]; then
                read -r -p "Update remote URL? (y/N): " response
                if [[ ! "${response}" =~ ^[Yy]$ ]]; then
                    print_error "Cannot proceed with mismatched remote"
                    return 1
                fi
            fi

            if [[ "${DRY_RUN}" != true ]]; then
                git remote set-url origin "${remote_url}"
                print_success "Remote URL updated"
            fi
        fi
    else
        if [[ "${DRY_RUN}" == true ]]; then
            print_info "[DRY RUN] Would add remote: origin ${remote_url}"
        else
            git remote add origin "${remote_url}"
            print_verbose "Remote 'origin' added"
        fi
    fi

    # Set branch name
    if [[ "${DRY_RUN}" == true ]]; then
        print_info "[DRY RUN] Would rename branch to: ${DEFAULT_BRANCH}"
        print_info "[DRY RUN] Would push to: origin ${DEFAULT_BRANCH}"
        return 0
    fi

    git branch -M "${DEFAULT_BRANCH}"

    # Push to GitHub
    if git push -u origin "${DEFAULT_BRANCH}"; then
        print_success "Pushed to GitHub"
    else
        print_error "Failed to push to GitHub"
        print_info "Check your authentication and repository permissions"
        return 1
    fi

    echo ""
    return 0
}

# Create release tag
create_release() {
    if [[ "${AUTO_YES}" != true ]]; then
        echo ""
        read -r -p "Create v${VERSION} release tag? (y/N): " create_tag
        if [[ ! "${create_tag}" =~ ^[Yy]$ ]]; then
            print_info "Skipping release creation"
            return 0
        fi
    fi

    print_section "Creating release..."

    cd "${PROJECT_ROOT}" || return 1

    if [[ "${DRY_RUN}" == true ]]; then
        print_info "[DRY RUN] Would create tag v${VERSION}"
        print_info "[DRY RUN] Would push tag to GitHub"
        if check_github_cli; then
            print_info "[DRY RUN] Would create GitHub release"
        fi
        return 0
    fi

    local tag_message
    tag_message="Initial release of OpenPlugins marketplace

Features:
- Complete marketplace infrastructure
- Comprehensive documentation
- Plugin submission process
- Quality standards and review guidelines
- Community governance
- Validation tools

Ready for community plugin submissions."

    # Create annotated tag
    if git tag -a "v${VERSION}" -m "${tag_message}"; then
        print_success "Tag v${VERSION} created"
    else
        print_warning "Failed to create tag (may already exist)"
    fi

    # Push tag
    if git push origin "v${VERSION}"; then
        print_success "Tag pushed to GitHub"
    else
        print_warning "Failed to push tag"
    fi

    # Create GitHub release if CLI available
    if check_github_cli; then
        local release_notes
        release_notes="First public release of OpenPlugins marketplace.

## Features
- Complete marketplace infrastructure
- Comprehensive documentation (README, CONTRIBUTING, CODE_OF_CONDUCT)
- Plugin submission process with quality standards
- GitHub templates for issues and PRs
- Automated validation tools
- Community governance model

## Getting Started
\`\`\`bash
# Add marketplace to Claude Code
/plugin marketplace add ${GITHUB_OWNER}/${REPO_NAME}

# Browse plugins (currently 0, awaiting submissions!)
/plugin marketplace list open-plugins
\`\`\`

## Contributing
We welcome high-quality plugin submissions! See [CONTRIBUTING.md](https://github.com/${GITHUB_OWNER}/${REPO_NAME}/blob/main/CONTRIBUTING.md) for details.

**Ready for community contributions!** 🚀"

        if gh release create "v${VERSION}" \
            --title "OpenPlugins v${VERSION} - Initial Release" \
            --notes "${release_notes}"; then
            print_success "GitHub release created"
        else
            print_warning "Failed to create GitHub release (you can create it manually)"
        fi
    fi

    echo ""
    return 0
}

# ====================
# Main Workflow
# ====================

# Show final success message
show_success_message() {
    echo ""
    print_header "✅ Publication Complete!"
    echo ""
    print_success "Your marketplace is now live at:"
    echo -e "  ${BOLD}${BLUE}https://github.com/${GITHUB_OWNER}/${REPO_NAME}${NC}"
    echo ""
    print_info "Next steps:"
    echo ""
    echo "1. Configure repository settings:"
    echo "   - Enable Discussions"
    echo "   - Add topics: claude-code, plugins, marketplace, open-source"
    echo "   - Configure branch protection (optional)"
    echo ""
    echo "2. Test installation:"
    echo "   /plugin marketplace add ${GITHUB_OWNER}/${REPO_NAME}"
    echo ""
    echo "3. Announce to community:"
    echo "   - Share in Claude Code communities"
    echo "   - Post in GitHub Discussions"
    echo "   - Invite plugin authors"
    echo ""
    echo "4. Accept first plugin submissions!"
    echo ""
    print_info "Documentation:"
    echo "  - Main docs: README.md"
    echo "  - Submission guide: CONTRIBUTING.md"
    echo "  - Setup guide: SETUP_GUIDE.md"
    echo ""
    print_success "Happy curating! 🎉"
    echo ""
}

# Main execution function
main() {
    print_header "OpenPlugins GitHub Publication"

    # Change to project root
    cd "${PROJECT_ROOT}" || {
        print_error "Failed to change to project root: ${PROJECT_ROOT}"
        exit ${E_GIT_ERROR}
    }

    print_verbose "Project root: ${PROJECT_ROOT}"
    print_verbose "Script directory: ${SCRIPT_DIR}"

    if [[ "${DRY_RUN}" == true ]]; then
        print_warning "DRY RUN MODE - No changes will be made"
        echo ""
    fi

    # Execute workflow
    validate_directory || exit ${E_VALIDATION_FAILED}
    check_prerequisites || exit ${E_PREREQ_MISSING}
    validate_marketplace || exit ${E_VALIDATION_FAILED}
    init_git_repo || exit ${E_GIT_ERROR}
    stage_files || exit ${E_GIT_ERROR}
    create_initial_commit || exit ${E_GIT_ERROR}

    # GitHub operations
    local has_gh_cli=false
    if check_github_cli; then
        has_gh_cli=true
    else
        print_warning "GitHub CLI not found or not authenticated"
        print_info "Install: https://cli.github.com/manual/installation"
        print_info "Authenticate: gh auth login"
        echo ""
    fi

    prompt_github_config || exit $?

    if [[ "${has_gh_cli}" == true ]]; then
        create_github_repo_cli || exit ${E_GITHUB_ERROR}
        push_to_github || exit ${E_GITHUB_ERROR}
        create_release
    else
        show_manual_instructions
        exit ${E_SUCCESS}
    fi

    show_success_message

    return ${E_SUCCESS}
}

# ====================
# Usage & Help
# ====================

show_usage() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS]

Automate publishing OpenPlugins marketplace to GitHub.

OPTIONS:
    -h, --help              Show this help message
    -v, --verbose           Enable verbose output
    -d, --dry-run           Show what would be done without making changes
    -y, --yes               Automatically answer yes to prompts
    -f, --force             Force operations (overwrite existing)
    --skip-validation       Skip marketplace validation
    --owner OWNER           GitHub username or organization
    --repo REPO             Repository name (default: open-plugins)

EXAMPLES:
    # Interactive mode
    $(basename "$0")

    # Dry run to preview
    $(basename "$0") --dry-run

    # Automated with specific repo
    $(basename "$0") --yes --owner myorg --repo my-marketplace

    # Verbose dry run
    $(basename "$0") --dry-run --verbose

ENVIRONMENT:
    GH_TOKEN                GitHub token for authentication

EXIT CODES:
    0   Success
    1   Validation failed
    2   Git error
    3   GitHub error
    4   User cancelled
    5   Missing prerequisites
    6   Invalid input

EOF
}

# ====================
# Argument Parsing
# ====================

parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_usage
                exit ${E_SUCCESS}
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -d|--dry-run)
                DRY_RUN=true
                shift
                ;;
            -y|--yes)
                AUTO_YES=true
                shift
                ;;
            -f|--force)
                FORCE=true
                shift
                ;;
            --skip-validation)
                SKIP_VALIDATION=true
                shift
                ;;
            --owner)
                GITHUB_OWNER="$2"
                shift 2
                ;;
            --repo)
                REPO_NAME="$2"
                shift 2
                ;;
            *)
                print_error "Unknown option: $1"
                show_usage
                exit ${E_INVALID_INPUT}
                ;;
        esac
    done
}

# ====================
# Entry Point
# ====================

parse_arguments "$@"
main
exit $?
