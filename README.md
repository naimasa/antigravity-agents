# 🤖 Antigravity Autonomous AI Developer Pipeline

Antigravity IDE と各種 AI CLI（Codex / Claude Code）を適材適所で協調動作させる、自律型開発オーケストレーション設定です。
**新規アプリケーションのゼロサム開発** から **既存システムのリファクタリング・パフォーマンス改善・機能追加** までシームレスに対応します。

## 📁 ディレクトリ構造

```
.
├── .agents/                      # AIエージェント設定（本ディレクトリ）
│   ├── README.md                 # チーム構成・使い方ガイド
│   ├── agents.md                 # 4ペルソナ定義 & CLI使い分け方針
│   ├── skills/                   # 専門スキル群 (.md)
│   │   ├── write_specs.md        # PM: 要件定義・リファクタリング計画 & 承認ゲート & 仕様の履歴保全
│   │   ├── generate_code.md      # Engineer: 実装・安全な差分改修 (Codex CLI連携)
│   │   ├── audit_code.md         # QA: コード監査 & デグレード防止 (Claude Code CLI連携)
│   │   ├── deploy_app.md         # DevOps: ローカル環境での起動・確認
│   │   ├── deploy_production.md  # DevOps: 本番/クラウド環境デプロイ
│   │   ├── track_progress.md     # 共通: 全ペルソナの作業結果を journal に集約
│   │   └── report_run.md         # 共通: サイクル最終レポート & Run 一覧の生成
│   └── workflows/
│       └── startcycle.md         # スラッシュコマンド `/startcycle` 定義
│
├── docs/
│   ├── spec.md                   # 生きた仕様書（常に最新の To-Be + 改訂履歴表）
│   ├── specs/<RUN_ID>.md         # 承認時点の仕様スナップショット（不変）
│   └── runs/
│       ├── index.md              # 全開発サイクルの一覧ダッシュボード
│       └── <RUN_ID>/
│           ├── journal.md        # 各エージェントの逐次作業ログ
│           ├── report.md         # サイクル最終レポート
│           └── raw/              # Codex / Claude Code CLI の生出力（証跡）
└── src/                          # アプリケーションソースコード
```

## 🚀 使い方

Antigravity チャット欄で以下を実行：

```text
# 例1: 新規アプリケーション開発
/startcycle "オセロゲームを作成してください"

# 例2: 既存システムのリファクタリング・機能改善
/startcycle "game.js の状態管理をステートマシンにリファクタリングし、難易度設定を追加してください"
```

1. **PM (@pm)** が現状（As-Is）と改善後（To-Be）の差分を分析し、`docs/spec.md` に技術仕様書を作成して承認を求めます。
2. 内容を確認して「**承認**」と返答すると、**Engineer (@engineer)** が既存コードを尊重しながら安全に差分改修・実装。
3. **QA (@qa)** が `Claude Code CLI` を使ってデグレード（機能破損）や型不整合がないか監査・修正。
4. **DevOps (@devops)** がアプリケーションを起動・テストし、URLを報告します。
5. **統合レポート**が `docs/runs/<RUN_ID>/report.md` に生成され、チャットに全エージェントの結果サマリが提示されます。

> ⚠️ **前提**: 親プロジェクトが Git リポジトリであること（`git init` 済み）。未初期化の場合、パイプラインは Step 0 で停止します。

## 📊 作業結果の確認方法（Run 単位の集約）

`/startcycle` の 1 実行を **1 Run**（`RUN_ID = YYYYMMDD-HHMMSS-<slug>`）として扱い、
4 ペルソナの作業結果を 1 か所に集約します。

| 見たいもの | 見る場所 |
|:---|:---|
| 全サイクルの一覧（いつ・何を・結果は） | `docs/runs/index.md` |
| このサイクルの総括（誰が何をしたか一覧） | `docs/runs/<RUN_ID>/report.md` |
| 各エージェントの詳細な作業ログ | `docs/runs/<RUN_ID>/journal.md` |
| Codex / Claude Code の生出力（判断根拠） | `docs/runs/<RUN_ID>/raw/` |
| 承認された時点の仕様 | `docs/specs/<RUN_ID>.md` |
| 現在の仕様（最新） | `docs/spec.md` |

各ペルソナは**ステップ完了直後**に `journal.md` へ追記します（末尾一括ではないため、途中で中断しても記録が残ります）。

## 🗂 仕様書（spec.md）の履歴管理

`docs/spec.md` は「生きた仕様書」として常に最新の To-Be を表すため上書き更新されますが、
過去版が失われないよう次の 3 段構えで保全します。

1. **上書き前コミット**: @pm は `docs/spec.md` を書き換える前に、未コミットの前版を必ずコミットする。
   → 承認ゲートを何往復しても、その過程が Git 履歴に残る（*Git 管理下でも、コミットしない限り上書きで消えます*）。
2. **承認時スナップショット**: 承認が下りた時点の内容を `docs/specs/<RUN_ID>.md` に**不変のコピー**として保存する。
   → 「あのときの承認仕様」を diff を追わずに 1 ファイルで参照できる。
3. **改訂履歴テーブル**: `docs/spec.md` 冒頭の Revision History に Run ID・日付・変更概要を追記する。

```bash
# 仕様書の変遷を追う
git log --oneline --follow docs/spec.md
git diff <old>..<new> -- docs/spec.md
```

### コミット単位
各ゲートでコミットするため、「誰の作業による変更か」が履歴上で分離されます。

| タイミング | コミットメッセージ例 |
|:---|:---|
| Run 開始（作業ツリー確定） | `chore: baseline before <RUN_ID>` |
| 仕様の承認 | `docs(spec): approve spec for <RUN_ID>` |
| 実装完了 (@engineer) | `feat: <概要> (<RUN_ID>)` |
| QA 修正完了 (@qa) | `fix(qa): <概要> (<RUN_ID>)` |
| レポート生成 | `docs(run): add report for <RUN_ID>` |

## 📦 他プロジェクトへの導入（Git Submodule で再利用）

新しいプロジェクトで本エージェント設定を利用するには、プロジェクトのルートディレクトリで以下のコマンドを実行します：

```bash
# 1. 新規プロジェクトのルートでサブモジュールとして追加
git submodule add https://github.com/naimasa/antigravity-agents.git .agents

# 2. 必要な作業ディレクトリを作成
mkdir -p docs/specs docs/runs src

# 2.5 親プロジェクトが Git 管理されていることを確認（仕様書の履歴保全に必須）
git rev-parse --git-dir || git init

# 3. (任意) 最新のエージェント定義に更新したい場合
git submodule update --remote
```

## 🛠️ CLI 連携方針

- **Codex CLI**: 複雑なアルゴリズム導出・データ構造・単体関数最適化・数学的推論
- **Claude Code CLI**: アーキテクチャレビュー・型安全性チェック・セキュリティ監査・リファクタリング差分検証
- **Antigravity**: パイプライン全体の司令、差分検証、ビルド・テスト・ローカル実行
