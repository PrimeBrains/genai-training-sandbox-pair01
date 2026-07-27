#!/usr/bin/env bash
# [Staff only] Bedrock モデル呼び出しログから、ユーザー別・モデル別のトークン数とコスト試算を出す。
# 前提: モデル呼び出しログが有効（2026-07-26 有効化済み。それ以前の呼び出しは記録なし）
# 使い方: AWS_PROFILE=<admin-profile> scripts/usage-cost.sh [開始日 YYYY-MM-DD] [終了日 YYYY-MM-DD]
# 単価の差し替え: PRICE_JSON='{"sonnet":[3.0,15.0],"haiku":[1.0,5.0]}' scripts/usage-cost.sh ...
#   （USD per 100万トークン [入力, 出力]。既定値は Anthropic 標準相当・JPプロファイルの上乗せ有無は要確認）
set -euo pipefail
START="${1:-$(date +%F)}"
END="${2:-$START}"
REGION="${AWS_REGION:-ap-northeast-1}"
LG="/aws/bedrock/genai-training-invocation-logs"

if [ -z "${AWS_PROFILE:-}" ]; then
  echo "ERROR: AWS_PROFILE が設定されていません（export を忘れていませんか）。" >&2
  echo "  export AWS_PROFILE=<admin-profile>  または  AWS_PROFILE=<admin-profile> $0 ... で実行してください。" >&2
  exit 1
fi
if ! aws sts get-caller-identity >/dev/null 2>&1; then
  echo "ERROR: AWS 認証が無効です（SSO トークン切れ）。" >&2
  echo "  aws sso login --profile $AWS_PROFILE を実行してから再実行してください。" >&2
  exit 1
fi

START_MS=$(date -d "${START}T00:00:00+09:00" +%s%3N)
END_MS=$(date -d "${END}T23:59:59+09:00" +%s%3N)

aws logs filter-log-events --region "$REGION" --log-group-name "$LG" \
  --start-time "$START_MS" --end-time "$END_MS" --output json \
| python3 -c "
import sys, json, os
from collections import defaultdict

prices = json.loads(os.environ.get('PRICE_JSON', '{\"sonnet\":[3.0,15.0],\"haiku\":[1.0,5.0]}'))

def price_for(model_id):
    for key, p in prices.items():
        if key in model_id:
            return p
    return None

agg = defaultdict(lambda: {'calls':0,'in':0,'out':0,'cr':0,'cw':0})
data = json.load(sys.stdin)
for e in data.get('events', []):
    try:
        d = json.loads(e['message'])
    except json.JSONDecodeError:
        continue
    ident = d.get('identity', {}).get('arn', '?').split('/')[-1]
    model = d.get('modelId', '?').split('/')[-1]
    i, o = d.get('input', {}), d.get('output', {})
    a = agg[(ident, model)]
    a['calls'] += 1
    a['in']  += i.get('inputTokenCount') or 0
    a['out'] += o.get('outputTokenCount') or 0
    a['cr']  += i.get('cacheReadInputTokenCount') or 0
    a['cw']  += i.get('cacheWriteInputTokenCount') or 0

print(f\"{'ユーザー':<28}{'モデル':<32}{'回数':>5}{'入力':>10}{'出力':>9}{'ｷｬｯｼｭ読':>11}{'ｷｬｯｼｭ書':>10}{'試算USD':>9}\")
total = 0.0
for (ident, model), a in sorted(agg.items(), key=lambda x: -(x[1]['in']+x[1]['out'])):
    p = price_for(model)
    if p:
        # キャッシュ書込=入力単価x1.25 / キャッシュ読出=入力単価x0.1（Anthropic標準の係数）
        cost = (a['in']*p[0] + a['out']*p[1] + a['cw']*1.25*p[0] + a['cr']*0.1*p[0]) / 1_000_000
        total += cost
        cost_s = f\"{cost:9.4f}\"
    else:
        cost_s = '   単価未設定'
    print(f\"{ident:<28}{model:<32}{a['calls']:>5}{a['in']:>10}{a['out']:>9}{a['cr']:>11}{a['cw']:>10}{cost_s}\")
print(f\"\n合計試算: \${total:.2f}（単価は既定値ベース・JPプロファイルの上乗せ有無は要確認）\")
if not agg:
    print('(該当期間に記録なし。ログ有効化(2026-07-26)以前の呼び出しは記録されていません)')
"
