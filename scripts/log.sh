#!/usr/bin/env bash
# 使い方: log.sh <persona> <Done|Warning|Blocked|Awaiting> "<一行要約>" [key=value ...]
# key: input actions changed cli cost findings next（省略可）。changed 省略時は git diff --stat を自動転記。
. "$(dirname "$0")/_common.sh"
r="$(current_run)"; persona="$1"; status="$2"; summary="$3"; shift 3
case "$status" in
  Done) s="✅ Done";; Warning) s="⚠️ Warning";; Blocked) s="❌ Blocked";; Awaiting) s="⏸ Awaiting Approval";;
  *) echo "status は Done|Warning|Blocked|Awaiting" >&2; exit 2;;
esac
declare -A kv=()
for a in "$@"; do kv["${a%%=*}"]="${a#*=}"; done
changed="${kv[changed]:-$(git diff --stat HEAD 2>/dev/null | tail -n 20)}"
{
  echo
  echo "## [$(date '+%Y-%m-%d %H:%M:%S')] @$persona — $summary"
  echo "- **Status**: $s"
  echo "- **Input**: ${kv[input]:--}"
  echo "- **Actions**: ${kv[actions]:--}"
  echo "- **Changed Files**: ${changed:-なし}"
  echo "- **CLI Calls**: ${kv[cli]:-なし}"
  echo "- **Cost**: ${kv[cost]:-}"
  echo "- **Findings / Issues**: ${kv[findings]:--}"
  echo "- **Next**: ${kv[next]:--}"
} >> "docs/runs/$r/journal.md"
