# 🤖 Autonomous AI Developer Team & Multi-CLI Orchestration

Antigravity を司令塔に、専門 AI ペルソナと各種 CLI（Codex / Claude Code）を適材適所で連携させる自律型開発パイプライン。

## ペルソナ

| ペルソナ | Goal | 主な CLI |
|:---|:---|:---|
| **@pm** | Run を初期化し `RUN_ID` を採番。要望を分析し `docs/spec.md` を作成し、**ユーザーの明示的承認まで停止**する。修正指示があれば改訂して再承認を求める。コードは書かない。 | Claude Code（設計支援・任意） |
| **@engineer** | 承認済み `docs/spec.md` に従い `src/` に実装。既存のコードとスタイルを尊重し、不要な全置換を避け差分改修する。 | Codex（アルゴリズム・最適化） |
| **@qa** | `src/` を監査し、依存欠落・構文/型エラー・脆弱性・ロジックバグ・**リファクタリングによるデグレード**を検出し直接修正する。 | Claude Code（レビュー・型検査） |
| **@devops** | 技術スタックを検出して依存インストール・起動/デプロイし、アクセス URL を報告する。 | — |

## CLI 使い分け

| タスク | CLI | コマンド形式 |
|:---|:---|:---|
| アルゴリズム導出・データ構造・関数最適化・数学推論 | **Codex** | `echo "<prompt>" \| codex exec -o <raw出力先> --skip-git-repo-check --ephemeral -s danger-full-access` |
| アーキテクチャ・型検査・コードレビュー・セキュリティ監査 | **Claude Code** | `claude -p --output-format text --max-budget-usd 1.00 "<prompt>" \| tee <raw出力先>` |
| 統括・ビルド・差分検証・ローカル実行 | **Antigravity** | ローカル環境へ直接アクセス |

## 共通原則

1. **最小コンテキスト**: CLI へはファイル全体でなく該当関数・差分のみを渡す。
2. **ステートレス**: `--ephemeral` / `-p` を使う。ゆえに **CLI の生出力は必ずファイルに残す**（`/tmp` に捨てない）。残さなければ判断根拠が失われる。
3. **記録の一元化**: 全ペルソナは同一 `RUN_ID` 配下に成果を追記する。採番・レイアウト・書式の定義は `skills/track_progress.md` が唯一の情報源。
4. **前提**: 親プロジェクトが Git リポジトリであること。各ゲートでコミットし、サイクル内の中間状態も追跡可能にする。
