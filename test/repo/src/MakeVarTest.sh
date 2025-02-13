#!/usr/bin/env bash

if [ ! -x "$JAVABASE_ROOTPATH/bin/java" ]; then
  echo '$JAVABASE_RUNFILES does not point to a working JRE' && exit 1
fi

echo $JAVA_ROOTPATH
if [ ! -x "$JAVA_ROOTPATH" ]; then
  echo '$JAVA_ROOTPATH does not exist' && exit 1
fi