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

ARCHIVE_ARDUINO_PARTIAL_PATH="arduino"

LOC_ARCHIVE_ORG="archive.org"
LOC_ORIGIN="original-source"

#USER_AGENT="Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1)


################################################################################
#
# $1: download location: origin, archive.org
# $2: Archive file list, entry to download must be in the following form:
#     <saved_filename>;<sha1>;<url_origin>;<url_archive_org>
#     note: sha1, url_origin and url_archive_org are optional
# $3: Download directory
#
################################################################################
function dl_archive_list()
{
    while IFS=";" read -r saved_filename expect_sha1 url_origin url_archive_org
    do
        if [ "${1}" = "${LOC_ORIGIN}" ]; then
            url="${url_origin}"
        elif [ "${1}" =  "${LOC_ARCHIVE_ORG}" ]; then
            url="${url_archive_org}"
        else
            echo "Invalid URL location: '${1}'"
            exit 1
        fi

        if [ "${url}" = "" ]; then
            echo "[i] '${1}' URL not provided, skip file download for: '${saved_filename}'"
            continue
        fi

        if [ -f "${3}/${saved_filename}" ]; then
            echo "[i] file exist, skip file download for: '${saved_filename}'"
            continue
        fi

        echo "[i] downloading: ${url}"
        echo "    save to '${3}/${saved_filename}'"

        # --user-agent="$USER_AGENT"
        # --no-verbose
        wget --tries=42 -O - "${url}" > "${3}/${saved_filename}"

        dl_file_hash=$(sha1sum "${3}/${saved_filename}" |cut -d ' ' -f 1)

        if [ "${expect_sha1}" = "" ]; then
            echo "[w] WARNING : file hash not provided for: '${saved_filename}'"
        elif [ "${expect_sha1}" != "" ] && [ "${dl_file_hash}" = "${expect_sha1}" ]; then
            echo "[+] file hash ok for: '${saved_filename}'"
        else
            echo "[-] file hash not match for: '${saved_filename}'"
            rm -f "${3}/${saved_filename}"
            exit 1
        fi


    done < "${2}"
}


################################################################################
# dl_github_repository
#
# Download a list of Github repository and archive it in tar.gz format with the
# following name format:
# github.com_USERNAME_REPOSITORYNAME.tar.gz
#
# $1: File containing a list of Github repository to download.
# $2: Download output directory.
#
################################################################################
function dl_github_repository()
{
    tmp_dir=/tmp/github_tmp_dl_dir
    rm -rf "${tmp_dir}"
    mkdir -p "${tmp_dir}"

    while IFS= read -r line
    do
        repo_user=$(echo "${line}" |cut -d "/" -f 4)
        repo_name=$(echo "${line}" |cut -d "/" -f 5)
        git_dir_name="github.com_${repo_user}_${repo_name}"
        git_archive="${git_dir_name}.tar.gz"

        if ! [ -f "${2}/${git_archive}" ]; then
            cd "${tmp_dir}" || exit 1
            echo "[i] cloning: ${line}"
            git clone "${line}"
            mv "${repo_name}" "${git_dir_name}"
            tar -czf "${git_archive}" "${git_dir_name}"
            mv "${git_archive}" "${2}/"
            rm -rf "${git_dir_name}"
        fi
    done < "${1}"

    rm -rf "${tmp_dir}"
}


################################################################################
# main
#
# $1: Archive locations.
# $2: Download output directory.
#
################################################################################
function main()
{
    echo "[i] Start file download."

    mkdir -p "${2}/${ARCHIVE_ARDUINO_PARTIAL_PATH}"

    if [ "${1}" = "${LOC_ORIGIN}" ]; then
        dl_github_repository "${SCRIPT_DIR}/../data/url_github_repositories.txt" "${2}"
    fi

    if [ "${1}" = "${LOC_ARCHIVE_ORG}" ] || [ "${1}" = "${LOC_ORIGIN}" ]; then
        dl_archive_list "${1}" "${SCRIPT_DIR}/../data/url_archives.txt" "${2}"
        dl_archive_list "${1}" "${SCRIPT_DIR}/../data/url_archives_arduino.txt" \
                        "${2}/${ARCHIVE_ARDUINO_PARTIAL_PATH}"
    fi

    echo "[+] files download success."
}


################################################################################
# Script entry point
#
# $1: Download output directory.
# $2: Optional archive download sources.
#     --archive-location: Download archive files from the original URL
#
################################################################################
archive_location=""
download_dir=""

while :; do
    case $1 in
      -h|-\?|--help)
          exit
      ;;
      --download-dir=?*)
          download_dir=$(realpath  "${1#*=}")
      ;;
      --archive-location=?*)
          archive_location=${1#*=}
      ;;
      *)
          break
    esac
    shift
done


if [ "${archive_location}" != "${LOC_ARCHIVE_ORG}" ] && [ "${archive_location}" != "${LOC_ORIGIN}" ]; then
    echo -e "[-] Invalid --archive-location option: ${1}\n"
    exit 1
fi


if [ ! -d "${download_dir}" ]; then
    echo "  --download-dir : provide a valid existing directory"
    exit 1
fi


main "${archive_location}" "${download_dir}"


