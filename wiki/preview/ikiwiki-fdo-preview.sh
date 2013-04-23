#!/bin/bash

#set -x
set -e

OUTPUTDIR="$( mktemp -d )"
trap 'rm -rf ${OUTPUTDIR}' EXIT

# this crappy filename translation will break on special characters, but works on the common relative_path/file_name.mdwn case at least
[[ "$1" =~ ^(.+)\..+$ ]]
SANSEXT=${BASH_REMATCH[1]}
[[ $PWD =~ ^$(git rev-parse --show-toplevel)/(.*) ]]
CHECKOUTPATH=${BASH_REMATCH[1]}

mkdir -p ${OUTPUTDIR}/output/${CHECKOUTPATH}/${SANSEXT}

curl -s https://secure.freedesktop.org/ikiwiki/setup/$(git remote -v show | grep freedesktop.org | head -n 1 | perl -pe 's~.+/(.+) .+~\1~').setup | ikiwiki-fdo-mangler.pl $OUTPUTDIR | ikiwiki --setup - --verbose --render "$1" > ${OUTPUTDIR}/output/${CHECKOUTPATH}/${SANSEXT}/index.html

x-www-browser ${OUTPUTDIR}/output/${CHECKOUTPATH}/${SANSEXT}/index.html
