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
    PROJECT_RESULT=$(gh api graphql -f query="
    query {
        organization(login: \"${ORG}\") {
            projectV2(number: ${PROJECT_NUM}) {
                id
                title
            }
        }
    }")

    PROJECT_ID=$(echo "$PROJECT_RESULT" | jq -r '.data.organization.projectV2.id')
    PROJECT_TITLE=$(echo "$PROJECT_RESULT" | jq -r '.data.organization.projectV2.title')

    if [[ -z "$PROJECT_ID" || "$PROJECT_ID" == "null" ]]; then
        echo "Error: Could not find project #${PROJECT_NUM} in organization ${ORG}"
        exit 1
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

if [[ -n "$ISSUE_TYPE" ]]; then
    echo "Setting issue type to ${ISSUE_TYPE}..."
    gh api graphql -f query="
    mutation {
        updateIssue(input: {
            id: \"${ISSUE_NODE_ID}\",
            issueTypeId: \"${ISSUE_TYPE}\"
        }) {
            issue { id }
        }
    }" 2>/dev/null || echo "Warning: Could not set issue type (may require different API)"
fi

# 3. Add to project (if not skipped and project specified)
if [[ "$SKIP_PROJECT" != true && -n "$PROJECT_NUM" ]]; then
    echo "Adding to ${PROJECT_TITLE} project..."
    gh api graphql -f query="
    mutation {
        addProjectV2ItemById(input: {
            projectId: \"${PROJECT_ID}\",
            contentId: \"${ISSUE_NODE_ID}\"
        }) {
            item { id }
        }
    }"
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
