#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# SPDX-FileCopyrightText: Copyright © 2024 bomctl a Series of LF Projects, LLC
# SPDX-FileName: .github/scripts/run-command.sh
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

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]:-$0}")" &> /dev/null && pwd)"
readonly SCRIPT_DIR

# shellcheck source=/dev/null
source "${SCRIPT_DIR}/utils.sh"

# Convert input args string to array.
IFS=" " read -r -a BOMCTL_ARGS <<< "${BOMCTL_ARGS:=}"

if [[ -n ${DATABASE_DIR:=} ]]; then
  BOMCTL_ARGS+=(--cache-dir "${DATABASE_DIR}")
fi

log_info "Running command: bomctl ${BOMCTL_COMMAND:=version} ${BOMCTL_ARGS[*]}..."

bomctl "$BOMCTL_COMMAND" "${BOMCTL_ARGS[@]}"
