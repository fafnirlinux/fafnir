# contrib/libreoffice README.md

# Dependencies

## harfbuzz-icu
`contrib/libreoffice` will need `opt/harfbuzz` with `opt/icu` and
`contrib/graphite2` support around, both are optional dependencies for
that port. If things don't work, try to check if this chain is installed
and properly rebuild to make use of each other:

```sh
prt-get isinst graphite2 && \
prt-get isinst icu && \
prt-get update -fr harfbuzz || \
echo "please install graphite2 and icu first"
```

## xmlsec and nss support

Again, `contrib/xmlsec` will depend on another optional port, `opt/nss`.
Check the following chain:
```sh
prt-get isinst nss && prt-get update -fr xmlsec || \
echo "please install nss before you attempt to rebuild xmlsec"
```
