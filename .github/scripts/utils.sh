#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# SPDX-FileCopyrightText: Copyright © 2024 bomctl a Series of LF Projects, LLC
# SPDX-FileName: .github/scripts/utils.sh
# SPDX-FileType: SOURCE
# SPDX-License-Identifier: Apache-2.0
# -----------------------------------------------------------------------------
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# -----------------------------------------------------------------------------

set -euo pipefail

# ANSI color escape codes
declare -xr BOLD="\x1b[1m"
declare -xr GREEN="\x1b[32m"
declare -xr CYAN="\x1b[1;36m"
declare -xr RED="\x1b[1;31m"
declare -xr RESET="\x1b[0m"
declare -xr YELLOW="\x1b[1;33m"

shopt -s expand_aliases

alias curl_opts="curl --fail --silent --show-error --location --url"

if [ -z "${NO_COLOR:-}" ]; then
  alias log_error='echo -e "${RED}ERROR${RESET}:"'
  alias log_info='echo -e "${CYAN}INFO${RESET}:"'
  alias log_warn='echo -e "${YELLOW}WARN${RESET}:"'
else
  alias log_error='echo "ERROR:"'
  alias log_info='echo "INFO:"'
  alias log_warn='echo "WARN:"'
fi

function exit_with_error {
  log_error "${1}"
  exit 1
}

function export_db_json {
  local db_file=$1
  local objects=()
  local rows

  tables="$(
    sqlite3 "${db_file}" \
      "SELECT name FROM sqlite_schema
      WHERE type == 'table'
      AND name NOT LIKE 'sqlite_%'
      ORDER BY name"
  )"

  for table in $tables; do
    rows="$(sqlite3 "${db_file}" -json "SELECT * FROM ${table}")"

    [[ -z $rows ]] && rows="[]"

    objects+=("$(printf '{"%s": %s}' "$table" "$rows")")
  done

  output=$(echo "${objects[*]}" | jq --slurp 'reduce .[] as $obj ({}; . += $obj)')
  echo "$output" > bomctl-export.json
}

function export_db_sql {
  local db_file=$1

  sqlite3 "${db_file}" -cmd ".output bomctl-export.sql" ".dump"
}
