#!/bin/bash

set -e

# shellcheck source=maven.sh
source "${TRAVIS_BUILD_DIR}/travis/maven.sh"

main() {
  mvn_expression_evaluate_cmd="$(maven_runner)$(maven_settings)$(maven_project_file) --batch-mode --non-recursive"
  mvn_expression_evaluate_cmd="${mvn_expression_evaluate_cmd:+${mvn_expression_evaluate_cmd} }org.apache.maven.plugins:maven-help-plugin:3.2.0:evaluate"

  jboss_image_name_cmd="${mvn_expression_evaluate_cmd:+${mvn_expression_evaluate_cmd} }--define expression=jboss.image"
  jboss_image_name="$(eval "${jboss_image_name_cmd}" | sed -e '/^\[.*\].*$/d')"

  docker_cache_dir="${HOME}/docker"
  jboss_image_file="${docker_cache_dir}/jboss.tar.gz"

  if docker images --format '{{ .Repository }}:{{ .Tag }}' \
    | grep -m 1 -F -- "${jboss_image_name}" >/dev/null; then
    echo "Saving ${jboss_image_name} image into ${jboss_image_file}"
    mkdir -p "$(dirname "${jboss_image_file}")"
    docker save "${jboss_image_name}" | gzip -2 > "${jboss_image_file}"
  fi
}

main "${@}"
