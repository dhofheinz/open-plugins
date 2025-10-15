#!/bin/bash
# Purpose: Generate ASCII architecture diagrams from system descriptions
# Version: 1.0.0
# Usage: ./diagram-generator.sh <type> [options]
# Types: layered, microservices, database, network, component
# Returns: ASCII diagram
# Exit codes: 0=success, 1=error, 2=invalid input

set -euo pipefail

# Configuration
readonly SCRIPT_NAME="$(basename "$0")"
readonly DIAGRAM_TYPE="${1:-}"

# Box drawing characters
readonly TL="┌"  # Top-left
readonly TR="┐"  # Top-right
readonly BL="└"  # Bottom-left
readonly BR="┘"  # Bottom-right
readonly H="─"   # Horizontal
readonly V="│"   # Vertical
readonly VR="├"  # Vertical-right
readonly VL="┤"  # Vertical-left
readonly HU="┴"  # Horizontal-up
readonly HD="┬"  # Horizontal-down
readonly X="┼"   # Cross

# Arrow characters
readonly ARROW_DOWN="▼"
readonly ARROW_UP="▲"
readonly ARROW_LEFT="◄"
readonly ARROW_RIGHT="►"
readonly ARROW_BIDIRECT="◄►"

# Color codes
readonly BLUE='\033[0;34m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly RED='\033[0;31m'
readonly NC='\033[0m'

# Usage information
usage() {
    cat <<EOF
Usage: $SCRIPT_NAME <type> [options]

Diagram Types:
  layered         Generate layered architecture diagram
  microservices   Generate microservices architecture diagram
  database        Generate database architecture diagram
  network         Generate network topology diagram
  component       Generate component interaction diagram
  dataflow        Generate data flow diagram

Options:
  --title TEXT    Set diagram title (default: architecture type)
  --color         Enable colored output
  --help          Show this help message

Examples:
  $SCRIPT_NAME layered --title "Web Application Architecture"
  $SCRIPT_NAME microservices --color
  $SCRIPT_NAME database --title "E-commerce Database"

Exit Codes:
  0 - Success
  1 - Error during execution
  2 - Invalid input
EOF
}

# Parse options
parse_options() {
    DIAGRAM_TITLE=""
    USE_COLOR=false

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --title)
                DIAGRAM_TITLE="$2"
                shift 2
                ;;
            --color)
                USE_COLOR=true
                shift
                ;;
            --help)
                usage
                exit 0
                ;;
            *)
                shift
                ;;
        esac
    done
}

# Draw a box
draw_box() {
    local width="$1"
    local height="$2"
    local text="$3"
    local color="${4:-$NC}"

    # Top border
    echo -n "$color$TL"
    printf '%*s' "$((width-2))" '' | tr ' ' "$H"
    echo "$TR$NC"

    # Calculate padding for centered text
    local text_len=${#text}
    local padding=$(( (width - text_len - 2) / 2 ))
    local padding_right=$(( width - text_len - padding - 2 ))

    # Middle rows with text
    for ((i=1; i<height-1; i++)); do
        if [[ $i -eq $((height/2)) ]] && [[ -n "$text" ]]; then
            echo -n "$color$V$NC"
            printf '%*s' "$padding" ''
            echo -n "$text"
            printf '%*s' "$padding_right" ''
            echo "$color$V$NC"
        else
            echo -n "$color$V$NC"
            printf '%*s' "$((width-2))" ''
            echo "$color$V$NC"
        fi
    done

    # Bottom border
    echo -n "$color$BL"
    printf '%*s' "$((width-2))" '' | tr ' ' "$H"
    echo "$BR$NC"
}

# Generate layered architecture diagram
generate_layered() {
    local title="${DIAGRAM_TITLE:-Layered Architecture}"
    local width=60

    cat <<EOF

$title
$( printf '=%.0s' $(seq 1 ${#title}) )

┌────────────────────────────────────────────────────────────┐
│                      Presentation Layer                     │
│                  (UI, Controllers, Views)                   │
└─────────────────────────┬──────────────────────────────────┘
                          │
                          ▼
┌────────────────────────────────────────────────────────────┐
│                      Business Layer                         │
│              (Business Logic, Services, DTOs)               │
└─────────────────────────┬──────────────────────────────────┘
                          │
                          ▼
┌────────────────────────────────────────────────────────────┐
│                     Persistence Layer                       │
│             (Data Access, Repositories, ORMs)               │
└─────────────────────────┬──────────────────────────────────┘
                          │
                          ▼
┌────────────────────────────────────────────────────────────┐
│                       Database Layer                        │
│                  (PostgreSQL, MongoDB, etc.)                │
└────────────────────────────────────────────────────────────┘

Data Flow: Top → Down (Request) | Bottom → Top (Response)
EOF
}

# Generate microservices architecture diagram
generate_microservices() {
    local title="${DIAGRAM_TITLE:-Microservices Architecture}"

    cat <<EOF

$title
$( printf '=%.0s' $(seq 1 ${#title}) )

                    ┌─────────────┐
                    │   API       │
                    │   Gateway   │
                    └──────┬──────┘
                           │
        ┌──────────────────┼──────────────────┐
        │                  │                  │
        ▼                  ▼                  ▼
  ┌──────────┐      ┌──────────┐      ┌──────────┐
  │  User    │      │ Product  │      │ Order    │
  │ Service  │      │ Service  │      │ Service  │
  └────┬─────┘      └────┬─────┘      └────┬─────┘
       │                 │                  │
       ▼                 ▼                  ▼
  ┌──────────┐      ┌──────────┐      ┌──────────┐
  │  Users   │      │ Products │      │  Orders  │
  │    DB    │      │    DB    │      │    DB    │
  └──────────┘      └──────────┘      └──────────┘

       ┌────────────────────────────────────┐
       │      Message Queue (RabbitMQ)      │
       │         Event Distribution         │
       └────────────────────────────────────┘

       ┌────────────────────────────────────┐
       │       Service Discovery            │
       │      (Consul/Eureka)               │
       └────────────────────────────────────┘
EOF
}

# Generate database architecture diagram
generate_database() {
    local title="${DIAGRAM_TITLE:-Database Architecture}"

    cat <<EOF

$title
$( printf '=%.0s' $(seq 1 ${#title}) )

                   ┌──────────────────┐
                   │  Application     │
                   │     Tier         │
                   └────────┬─────────┘
                            │
              ┌─────────────┼─────────────┐
              │             │             │
              ▼             ▼             ▼
        ┌──────────┐  ┌──────────┐  ┌──────────┐
        │  Read    │  │  Write   │  │  Cache   │
        │  Pool    │  │  Pool    │  │  Layer   │
        └────┬─────┘  └────┬─────┘  └──────────┘
             │             │         (Redis)
             │             │
             ▼             ▼
        ┌──────────────────────────────┐
        │     Load Balancer            │
        │    (Connection Pool)         │
        └──────────┬───────────────────┘
                   │
        ┌──────────┼──────────┐
        │          │          │
        ▼          ▼          ▼
   ┌────────┐ ┌────────┐ ┌────────┐
   │ Read   │ │Primary │ │ Read   │
   │Replica │ │Database│ │Replica │
   │   1    │ │ Master │ │   2    │
   └────────┘ └───┬────┘ └────────┘
                   │
                   │ Replication
                   ▼
             ┌──────────┐
             │  Backup  │
             │  Storage │
             └──────────┘
EOF
}

# Generate network topology diagram
generate_network() {
    local title="${DIAGRAM_TITLE:-Network Topology}"

    cat <<EOF

$title
$( printf '=%.0s' $(seq 1 ${#title}) )

                        Internet
                           │
                ┌──────────┴──────────┐
                │                     │
                ▼                     ▼
          ┌──────────┐          ┌──────────┐
          │   CDN    │          │   WAF    │
          │ (Static) │          │(Security)│
          └──────────┘          └────┬─────┘
                                     │
                              ┌──────┴──────┐
                              │             │
                              ▼             ▼
                        ┌──────────┐  ┌──────────┐
                        │   Load   │  │   Load   │
                        │ Balancer │  │ Balancer │
                        │   (AZ1)  │  │   (AZ2)  │
                        └────┬─────┘  └────┬─────┘
                             │             │
        ┌────────────────────┼─────────────┼────────────────────┐
        │                    │             │                    │
        ▼                    ▼             ▼                    ▼
  ┌──────────┐        ┌──────────┐  ┌──────────┐        ┌──────────┐
  │   App    │        │   App    │  │   App    │        │   App    │
  │ Server 1 │        │ Server 2 │  │ Server 3 │        │ Server 4 │
  │  (AZ1)   │        │  (AZ1)   │  │  (AZ2)   │        │  (AZ2)   │
  └────┬─────┘        └────┬─────┘  └────┬─────┘        └────┬─────┘
       │                   │             │                    │
       └───────────────────┼─────────────┼────────────────────┘
                           │             │
                           ▼             ▼
                     ┌──────────┐  ┌──────────┐
                     │ Database │  │ Database │
                     │ Primary  │  │ Standby  │
                     │  (AZ1)   │  │  (AZ2)   │
                     └──────────┘  └──────────┘

Availability Zones: AZ1 (Primary), AZ2 (Secondary)
EOF
}

# Generate component interaction diagram
generate_component() {
    local title="${DIAGRAM_TITLE:-Component Interaction}"

    cat <<EOF

$title
$( printf '=%.0s' $(seq 1 ${#title}) )

┌──────────────┐
│    Client    │
│  (Browser)   │
└───────┬──────┘
        │ HTTP/HTTPS
        │
        ▼
┌──────────────────────────────────────────┐
│           Frontend (React/Vue)           │
│  ┌────────────┐      ┌────────────┐     │
│  │ Components │◄────►│   State    │     │
│  └────────────┘      │ Management │     │
│                      └────────────┘     │
└───────────┬──────────────────────────────┘
            │ REST/GraphQL
            │
            ▼
┌──────────────────────────────────────────┐
│        Backend API (Node.js/Python)      │
│  ┌─────────┐  ┌──────────┐  ┌────────┐  │
│  │  Auth   │  │ Business │  │  Data  │  │
│  │ Service │──│  Logic   │──│ Access │  │
│  └─────────┘  └──────────┘  └────┬───┘  │
└────────────────────────────────────┬─────┘
                                     │
                    ┌────────────────┼────────────────┐
                    │                │                │
                    ▼                ▼                ▼
              ┌──────────┐     ┌──────────┐    ┌──────────┐
              │PostgreSQL│     │  Redis   │    │   S3     │
              │ Database │     │  Cache   │    │ Storage  │
              └──────────┘     └──────────┘    └──────────┘

Data Flow:
  → Request (Client to Server)
  ← Response (Server to Client)
  ◄► Bidirectional Communication
EOF
}

# Generate data flow diagram
generate_dataflow() {
    local title="${DIAGRAM_TITLE:-Data Flow Diagram}"

    cat <<EOF

$title
$( printf '=%.0s' $(seq 1 ${#title}) )

External Systems                Application                 Data Storage
─────────────────              ─────────────              ──────────────

    ┌────────┐                                                ┌────────┐
    │  User  │───────(1)────►┌──────────┐                    │Primary │
    │ Input  │  User Request  │   API    │────(2)───────────►│Database│
    └────────┘                │ Gateway  │    Query/Write     └────┬───┘
                              └────┬─────┘                         │
                                   │                               │
                                   │ (3) Process                   │
                                   ▼                               │
       ┌────────┐            ┌──────────┐                         │
       │External│◄───(4)─────│ Business │◄────(5)─────────────────┘
       │  APIs  │  Fetch Data│  Logic   │   Read Data
       └────────┘            └────┬─────┘
                                  │
                                  │ (6) Cache
                                  ▼
                             ┌──────────┐
                             │  Cache   │
                             │  Layer   │
                             └────┬─────┘
                                  │
                                  │ (7) Response
                                  ▼
       ┌────────┐            ┌──────────┐
       │  User  │◄───(8)─────│ Response │
       │ Output │  JSON/HTML │Formatter │
       └────────┘            └──────────┘

Flow Steps:
  (1) User sends request
  (2) Gateway queries database
  (3) Business logic processes
  (4) External API calls
  (5) Database read operations
  (6) Cache result
  (7) Format response
  (8) Return to user
EOF
}

# Main execution
main() {
    if [[ $# -eq 0 ]] || [[ "$1" == "--help" ]]; then
        usage
        exit 0
    fi

    parse_options "$@"

    case "$DIAGRAM_TYPE" in
        layered)
            generate_layered
            ;;
        microservices)
            generate_microservices
            ;;
        database)
            generate_database
            ;;
        network)
            generate_network
            ;;
        component)
            generate_component
            ;;
        dataflow)
            generate_dataflow
            ;;
        *)
            echo "Error: Unknown diagram type: $DIAGRAM_TYPE" >&2
            echo "Run '$SCRIPT_NAME --help' for usage information" >&2
            exit 2
            ;;
    esac

    exit 0
}

# Run main function
main "$@"
