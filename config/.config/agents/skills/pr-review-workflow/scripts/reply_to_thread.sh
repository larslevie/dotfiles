#!/bin/bash
# Reply to a PR review comment thread
# Usage: ./reply_to_thread.sh owner repo pr_number comment_id "reply body"

set -e

OWNER="$1"
REPO="$2"
PR_NUMBER="$3"
COMMENT_ID="$4"
BODY="$5"

if [ -z "$OWNER" ] || [ -z "$REPO" ] || [ -z "$PR_NUMBER" ] || \
   [ -z "$COMMENT_ID" ] || [ -z "$BODY" ]; then
    echo "Usage: $0 owner repo pr_number comment_id \"reply body\"" >&2
    exit 1
fi

# Use the REST API to create a reply to a review comment
# The comment_id should be the databaseId of the comment being replied to
gh api \
    --method POST \
    "/repos/${OWNER}/${REPO}/pulls/${PR_NUMBER}/comments/${COMMENT_ID}/replies" \
    -f body="$BODY"
