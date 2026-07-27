#!/usr/bin/env bash
# ペア用リポジトリを一括作成する（運営用）
# テンプレートからペア数分の Public リポジトリを作り、branch protection と Issue を仕込む。
# 使い方: scripts/provision-pairs.sh <org> <template-repo> <ペア数>
# 例:     scripts/provision-pairs.sh PrimeBrains genai-training-sandbox 5
set -euo pipefail
ORG="${1:?usage: provision-pairs.sh <org> <template-repo> <pairs>}"
TEMPLATE="${2:?template repo name}"
PAIRS="${3:?number of pairs}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

for i in $(seq 1 "$PAIRS"); do
  NAME="${TEMPLATE}-pair$(printf '%02d' "$i")"
  echo "== $ORG/$NAME =="
  gh repo create "$ORG/$NAME" --template "$ORG/$TEMPLATE" --public
  sleep 3  # テンプレート展開待ち

  # main への直 push 禁止（PR 必須・レビュー承認は求めない）
  gh api -X PUT "repos/$ORG/$NAME/branches/main/protection" \
    --input - <<'JSON'
{
  "required_status_checks": null,
  "enforce_admins": false,
  "required_pull_request_reviews": { "required_approving_review_count": 0 },
  "restrictions": null,
  "allow_force_pushes": false,
  "allow_deletions": false
}
JSON

  "$SCRIPT_DIR/seed-issues.sh" "$ORG/$NAME"
done
echo "provisioned $PAIRS repos"
