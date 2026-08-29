# 🤖 Antigravity Autonomous AI Developer Pipeline

> **本ファイルは人間向けのガイドです。エージェントは読み込む必要はありません**（動作定義は `agents.md` / `skills/` / `workflows/` が唯一の情報源）。

Antigravity IDE と各種 AI CLI（Codex / Claude Code）を適材適所で協調動作させる、自律型開発オーケストレーション設定です。
**新規アプリケーションのゼロサム開発**から**既存システムのリファクタリング・機能追加**までシームレスに対応します。

## 📁 ディレクトリ構造

```
.agents/                      # 本リポジトリ（エージェント設定）
├── agents.md                 # ペルソナ定義 & CLI使い分け（常時読み込み）
├── skills/
│   ├── write_specs.md        # @pm: 要件定義・承認ゲート・仕様の履歴保全
│   ├── generate_code.md      # @engineer: 実装・差分改修（Codex 連携）
│   ├── audit_code.md         # @qa: 監査・デグレード防止（Claude Code 連携）
│   ├── deploy_app.md         # @devops: ローカル起動
│   ├── deploy_production.md  # @devops: 本番/クラウドデプロイ
│   ├── track_progress.md     # 共通: 作業結果の記録規約（唯一の情報源）
│   └── report_run.md         # 共通: サイクル最終レポート生成
└── workflows/startcycle.md   # スラッシュコマンド `/startcycle` 定義

docs/
├── spec.md                   # 生きた仕様書（最新の To-Be + 改訂履歴表）
├── specs/<RUN_ID>.md         # 承認時点の仕様スナップショット（不変）
└── runs/
    ├── index.md              # 全開発サイクルの一覧ダッシュボード
    └── <RUN_ID>/             # journal.md / report.md / raw/（CLI生出力）
src/                          # アプリケーションソースコード
```

## 🚀 使い方

> ⚠️ **前提**: 親プロジェクトが Git リポジトリであること。未初期化の場合、パイプラインは Step 0 で停止します。

Antigravity のチャット欄で実行します。

```text
/startcycle "オセロゲームを作成してください"
/startcycle "game.js の状態管理をステートマシンにリファクタリングし、難易度設定を追加してください"
```

| Step | 担当 | 内容 |
|:-:|:---|:---|
| 0 | — | `RUN_ID` 採番、作業ツリーを起点コミットとして確定 |
| 1 | **@pm** | As-Is / To-Be を分析し `docs/spec.md` を作成 → **承認待ちで停止**（「承認」と返信すると次へ） |
| 2 | **@engineer** | 既存コードを尊重して安全に差分改修・実装 |
| 3 | **@qa** | デグレード・型不整合・脆弱性を監査し修正 |
| 4 | **@devops** | 起動またはデプロイし、URL を報告 |
| 5 | — | 統合レポートを生成し、チャットに結果サマリを提示 |

## 📊 作業結果の確認方法

`/startcycle` の 1 実行を **1 Run**（`RUN_ID = YYYYMMDD-HHMMSS-<slug>`）として、4 ペルソナの成果を 1 か所に集約します。各ペルソナは**ステップ完了直後**に追記するため、途中で中断しても記録が残ります。

| 見たいもの | 場所 |
|:---|:---|
| 全サイクルの一覧（いつ・何を・結果は） | `docs/runs/index.md` |
| このサイクルの総括（誰が何をしたか） | `docs/runs/<RUN_ID>/report.md` |
| 各エージェントの詳細な作業ログ | `docs/runs/<RUN_ID>/journal.md` |
| Codex / Claude Code の生出力（判断根拠） | `docs/runs/<RUN_ID>/raw/` |
| 承認された時点の仕様 / 現在の仕様 | `docs/specs/<RUN_ID>.md` / `docs/spec.md` |

## 🗂 仕様書（spec.md）の履歴管理

`docs/spec.md` は常に最新の To-Be を表すため上書き更新されますが、過去版を失わないよう 3 段構えで保全します。

1. **上書き前コミット** — 書き換える前に未コミットの前版を必ずコミット。承認ゲートを何往復してもその過程が Git 履歴に残ります（*Git 管理下でも、コミットしない限り上書きで消えます*）。
2. **承認時スナップショット** — 承認時点の内容を `docs/specs/<RUN_ID>.md` に不変コピーとして保存。diff を追わず 1 ファイルで参照できます。
3. **改訂履歴テーブル** — `docs/spec.md` 冒頭の Revision History に Run ID・日付・変更概要を追記。

```bash
git log --oneline --follow docs/spec.md   # 仕様書の変遷を追う
```

各ゲートでコミットするため、「誰の作業による変更か」が履歴上で分離されます。

| タイミング | コミットメッセージ |
|:---|:---|
| Run 開始 | `chore: baseline before <RUN_ID>` |
| 仕様の承認 | `docs(spec): approve spec for <RUN_ID>` |
| 実装完了 (@engineer) | `feat: <概要> (<RUN_ID>)` |
| QA 修正完了 (@qa) | `fix(qa): <概要> (<RUN_ID>)` |
| レポート生成 | `docs(run): add report for <RUN_ID>` |

## 📦 他プロジェクトへの導入（Git Submodule）

```bash
git submodule add https://github.com/naimasa/antigravity-agents.git .agents
mkdir -p docs/specs docs/runs src
git rev-parse --git-dir || git init   # 履歴保全に必須
git submodule update --remote         # 最新のエージェント定義へ更新
```

## 🛠 CLI 連携方針

- **Codex CLI**: アルゴリズム導出・データ構造・単体関数最適化・数学的推論
- **Claude Code CLI**: アーキテクチャレビュー・型安全性・セキュリティ監査・差分検証
- **Antigravity**: パイプライン統括・ビルド・テスト・ローカル実行
