#!/usr/bin/env bash
set -ex

# Arguments:
# $1 ~ $TDIR:	 /build/debian-cd/tmp
# $2 ~ $MIRROR:  /build/mirror
# $3 ~ $DISKNUM: 1
# $4 ~ $CDDIR:   /build/debian-cd/tmp/${DEBIAN_RELEASE}/CD1
# $5 ~ $ARCHES:  amd64

declare -ra TARGETS=(${MIRROR}/
                     /build/extra/
                     /build/conf/preseed/preseed.cfg)

ln --symbolic \
   --verbose \
   "${TARGETS[@]}" \
   $4/
