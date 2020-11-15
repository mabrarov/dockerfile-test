#!/bin/bash

set -e

# shellcheck source=maven.sh
source "${TRAVIS_BUILD_DIR}/travis/maven.sh"

main() {
  docker_cache_dir="${HOME}/docker"
  if ! [[ -d "${docker_cache_dir}" ]]; then
    return
  fi

  for file in "${docker_cache_dir}/"*.tar.gz; do
    [[ -f "${file}" ]] || continue
    echo "Loading image from ${file}"
    zcat "${file}" | docker load
  done
}

main "${@}"
