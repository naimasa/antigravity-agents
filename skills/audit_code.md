# Skill: Audit Code

## Objective
QA Engineer（@qa）として、`app_build/` 内の生成コードを監査し、依存関係の欠落、構文エラー、未処理エラー、セキュリティ脆弱性、ロジックバグを検出・修正する。

## Rules of Engagement
- **対象ディレクトリ**: `app_build/`
- **基準ドキュメント**: `production_artifacts/Technical_Specification.md`
- **直接コミット**: 修正が必要な箇所は直接 `app_build/` 配下のファイルを上書き・修正する。
- **CLI連携**:
  - 横断的なセキュリティチェック、型整合性の検査、網羅的レビューには **Claude Code CLI**（`claude -p --output-format text "<code-or-diff>"`）を活用する。

## Instructions
1. 仕様書（`production_artifacts/Technical_Specification.md`）と `app_build/` 内の実装を比較検証する。
2. 構文エラー、インポート漏れ、環境設定の不備、セキュリティホールを検出する。
3. 問題箇所を修正し、修正済みのクリーンなコードを `app_build/` に反映する。
