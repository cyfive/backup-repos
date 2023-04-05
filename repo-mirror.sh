#!/bin/bash

#
# Backup (or sync) repos to local from cloud git services
#
# Author: Stanislav V. Emets <emetssv@mail.ru>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>

DEBUG=${DEBUG:-0}

CACHE_DIR=".cache"
REPO_LIST=""
SRC_REPO=""
DST_REPO=""

function usage() {
	echo
	echo "Usage:"
	echo "	$0 -l|--list repo.list [-r | --rm]"
	echo
	echo "	-l | --list file containing repo list for mirroring"
	echo "	-c | --cache cache path, the default path .cache"
	echo "	-s | --src source repo for once mirror"
	echo "	-d | --dst destination repo for once mirror"
	echo
}

function mirror_repo() {
	local src_repo=$1
	local dst_repo=$2

	src_repo_path=$(basename ${src_repo})
	if [[ "${src_repo_path}" != *".git" ]]; then
		src_repo_path="${src_repo_path}.git"
	fi

	if [ ${DEBUG} -gt 0 ]; then
		echo "src_repo_path: ${src_repo_path}"
	fi
	
	echo "Mirroring repo ${src_repo}"
	pushd "${CACHE_DIR}" > /dev/null
	git clone --mirror ${src_repo}
	popd > /dev/null
	pushd "${CACHE_DIR}/${src_repo_path}" > /dev/null
	
	git remote set-url --push origin ${dst_repo}
	git push --mirror
	popd > /dev/null
}

while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        -l|--list)
        shift
        REPO_LIST="$1"
        ;;
        -c|--cache)
        shift
        CACHE_DIR="$1"
        ;;
        -s|--src)
        shift
        SRC_REPO="$1"
        ;;
        -d|--dst)
        shift
        DST_REPO="$1"
        ;;
    esac
    shift
done

CACHE_DIR=${CACHE_DIR/[[:blank:]]/}
if [ ${DEBUG} -gt 0 ]; then
	echo "Cache dir: ${CACHE_DIR}"
fi

if [ ! -d ${CACHE_DIR} ]; then
    mkdir -p ${CACHE_DIR}
fi

if [ -z "${REPO_LIST}"] && ([ -z "${SRC_REPO}" ] || [ -z "${DST_REPO}" ]); then
   	echo "Nothing to mirror!"
   	usage
   	exit 1
fi

if [ -n "${REPO_LIST}" ] && [ -f "${REPO_LIST}" ]; then
	while read repo; do
		if [ -n "${repo}" ]; then
			repo=${repo/[[:blank:]]/}
			src_repo=$(echo $repo | cut -d ';' -f 1)
			dst_repo=$(echo $repo | cut -d ';' -f 2)

			mirror_repo ${src_repo} ${dst_repo}
		fi
	done < ${REPO_LIST}
fi

if [ -n "${SRC_REPO}" ] && [ -n "${DST_REPO}" ]; then
	mirror_repo ${SRC_REPO} ${DST_REPO}
fi

if [ -d "${CACHE_DIR}" ]; then
	if [ -n "${CACHE_DIR}" ]; then
		echo "Cleaning cache directory..."
		rm --preserve-root -rf ${CACHE_DIR}
	fi
fi
