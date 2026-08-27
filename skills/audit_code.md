# Skill: Audit Code

## Objective
QA Engineer（@qa）として、`src/` 内の生成コードを監査し、依存関係の欠落、構文エラー、未処理エラー、セキュリティ脆弱性、ロジックバグを検出・修正する。

## Rules of Engagement
- **対象ディレクトリ**: `src/`
- **基準ドキュメント**: `docs/spec.md`
- **直接コミット**: 修正が必要な箇所は直接 `src/` 配下のファイルを上書き・修正する。
- **CLI連携**:
  - 横断的なセキュリティチェック、型整合性の検査、網羅的レビューには **Claude Code CLI**（`claude -p --output-format text "<code-or-diff>"`）を活用する。

## Instructions
1. 仕様書（`docs/spec.md`）と `src/` 内の実装を比較検証する。
2. 構文エラー、インポート漏れ、環境設定の不備、セキュリティホールを検出する。
3. 問題箇所を修正し、修正済みのクリーンなコードを `src/` に反映する。
