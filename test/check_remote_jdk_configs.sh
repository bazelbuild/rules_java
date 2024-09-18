#!/usr/bin/env bash
# Copyright 2024 The Bazel Authors. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

echo "Checking hashes and strip_prefix for $# configs"

_MISSING_MIRRORS=()
for config in "$@"; do
    TMP_FILE=$(mktemp -q /tmp/remotejdk.XXXXXX)
    IFS=, read -r name url mirror_url hash strip_prefix <<< "${config}"
    echo "fetching $name from $url to ${TMP_FILE}"
    curl --silent -o ${TMP_FILE} -L "$url"
    actual_hash=$(sha256sum ${TMP_FILE} | cut -d' ' -f1)
    if [ "${hash}" != "${actual_hash}" ]; then
      echo "ERROR: wrong hash for ${name}! wanted: ${hash}, got: ${actual_hash}"
      exit 1
    fi
    if [[ -z "${url##*.tar.gz}" ]]; then
      root_dir=$(tar ztf ${TMP_FILE} --exclude='*/*')
    elif [[ -z "${url##*.zip}" ]]; then
      root_dir=$(unzip -Z1 ${TMP_FILE} | head -n1)
    else
      echo "ERROR: unexpected archive type for ${name}"
      exit 1
    fi
    if [ "${root_dir}" != "${strip_prefix}/" ]; then
      echo "ERROR: bad strip_prefix for ${name}, wanted: ${strip_prefix}/, got: ${root_dir}"
      exit 1
    fi
    if [[ -n "${mirror_url}" ]]; then
      echo "checking mirror: ${mirror_url}"
      curl --silent --fail -I -L ${mirror_url} > /dev/null || { _MISSING_MIRRORS+=("${mirror_url}"); }
    fi
done

if [[ ${#_MISSING_MIRRORS[@]} -gt 0 ]]; then
  echo "Missing mirror URLs:"
  for m in "${_MISSING_MIRRORS[@]}"; do
    echo "  ${m}"
  done
  exit 1
fi