# Skill: Deploy Production / Cloud（@devops）

`docs/spec.md` の「Deployment & Hosting Strategy」で承認された方針に従い、`src/` を本番環境へデプロイする。

## Rules
- **仕様準拠**: 指定されたデプロイ先（Cloud Run / Firebase Hosting / Vercel / AWS / Docker 等）と手順に厳密に従う。
- **使用ツール**: 導入済み CLI（`gcloud`, `firebase`, `vercel`, `docker` 等）や関連 MCP ツールを仕様に応じて選択する。
- **記録**: `track_progress.md` に従い `@devops` エントリを追記。プラットフォーム / デプロイコマンド / ビルド結果 / 公開 URL / リビジョン識別子を残す。**シークレットの値は記録しない**（変数名・参照先のみ可）。失敗時も `❌ Blocked` としてエラー要約を必ず記録する。

## Instructions
1. **要件読取**: `docs/spec.md` からデプロイ先・必要な環境変数・ビルド/デプロイ手順を確認する。
2. **前提検証**: 必要な設定ファイル（`Dockerfile`, `firebase.json`, `vercel.json`, `package.json` 等）の有無を確認し、不足があれば整備する。
3. **デプロイ実行**: 仕様書で定義された手順を実行する（`gcloud run deploy`, `firebase deploy`, `docker compose up` 等）。
4. **URL報告**: 公開された本番 URL・アクセス情報をユーザーに報告する。
