#!/usr/bin/env sh
TMPPATH=$(mktemp -d "/tmp/lua-language-server.XXXX")
DEFAULT_LOGPATH="$TMPPATH/log"
DEFAULT_METAPATH="$TMPPATH/meta"

exec /usr/lib/lua-language-server/bin/lua-language-server -E /usr/lib/lua-language-server/main.lua \
  --logpath="$DEFAULT_LOGPATH" --metapath="$DEFAULT_METAPATH" \
  "$@"
