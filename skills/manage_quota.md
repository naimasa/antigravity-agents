# Skill: Manage Quota（CLI 消費量の記録とルーティング制御）

Gemini（Antigravity）に負荷が偏り Quota を使い切る問題を防ぐ。**残量の自動照会はできない**ため、
「消費量を実測して積み上げる」＋「ユーザーが宣言した上限に対する残量推定」＋「モードによる手動切替」で運用する。

## 各サービスから取得できるもの
| サービス | 残量照会 | 実測できる消費量 |
|:---|:---|:---|
| Antigravity / Gemini | ✗（IDE の UI 表示のみ） | 自前処理したタスク数＋**対話的ブラウザ操作のステップ数**（スクリーンショットを伴うため単価が高い） |
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

## 利用制限（Usage Limit / Rate Limit）到達時のハンドリング

CLI の実行中に利用制限エラー（429 Too Many Requests、Rate limit exceeded、Quota/Credit exhausted 等）が発生した場合の処理手順：

1. **エラー検知と一時停止**:
   - CLI の終了コードやエラー出力を検知し、処理を直ちに一時停止する。
   - 勝手に自前処理（Antigravity 直接実行）へフォールバックしたり、エラーを無視して次へ進んではならない。

2. **ユーザーへの選択肢提示と確認**:
   - チャット上でユーザーに対し、利用制限に達した CLI/サービス名とエラー内容を報告する。
   - 以下の選択肢を提示し、**代替モデルで続行するか解除を待つか**の判断を仰ぐ：
     - **選択肢 A（代替 CLI / モデルで続行）**:
       - Codex が制限時: `Claude Code`（または利用可能な別モデル）に切り替えて実行。
       - Claude Code が制限時: `Codex`（または利用可能な別モデル）に切り替えて実行。
     - **選択肢 B（Antigravity / Gemini 自前処理で続行）**:
       - 外部 CLI を使わず、Antigravity が直接コード生成/レビュー等を肩代わりして続行。
     - **選択肢 C（利用制限の解除待ち）**:
       - 処理を一時停止（Pause）したまま待機し、制限解除後にユーザーからの再開指示（「再開」「resume」等）を受けて同一 CLI で再試行。

3. **記録**:
   - `journal.md` に選択待ち状態（`⏸ Awaiting User Decision`）または確定した選択肢（フォールバック理由・変更先モデル）を記録する。
   - `docs/runs/usage.md` および `report.md` にも、制限到達とフォールバックの経緯を明記する。

## `docs/runs/usage.md`（累積台帳 / 初回のみ作成）
```markdown
# Usage Ledger

| Run ID | 日時 | mode | Gemini自前 | ブラウザ操作 | Codex呼出 | Claude呼出 | Claude実測USD | 委譲率 |
|:---|:---|:---|--:|--:|--:|--:|--:|--:|
| <RUN_ID> | 2026-08-29 14:30 | balanced | 3 | 0 | 4 | 5 | 0.42 | 75% |
```
**委譲率** = CLI 呼び出し数 ÷（CLI 呼び出し数 + Gemini 自前処理数）。
`balanced` で継続的に 50% を下回る場合、委譲規約が守られていない兆候として report に警告を記載する。
