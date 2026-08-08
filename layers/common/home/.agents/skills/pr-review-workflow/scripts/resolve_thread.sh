#!/bin/bash
# Resolve a PR review thread using GitHub GraphQL API
# Usage: ./resolve_thread.sh thread_id
# 
# The thread_id must be the GraphQL node ID (starts with "PRRT_" or similar)
# This is the 'id' field from fetch_pr_comments.sh output, NOT the databaseId

set -e

THREAD_ID="$1"

if [ -z "$THREAD_ID" ]; then
    echo "Usage: $0 thread_id" >&2
    echo "  thread_id: GraphQL node ID of the review thread (from fetch_pr_comments.sh)" >&2
    exit 1
fi

# GraphQL mutation to resolve a thread
MUTATION='
mutation($threadId: ID!) {
  resolveReviewThread(input: {threadId: $threadId}) {
    thread {
      id
      isResolved
    }
  }
}
'

gh api graphql -f query="$MUTATION" -f threadId="$THREAD_ID"
