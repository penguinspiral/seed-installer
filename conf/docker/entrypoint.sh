#!/usr/bin/env bash
set -e

function webserver() {
  printf "\n=== Starting local HTTP server ===\n"
  python3 -m http.server 8080 \
          --directory /build/mirror/ &

  while [[ $(/bin/nc -z localhost 8080) ]]; do
    echo ">>> Waiting for webserver to start..."
    sleep 1
  done
}

function prepenv() {
  printf "\n=== Preparing debian-cd environment ===\n"
  rsync --recursive --copy-links /usr/share/debian-cd /build/

  printf "\n=== Detecting release version ===\n"
  local DEBIAN_RELEASE_VERSION=$(awk '/^Version:/ {print $2}' mirror/dists/${DEBIAN_RELEASE}/Release)
  export DEBIAN_RELEASE_VERSION=${DEBIAN_RELEASE_VERSION:-unknown}

  printf "\n=== Importing debian-cd configuration ===\n"
  rsync --recursive /build/conf/debian-cd/* /build/debian-cd/
  mv /build/debian-cd/tasks/Debian-seed-installer /build/debian-cd/tasks/${DEBIAN_RELEASE}/

  printf "\n=== Sourcing debian-cd configuration ===\n"
  cd /build/debian-cd/
  source CONF.sh
  export DEBIAN_CD_CONF_SOURCED=true
}

function build() {
  printf "\n=== Make distclean ===\n"
  make distclean

  printf "\n=== Make status ===\n"
  make status

  printf "\n=== Make packagelists ===\n"
  make packagelists COMPLETE=1 TASK=Debian-seed-installer

  printf "\n=== Make image-trees ===\n"
  make image-trees

  printf "\n=== Make images (iso) ===\n"
  make images
}

function main() {
  webserver;
  prepenv;
  build;
}

main;
