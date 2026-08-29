# Skill: Track Progress（共通スキル / 全ペルソナ必須）

## Objective
各ペルソナ（@pm / @engineer / @qa / @devops）の作業結果を **1 つの追跡可能な場所に集約**し、
「誰が・何を・どの CLI で・どのファイルに対して・どうなったか」を後から一覧できる状態にする。
CLI（Codex / Claude Code）の生出力を破棄せず、証跡として残すことも本スキルの責務。

## Run ID（サイクル識別子）
- `/startcycle` の 1 回の実行を **1 Run** とし、Step 0 で `RUN_ID` を採番する。
- 形式: `RUN_ID = YYYYMMDD-HHMMSS-<kebab-slug>`
  - `<kebab-slug>` はユーザー要望を英小文字ケバブケース 3〜5 語で要約したもの（例: `othello-state-machine-refactor`）。
  - 採番例: `date +%Y%m%d-%H%M%S` の結果に slug を連結する。
- 採番後、**以降すべてのペルソナが同一の RUN_ID を使う**。ペルソナ切り替え時に再採番してはならない。

## 成果物レイアウト（親プロジェクト側）
```
docs/
├── spec.md                       # 生きた仕様書（常に最新の To-Be）
├── specs/
│   └── <RUN_ID>.md               # 承認時点の仕様スナップショット（不変）
└── runs/
    ├── index.md                  # 全 Run の一覧ダッシュボード
    └── <RUN_ID>/
        ├── journal.md            # 各ペルソナの逐次作業ログ（追記のみ）
        ├── report.md             # サイクル最終レポート（report_run.md が生成）
        └── raw/
            ├── 01-codex-engineer-<topic>.md
            └── 02-claude-qa-<topic>.md
```

## Rules of Engagement
- **追記のみ（Append-only）**: `journal.md` の既存エントリは絶対に書き換え・削除しない。訂正は新しいエントリで行う。
- **即時記録**: 各ステップの**完了直後**に追記する。サイクル末尾にまとめて書かない（途中で中断した場合に記録が残らないため）。
- **CLI 生出力の永続化**: CLI の出力を `/tmp` に捨てず、`docs/runs/<RUN_ID>/raw/` に保存する。
  - Codex: `echo "<prompt>" | codex exec -o docs/runs/$RUN_ID/raw/<NN>-codex-<persona>-<topic>.md --skip-git-repo-check --ephemeral -s danger-full-access`
  - Claude Code: `claude -p --output-format text --max-budget-usd 1.00 "<prompt>" | tee docs/runs/$RUN_ID/raw/<NN>-claude-<persona>-<topic>.md`
  - `<NN>` は Run 内の通し番号（`01`, `02`, ...）。
- **変更ファイルは実測**: 「Changed Files」は記憶で書かず `git status --porcelain` / `git diff --stat` の実行結果から転記する。
- **正直な Status**: 失敗・未完了・スキップした作業は隠さず `❌ Blocked` / `⚠️ Warning` として残す。

## Journal エントリ書式（この形式を厳守）
```markdown
## [<YYYY-MM-DD HH:MM:SS>] @<persona> — <一行要約>
- **Status**: ✅ Done / ⚠️ Warning / ❌ Blocked / ⏸ Awaiting Approval
- **Input**: 参照した仕様・指示（例: `docs/spec.md#architecture`, ユーザー承認コメント）
- **Actions**:
  - 実施した作業を箇条書き
- **Changed Files**:
  - `src/foo.js` (+42 / -11)
  - （変更なしの場合は「なし」）
- **CLI Calls**:
  - `codex exec` — 目的: 〜 → [raw/01-codex-engineer-minimax.md](raw/01-codex-engineer-minimax.md)
  - （呼び出しなしの場合は「なし」）
- **Findings / Issues**: 検出した問題・既知の制約・残課題
- **Next**: 次のペルソナへの申し送り事項
```

## Instructions
1. **Step 0（@pm が実行）**: `RUN_ID` を採番し、`docs/runs/<RUN_ID>/raw/` を作成。`journal.md` にヘッダ（Run ID / 開始時刻 / ユーザー要望の原文 / 起点コミットハッシュ `git rev-parse --short HEAD`）を書き出す。
2. **各ステップ完了時**: 担当ペルソナが上記書式のエントリを `journal.md` に追記する。
3. **CLI 呼び出し時**: 生出力を `raw/` に保存し、journal から相対リンクで参照する。
4. **サイクル終了時**: `report_run.md` スキルへ引き継ぐ。
