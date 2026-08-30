# Skill: Deploy App（@devops / ローカル）

`src/`（またはプロジェクトルート）の技術スタックを自動判定し、依存関係のインストールとローカルサーバー起動を行う。

## Rules
- **非同期実行**: サーバー起動コマンド（`npm run dev`, `python3 app.py`, `serve` 等）はバックグラウンドで起動する。
- **記録**: `track_progress.md` に従い `@devops` エントリを追記。検出スタック / install・起動コマンド / ポート / URL / 起動ログ要点を残す。起動失敗時も `❌ Blocked` としてエラー要約を必ず記録し、動作確認未実施なら「未検証」と明記する。

## Instructions
1. **スタック検出**: `package.json` / `requirements.txt` / `index.html` 等からランタイムを判定する。
2. **依存インストール**: `npm install`、`pip install -r requirements.txt` 等を実行する。
3. **起動**: 開発サーバーまたはローカル HTTP サーバーをバックグラウンドで起動する。
4. **URL報告**: クリック可能な URL（例 `http://localhost:3000` / `file:///...`）をユーザーに報告する。
5. **動作確認**: Web アプリの場合は `verify_ui.md` に従う。対話的なブラウザ操作で確認を繰り返してはならない。
