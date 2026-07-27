#!/usr/bin/env bash
# [Staff only] 受講者を全ペアリポジトリに write 権限で招待する（全員×全リポジトリ方式）。
# タスク4（隣のペアの PR をレビュー→マージ）もこれで権限が足りる。
# admin は付与しない（branch protection をバイパスできてしまうため）。
# 使い方: scripts/invite-collaborators.sh <リポジトリ数> <githubユーザー名>...
# 例:     scripts/invite-collaborators.sh 15 alice bob carol
set -euo pipefail
N="${1:?usage: invite-collaborators.sh <repos> <github-username>...}"
shift
[ $# -ge 1 ] || { echo "usage: invite-collaborators.sh <repos> <github-username>..." >&2; exit 1; }

for i in $(seq 1 "$N"); do
  R="PrimeBrains/genai-training-sandbox-pair$(printf '%02d' "$i")"
  for U in "$@"; do
    if gh api -X PUT "repos/$R/collaborators/$U" -f permission=push >/dev/null 2>&1; then
      echo "OK  $R <- $U"
    else
      echo "NG  $R <- $U （ユーザー名の typo か権限不足）" >&2
    fi
  done
done
echo "done. 招待は本人が承認するまで pending（確認: gh api repos/PrimeBrains/genai-training-sandbox-pair01/invitations）"
