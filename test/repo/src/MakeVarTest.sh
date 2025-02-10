#!/usr/bin/env bash

if [ ! -f "$JAVABASE_RUNFILES/bin/java" ]; then
  echo '$JAVABASE_RUNFILES does not point to a working JRE' && exit 1
fi