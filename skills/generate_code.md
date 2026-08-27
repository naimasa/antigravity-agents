# Skill: Generate Code

## Objective
Full-Stack Engineer（@engineer）として、承認された `docs/spec.md` に基づき、`src/` ディレクトリ配下に完全な動作コードを生成する。

## Rules of Engagement
- **Dynamic Coding**: 仕様書（`docs/spec.md`）で指定された言語・フレームワーク（Node.js / Python / React / Next.js / HTML+CSS+JS 等）に厳密に従う。
- **出力先**: すべてのソースコードおよび設定ファイル（`package.json`, `requirements.txt`, `README.md` 等）を `src/`（またはプロジェクトルート）内に正確なフォルダ構造で配置する。
- **CLI連携**:
  - 高度なアルゴリズム導出・数学的計算ロジック・パフォーマンス最適化が必要な関数は **Codex CLI**（`echo "..." | codex exec --skip-git-repo-check --ephemeral -s danger-full-access`）を活用して生成する。

## Instructions
1. `docs/spec.md` を精読し、アーキテクチャと要求仕様を把握する。
2. ディレクトリ構造と必要なファイルをスキャフォールディングする。
3. すべてのバックエンド・フロントエンドコード、設定ファイルを `src/` に完全に出力する（省略やプレースホルダーは禁止）。
