#!/usr/bin/env bash
# A stand-in for a proguard allowlister that copies the spec without validating it.
set -euo pipefail

while [[ $# -gt 0 ]]; do
  case "$1" in
    --path) path="$2"; shift 2 ;;
    --output) output="$2"; shift 2 ;;
    *) echo "unexpected argument: $1" >&2; exit 1 ;;
  esac
done
cp "$path" "$output"
