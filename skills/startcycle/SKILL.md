---
name: startcycle
description: 新しい開発要望（新規アプリ・機能追加・リファクタリング）を受けて自律開発サイクル（仕様→実装→検証→QA→デプロイ→レポート）を統括する。/startcycle <要望> または /startcycle resume で起動する。
---

最初に `.agents/agents.md`（ペルソナ・ルーティング・原則）を読む。再開（`resume`）時は `docs/runs/.current` が指す Run の `STATE.md` を読んで続きから進める。

`/startcycle <要望>` で `.agents/agents.md` と各 skill に従い開発サイクルを統括する。`/startcycle resume` は上記のとおり再開する。

記録・CLI 呼出・検証は `.agents/scripts/` を使う（手書きしない）。各ステップは**完了直後に `log.sh` と `state.sh` を実行**してから次へ進む。

| Step | 担当 | スキル | 完了条件 / コミット |
|:-:|:---|:---|:---|
| 0 | — | `track-progress` `manage-quota` | モード決定 → `scripts/run_init.sh <slug> "<要望>"`（未初期化の Git なら停止し `git init` を促す）→ 未コミット変更があれば `chore: baseline before <RUN_ID>` |
| 1 | @pm | `write-specs` | `docs/spec.md`（受入基準 AC 付き）＋`docs/ARCHITECTURE.md` → **停止して承認待ち**。承認後 `docs(spec): approve spec for <RUN_ID>` |
| 2 | @engineer | `generate-code` | 実装＋`verify.sh` 通過（最大3回の修正ループ）→ `feat: <概要> (<RUN_ID>)` |
| 3 | @qa | `audit-code` | 機械検査外の監査・修正、`verify.sh` 再通過 → `fix(qa): <概要> (<RUN_ID>)` |
| 4 | @devops | `deploy-app` / `deploy-production`、Web は `verify-ui` | 起動/デプロイし URL と検証結果を報告 |
| 5 | — | `report-run` | `report.sh` の集計で `report.md`・`index.md` 生成 → `docs(run): add report for <RUN_ID>` → チャットに要約 |

- Step 1 の承認ゲートを省略・自動承認してはならない。承認時は `touch docs/runs/<RUN_ID>/APPROVED` を作成し、Step 2 開始前にその存在を確認する。
- 利用制限（`cli.sh` 終了コード 75）は `manage-quota` に従いユーザーに確認する。
