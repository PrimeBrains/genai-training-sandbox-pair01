#!/usr/bin/env bash
# [運営用] テンプレートの指定ファイルを、作成済みペアリポジトリの main へ後追い反映する
# （テンプレート変更は作成済みリポジトリに自動反映されないため。admin 権限で protection をバイパス）
# 使い方: scripts/sync-pair-files.sh <org> <template-repo> <ペア数> <ファイル...>
# 例:     scripts/sync-pair-files.sh PrimeBrains genai-training-sandbox 15 .claude/settings.json .claude/statusline.ps1
set -euo pipefail
ORG="${1:?usage: sync-pair-files.sh <org> <template-repo> <pairs> <file...>}"
TEMPLATE="${2:?template repo name}"
PAIRS="${3:?number of pairs}"
shift 3
[ $# -ge 1 ] || { echo "反映するファイルを1つ以上指定してください" >&2; exit 1; }
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

for i in $(seq 1 "$PAIRS"); do
  NAME="${TEMPLATE}-pair$(printf '%02d' "$i")"
  echo "== $ORG/$NAME =="
  for f in "$@"; do
    B64=$(base64 -w0 "$ROOT/$f")
    # 既存ファイルなら sha 必須、新規なら不要
    # 注: gh api は 404 でもエラー本文 JSON を標準出力に出すため、jq で sha だけ抜いて判定する
    SHA=$(gh api "repos/$ORG/$NAME/contents/$f" 2>/dev/null | jq -r '.sha // empty' || true)
    if [ -n "$SHA" ]; then
      REMOTE=$(gh api "repos/$ORG/$NAME/contents/$f" --jq .content | tr -d '\n')
      if [ "$REMOTE" = "$B64" ]; then echo "   $f: 変更なし(スキップ)"; continue; fi
      gh api -X PUT "repos/$ORG/$NAME/contents/$f" \
        -f message="chore: テンプレートのファイルを後追い反映 ($f)" \
        -f content="$B64" -f sha="$SHA" --jq '.commit.sha' | sed "s|^|   $f: 更新 |"
    else
      gh api -X PUT "repos/$ORG/$NAME/contents/$f" \
        -f message="chore: テンプレートのファイルを後追い反映 ($f)" \
        -f content="$B64" --jq '.commit.sha' | sed "s|^|   $f: 追加 |"
    fi
  done
done
echo "完了"
