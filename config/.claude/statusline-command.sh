#!/bin/bash
# Hacker-themed Claude Code statusline
# [Model] │ [Bar] [%] [Dir] ⎇ [branch] ⚡ [cache] ⏳ [cache-left] ⏱ [duration]
#
# Displayed % is scaled to the usable window ((raw / 80) * 100) so the bar
# hits 100% as auto-compact kicks in. The bar color fades green->yellow->red.

LOG=/tmp/claude-statusline-calls.log
input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name // "unknown"')
dir=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // "?"')
dir_display=$(basename "$dir")
transcript_path=$(echo "$input" | jq -r '.transcript_path // empty')

# Git segment: branch name.
git_seg=""
if git -C "$dir" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  branch=$(git -C "$dir" symbolic-ref --quiet --short HEAD 2>/dev/null)
  # Detached HEAD: fall back to a short SHA.
  [ -z "$branch" ] && branch=$(git -C "$dir" rev-parse --short HEAD 2>/dev/null)
  git_seg=" ⎇ ${branch}"
fi

raw_used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
total_tokens=$(echo "$input" | jq -r '.context_window.total_input_tokens // empty')
exceeds=$(echo "$input" | jq -r '.context_window.exceeds_200k_tokens // false')

# Cache segment: tokens served from cache this turn. Realtime provides it
# directly; fallback pulls the latest assistant usage from the transcript.
cache_tokens=$(echo "$input" | jq -r '.context_window.current_usage.cache_read_input_tokens // empty')
if [ -z "$cache_tokens" ] && [ -n "$transcript_path" ] && [ -f "$transcript_path" ]; then
  cache_tokens=$(tail -r "$transcript_path" 2>/dev/null \
    | jq -r 'select(.type=="assistant" and .message.usage.cache_read_input_tokens != null)
             | .message.usage.cache_read_input_tokens' 2>/dev/null \
    | head -1)
fi
[ -z "$cache_tokens" ] && cache_tokens=0
# Humanize: >=1k rounded to "Nk".
cache_display=$(awk -v n="$cache_tokens" 'BEGIN{ if(n>=1000) printf "%.0fk", n/1000; else printf "%d", n }')

# Cache time-left: prompt-cache entries carry an ephemeral TTL tier (1h or 5m)
# and are rewritten each turn, so remaining = tier_seconds - (now - last write).
# The statusline JSON lacks the tier, so read the newest cache_creation entry
# (timestamp + tier) from the transcript. Resets to ~full every turn; only
# ticks down while idle.
cache_left=""
if [ -n "$transcript_path" ] && [ -f "$transcript_path" ]; then
  entry=$(tail -r "$transcript_path" 2>/dev/null \
    | jq -rc 'select(.type=="assistant" and .message.usage.cache_creation != null)
              | {ts: .timestamp,
                 ttl: (if .message.usage.cache_creation.ephemeral_1h_input_tokens > 0
                       then 3600 else 300 end)}' 2>/dev/null \
    | head -1)
  if [ -n "$entry" ]; then
    ts=$(echo "$entry" | jq -r '.ts')
    ttl=$(echo "$entry" | jq -r '.ttl')
    # Strip fractional seconds + trailing Z, then parse as UTC.
    ts_clean=${ts%%.*}; ts_clean=${ts_clean%Z}
    ts_epoch=$(date -j -u -f "%Y-%m-%dT%H:%M:%S" "$ts_clean" "+%s" 2>/dev/null)
    if [ -n "$ts_epoch" ]; then
      rem=$(( ttl - ($(date +%s) - ts_epoch) ))
      [ "$rem" -lt 0 ] && rem=0
      cache_left=$(awk -v r="$rem" 'BEGIN{ if(r>=60) printf "%dm", int(r/60); else printf "%ds", r }')
    fi
  fi
fi
cache_left_seg=""
[ -n "$cache_left" ] && cache_left_seg=" ⏳ ${cache_left}"

# Session duration: wall-clock time reported by the harness, humanized.
duration_ms=$(echo "$input" | jq -r '.cost.total_duration_ms // 0')
duration_display=$(awk -v ms="$duration_ms" 'BEGIN{
  s=int(ms/1000); h=int(s/3600); m=int((s%3600)/60); sec=s%60;
  if(h>0) printf "%dh%dm", h, m;
  else if(m>0) printf "%dm%ds", m, sec;
  else printf "%ds", sec;
}')

mode="REALTIME"

# In realtime mode used_percentage is already computed against whatever window
# is active (200k or 1M), so it's authoritative and needs no scaling here.
# Only the fallback path has to pick a window: a 1M session routinely runs past
# 200k tokens (~20% used), so infer 1M whenever the parsed token count clears1
# 200k and divide by the right denominator.
is_1m=false

if [ -z "$raw_used" ] || [ "$raw_used" = "null" ]; then
  mode="FALLBACK"
  total_tokens=0
  raw_used=0
  if [ -n "$transcript_path" ] && [ -f "$transcript_path" ]; then
    # macOS ships BSD tools: reverse with `tail -r` (no GNU `tac`).
    total_tokens=$(tail -r "$transcript_path" 2>/dev/null \
      | jq -c 'select(.type=="assistant" and .message.usage != null)' 2>/dev/null \
      | while IFS= read -r line; do
          it=$(echo "$line" | jq -r '.message.usage.input_tokens // 0')
          cr=$(echo "$line" | jq -r '.message.usage.cache_read_input_tokens // 0')
          tot=$((it + cr))
          if [ "$tot" -gt 1000 ]; then
            echo "$tot"
            break
          fi
        done)
    [ -z "$total_tokens" ] && total_tokens=0
    window=200000
    if [ "$total_tokens" -gt 200000 ]; then
      window=1000000
      is_1m=true
    fi
    raw_used=$(awk -v t="$total_tokens" -v w="$window" 'BEGIN{printf "%.2f", (t/w)*100}')
  fi
fi

# Scale to the usable window: auto-compact triggers around 80% of the raw
# context, so (raw / 80) * 100 reframes the bar as "% of usable context",
# hitting 100% right as compaction kicks in.
final_pct=$(awk -v r="$raw_used" 'BEGIN{v=(r/80)*100; if(v>100)v=100; printf "%.2f", v}')
# No exceeds_200k_tokens override: on a 200k window a real overflow already
# pushes used_percentage to ~100%, and on a 1M window the flag is expected at
# ~20% used, so forcing 100% there would be wrong. Trust the computed value.
: "$exceeds"

pct_int=$(awk -v p="$final_pct" 'BEGIN{v=int(p+0.5); if(v>100)v=100; if(v<0)v=0; print v}')

{
  echo "$(date '+%Y-%m-%d %H:%M:%S') ${mode}: Tokens: ${total_tokens:-N/A} | Raw: ${raw_used}% | Final: ${pct_int}%"
} >> "$LOG"

# Progress bar: 10 blocks. Build with while-loops, not `seq 1 N` — BSD seq
# (macOS) counts DOWN on `seq 1 0`, emitting a spurious block when N is 0.
filled=$(( pct_int / 10 ))
[ "$filled" -gt 10 ] && filled=10
[ "$filled" -lt 0 ] && filled=0
empty=$(( 10 - filled ))
bar=""
i=0; while [ "$i" -lt "$filled" ]; do bar="${bar}▰"; i=$((i + 1)); done
i=0; while [ "$i" -lt "$empty" ]; do bar="${bar}▱"; i=$((i + 1)); done

# Colors: matrix-green ramp fading to red as context fills.
RESET="\033[0m"
# Model/dir/branch label. The faint attribute (\033[2m) is near-unreadable on
# dark themes, so use a light gray from the 256-color palette instead — a
# nudge brighter while staying subdued against the colored bar.
DIM="\033[38;5;250m"
if [ "$pct_int" -ge 80 ]; then
  COLOR="\033[1;31m"
elif [ "$pct_int" -ge 70 ]; then
  COLOR="\033[1;33m"
elif [ "$pct_int" -ge 60 ]; then
  COLOR="\033[2;32m"
else
  COLOR="\033[1;32m"
fi

printf "${DIM}%s${RESET} │ ${COLOR}%s %d%%${RESET} ${DIM}%s%s ⚡ %s%s ⏱ %s${RESET}\n" \
  "$model" "$bar" "$pct_int" "$dir_display" "$git_seg" \
  "$cache_display" "$cache_left_seg" "$duration_display"
