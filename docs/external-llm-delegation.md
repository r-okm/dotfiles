# Claude Code サブエージェントから外部 LLM CLI への委譲

Claude Code のカスタムサブエージェントから Copilot CLI 等の外部 LLM CLI に
タスクを委譲することで、Claude のトークン消費を節約するパターン。

## 目的

Web 検索・URL 取得などトークン消費が大きいタスクを外部 LLM CLI に委譲し、
Claude 側のトークン消費を抑える。

## アーキテクチャ

```
Claude Code (main conversation)
  └── Task tool → カスタムサブエージェント (haiku)
                    └── Bash tool → 外部 LLM CLI (copilot, gemini, etc.)
                                      └── web_fetch / web_search
```

- サブエージェント自体は haiku で実行（オーケストレーションのみ）
- トークン消費の大きい Web 操作は外部 CLI が処理
- サブエージェントは結果を要約して返す

## サブエージェント定義

`.claude/agents/<name>.md` に Markdown + YAML frontmatter で定義する。

```markdown
---
name: my-researcher
description: <Task tool の自動マッチに使われる説明文>
tools: Bash, WebFetch, WebSearch
model: haiku
permissionMode: default
---

<システムプロンプト>
```

| フィールド | 説明 |
|------------|------|
| `name` | エージェント名 |
| `description` | Task tool による自動ルーティングのマッチ対象 |
| `tools` | 使用可能なツール (Bash, Read, Grep, Glob, WebFetch, WebSearch, etc.) |
| `model` | 実行モデル (haiku / sonnet / opus / inherit) |
| `permissionMode` | `default` (都度確認) / `bypassPermissions` (自動許可) |

## タスク粒度の設計

### 原則: 1 コール = 1 タスク

外部 CLI への 1 回の呼び出しは、1 つの検索クエリまたは 1 つの URL 取得に
限定する。複数のタスクを 1 回の呼び出しに詰め込むとタイムアウトの原因になる。

```
# Bad: 複数トピックを 1 コールに詰め込む
copilot -p "AとBとCについて調べて比較して" -s

# Good: トピックごとに分割
copilot -p "Aについて調べて" -s
copilot -p "Bについて調べて" -s
copilot -p "CについてAとBとの違いを説明して" -s
```

### 分解→実行→統合パターン

サブエージェントが以下の手順で処理する:

1. **Decompose** — リクエストをサブタスクに分解（1 サブタスク = 1 検索 or 1 URL）
2. **Execute** — サブタスクごとに外部 CLI を呼び出す。独立したサブタスクは並列実行可能
3. **Fall back** — 失敗したサブタスクのみ別手段（WebFetch/WebSearch）にフォールバック
4. **Synthesize** — 全サブタスクの結果を統合して要約を返す

### 並列実行

独立したサブタスクは、サブエージェントが複数の Bash tool call を
1 レスポンスで発行することで並列実行できる。ただし同時実行数が多すぎると
レート制限に当たる可能性がある。

## タイムアウト対策

### timeout コマンド

外部 CLI の呼び出しには必ず `timeout` をつける。

```bash
timeout 120 copilot -p "<prompt>" -s --model <model> --allow-tool 'web_fetch'
```

- exit code 124 = タイムアウト
- タスク粒度が適切なら 120 秒で十分

### リトライ戦略

```
失敗 (exit 124 or 空出力)
  → 5 秒待機
  → リトライ (1 回のみ)
  → 再度失敗 → フォールバック (WebFetch/WebSearch)
```

- リトライは該当サブタスクのみ。他のサブタスクは引き続き外部 CLI を使用
- 5 秒待機はレート制限回避のため

## プロンプト設計

### 外部 CLI に渡すプロンプト

- **短く具体的に**: 1 つの質問 or 1 つの URL
- **リサーチ全体を渡さない**: サブエージェントが分解した個別タスクのみ
- **出力形式を指定しない**: 外部 CLI の出力はサブエージェントが加工する

### サブエージェントのシステムプロンプト

- **手順を明示的に**: haiku 等の小型モデルには暗黙的な指示より明示的な手順
- **ルールを箇条書きで**: 「〜するな」を明確に列挙
- **短く保つ**: システムプロンプトが長いとトークン節約の意味が薄れる

## パーミッション設定

`settings.json` で外部 CLI の実行を許可する。

```json
{
  "permissions": {
    "allow": [
      "Bash(timeout 120 copilot:*)"
    ]
  }
}
```

- プレフィックスマッチのため、`timeout 120 copilot` で始まるコマンドはすべて許可
- `--allow-all` や `--allow-tool 'write'` は禁止（安全性のため）

## モデル選定の指針

| 役割 | 推奨モデル | 理由 |
|------|------------|------|
| メイン会話 (Claude Code) | opus / sonnet | 複雑な判断・コード生成 |
| オーケストレーション (サブエージェント) | haiku | 分解・統合のみ、低コスト |
| Web 研究 (外部 CLI 経由) | haiku | 検索・取得がメイン、推論不要 |
| コードレビュー | sonnet / opus | 品質判断に高い推論能力が必要 |

サブエージェントの `model` フィールドは Claude 側の実行モデル。
外部 CLI に渡す `--model` は CLI 側のモデル（別のトークン予算）。

## 実装例: copilot-web-researcher

```markdown
---
name: copilot-web-researcher
description: Use when you need to fetch documentation, technical articles,
  API references, or any web content. Delegates to Copilot CLI to avoid
  Claude rate limits, with WebFetch/WebSearch as fallback.
tools: Bash, WebFetch, WebSearch
model: haiku
permissionMode: default
---

You are a web research agent. Gather information from the web and return
concise summaries to the caller. Do not return raw web content.

## Procedure

1. **Decompose** — Break the request into focused sub-tasks. Each
   sub-task is ONE search query or ONE URL fetch.
2. **Execute** — Run each sub-task as a separate Copilot CLI call.
   Independent sub-tasks can be run in parallel via multiple Bash
   calls in a single response.
3. **Fall back** — If a call fails twice, use WebFetch/WebSearch for
   that sub-task only. Continue using Copilot for remaining sub-tasks.
4. **Synthesize** — Combine all results into a single summary.

## Copilot CLI invocation

Each call must have a short, specific prompt (one question or one URL).

    timeout 120 copilot -p "<focused prompt>" -s \
      --model claude-haiku-4.5 \
      --allow-tool 'web_fetch' --allow-tool 'web_search'

Rules:
- Do NOT use `--allow-all` or `--allow-tool 'write'`.
- Do NOT pass the full research brief as the prompt. Extract one
  specific question per call.
- On timeout (exit 124) or empty output, wait 5 seconds, then retry
  once. On second failure, use WebFetch/WebSearch for that sub-task.
```

## 既知の制約

- サブエージェントは他のサブエージェントを起動できない（ネスト不可）
- 外部 CLI の並列実行はレート制限に注意
- haiku の分解能力には限界がある（複雑すぎるリクエストでは sonnet を検討）
- 外部 CLI のトークン予算は別管理（Copilot: ~300 premium requests/月 @ $10/月）
