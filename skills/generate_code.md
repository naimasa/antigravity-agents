# Skill: Generate Code

## Objective
Full-Stack Engineer（@engineer）として、承認された `docs/spec.md` に基づき、新規実装または既存コードのリファクタリングを行い、`src/` 配下に完全な動作コードを生成・更新する。

## Rules of Engagement
- **Dynamic & Safe Coding**:
  - 新規作成時: 仕様書で指定された言語・フレームワークに厳密に従い、完全なファイル群を生成する。
  - リファクタリング時: 既存のコードベースとコーディングスタイルを尊重し、不要な全置換を避け、**対象箇所を安全に差分改修（In-place Refactoring）** する。既存の正常な機能やコメントを無闇に消去しない。
- **出力先**: すべてのソースコードおよび設定ファイルを `src/`（またはプロジェクトルート）内に正確なフォルダ構造で配置する。
- **CLI連携**:
  - 複雑なアルゴリズム導出・データ構造設計・パフォーマンスボトルネック関数の局所最適化は **Codex CLI** を活用する。
  - 生出力は破棄せず Run ディレクトリへ保存する: `echo "..." | codex exec -o docs/runs/$RUN_ID/raw/<NN>-codex-engineer-<topic>.md --skip-git-repo-check --ephemeral -s danger-full-access`

## Instructions
1. `docs/spec.md` を精読し、要求仕様と変更範囲（新規 or リファクタリング）を把握する。
2. 既存コードがある場合は事前にコード構造を把握した上で、適切なファイルに修正・機能追加・リファクタリングを適用する。
3. すべてのバックエンド・フロントエンドコード、設定ファイルを `src/` に完全に出力・更新する（省略やプレースホルダーは禁止）。

## 作業記録（必須）
- `track_progress.md` に従い、実装完了直後に `docs/runs/$RUN_ID/journal.md` へ `@engineer` エントリを追記する。
- 「Changed Files」は `git diff --stat` の実測値を転記する（記憶で書かない）。
- 実装後にコミットする: `git add -A && git commit -m "feat: <実装概要> (<RUN_ID>)"`
  - これにより、後続の @qa による修正差分が「QA が何を直したか」として独立して見えるようになる。
- プレースホルダーのまま残した箇所・未実装の要件があれば、隠さず journal の **Findings / Issues** に列挙する。
