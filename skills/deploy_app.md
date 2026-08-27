# Skill: Deploy App (Local)

## Objective
DevOps Master（@devops）として、`src/`（またはプロジェクトルート）内の技術スタックを自動判定し、依存関係のインストールおよびローカルサーバーの起動を行う。

## Rules of Engagement
- **作業ディレクトリ**: `src/`（またはプロジェクトルート）
- **非同期実行**: サーバー起動コマンド（`npm run dev`, `python3 app.py`, `serve` 等）はバックグラウンドプロセス（Daemon / Async）として起動する。

## Instructions
1. **スタック検出**: `src/` 内の構成ファイル（`package.json`, `requirements.txt`, `index.html` 等）を確認し、適切なランタイムを判定する。
2. **依存関係インストール**: 必要に応じて `npm install` や `pip install -r requirements.txt` 等を実行する。
3. **ローカルサーバー起動**: 開発サーバーやローカルHTTPサーバーをバックグラウンドで起動する。
4. **URL報告**: ユーザーが直接アクセスできるクリック可能な URL（例: `http://localhost:3000` または `file:///...`）を報告する。
