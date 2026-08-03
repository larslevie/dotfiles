# Loader only — real config lives in ~/.config/zsh/conf.d/*.zsh, sourced in
# filename order. Fragments are numbered because order matters here: fpath must
# be final before the deferred compinit runs, and the tool init at the end
# depends on PATH being complete.
for _f in "$ZDOTDIR_CONF"/conf.d/*.zsh(N); do . "$_f"; done
unset _f
