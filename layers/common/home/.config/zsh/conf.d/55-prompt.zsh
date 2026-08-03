# Deliberately spawns no subprocess. Zscaler ZDP inspects every ad-hoc-signed
# binary on exec, so a Homebrew tool costs ~10s per launch on managed machines
# — `git --version` measured 10.1s against 57ms for Apple's /usr/bin/git. A
# vcs_info or gitstatus prompt would pay that on every single prompt, which is
# what made the previous Powerlevel10k setup unusable here.
#
# Once /opt/homebrew is excluded from ZDP scanning, a git segment becomes
# affordable again.
setopt prompt_subst

PROMPT='%F{blue}%~%f %(?.%F{green}.%F{red})❯%f '
RPROMPT='%(1j.%F{242}%j job%(2j.s.)%f .)'
