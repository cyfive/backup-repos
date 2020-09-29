#!/bin/bash

#
# Backup (or sync) repos to local from cloug git services
#
# Author: Stanislav V. Emets <emetssv@mail.ru>
#

function usage() {
    echo
    echo "Usage:"
    echo "  $0 -l|--list repo.list [-t|--to new-origin]"
    echo
    echo " -l | --list file containing repo list for caching"
}

repo_list=""
new_hosting=""

while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        -l|--list)
        shift
        repo_list="$1"
        ;;
    esac
    shift
done

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
    repo_name=$(basename $repo_url)
    repo_name=${repo_name/.git/}
    if [ -d $repo_name ]; then
        echo "Repo alredy cloned, pull changes"
        pushd $repo_name > /dev/null
        git pull
        popd > /dev/null
    else
        echo "Cloning repo $repo_url"
        git clone $repo_url
    fi
done