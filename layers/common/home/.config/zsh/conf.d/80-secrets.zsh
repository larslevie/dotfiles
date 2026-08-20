# Secrets resolve from 1Password on demand. Only op:// pointers live on disk,
# in secrets.d/*.env; resolved values stay in this shell's memory and go away
# with it. Any layer can drop a file in secrets.d.
#
# Loading is manual on purpose. Resolving at startup would put a Touch ID
# prompt in front of every new shell and export every value to every child
# process, whether or not it needs one.
#
#   opload            resolve every secrets.d/*.env
#   opload work       resolve secrets.d/work.env only
#   opunload          drop the resolved values again

opload() {
  local dir="$ZDOTDIR_CONF/secrets.d"
  local pat=${1:-*} file line key ref
  typeset -gUa OPLOAD_KEYS
  for file in "$dir"/${~pat}.env(N); do
    while IFS= read -r line; do
      [[ -z $line || $line == \#* ]] && continue
      key=${line%%=*}
      ref=${line#*=}
      # Plain values pass through; only op:// references cost a lookup.
      if [[ $ref == op://* ]]; then
        export "$key=$(op read -n "$ref")" || return 1
      else
        export "$key=$ref"
      fi
      OPLOAD_KEYS+=("$key")
    done < "$file"
  done
}

opunload() {
  local key
  for key in $OPLOAD_KEYS; do unset "$key"; done
  unset OPLOAD_KEYS
}
