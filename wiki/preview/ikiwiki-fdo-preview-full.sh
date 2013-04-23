#!/bin/bash

#set -xe

REPO=$(git remote -v show | grep freedesktop.org | head -n 1 | perl -pe 's~.+/(.+) .+~\1~')

OUTPUTDIR=/tmp/fdo-ikiwiki-${REPO} # you may want to change this to survive across reboots
#trap 'rm -rf ${OUTPUTDIR}' EXIT

mkdir -p ${OUTPUTDIR}
(
  cd ${OUTPUTDIR}
  [ -f ${OUTPUTDIR}/${REPO}.setup ]     || curl -O https://secure.freedesktop.org/ikiwiki/setup/${REPO}.setup # http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=652480
  [ -d ${OUTPUTDIR}/underlay ]  || wget --no-host-directories --cut-dirs=1 --no-check-certificate -r https://secure.freedesktop.org/ikiwiki/underlay/ # the rest of these aren't executables, so whatever.
  [ -d ${OUTPUTDIR}/templates ] || wget --no-host-directories --cut-dirs=1 --no-check-certificate -r https://secure.freedesktop.org/ikiwiki/templates/
)

# this crappy filename translation will break on special characters, but works on the common relative_path/file_name.mdwn case at least
[[ "$1" =~ ^(.+)\..+$ ]] || true
SANSEXT=${BASH_REMATCH[1]}
[[ $PWD =~ ^$(git rev-parse --show-toplevel)(/|())(.*) ]] # Bash hates (thing|)
CHECKOUTPATH=${BASH_REMATCH[3]}

cat ${OUTPUTDIR}/${REPO}.setup | ikiwiki-fdo-mangler.pl $OUTPUTDIR | ikiwiki --setup - --refresh # --verbose

# The following line will work with or without that first argument.
x-www-browser ${OUTPUTDIR}/output/${CHECKOUTPATH}/${SANSEXT}/index.html
