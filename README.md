# 🤖 Antigravity Autonomous AI Developer Pipeline

*[English README](README.en.md)*

> **本ファイルは人間向けのガイドです。エージェントは読み込む必要はありません**（動作定義は `agents.md` / `skills/` が唯一の情報源）。

Antigravity IDE と各種 AI CLI（Codex / Claude Code）を適材適所で協調動作させる、自律型開発オーケストレーション設定です。
**新規アプリケーションのゼロサム開発**から**既存システムのリファクタリング・機能追加**までシームレスに対応します。

ペルソナ構成・`.agents/` のディレクトリ規約・`/startcycle`・承認ゲートは Google の Codelab をベースにしています（[謝辞](#-謝辞)）。本リポジトリはそこに、複数 CLI への委譲・Run 単位の成果集約・仕様書の履歴保全・消費量の記録を追加したものです。

## 📁 ディレクトリ構造

```
.agents/                      # 本リポジトリ（エージェント設定）
├── agents.md                 # ペルソナ定義 & CLI使い分け（常時読み込み）
├── skills/                   # Agent Skills 標準（<name>/SKILL.md ＋ frontmatter）
│   ├── startcycle/           # /startcycle 本体（統括）
│   ├── write-specs/          # @pm: 要件定義・AC・承認ゲート・仕様の履歴保全
│   ├── generate-code/        # @engineer: 実装・修正ループ（Codex 連携）
│   ├── audit-code/           # @qa: 監査・デグレード防止（Claude Code 連携）
│   ├── deploy-app/  deploy-production/   # @devops
│   ├── track-progress/       # 共通: 記録規約（唯一の情報源）
│   ├── manage-quota/         # 共通: 消費量の記録・ルーティング・利用制限時の確認
│   ├── verify-ui/            # 共通: ブラウザ動作確認の方針（spec 化）
│   └── report-run/           # 共通: 最終レポート生成
├── scripts/                  # 定型作業の決定論的スクリプト（LLM 推論を使わない）
│   ├── run_init.sh  log.sh  state.sh   # 採番・journal・再開用 STATE
│   ├── cli.sh                          # Codex/Claude 呼出の唯一の入口（権限・生出力・コスト・制限検知）
│   ├── verify.sh                       # lint/型/テスト/E2E の機械的な合否判定
│   ├── report.sh                       # 実測集計・usage 台帳追記
│   ├── install.sh                      # 初回導入（Claude Code 用リンク・AGENTS.md 追記）
│   └── lint_skills.sh                  # 本リポジトリ自身の整合性チェック
├── workflows/startcycle.md   # 旧 Antigravity workflow 用の互換スタブ（実体は skills/startcycle）
├── quota.example.yml         # ルーティングモード設定のテンプレート
└── quota.local.yml           # (任意) 自分のプラン上限。gitignore 推奨

docs/
├── ARCHITECTURE.md           # 全 CLI が最初に読む地図（100 行以内・差分更新）
├── verify.json               # verify.sh の実行ステップ（`verify.sh --detect` で雛形生成）
├── spec.md                   # 生きた仕様書（最新の To-Be + 改訂履歴表）
├── specs/<RUN_ID>.md         # 承認時点の仕様スナップショット（不変）
└── runs/
    ├── index.md              # 全開発サイクルの一覧ダッシュボード
    ├── usage.md              # CLI 消費量の累積台帳（委譲率）
    └── <RUN_ID>/             # journal.md / STATE.md / report.md / briefs/ / raw/ / verify/
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

## ✅ 品質ゲートとトークン最適化の仕組み

| 仕組み | 内容 |
|:---|:---|
| **受入基準 (AC)** | spec に Given/When/Then の AC と検証手段を必須化。承認ゲートで AC も確認 |
| **機械的な完了判定** | `scripts/verify.sh` が lint・型・テスト・E2E を実行（推論なし）。完了の定義はこれが通ること |
| **修正ループ** | @engineer は失敗ログ末尾だけを使い最大 3 回修正。超えたら Opus 分析かユーザー確認 |
| **テスト分離** | AC に対応するテストは実装を見せず別呼出で生成（実装の追認を防ぐ） |
| **brief 方式** | CLI にはコード断片でなく `briefs/NN.md`（AC・触るファイル・完了条件）を渡す。必要範囲は CLI が自分で読む |
| **ARCHITECTURE.md** | 全体探索のキャッシュ。毎回の再探索を省く |
| **スクリプト化** | 採番・journal・コスト集計・CLI 呼出をシェルで決定論的に実行。LLM は文章部分のみ |
| **要約のみ読む** | `cli.sh` は結果本文のパスと先頭数行だけ返す。生出力は `raw/` に保存し必要時のみ開く |
| **権限の絞り込み** | 既定は Codex `workspace-write`、Claude `acceptEdits`＋許可ツール明示＋`--max-turns`。広げるのは明示時のみ（`CODEX_SANDBOX` / `CLAUDE_TOOLS`） |
| **再開** | `/startcycle resume` は `STATE.md`（20 行以内）だけ読んで続行 |

## ⚖️ Quota 配分と CLI 委譲

Antigravity（Gemini）に作業が偏り Quota を使い切るのを防ぐため、**委譲を既定**にしています。

> **残量（remaining quota）の自動照会は 3 サービスとも手段がありません。** Gemini は IDE の UI 表示のみ、Claude Code CLI に `usage` 系サブコマンドはなく、Codex CLI も同様です。したがって本設定は「消費量の実測記録」＋「ユーザーが宣言した上限に対する残量推定」＋「手動モード切替」で運用します。

### ルーティング規約
`agents.md` の表で CLI が指定された作業（複数ファイルの実装・アルゴリズム・レビュー・監査・アーキテクチャ設計など。単一ファイルの小編集は自前でよい）を Antigravity が自前で処理した場合、**journal に理由を記録する義務**があります。無記録の自前実行は規約違反です。Antigravity 自身が担うのはファイル I/O・git・ビルド・テスト・ユーザー対話などの統括作業のみです。Claude Code は **Sonnet** を基本モデルとし、複雑なアーキテクチャ設計や難度の高い不具合調査・デグレード深層追跡には **Opus** を使用します。

### モード切替
```bash
cp .agents/quota.example.yml .agents/quota.local.yml   # mode を編集
```

| mode | 用途 |
|:---|:---|
| `balanced`（既定） | 規約どおりに委譲 |
| `gemini-saver` | Gemini 残量が少ない時。小さなコード生成・読解も CLI へ寄せる |
| `local-only` | Codex/Claude が尽きた時。全て Antigravity で処理 |

### 利用制限（Usage Limit）発生時の確認フロー
Codex または Claude Code の実行中に利用制限（Rate Limit / Quota Exceeded / 429 等）に到達した場合、Antigravity は独断で自前処理へ倒したり中断を強行せず、**必ずユーザーに以下の選択肢を提示して指示を仰ぎます**。

1. **代替 CLI / モデルへの切り替え**: Codex 制限時は Claude Code、Claude Code 制限時は Codex（または利用可能な別モデル）に切り替えて続行。
2. **Antigravity (Gemini) 自前処理**: CLI を使わず Antigravity が直接処理を肩代わりして続行（journal に理由を記録）。
3. **利用制限の解除待ち**: 処理を一時停止し、制限がリセット・解除されるまで待機してから再試行。

### ブラウザでの動作確認
Web アプリの動作確認を対話的なブラウザ操作（スクリーンショットを撮って判断して操作する繰り返し）で行うと、毎ステップ画像がモデルに渡るため Quota を最も速く消費します。しかもサイクルのたびに全ステップが再実行されます。

そこで **一度 spec に落とし、以後は推論なしで回す**方針にしています。

1. Playwright 等の spec を書く（**生成は Codex へ委譲**）
2. `npx playwright test` で実行する（モデル推論を伴わないためトークンを消費しない）
3. **失敗したケースだけ**、そのログとスクリーンショットを Claude Code に渡して原因分析させる

対話的なブラウザ操作を使ってよいのは、spec が無い初回の疎通確認1回と、自動化困難な視覚判断のみです。使った場合は操作ステップ数を journal に記録し、消費台帳では「Gemini 自前処理」として計上します。同じ確認を2回以上行う場合は、必ず spec に落としてから実行します。詳細は `skills/verify-ui`。

### 消費量の可視化
`cli.sh` が `--output-format json` の `total_cost_usd` と tokens を Run ごとの `usage.tsv` に記録し、Codex は呼び出し回数、Gemini は「自前処理した件数」で計上します。`report.sh` が `docs/runs/usage.md` へ追記され、**委譲率**（CLI 呼出 ÷ 全処理）が記録されます。`balanced` で 50% を下回り続ける場合、レポートに警告が出ます。

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

## 🔌 Antigravity / Codex / Claude Code 互換

skill を **Agent Skills 標準（`<name>/SKILL.md` ＋ `name`/`description` の frontmatter）** に統一し、3 ツールが同じ実体を読みます。サブモジュールを親プロジェクトの `.agents/` に置くため、探索パスは次のとおりです（公式ドキュメントで確認済み）。

| ツール | skill の探索場所 | 本リポジトリでの扱い |
|:---|:---|:---|
| **Antigravity** | `<workspace>/.agents/skills/<name>/` | そのまま発見される（追加作業なし） |
| **Codex** | `<repo root>/.agents/skills`（カレントから root まで。symlink 可） | そのまま発見される（追加作業なし） |
| **Claude Code** | `.claude/skills/<name>/` | `install.sh` がシンボリックリンクを作成 |

- skill は `description` だけが常時ロードされ、本文は必要時のみ読まれる（段階的開示）ため、使わない skill のトークンはかかりません。
- 常時ロード指示は親プロジェクトの `AGENTS.md`（`install.sh` が管理ブロックを追記）。Claude Code は `CLAUDE.md` があると `AGENTS.md` を読まないため、その場合は `CLAUDE.md` に `@AGENTS.md` を 1 行追加してください。
- `/startcycle` は skill として定義しているため、3 ツールで同じ手順が走ります（呼び出し記法はツールごとに異なる場合があります）。CLI に委譲された Codex / Claude Code も、同じ `.agents/skills` を読めます。
- ツール固有機能（hooks 等）には依存せず、強制力は `verify.sh` と `APPROVED` ファイルなどスクリプトで担保します。
- 本リポジトリの変更後は `scripts/lint_skills.sh` で frontmatter・参照整合性を確認できます。

## 🧭 古い文書よりコードを優先する（stale instruction 対策）

論文 [arXiv:2610.30571](https://arxiv.org/abs/2610.30571) は、`CLAUDE.md` / `AGENTS.md` が既存コードと食い違うとき、コーディングエージェントが**食い違いに気づいても古い文書に従う**（選択の約 90%）ことを示しました。Codex CLI は 80 回中 20 回、既存コードを文書に合わせて書き換え、その多くで既存テストが壊れています。ユーザーレベルの指示ファイルに「文書とコードが食い違うときは既存コードに従い、不一致を報告する」という 1 文を足すと、コードに従う割合は 4.2% から 91.4% に上がりました。

> ※ 対象は Python の合成プロジェクト 40 件・慣習の食い違いのみ・Claude Code と Codex CLI の 2 つで、Antigravity（Gemini）は未検証のプレプリントです。

本ハーネスの対応:

| 対応 | 内容 |
|:---|:---|
| 優先順位の 1 文 | `scripts/precedence.txt`。`agents.md`・`cli.sh` が渡す全プロンプト・`install.sh` が書く `AGENTS.md` ブロックに入る。承認済み AC と brief が明示する変更は例外 |
| 不一致の報告 | CLI は最終報告に `[DOC-DRIFT]` を列挙 → journal → 次の Run で @pm が文書を修正 |
| 陳腐化検査 | `scripts/doc_drift.sh`（`ARCHITECTURE.md` の `as of` と参照パスの実在を検査。Step 0 で実行。警告のみ） |
| 書き換えの検出 | `scripts/scope_check.sh`（`cli.sh` が自動実行。brief の「触るファイル」外の変更と既存ファイルの大幅削除を警告。警告のみ）、`verify.sh --baseline` で着手前のテスト状態を記録 |

**ユーザーレベルにも入れる場合**（論文が検証した配置。プロジェクトを問わず効く）は、次を `~/.claude/CLAUDE.md` と `~/.codex/AGENTS.md` に追記してください。

```text
When a repository's documentation and its existing code disagree, follow the conventions used in the existing code, and in your final reply point out each inconsistency you found between the documentation and the code.
```

## 📈 ハーネスの評価（evals）

ルーティングや skill を変えたときに効果を数値で比べるため、小さな評価課題を用意しています（`evals/`）。新規作成と既存コードのリファクタ各 1 件で、エージェントから見えない受入判定を持ちます。`run_eval.sh` で実行し、成功率・修正ループ回数・CLI 呼出数・USD・tokens を `results.tsv` に記録、`compare.sh` で版ごとの平均を比較します。詳細は `evals/README.md`。

## 📦 他プロジェクトへの導入

`install.sh` は Claude Code 用リンク（`.claude/skills/`）・`AGENTS.md` の管理ブロック・`docs/`・`.gitignore` を整備します。これらが git の差分に出てよいかで、2 つのパターンを選びます。

### パターン A: チーム共有（Git Submodule・生成物をコミットする）
`.agents` を submodule として管理し、`install.sh` の生成物もコミットして、クローンした全員が同じ構成になります。

```bash
git rev-parse --git-dir || git init                  # 履歴保全に必須
git submodule add https://github.com/naimasa/antigravity-agents.git .agents
.agents/scripts/install.sh                           # .claude/skills・AGENTS.md・.gitignore を整備（冪等）
.agents/scripts/verify.sh --detect                   # docs/verify.json を生成（内容を確認）
git add .gitmodules .agents .claude AGENTS.md .gitignore docs
git commit -m "chore: add antigravity-agents harness"

# (任意) ルーティングモード設定。quota.local.yml は .gitignore 済み
cp .agents/quota.example.yml .agents/quota.local.yml

# 更新時
git submodule update --remote && .agents/scripts/install.sh
```

### パターン B: 個人利用（git の差分に出さない）
`.agents` を単なる clone で置き、`install.sh --local` で生成物を `.git/info/exclude`（コミットされないローカル専用の除外設定）に登録します。`git status` には何も出ません。

```bash
git rev-parse --git-dir || git init
git clone https://github.com/naimasa/antigravity-agents.git .agents
.agents/scripts/install.sh --local                   # .agents/・.claude/skills・AGENTS.md を除外して整備（冪等）
.agents/scripts/verify.sh --detect                   # docs/verify.json を生成（内容を確認）
git status --short                                   # → .agents/ 等は表示されない

# (任意) ルーティングモード設定
cp .agents/quota.example.yml .agents/quota.local.yml

# 更新時
git -C .agents pull && .agents/scripts/install.sh --local
```

- 追跡済みの `AGENTS.md` が既にある場合、`--local` はそれを変更せず、追記すべきブロックを表示します（skill は `.agents/skills` から直接発見されるため、追記しなくても動作します）。
- `docs/spec.md`・`docs/runs/` などの**開発成果物はプロジェクトの記録として通常どおり差分に出ます**（除外対象は導入物のみ）。
- 後から共有に切り替える場合は `.git/info/exclude` の該当行を削除し、パターン A の手順を実施します。

## 🙏 謝辞

本リポジトリは Google Codelabs の **[Build Autonomous Developer Pipelines using agents.md and skills.md in Antigravity](https://codelabs.developers.google.com/autonomous-ai-developer-pipelines-antigravity)** をベースにしています。

4 ペルソナ構成（@pm / @engineer / @qa / @devops）、`.agents/` のディレクトリ規約、`/startcycle`、そしてユーザーの承認ゲートは、いずれも同 Codelab に由来します。本リポジトリはこれに対し、Codex CLI / Claude Code CLI への委譲、Run 単位の成果集約、仕様書の履歴保全、消費量の記録、および submodule として再利用可能な形へのパッケージングを追加しています。
