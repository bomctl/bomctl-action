#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# SPDX-FileCopyrightText: Copyright © 2024 bomctl a Series of LF Projects, LLC
# SPDX-FileName: .github/scripts/install.sh
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

archive_ext=".tar.gz"
binary_ext=""

[[ $RUNNER_OS =~ [Ww]indows ]] && archive_ext=".zip" && binary_ext=".exe"

install_path="${INPUT_INSTALL_DIR:=$HOME/.bomctl}/bomctl${binary_ext}"
releases_api="https://api.github.com/repos/bomctl/bomctl/releases"
semver_pattern="^v[0-9]+(\.[0-9]+){0,2}$"

# shellcheck source=/dev/null
source "${SCRIPT_DIR}/utils.sh"

function download_binary {
  local download_url="https://github.com/bomctl/bomctl/releases/download/${INPUT_VERSION}/${1}"

  log_info "Downloading platform-specific version '${INPUT_VERSION}' of bomctl...\n\t${download_url}"

  case ${RUNNER_OS} in
    [Ll]inux | mac[Oo][Ss])
      curl_opts "${download_url}" | tar --extract --gzip --directory "${INPUT_INSTALL_DIR}" bomctl
      ;;
    [Ww]indows)
      curl_opts "${download_url}" --remote-name

      powershell -Command "Add-Type -Assembly System.IO.Compression.FileSystem;
        \$zip = [IO.Compression.ZipFile]::OpenRead('$(basename "${download_url}")');
        \$entry = \$zip.Entries | Where-Object -Property Name -EQ 'bomctl.exe';
        \$installPath = Join-Path -Path \$env:INPUT_INSTALL_DIR -ChildPath 'bomctl.exe';
        [IO.Compression.ZipFileExtensions]::ExtractToFile(\$entry, \$installPath)"
      ;;
    *)
      exit_with_error "Unsupported OS ${RUNNER_OS}."
      ;;
  esac
}

function resolve_arch {
  case ${RUNNER_ARCH} in
    X64 | amd64)   echo "amd64"                                              ;;
    ARM64 | arm64) echo "arm64"                                              ;;
    *)             exit_with_error "Unsupported architecture ${RUNNER_ARCH}" ;;
  esac
}

function resolve_os {
  case ${RUNNER_OS} in
    [Ll]inux)    echo "linux"                                   ;;
    mac[Oo][Ss]) echo "darwin"                                  ;;
    [Ww]indows)  echo "windows"                                 ;;
    *)           exit_with_error "Unsupported OS ${RUNNER_OS}." ;;
  esac
}

function run_install {
  # jq is needed to parse JSON data. It is included on all GitHub-hosted runners by default.
  if ! command -v jq &> /dev/null; then
    exit_with_error "jq is required for this action."
  fi

  mkdir -p "${INPUT_INSTALL_DIR}"

  # Resolve "latest" to a concrete release version.
  if [[ ${INPUT_VERSION:=latest} == latest ]]; then
    INPUT_VERSION=$(curl_opts "${releases_api}/latest" | jq --raw-output .name)

    log_info "Resolved 'latest' to version ${INPUT_VERSION}"
  fi

  # Perform go install if requested version doesn't match tag pattern.
  if [[ ! $INPUT_VERSION =~ $semver_pattern ]]; then
    log_info "Performing go install of github.com/bomctl/bomctl@${INPUT_VERSION}"

    GOBIN="${INPUT_INSTALL_DIR}" go install "github.com/bomctl/bomctl@${INPUT_VERSION}"

    return
  fi

  log_info "Custom bomctl version '${INPUT_VERSION}' requested"

  download_binary "bomctl_${INPUT_VERSION#v}_$(resolve_os)_$(resolve_arch)${archive_ext}"
}

run_install

if [[ ! -x $install_path ]]; then
  exit_with_error "bomctl executable not found at ${install_path} or not executable"
fi

log_info "Successfully installed bomctl to\n\t${install_path}"

echo "bomctl-binary=${INPUT_INSTALL_DIR}/bomctl${binary_ext}" >> "${GITHUB_OUTPUT}"
echo "${INPUT_INSTALL_DIR}" >> "${GITHUB_PATH}"
