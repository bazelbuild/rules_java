#!/usr/bin/env bash

test -d "$JAVABASE_RUNFILES" || (echo 'JAVABASE_RUNFILES not found' && exit 1)
test -f "$JAVA_RUNFILES" || (echo 'JAVA_RUNFILES not found' && exit 1)
