---
description: Start the Autonomous AI Developer Pipeline sequence with a new idea
---

`/startcycle <idea>` で `.agents/agents.md` と `.agents/skills/` に従い開発サイクルを統括する。`/startcycle resume` は `docs/runs/.current` の `STATE.md` を読んで続きから再開する。

記録・CLI 呼出・検証は `.agents/scripts/` を使う（手書きしない）。各ステップは**完了直後に `log.sh` と `state.sh` を実行**してから次へ進む。

| Step | 担当 | スキル | 完了条件 / コミット |
|:-:|:---|:---|:---|
| 0 | — | `track_progress.md` `manage_quota.md` | モード決定 → `scripts/run_init.sh <slug> "<要望>"`（未初期化の Git なら停止し `git init` を促す）→ 未コミット変更があれば `chore: baseline before <RUN_ID>` |
| 1 | @pm | `write_specs.md` | `docs/spec.md`（受入基準 AC 付き）＋`docs/ARCHITECTURE.md` → **停止して承認待ち**。承認後 `docs(spec): approve spec for <RUN_ID>` |
| 2 | @engineer | `generate_code.md` | 実装＋`verify.sh` 通過（最大3回の修正ループ）→ `feat: <概要> (<RUN_ID>)` |
| 3 | @qa | `audit_code.md` | 機械検査外の監査・修正、`verify.sh` 再通過 → `fix(qa): <概要> (<RUN_ID>)` |
| 4 | @devops | `deploy_app.md` / `deploy_production.md`、Web は `verify_ui.md` | 起動/デプロイし URL と検証結果を報告 |
| 5 | — | `report_run.md` | `report.sh` の集計で `report.md`・`index.md` 生成 → `docs(run): add report for <RUN_ID>` → チャットに要約 |

- Step 1 の承認ゲートを省略・自動承認してはならない。承認時は `touch docs/runs/<RUN_ID>/APPROVED` を作成し、Step 2 開始前にその存在を確認する。
- 利用制限（`cli.sh` 終了コード 75）は `manage_quota.md` に従いユーザーに確認する。
