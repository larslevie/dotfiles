# git checkout that cd's into the branch's worktree when it has one. Falls
# through to plain checkout for flags, files, and non-worktree branches.
unalias gco 2>/dev/null
gco() {
  emulate -L zsh
  if [[ $# -eq 1 && $1 != -* ]]; then
    local wt
    wt=$(command git worktree list --porcelain 2>/dev/null | command awk -v b="refs/heads/$1" '/^worktree / {p=$2} $1=="branch" && $2==b {print p; exit}')
    if [[ -n $wt && $wt != $(command git rev-parse --show-toplevel 2>/dev/null) ]]; then
      cd "$wt"
      return
    fi
  fi
  command git checkout "$@"
}
