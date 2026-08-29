# Skill: Deploy Production / Cloud

## Objective
DevOps Master（@devops）として、`docs/spec.md` で事前に検討・承認されたデプロイ先およびホスティング方針に従い、`src/` 配下のアプリケーションを本番環境へデプロイする。

## Rules of Engagement
- **仕様準拠**: `docs/spec.md` の「Deployment & Hosting Strategy」で評価・指定されたデプロイ先（Google Cloud Run, Firebase Hosting, Vercel, AWS, Docker Container 等）とデプロイコマンド・手順に厳密に従う。
- **作業ディレクトリ**: `src/`（またはプロジェクトルート）
- **使用ツール**: ローカル環境に導入済みの CLI（`gcloud`, `firebase`, `vercel`, `docker` 等）や関連 MCP ツールを仕様に応じて選択する。

## Instructions
1. **デプロイ要件の読み取り**:
   - `docs/spec.md` を参照し、指定されたデプロイ先プラットフォーム、必要な環境変数、ビルド/デプロイ手順を確認する。
2. **構成・前提条件の検証**:
   - `src/` 内にデプロイに必要な設定ファイル（例: `Dockerfile`, `firebase.json`, `vercel.json`, `package.json` 等）が揃っているか確認する。不足があれば整備する。
3. **デプロイコマンドの実行**:
   - 仕様書で定義された手順に沿ってデプロイを実行する（例: `gcloud run deploy`, `firebase deploy`, `docker compose up` 等）。
4. **URL報告**:
   - デプロイ完了後、公開された本番 URL やアクセス情報をユーザーに報告する。

## 作業記録（必須）
- `track_progress.md` に従い、デプロイ後に `docs/runs/$RUN_ID/journal.md` へ `@devops` エントリを追記する。
- 記録必須項目: デプロイ先プラットフォーム / 実行したデプロイコマンド / ビルド結果 / 公開 URL / リビジョン識別子（例: Cloud Run のリビジョン名）。
- **シークレットは記録しない**: 環境変数名・参照先は記録してよいが、値（APIキー・トークン等）は journal / report に書かない。
- デプロイ失敗時も `❌ Blocked` としてエラー要約を必ず記録する。
