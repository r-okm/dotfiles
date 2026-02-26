---
name: fetch-pr-context
description: Fetch code review context (inline comments, verdicts, threads)
allowed-tools: Bash(gh *), Write
argument-hint: "<PR number>"
---

# Fetch PR Context

Retrieve review context for a pull request. The PR number is provided via `$ARGUMENTS`.

## Step 1: Review Verdicts

```bash
gh api '/repos/{owner}/{repo}/pulls/<number>/reviews' \
  --jq '[.[] | select(.body | length > 0)
    | {author: .user.login, state, body}]'
```

## Step 2: Inline Review Comments

```bash
gh api '/repos/{owner}/{repo}/pulls/<number>/comments' --paginate \
  --jq '[.[] | {id, path, line, author: .user.login,
    body: .body[0:200], in_reply_to_id}]'
```

## Step 3: Review Threads with Resolved Status (Optional — GraphQL)

Use this step when you need to:
- Filter to only unresolved review threads
- Exclude already-resolved threads
- Identify outdated comments

Write the following query to `/tmp/review-threads.graphql`:

```graphql
query($owner: String!, $repo: String!, $number: Int!) {
  repository(owner: $owner, name: $repo) {
    pullRequest(number: $number) {
      reviewThreads(first: 100) {
        nodes {
          id
          isResolved
          isOutdated
          comments(first: 10) {
            nodes { author { login } path line body }
          }
        }
      }
    }
  }
}
```

Limitation: `reviewThreads(first: 100)` and `comments(first: 10)` cap results. Large PRs may have truncated output.

Execute:

```bash
gh api graphql -F query=@/tmp/review-threads.graphql \
  -f owner="$(gh repo view --json owner --jq '.owner.login')" \
  -f repo="$(gh repo view --json name --jq '.name')" \
  -F number=<number>
```

To extract only unresolved threads:

```bash
| jq '[.data.repository.pullRequest.reviewThreads.nodes[]
  | select(.isResolved == false)
  | {id, path: .comments.nodes[0].path,
     line: .comments.nodes[0].line,
     author: .comments.nodes[0].author.login,
     body: .comments.nodes[0].body}]'
```
