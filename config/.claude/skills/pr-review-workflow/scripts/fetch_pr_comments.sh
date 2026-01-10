#!/bin/bash
# Fetch all review comment threads for a PR using GitHub GraphQL API
# Usage: ./fetch_pr_comments.sh owner repo pr_number

set -e

OWNER="$1"
REPO="$2"
PR_NUMBER="$3"

if [ -z "$OWNER" ] || [ -z "$REPO" ] || [ -z "$PR_NUMBER" ]; then
    echo "Usage: $0 owner repo pr_number" >&2
    exit 1
fi

# GraphQL query to fetch review threads with all comments
QUERY='
query($owner: String!, $repo: String!, $pr: Int!, $cursor: String) {
  repository(owner: $owner, name: $repo) {
    pullRequest(number: $pr) {
      reviewThreads(first: 100, after: $cursor) {
        pageInfo {
          hasNextPage
          endCursor
        }
        nodes {
          id
          isResolved
          isOutdated
          path
          line
          startLine
          diffSide
          comments(first: 50) {
            nodes {
              id
              databaseId
              body
              author {
                login
              }
              createdAt
              url
            }
          }
        }
      }
    }
  }
}
'

# Fetch all pages and combine results
ALL_THREADS="[]"
CURSOR=""
HAS_NEXT="true"

while [ "$HAS_NEXT" = "true" ]; do
    if [ -z "$CURSOR" ]; then
        RESULT=$(gh api graphql -f query="$QUERY" \
            -f owner="$OWNER" \
            -f repo="$REPO" \
            -F pr="$PR_NUMBER")
    else
        RESULT=$(gh api graphql -f query="$QUERY" \
            -f owner="$OWNER" \
            -f repo="$REPO" \
            -F pr="$PR_NUMBER" \
            -f cursor="$CURSOR")
    fi
    
    # Extract threads from this page
    THREADS=$(echo "$RESULT" | jq '.data.repository.pullRequest.reviewThreads.nodes')
    
    # Combine with existing threads
    ALL_THREADS=$(echo "$ALL_THREADS" "$THREADS" | jq -s 'add')
    
    # Check for next page
    HAS_NEXT=$(echo "$RESULT" | jq -r '.data.repository.pullRequest.reviewThreads.pageInfo.hasNextPage')
    CURSOR=$(echo "$RESULT" | jq -r '.data.repository.pullRequest.reviewThreads.pageInfo.endCursor')
done

# Output all threads as JSON
echo "$ALL_THREADS" | jq '.'
