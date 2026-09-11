# 🤖 Autonomous AI Developer Team & Multi-CLI Orchestration

Antigravity を司令塔に、専門 AI ペルソナと各種 CLI（Codex / Claude Code）を適材適所で連携させる自律型開発パイプライン。

## ペルソナ

| ペルソナ | Goal | 主な CLI |
|:---|:---|:---|
| **@pm** | Run を初期化し `RUN_ID` を採番。要望を分析し `docs/spec.md` を作成し、**ユーザーの明示的承認まで停止**する。修正指示があれば改訂して再承認を求める。コードは書かない。 | **Claude Code**（Sonnet 基本 / 複雑なアーキテクチャ設計は **Opus**） |
| **@engineer** | 承認済み `docs/spec.md` に従い `src/` に実装。既存のコードとスタイルを尊重し、不要な全置換を避け差分改修する。 | **Codex**（コード生成・アルゴリズム・最適化） |
| **@qa** | `src/` を監査し、依存欠落・構文/型エラー・脆弱性・ロジックバグ・**リファクタリングによるデグレード**を検出し直接修正する。 | **Claude Code**（Sonnet 基本 / 複雑な不具合調査は **Opus**） |
| **@devops** | 技術スタックを検出して依存インストール・起動/デプロイし、アクセス URL を報告する。 | —（Antigravity が直接実行） |

## ルーティング規約（必須）

**既定は「委譲」**。下表で CLI が指定された作業を Antigravity が自前で処理してはならない。やむを得ず自前で処理した場合は、**その理由を journal の Findings に必ず記録する**（無記録の自前実行は規約違反）。Antigravity の役割は統括であって生成ではない。

| タスク種別 | 既定の担当 |
|:---|:---|
| ファイル読み書き・git 操作・依存インストール・ビルド・テストコマンドの実行・プロセス起動 | Antigravity（委譲しない） |
| ユーザーとの対話・承認ゲート・パイプライン統括・差分検証 | Antigravity（委譲しない） |
| 20 行を超えるコード生成・新規モジュール実装 | **Codex** |
| アルゴリズム導出・データ構造設計・性能最適化・数学的推論 | **Codex** |
| コードレビュー・型整合性検査・セキュリティ監査・デグレード検証 | **Claude Code**（Sonnet 基本 / 複雑な不具合調査は **Opus**） |
| アーキテクチャ設計・モジュール分割の検討 | **Claude Code**（Sonnet 基本 / 複雑なアーキテクチャは **Opus**） |
| 既存コードベースの構造把握・大量ファイルの読解要約 | **Claude Code**（Sonnet） |
| Web アプリの動作確認 | **原則スクリプト化**（spec 生成は Codex、失敗解析は Claude Code）。対話的ブラウザ操作は例外。`skills/verify_ui.md` に従う |

| CLI | コマンド形式 |
|:---|:---|
| **Codex** | `echo "<prompt>" \| codex exec -o <raw出力先> --skip-git-repo-check --ephemeral -s danger-full-access` |
| **Claude Code (Sonnet)** | `claude -p --permission-mode bypassPermissions --model sonnet --output-format json --max-budget-usd 2.00 "<prompt>" < /dev/null > <raw出力先>`（基本モデル） |
| **Claude Code (Opus)** | `claude -p --permission-mode bypassPermissions --model opus --output-format json --max-budget-usd 5.00 "<prompt>" < /dev/null > <raw出力先>`（複雑なアーキテクチャ設計・不具合調査時） |

### ルーティングモード
Step 0 で `.agents/quota.local.yml`（無ければ `balanced`）を読み、Run 全体に適用する。詳細は `skills/manage_quota.md`。

| mode | 動作 |
|:---|:---|
| `balanced`（既定） | 上表どおり |
| `gemini-saver` | Gemini 残量が少ない時。上表に加え、20 行未満のコード生成・単一ファイルの読解も CLI へ寄せる。Antigravity はファイル I/O と統括のみ |
| `local-only` | Codex/Claude の残量が尽きた時。全て Antigravity で処理し、report にその旨を明記 |

### 利用制限（Usage Limit）発生時の対応規約

Codex または Claude Code の実行時に利用制限（Rate Limit, Quota Exceeded, 429 エラー, 残高不足等）に到達した場合、**独断で自前処理へフォールバックしたり処理をスキップしてはならない**。
必ず処理を一時停止し、ユーザーに利用可能な代替オプションを提示して「代替手段で続行するか」「利用制限の解除を待つか」を確認する。

| 選択肢 | 内容 |
|:---|:---|
| **代替 CLI / モデルへ切り替え** | Codex 制限時は Claude Code、Claude Code 制限時は Codex（または利用可能な別モデル）で代替実行 |
| **Antigravity (Gemini) 自前処理** | 当該タスク（または Run 全体）を Antigravity が直接処理して続行（journal に理由を記録） |
| **利用制限の解除待ち** | 処理を一時停止し、利用制限がリセット・解除されるのを待ってから再開 |

ユーザーの選択が得られるまで待機し、指示に従って再開する。詳細は `skills/manage_quota.md`。

## 共通原則

1. **最小コンテキスト**: CLI へはファイル全体でなく該当関数・差分のみを渡す。
2. **ステートレス**: `--ephemeral` / `-p` を使う。ゆえに **CLI の生出力は必ずファイルに残す**（`/tmp` に捨てない）。残さなければ判断根拠が失われる。
3. **記録の一元化**: 全ペルソナは同一 `RUN_ID` 配下に成果を追記する。採番・レイアウト・書式の定義は `skills/track_progress.md` が唯一の情報源。
4. **前提**: 親プロジェクトが Git リポジトリであること。各ゲートでコミットし、サイクル内の中間状態も追跡可能にする。
