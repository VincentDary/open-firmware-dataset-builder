#!/usr/bin/env bash

################################################################################
#
# Copyright 2023-2024 Vincent Dary
#
# This file is part of open-firmware-dataset-builder (OFDB).
#
# open-firmware-dataset-builder is free software: you can redistribute it and/or
# modify it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or (at your
# option) any later version.
#
# open-firmware-dataset-builder is distributed in the hope that it will be
# useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
# Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# open-firmware-dataset-builder. If not, see <https://www.gnu.org/licenses/>.
#
################################################################################

set -e

################################################################################
# bootstrap_git_archive
#
# Uncompress an archived git repository compressed as tar.gz to a target
# directory and checkout to a specific commit.
#
# $1: Git repository archive in targ.gz format.
# $2: Target directory where to uncompress the repository.
# $3: Git commit or tag to checkout the git repository.
#
################################################################################
function bootstrap_git_archive()
{
    if [[ $1 != *.tar.gz ]]; then
      echo "[ERROR] Archive must be compressed as tar.gz: '${1}'"
      exit 1
    fi

    tar --extract --file="${1}" --directory="${2}"
    repo_name=$(basename "${1}")
    cd "${2}/${repo_name%.tar.gz}"
    git checkout "${3}"
}


bootstrap_git_archive "$@"
