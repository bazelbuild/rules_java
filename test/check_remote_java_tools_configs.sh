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

echo "Checking hashes for $# configs"

function download_and_check_hash() {
    name=$1
    url=$2
    hash=$3
    TMP_FILE=$(mktemp -q /tmp/remotejavatools.XXXXXX)
    echo "fetching $name from $url to ${TMP_FILE}"
    curl --silent -o ${TMP_FILE} -L "$url"
    actual_hash=`sha256sum ${TMP_FILE} | cut -d' ' -f1`
    if [ "${hash}" != "${actual_hash}" ]; then
      echo "ERROR: wrong hash for ${name}! wanted: ${hash}, got: ${actual_hash}"
      exit 1
    fi
}

for config in "$@"; do
    IFS=, read -r name mirror_url gh_url hash <<< "${config}"
    download_and_check_hash ${name} ${mirror_url} ${hash}
    download_and_check_hash ${name} ${gh_url} ${hash}
done