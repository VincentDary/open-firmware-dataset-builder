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

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

ARCHIVE_DIR_PARTIAL_PATH="archives"
ARCHIVE_ARDUINO_PARTIAL_PATH="${ARCHIVE_DIR_PARTIAL_PATH}/arduino"


################################################################################
# build_env_tree
#
# $1: Environment root directory.
#
################################################################################
function build_env_tree()
{
    mkdir -p "${1}/${ARCHIVE_DIR_PARTIAL_PATH}"
    mkdir -p "${1}/${ARCHIVE_ARDUINO_PARTIAL_PATH}"
    mkdir -p "${1}/builds"
    mkdir -p "${1}/src"
    mkdir -p "${1}/tools"
    mkdir -p "${1}/releases"
}


################################################################################
# extract_tools
#
# $1: Archive directory.
# $2: Tool directory.
#
################################################################################
function extract_tools()
{
    target_dir="${2}/arm-gnu-toolchain-13.2.rel1"
    mkdir "${target_dir}"
    echo "[i] Extracting to '${target_dir}'"
    tar --strip-components=1 --directory="${target_dir}" -x \
        -f "${1}/arm-gnu-toolchain-13.2.rel1-x86_64-arm-none-eabi.tar.xz"

    target_dir="$2/gcc-arm-none-eabi-7-2017-q4-major-linux"
    mkdir "${target_dir}"
    echo "[i] Extracting to '${target_dir}'"
    tar --strip-components=1 --directory="${target_dir}" -x \
        -f "${1}/gcc-arm-none-eabi-7-2017-q4-major-linux.tar.bz2"
}


################################################################################
# check archive files tree
#
# # $1: Environment root directory.
#
################################################################################
function check_archive_files_tree()
{
    cd "${1}/${ARCHIVE_DIR_PARTIAL_PATH}"

    while IFS=";" read -r expected_sha1 file_path
    do
        if [ ! -f "${file_path}"  ]; then
            echo "[-] Archive files tree check fail, missing file: ${file_path}"
            exit 1
        fi

        file_sha1=$(sha1sum "${file_path}" |cut -d " " -f 1)

        if [ "${expected_sha1}" != "" ]; then
            if [ "${file_sha1}" != "${expected_sha1}" ]; then
                echo "[-] Archive file integrity check fail for: ${file_path}"
                exit 1
            else
                echo "[+] Archive file integrity check ok for: ${file_path}"
            fi
        fi

    done < "${SCRIPT_DIR}/../data/archive_files_freeze.txt"

    echo "[+] Archive files tree check ok."
}


################################################################################
# main
#
# $1: Environment root directory to create.
# $2: Archive locations.
#
################################################################################
function main()
{
    if [ -d "${2}" ]; then
        if [ -d "${1}/${ARCHIVE_DIR_PARTIAL_PATH}" ]; then
            echo "[-] Archive directory exist, can't symlink to: "
            echo  "   ${1}/${ARCHIVE_DIR_PARTIAL_PATH}"
            exit 1
        else
            ln -s "${2}" "${1}/${ARCHIVE_DIR_PARTIAL_PATH}"
        fi
        build_env_tree "${1}"
    else
        echo "OK"
        build_env_tree "${1}"
        "${SCRIPT_DIR}/dl_dependencies.sh" \
            --archive-location="${2}"  \
            --download-dir="${1}/${ARCHIVE_DIR_PARTIAL_PATH}"
    fi

    check_archive_files_tree "${1}"

    cd "${1}"
    extract_tools "${1}/${ARCHIVE_DIR_PARTIAL_PATH}" "${1}/tools"

    echo -e "[+] firmware-dataset-builder environment successfully created.\n"
    echo -e  "    To build the firmware dataset:"
    echo -e  "     $ cd builders && make \n"
}


################################################################################
# Script entry point
#
# $1: Archive sources.
#     --archive-location: Download archive files from the provided location.
#                         The value can be the followings:
#            archive.org: Download archive from a frozen archive from archive.org. (recommended)
#            original-source: Download archive from the original archive files URLs.
#            /path/to/archive/dir: An archive directory on the filesystem.
#
################################################################################
archive_location=""

while :; do
    case $1 in
        -h|-\?|--help)
            exit
        ;;
        --archive-location=?*)
            archive_location=${1#*=}
        ;;
        *)
            break
    esac
    shift
done


if [ "${archive_location}" = "" ]; then
    echo "  --archive-location option must be provided"
    echo "      archive.org: Download archive from a frozen archive from archive.org. (recommended)"
    echo "      original-source: Download archive from the original archive files URLs."
    echo "      /path/to/archive/dir: A valid archive directory on the filesystem."
    exit 1
fi

install_dir=$(realpath "${SCRIPT_DIR}/..")
main "${install_dir}" "${archive_location}"
