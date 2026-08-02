# Corporate TLS interception bundle. Guarded on existence: pointing SSL_CERT_FILE
# and REQUESTS_CA_BUNDLE at a missing file makes curl and every Python TLS call
# fail outright, which is what happened when these were exported unconditionally.
_ca="$XDG_CONFIG_HOME/witco/ca-bundle.pem"
if [[ -r $_ca ]]; then
  export AWS_CA_BUNDLE="$_ca"
  export CURL_CA_BUNDLE="$_ca"
  export GIT_SSL_CAINFO="$_ca"
  export NODE_EXTRA_CA_CERTS="$_ca"
  export REQUESTS_CA_BUNDLE="$_ca"
  export SSL_CERT_FILE="$_ca"
fi
unset _ca
