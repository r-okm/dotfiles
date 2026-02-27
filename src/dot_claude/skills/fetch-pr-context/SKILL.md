---
name: fetch-pr-context
description: Fetch code review context (inline comments, verdicts, threads)
allowed-tools: Bash(gh *)
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

First, get the repository owner and name:

```bash
gh repo view --json owner,name --jq '{owner: .owner.login, name: .name}'
```

Then run the GraphQL query, replacing owner/repo/number with actual values:

```bash
gh api graphql -f query='{
  repository(owner: "<owner>", name: "<repo>") {
    pullRequest(number: <number>) {
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
}'
```

Limitation: `reviewThreads(first: 100)` and `comments(first: 10)` cap results. Large PRs may have truncated output.

To extract only unresolved threads, append the following `jq` filter:

```bash
| jq '[.data.repository.pullRequest.reviewThreads.nodes[]
  | select(.isResolved == false)
  | {id, path: .comments.nodes[0].path,
     line: .comments.nodes[0].line,
     author: .comments.nodes[0].author.login,
     body: .comments.nodes[0].body}]'
```
