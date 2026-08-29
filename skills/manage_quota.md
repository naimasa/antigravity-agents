# Skill: Manage Quota（CLI 消費量の記録とルーティング制御）

Gemini（Antigravity）に負荷が偏り Quota を使い切る問題を防ぐ。**残量の自動照会はできない**ため、
「消費量を実測して積み上げる」＋「ユーザーが宣言した上限に対する残量推定」＋「モードによる手動切替」で運用する。

## 各サービスから取得できるもの
| サービス | 残量照会 | 実測できる消費量 |
|:---|:---|:---|
| Antigravity / Gemini | ✗（IDE の UI 表示のみ） | 自前処理したタスク数（委譲しなかった件数） |
| Claude Code CLI | ✗（`usage` 系サブコマンドなし） | `--output-format json` の `total_cost_usd` / `usage` / `modelUsage` |
| Codex CLI | ✗ | 呼び出し回数 |

Claude の実測例: `claude -p --output-format json ... > raw/NN-....json` の後
`jq -r '.total_cost_usd, .usage.input_tokens, .usage.output_tokens' raw/NN-....json`

## `.agents/quota.local.yml`（任意 / 親プロジェクトで gitignore 推奨）
無ければ `mode: balanced` として扱い、警告は出さない。
```yaml
mode: balanced          # balanced | gemini-saver | local-only
limits:                 # ユーザーが自分のプランを見て手入力する。省略可
  gemini:  { window: "5h", requests: 100 }
  claude:  { window: "5h", usd: 5.00 }
  codex:   { window: "5h", requests: 50 }
```

## 手順
1. **Step 0（preflight）**: `quota.local.yml` を読み `mode` を Run 全体に適用する。`docs/runs/usage.md` の
   直近ウィンドウ内の消費を合計し、`limits` の 80% を超えるサービスがあればユーザーに提示して
   モード変更を提案する（超過していても勝手に停止はしない）。
2. **各 CLI 呼び出し後**: journal の `Cost` 欄に実測値を記録する（`track_progress.md` の書式）。
3. **Step 5**: `report_run.md` が Run 合計を集計し、`docs/runs/usage.md` に 1 行追記する。

## `docs/runs/usage.md`（累積台帳 / 初回のみ作成）
```markdown
# Usage Ledger

| Run ID | 日時 | mode | Gemini自前 | Codex呼出 | Claude呼出 | Claude実測USD | 委譲率 |
|:---|:---|:---|--:|--:|--:|--:|--:|
| <RUN_ID> | 2026-08-29 14:30 | balanced | 3 | 4 | 5 | 0.42 | 75% |
```
**委譲率** = CLI 呼び出し数 ÷（CLI 呼び出し数 + Gemini 自前処理数）。
`balanced` で継続的に 50% を下回る場合、委譲規約が守られていない兆候として report に警告を記載する。
