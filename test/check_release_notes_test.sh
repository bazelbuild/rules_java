#!/usr/bin/env bash
# Copyright 2025 The Bazel Authors. All rights reserved.
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

RELNOTES_FILE=$1
VERSION=$2

function fail() {
  echo "ERROR: ${1}"
  echo "Release notes content:"
  echo "--------------------------------------"
  cat ${RELNOTES_FILE}
  echo "--------------------------------------"
  exit 1
}

echo "Checking generated release notes: ${RELNOTES_FILE}"

grep -q '**Changes since fake-tag-for-tests**' ${RELNOTES_FILE} || fail "No changelog header"
grep -q 'Fake commit message for testing' ${RELNOTES_FILE} || fail "No changelog commit"
grep -q '**MODULE.bazel setup**' ${RELNOTES_FILE} || fail "No bzlmod setup header"
grep -q "bazel_dep(name = \"rules_java\", version = \"${VERSION}\")" ${RELNOTES_FILE} || fail "No bzlmod dep stanza"
grep -q '**WORKSPACE setup**' ${RELNOTES_FILE} || fail "No WORKSPACE setup header"
grep -q '**Using the rules**' ${RELNOTES_FILE} || fail "No using the rules header"
