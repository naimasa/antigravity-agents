# Skill: Audit Code（@qa）

`src/` のコードを監査し、依存関係の欠落・構文エラー・未処理エラー・セキュリティ脆弱性・ロジックバグ、および**リファクタリングによる既存機能のデグレード**を検出・修正する。

## Rules
- **対象**: `src/` ／ **基準**: `docs/spec.md`
- **範囲**: 本スキルは静的な監査を扱う。ブラウザ上での動作確認は `verify_ui.md` に従う。
- **デグレード防止を最優先**: 既存の要件・機能が壊れていないか、インターフェースの整合性が保たれているかを最重要視する。
- **直接修正**: 修正が必要な箇所は `src/` 配下のファイルを直接修正する。
- **委譲（既定）**: 監査本体は **Claude Code CLI へ委譲する**（`claude -p --permission-mode bypassPermissions --model sonnet --output-format json --max-budget-usd 2.00 "<prompt>" < /dev/null > docs/runs/$RUN_ID/raw/<NN>-claude-qa-<topic>.json`、モデルは **Sonnet** を基本とする。ただし複雑な不具合調査・深層原因追跡には **Opus**（`--model opus` / `--max-budget-usd 5.00`）を使用する）。自前監査で済ませてはならない（`local-only` モード時を除く）。`total_cost_usd` を journal の Cost に記録する。
- **利用制限のハンドリング**: Claude Code CLI 実行時に利用制限（Usage Limit / Rate Limit / 429 / 残高不足等）が発生した場合は勝手に自前処理へ倒さず、`manage_quota.md` に従って利用可能なモデルオプション（Codex、Antigravity 自前処理、制限解除待ち）を提示してユーザーに確認する。
- **記録**: `track_progress.md` に従い `@qa` エントリを追記 → `git add -A && git commit -m "fix(qa): <概要> (<RUN_ID>)"`。**検出項目は未対応分も含め全件**を下表で Findings に残す（黙って落とさない）。この表がそのまま `report_run.md` の QA セクションになる。

  | 検出項目 | 深刻度 (High/Med/Low) | 対応 (修正済み/未対応) | 備考 |
  |:---|:---|:---|:---|

## Instructions
1. `docs/spec.md` と `src/` の実装・差分を比較検証する。
2. 構文エラー・インポート漏れ・型不整合・セキュリティホール・デグレードを検出する。
3. 修正し、クリーンなコードを `src/` に反映する。
