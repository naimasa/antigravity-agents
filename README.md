# 🤖 Antigravity Autonomous AI Developer Pipeline

Antigravity IDE と各種 AI CLI（Codex / Claude Code）を適材適所で協調動作させる、自律型開発オーケストレーション設定です。

## 📁 ディレクトリ構造

```
.
├── .agents/                      # AIエージェント設定（本ディレクトリ）
│   ├── README.md                 # チーム構成・使い方ガイド
│   ├── agents.md                 # 4ペルソナ定義 & CLI使い分け方針
│   ├── skills/                   # 専門スキル群 (.md)
│   │   ├── write_specs.md        # PM: 要件定義・仕様書作成 & 承認ゲート
│   │   ├── generate_code.md      # Engineer: 実装・コード生成 (Codex CLI連携)
│   │   ├── audit_code.md         # QA: コード監査 & 修正 (Claude Code CLI連携)
│   │   ├── deploy_app.md         # DevOps: ローカル環境での起動・確認
│   │   └── deploy_production.md  # DevOps: 本番/クラウド環境デプロイ
│   └── workflows/
│       └── startcycle.md         # スラッシュコマンド `/startcycle` 定義
│
├── docs/                         # 仕様書・設計書 (spec.md)
└── src/                          # アプリケーションソースコード
```

## 🚀 使い方

Antigravity チャット欄で以下を実行：

```text
/startcycle "<作りたいアプリのアイデア>"
```

1. **PM (@pm)** が `docs/spec.md` に技術仕様書を作成し、承認を求めます。
2. 内容を確認して「**承認**」と返答すると、**Engineer (@engineer)** が `src/` にコードを実装。
3. **QA (@qa)** が `Claude Code CLI` を使ってコードを監査・修正。
4. **DevOps (@devops)** がアプリケーションを起動し、URLを報告します。

## 📦 他プロジェクトへの導入（Git Submodule で再利用）

新しいプロジェクトで本エージェント設定を利用するには、プロジェクトのルートディレクトリで以下のコマンドを実行します：

```bash
# 1. 新規プロジェクトのルートでサブモジュールとして追加
git submodule add https://github.com/naimasa/antigravity-agents.git .agents

# 2. 必要な作業ディレクトリを作成
mkdir -p docs src

# 3. (任意) 最新のエージェント定義に更新したい場合
git submodule update --remote
```

## 🛠️ CLI 連携方針

- **Codex CLI**: 複雑なアルゴリズム導出・データ構造・単体関数最適化・数学的推論
- **Claude Code CLI**: アーキテクチャレビュー・型安全性チェック・セキュリティ監査
- **Antigravity**: パイプライン全体の司令、差分検証、ビルド・テスト・ローカル実行
