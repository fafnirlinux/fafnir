#!/bin/sh

search_dir=$PWD/$1
for entry in $search_dir/*
do
  if [[ -f $entry ]]; then
  	continue;
  fi
  ./convert.sh $(basename $entry) $1
done
