---
name: track-progress
description: /startcycle の全ステップで一度読む記録規約。run_init.sh・log.sh・state.sh・cli.sh の使い方と docs/ のレイアウトを定義する。
---
# Skill: Track Progress（記録規約）

「誰が・何を・どの CLI で・どうなったか」を後から追える状態にする。**手書きせず `scripts/` を使う。Run 中に一度読めば足りる。**

## 使うスクリプト（親プロジェクトのルートで実行）
| 目的 | コマンド |
|:---|:---|
| Run 開始（RUN_ID 採番・ディレクトリ・journal ヘッダ・STATE） | `.agents/scripts/run_init.sh <slug> "<要望原文>"` |
| journal 追記 | `.agents/scripts/log.sh <persona> <Done\|Warning\|Blocked\|Awaiting> "<要約>" input=… actions=… cli=… cost=… findings=… next=…`（Changed Files は `git diff --stat` を自動転記） |
| 再開用状態（上書き・20行以内） | `.agents/scripts/state.sh "<現在>" "<次の1手>" "<Blocker or なし>"` |
| CLI 呼出（生出力保存・コスト記録・制限検知） | `.agents/scripts/cli.sh <codex\|claude-sonnet\|claude-opus> <brief.md> <persona-topic>` |

## レイアウト
```
docs/spec.md  docs/specs/<RUN_ID>.md  docs/ARCHITECTURE.md  docs/verify.json
docs/runs/index.md  docs/runs/usage.md  docs/runs/.current
docs/runs/<RUN_ID>/{journal.md,STATE.md,report.md,usage.tsv,APPROVED,briefs/,raw/,verify/}
```

## Rules
- **追記のみ**（journal）。訂正は新エントリで。STATE.md は上書き。
- **即時記録**: 各ステップ完了直後。中断しても残る。
- **正直に**: 失敗・未完了・スキップも `Blocked` / `Warning` で残す。未検証は「未検証」と書く。
- **委譲理由**: CLI 指定のタスクを自前処理したら `findings=` に理由を書く。
- **秘匿情報**: 環境変数名は可、値（キー・トークン）は書かない。
