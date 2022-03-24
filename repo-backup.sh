#!/bin/bash

#
# Backup (or sync) repos to local from cloug git services
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

function usage() {
    echo
    echo "Usage:"
    echo "  $0 -l|--list repo.list [-d |--dest destination] [ -o | --out backup file name] [-r | --rm]"
    echo
    echo " -l | --list file containing repo list for caching"
    echo " -d |--dest destination directory, default value: backup "
    echo " -o | --out backup file name, default value: backup-YYYY-MM-DD-HHMMSS.tar.gz"
    echo " -r | --rm remove destination directory after complete"
}

backup_dest="./backup"
backup_date=$(date +%Y-%m-%d-%H%M%S)
backup_file="backup-$backup_date.tar.gz"
repo_list=""
new_hosting=""
delete_dest=0

while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        -l|--list)
        shift
        repo_list="$1"
        ;;
        -d|--dest)
        shift
        backup_dest="$1"
        ;;
        -o|--out)
        shift
        backup_file="$1"
        ;;
        -r|--rm)
        delete_dest=1
        ;;
    esac
    shift
done

#clean backup destination from spaces
backup_dest=${backup_dest/[[:blank:]]/}

if [ -z "$backup_dest" ]; then
    echo "Empty backup destination not allowed!"
    exit 1
fi

if [ ! -d $backup_dest ]; then
    mkdir -p $backup_dest
fi

if [ -z "$repo_list" ]; then
    echo "Repo list not set!"
    usage
    exit 1
fi

if [ ! -f "$repo_list" ]; then
    echo "Repo does not exists!"
    usage
    exit 1
fi

all_repos=$(cat $repo_list)

for repo_url in $all_repos; do
    if [ -n "$repo_url" ]; then
        repo_name=$(basename $repo_url)
        repo_name=${repo_name/.git/}
        if [ -d "$backup_dest/$repo_name" ]; then
                echo "Repo alredy cloned, pull changes"
                pushd "$backup_dest/$repo_name" > /dev/null
                git pull
                popd > /dev/null
        else
                echo "Cloning repo $repo_url"
                pushd "$backup_dest" > /dev/null
                git clone $repo_url
                popd > /dev/null
        fi
    fi
done

tar -czvf $backup_file $backup_dest

if [ $delete_dest -gt 0 ]; then
    if [ -n "$backup_dest" ]; then
        rm --preserve-root -rf $backup_dest/*
    fi
fi