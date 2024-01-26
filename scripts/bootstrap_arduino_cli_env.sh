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

ARDUINO_CLI_ARCHIVE='arduino-cli_0.35.0-rc.2_Linux_64bit.tar.gz'
ARDUINO_LIB_INDEX_ARCHIVE='library_index.tar.bz2'
ARDUINO_PKG_INDEX_ARCHIVE='package_index.tar.bz2'
ARDUINO_PKG_STM_INDEX='package_stmicroelectronics_index.json'


################################################################################
# build_arduino_env
#
# Build an Arduino environment with an arduino-cli binary. The parameter
# $3 must provides a list of required packages to install in the environments,
# and $4 must provides a list of core to install in the environments. Note, to
# be entirely standalone the package list must contain a least the arduino
# builtin packages (catgs, serial-discovery...) and the required packages for a
# core. During the environment building This function search arduino package
# in the directory $1, the package file must be prefixed with the string
# 'arduino_pkg_' and the name of the package provided in the package list
# must be without the prefix.
#
# arguments:
# - $1: Archive directory where installation files are stored.
# - $2: Target directory where the arduino-cli environment is installed.
# - $3: File containing a list of Arduino package(s) to install.
#       example: ctags-5.8-arduino11-pm-x86_64-pc-linux-gnu.tar.bz2
# - $4: File containing a list of Arduino core(s) to install.
#       example: arduino:sam@1.6.12
#
################################################################################
function build_arduino_env()
{
  archive_dir=$1
  install_dir=$2
  arduino_cli_dir="${install_dir}/arduino-cli"
  arduino_cli_bin="${arduino_cli_dir}/arduino-cli"
  arduino_env="${install_dir}/arduino15"
  conf_file="${arduino_env}/arduino-cli.yaml"
  arduino_dl_cache="$install_dir/arduino15_dl_cache"
  arduino_cache_pkg="${arduino_dl_cache}/packages"
  log_file="${arduino_env}/scratch_log.txt"

  mkdir "${arduino_cli_dir}"
  mkdir "${arduino_env}"
  mkdir "${arduino_dl_cache}"
  mkdir "${arduino_cache_pkg}"

  tar --directory="${arduino_cli_dir}" -x -f "${archive_dir}/${ARDUINO_CLI_ARCHIVE}"
  tar --directory="${arduino_env}" -x -f "${archive_dir}/arduino/${ARDUINO_LIB_INDEX_ARCHIVE}"
  tar --directory="${arduino_env}" -x -f "${archive_dir}/arduino/${ARDUINO_PKG_INDEX_ARCHIVE}"
  cp "${archive_dir}/arduino/${ARDUINO_PKG_STM_INDEX}" "${arduino_env}/"

  while IFS= read -r line; do
    cp "${archive_dir}/arduino/${line}" "${arduino_cache_pkg}/${line}"
  done < "${3}"

  conf_directories_data=$(realpath "${arduino_env}")
  conf_directories_downloads=$(realpath "${arduino_dl_cache}")

  {
    echo "directories:"
    echo "  data: \"${conf_directories_data}\""
    echo "  downloads: \"${conf_directories_downloads}\""
    echo -e "\n"
  } > "${conf_file}"

  core_dep=$(< "$4" tr '\n' ' ')

  $arduino_cli_bin \
      --config-file "${conf_file}" \
      --log-file "${log_file}" \
      --additional-urls "${arduino_env}/${ARDUINO_PKG_STM_INDEX}" \
      core install $core_dep

  rm -rf "${arduino_dl_cache}"
}

################################################################################
# Script entry point
################################################################################

build_arduino_env "${@}"
