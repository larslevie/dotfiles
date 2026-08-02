# Loader only — real config lives in ~/.config/zsh/conf.d/*.zsh, sourced in
# filename order. Fragments are numbered because order matters here: p10k's
# instant prompt must precede anything that writes to the terminal, and the
# tool `eval`s at the end depend on PATH being final.
for _f in "$ZDOTDIR_CONF"/conf.d/*.zsh(N); do . "$_f"; done
unset _f
