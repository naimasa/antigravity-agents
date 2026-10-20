# evals — ハーネスの回帰評価

ハーネス（`agents.md` / `skills/` / `scripts/`）を変えたとき、品質とトークン消費が良くなったか悪くなったかを数値で比べるための小さな評価課題。**エージェントは読み込む必要はない。**

| 課題 | 種別 | 見るもの |
|:---|:---|:---|
| `todo-cli` | 新規作成 | spec/AC から動くものを作れるか |
| `pricing-refactor` | 既存コードのリファクタ＋機能追加 | デグレード防止（既存挙動が保たれるか、重複が解消されるか） |

各課題は `task.md`（要望）・`fixture/`（開始時のコード）・`check.py`（**エージェントから見えない受入判定**）・`reference/`（check を満たす参照解）で構成される。

## 使い方
```bash
evals/run_eval.sh <task> <tag> --selftest   # 課題の健全性検証（参照解で check が通る）
evals/run_eval.sh <task> <tag> --prepare    # 作業ツリーを用意 → Antigravity 等で /startcycle を手動実行 → score.sh
evals/run_eval.sh <task> <tag> --exec       # claude -p で /startcycle を非対話実行して採点（EVAL_BUDGET_USD 既定 10）
evals/compare.sh [task]                     # tag ごとの平均（成功率・verify 失敗回数・USD・tokens・CLI 呼出数）
```
`tag` はハーネスの版名（`baseline`、`after-xxx` など）。結果は `evals/results.tsv` に追記される。

## 指標
`check`（隠し受入判定の合否）／`verify_runs`・`verify_fails`（修正ループの回数）／`cli_calls`／`claude_usd`／`cli_tokens`（Claude は実測、Codex は取得できた場合のみ）／`blocked`／`approved`／`sec`。**Gemini（Antigravity 自身）の token は測れない**ため、自前処理量は台帳の件数で見る。

## 注意
- `--exec` は評価時のみ承認ゲートを自動化する（プロンプトで明示）。本番の `/startcycle` では禁止。また統括役が Claude になるため、Antigravity（Gemini）固有の挙動は測れない。Antigravity での評価は `--prepare` を使う。
- 1 回の結果はばらつく。**同じ tag で 3 回以上**回して平均を比較する。
- 委譲基準（`agents.md` のルーティング）を調整するときは、変更前後で `compare.sh` を見て、成功率を落とさず tokens / USD が下がるかを確認する。
