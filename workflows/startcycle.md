---
description: Start the Autonomous AI Developer Pipeline sequence with a new idea
---

`/startcycle <idea>` で、`.agents/agents.md` と `.agents/skills/` に厳密に従い開発サイクルを統括する。

**全ステップ共通**: Step 0 で `.agents/skills/track_progress.md` を一度読み、その記録規約を全ステップに適用する。各ステップは**完了直後に journal へ追記してから**次へ進む。

| Step | 担当 | スキル | 完了条件 / コミット |
|:-:|:---|:---|:---|
| 0 | — | `track_progress.md` | Git リポジトリか確認（未初期化なら**開始せず** `git init` を促す）→ `RUN_ID` 採番 → `docs/runs/<RUN_ID>/raw/` と journal ヘッダ作成 → 未コミット変更があれば `chore: baseline before <RUN_ID>` |
| 1 | @pm | `write_specs.md` | `docs/spec.md` 作成 → **停止してユーザー承認を待つ**。修正指示があれば改訂し再承認（往復ごとに前版をコミット）→ 承認後 `docs(spec): approve spec for <RUN_ID>` |
| 2 | @engineer | `generate_code.md` | `src/` に実装 → `feat: <概要> (<RUN_ID>)` |
| 3 | @qa | `audit_code.md` | 監査・修正 → `fix(qa): <概要> (<RUN_ID>)` |
| 4 | @devops | `docs/spec.md` の Deployment 方針に従い `deploy_app.md`（ローカル）または `deploy_production.md`（本番） | 起動/デプロイし URL を報告 |
| 5 | — | `report_run.md` | `report.md` 生成 + `index.md` 追記 → `docs(run): add report for <RUN_ID>` → **チャットに結果サマリを提示** |

Step 1 の承認ゲートを省略・自動承認してはならない。
