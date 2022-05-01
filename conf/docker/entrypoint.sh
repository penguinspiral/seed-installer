#!/usr/bin/env bash
set -e

function title() {
  printf "\n\033[1m=== $1 ===\033[0m\n"
}


function webserver() {
  title "Starting local HTTP server"
  python3 -m http.server 8080 \
          --directory /build/mirror/ &

  while [[ $(/bin/nc -z localhost 8080) ]]; do
    echo ">>> Waiting for webserver to start..."
    sleep 1
  done
}

function prepenv() {
  title "Preparing debian-cd environment"
  rsync --recursive --copy-links /usr/share/debian-cd /build/

  title "Detecting release version"
  local DEBIAN_RELEASE_VERSION=$(awk '/^Version:/ {print $2}' mirror/dists/${DEBIAN_RELEASE}/Release)
  export DEBIAN_RELEASE_VERSION=${DEBIAN_RELEASE_VERSION:-unknown}

  title "Importing debian-cd configuration"
  rsync --recursive /build/conf/debian-cd/* /build/debian-cd/
  mv /build/debian-cd/tasks/Debian-seed-installer /build/debian-cd/tasks/${DEBIAN_RELEASE}/

  title "Sourcing debian-cd configuration"
  cd /build/debian-cd/
  source CONF.sh
  export DEBIAN_CD_CONF_SOURCED=true
}

function build() {
  title "Make distclean"
  make distclean

  title "Importing local mirror GPG keys"
  mkdir --parents "${APTTMP}/${DEBIAN_RELEASE}-${ARCHES}/apt/trusted.gpg.d"
  rsync --ignore-missing-args /build/local/keys/*.gpg "${APTTMP}/${DEBIAN_RELEASE}-${ARCHES}/apt/trusted.gpg.d/";

  title "Make status"
  make status

  title "Make packagelists"
  make packagelists COMPLETE=1 TASK=Debian-seed-installer

  title "Make image-trees"
  make image-trees

  title "Make images (iso)"
  make images
}

function main() {
  webserver;
  prepenv;
  build;
}

main;
