# Claude Code ステータスライン（研修用・Windows PowerShell）
# 表示: モデル名 | ブランチ名* | Ctx:使用率% | $費用
# * = コミットしていない変更あり。Ctx はAIの作業記憶の使用率（60%超で黄、80%超で赤）
$ErrorActionPreference = "SilentlyContinue"
$reader = New-Object System.IO.StreamReader([Console]::OpenStandardInput(), [System.Text.Encoding]::UTF8)
$data = $reader.ReadToEnd() | ConvertFrom-Json

$esc = [char]27
$yellow = "$esc[33m"; $red = "$esc[31m"; $reset = "$esc[0m"

# モデル名
$model = if ($data.model.display_name) { $data.model.display_name } else { "?" }

# Git ブランチ（AIがブランチを切るとここが変わる）
$gitPart = ""
$branch = git branch --show-current 2>$null
if ($branch) {
  $dirty = if (git status --porcelain 2>$null) { "*" } else { "" }
  $gitPart = " | $branch$dirty"
}

# コンテキスト使用率
$ctxPart = ""
$u = $data.context_window.current_usage
$win = $data.context_window.context_window_size
if ($u -and $win) {
  $total = [long]$u.input_tokens + [long]$u.cache_creation_input_tokens + [long]$u.cache_read_input_tokens
  $pct = [int][math]::Floor($total * 100 / [long]$win)
  $color = ""
  if ($pct -gt 80) { $color = $red } elseif ($pct -gt 60) { $color = $yellow }
  $tail = if ($color) { $reset } else { "" }
  $ctxPart = " | ${color}Ctx:${pct}%${tail}"
}

# このセッションで使った費用（概算・USD）
$costPart = ""
if ($data.cost.total_cost_usd) {
  $costPart = " | `$" + ("{0:0.000}" -f [double]$data.cost.total_cost_usd)
}

[Console]::Out.Write("$model$gitPart$ctxPart$costPart")
