#!/usr/bin/env bash
# Setup a newly created GitHub issue with standard labels, type, and project
# Usage: setup-issue.sh <issue-url-or-number> [options]

set -euo pipefail

usage() {
    cat <<EOF
Usage: $0 <issue-url-or-number> [options]

Options:
  --type <type>       Issue type (e.g. Bug, Feature, Task)
  --label <label>     Label to add (repeatable). Falls back to default if not specified.
  --repo <owner/repo> Repository. Required if using issue number.
  --project <num>     Project number to add issue to
  --no-project        Skip adding to a project
  -h, --help          Show this help

Examples:
  $0 https://github.com/org/repo/issues/123
  $0 123 --repo org/repo --type Bug --label needs-triage
  $0 123 --repo org/repo --label urgent --label backend
  $0 123 --repo org/repo --no-project
EOF
    exit 1
}

# Parse arguments
ISSUE_REF=""
ISSUE_TYPE=""
REPO=""
PROJECT_NUM=""
SKIP_PROJECT=false
LABELS=()

while [[ $# -gt 0 ]]; do
    case $1 in
        --type)
            ISSUE_TYPE="$2"
            shift 2
            ;;
        --label)
            LABELS+=("$2")
            shift 2
            ;;
        --repo)
            REPO="$2"
            shift 2
            ;;
        --project)
            PROJECT_NUM="$2"
            shift 2
            ;;
        --no-project)
            SKIP_PROJECT=true
            shift
            ;;
        -h|--help)
            usage
            ;;
        *)
            ISSUE_REF="$1"
            shift
            ;;
    esac
done

if [[ -z "$ISSUE_REF" ]]; then
    usage
fi

# Extract repo and issue number from URL or use provided values
if [[ "$ISSUE_REF" =~ github\.com/([^/]+/[^/]+)/issues/([0-9]+) ]]; then
    REPO="${BASH_REMATCH[1]}"
    ISSUE_NUM="${BASH_REMATCH[2]}"
elif [[ "$ISSUE_REF" =~ ^[0-9]+$ ]]; then
    ISSUE_NUM="$ISSUE_REF"
    if [[ -z "$REPO" ]]; then
        echo "Error: --repo is required when using issue number"
        exit 1
    fi
else
    echo "Error: Invalid issue reference. Provide a GitHub URL or issue number with --repo"
    exit 1
fi

# Extract org from repo slug
ORG="${REPO%%/*}"

# Look up project if needed
PROJECT_ID=""
PROJECT_TITLE=""
if [[ "$SKIP_PROJECT" != true && -n "$PROJECT_NUM" ]]; then
    echo "Looking up project #${PROJECT_NUM} in ${ORG}..."
    PROJECT_QUERY='query { organization(login: "'"${ORG}"'") { projectV2(number: '"${PROJECT_NUM}"') { id title } } }'
    PROJECT_RESULT=$(gh api graphql -f "query=${PROJECT_QUERY}" 2>/dev/null || true)

    PROJECT_ID=$(echo "$PROJECT_RESULT" | jq -r '.data.organization.projectV2.id')
    PROJECT_TITLE=$(echo "$PROJECT_RESULT" | jq -r '.data.organization.projectV2.title')

    if [[ -z "$PROJECT_ID" || "$PROJECT_ID" == "null" ]]; then
        echo "Warning: Could not find project #${PROJECT_NUM} in organization ${ORG}"
        PROJECT_ID=""
    fi
fi

echo "Setting up issue #${ISSUE_NUM} in ${REPO}..."

# 1. Add labels
if [[ ${#LABELS[@]} -gt 0 ]]; then
    LABEL_CSV=$(IFS=,; echo "${LABELS[*]}")
    echo "Adding labels: ${LABEL_CSV}..."
    gh issue edit "$ISSUE_NUM" --repo "$REPO" --add-label "$LABEL_CSV" 2>/dev/null || \
        echo "Warning: Could not add labels (some may not exist in repo)"
fi

# 2. Set issue type via GraphQL
ISSUE_NODE_ID=$(gh api "repos/${REPO}/issues/${ISSUE_NUM}" --jq '.node_id')
REPO_OWNER="${REPO%%/*}"
REPO_NAME="${REPO##*/}"

if [[ -n "$ISSUE_TYPE" ]]; then
    echo "Setting issue type to ${ISSUE_TYPE}..."

    # Look up issue type node ID by name
    TYPES_QUERY='query { repository(owner: "'"${REPO_OWNER}"'", name: "'"${REPO_NAME}"'") { issueTypes(first: 20) { nodes { id name } } } }'
    ISSUE_TYPE_ID=$(gh api graphql -f "query=${TYPES_QUERY}" --jq ".data.repository.issueTypes.nodes[] | select(.name == \"${ISSUE_TYPE}\") | .id" 2>/dev/null || true)

    if [[ -z "$ISSUE_TYPE_ID" ]]; then
        echo "Warning: Issue type '${ISSUE_TYPE}' not found in ${REPO}"
    else
        # Use a temp file for the mutation to avoid shell escaping issues with GraphQL variables
        MUTATION_FILE=$(mktemp)
        cat > "$MUTATION_FILE" << 'GRAPHQL'
mutation($id: ID!, $typeId: ID!) {
  updateIssue(input: {id: $id, issueTypeId: $typeId}) {
    issue { id }
  }
}
GRAPHQL
        gh api graphql -F "query=@${MUTATION_FILE}" -f id="${ISSUE_NODE_ID}" -f typeId="${ISSUE_TYPE_ID}" \
            2>/dev/null || echo "Warning: Could not set issue type"
        rm -f "$MUTATION_FILE"
    fi
fi

# 3. Add to project via GraphQL (if not skipped and project was found)
if [[ "$SKIP_PROJECT" != true && -n "$PROJECT_ID" ]]; then
    echo "Adding to ${PROJECT_TITLE} project..."
    MUTATION_FILE=$(mktemp)
    cat > "$MUTATION_FILE" << 'GRAPHQL'
mutation($projectId: ID!, $contentId: ID!) {
  addProjectV2ItemById(input: {projectId: $projectId, contentId: $contentId}) {
    item { id }
  }
}
GRAPHQL
    gh api graphql -F "query=@${MUTATION_FILE}" -f projectId="${PROJECT_ID}" -f contentId="${ISSUE_NODE_ID}" \
        2>/dev/null || echo "Warning: Could not add issue to project"
    rm -f "$MUTATION_FILE"
fi

echo "Done! Issue #${ISSUE_NUM} has been set up."
if [[ ${#LABELS[@]} -gt 0 ]]; then
    echo "  - Labels: ${LABEL_CSV}"
fi
if [[ -n "$ISSUE_TYPE" ]]; then
    echo "  - Type: ${ISSUE_TYPE}"
fi
if [[ "$SKIP_PROJECT" != true && -n "$PROJECT_NUM" ]]; then
    echo "  - Project: ${PROJECT_TITLE} (#${PROJECT_NUM})"
fi
