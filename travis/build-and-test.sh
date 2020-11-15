#!/bin/bash

set -e

# shellcheck source=maven.sh
source "${TRAVIS_BUILD_DIR}/travis/maven.sh"
# shellcheck source=travis-retry.sh
source "${TRAVIS_BUILD_DIR}/travis/travis-retry.sh"

login_red_hat_docker_registry() {
  travis_retry docker login -u "${REDHAT_USER}" -p "${REDHAT_PASSWORD}" registry.redhat.io
}

build_maven_project() {
  build_cmd="$(maven_runner)$(maven_settings)$(maven_project_file)$(docker_maven_plugin_version)"
  build_cmd="${build_cmd:+${build_cmd} }--batch-mode"

  if [[ -n "${DOCKERHUB_USER}" ]]; then
    build_cmd="${build_cmd:+${build_cmd} }--define docker.image.registry=$(printf "%q" "${DOCKERHUB_USER}")"
  fi

  if [[ -n "${J2CLI_VERSION}" ]]; then
    build_cmd="${build_cmd:+${build_cmd} }--define j2cli.version=$(printf "%q" "${J2CLI_VERSION}")"
  fi

  build_cmd="${build_cmd:+${build_cmd} }package"

  echo "Building with: ${build_cmd}"
  eval "${build_cmd}"

  docker images
}

wait_container_log() {
  container_name="${1}"
  wait_seconds=${2}
  status="${3}"
  log_message="${4}"
  exit_code=0
  while true; do
    echo "Waiting for ${container_name} container log to contain ${log_message} during next ${wait_seconds} seconds"
    if [[ -n "${status}" ]]; then
      container_status="$(docker inspect --type container \
        --format='{{ .State.Status }}' "${container_name}")" ||
        exit_code="${?}"
      if [[ "${exit_code}" -ne 0 ]]; then
        echo "Failed to inspect ${container_name} container"
        return 1
      fi
      if [[ "${container_status}" != "${status}" ]]; then
        echo "${container_name} container status is ${container_status} while expected is ${status}"
        return 1
      fi
    fi
    if docker logs "${container_name}" 2>&1 |
      grep -m 1 -F -- "${log_message}" >/dev/null; then
      return 0
    fi
    if [[ "${wait_seconds}" -le 0 ]]; then
      echo "Timeout waiting for ${container_name} container log to contain ${log_message}"
      return 1
    fi
    sleep 1
    wait_seconds=$((wait_seconds - 1))
  done
}

run_tests() {
  mvn_expression_evaluate_cmd="$(maven_runner)$(maven_settings)$(maven_project_file) --batch-mode --non-recursive"
  mvn_expression_evaluate_cmd="${mvn_expression_evaluate_cmd:+${mvn_expression_evaluate_cmd} }org.apache.maven.plugins:maven-help-plugin:3.2.0:evaluate"

  docker_image_registry_cmd="${mvn_expression_evaluate_cmd:+${mvn_expression_evaluate_cmd} }--define expression=docker.image.registry"
  docker_image_registry="$(eval "${docker_image_registry_cmd}" | sed -e '/^\[.*\].*$/d')"

  maven_project_version_cmd="${mvn_expression_evaluate_cmd:+${mvn_expression_evaluate_cmd} }--define expression=project.version"
  maven_project_version="$(eval "${maven_project_version_cmd}" | sed -n -e '/^\[.*\]/ !{ /^[0-9]/ { p; q } }')"

  image_name="${docker_image_registry}/dockerfile-test:${maven_project_version}"
  container_name="test"
  container_port="8080"
  docker_host="localhost"
  jboss_start_message="JBAS015874"
  jboss_stop_message="JBAS015950"

  echo "Staring ${container_name} container created from ${image_name} image"
  docker run -d --name "${container_name}" -p "${container_port}:8080" "${image_name}" >/dev/null

  wait_container_log "${container_name}" "${APP_START_TIMEOUT}" "running" "${jboss_start_message}"

  echo "Requesting application"
  curl -s "http://${docker_host}:${container_port}"

  echo "Stopping ${container_name} container"
  docker stop -t "${APP_STOP_TIMEOUT}" "${container_name}" >/dev/null

  wait_container_log "${container_name}" 0 "" "${jboss_stop_message}"

  container_exit_code="$(docker inspect \
    --type container \
    --format='{{ .State.ExitCode }}' \
    "${container_name}")"
  if [[ "${container_exit_code}" -ne 0 ]]; then
    echo "Unexpected exit code of ${container_name} container: ${container_exit_code}"
    return 1
  fi

  echo "Removing ${container_name} container"
  docker rm -fv "${container_name}" >/dev/null

  travis_branch_name="${TRAVIS_BRANCH}"
  if [[ "${TRAVIS_PULL_REQUEST}" != "false" ]]; then
    travis_branch_name="${TRAVIS_PULL_REQUEST_BRANCH}"
  fi

  if [[ -z "${RELEASE_JOB}" ]] ||
    [[ "${RELEASE_JOB}" -eq 0 ]] ||
    [[ "${travis_branch_name}" != "master" ]]; then
    mvn_docker_remove_cmd="$(maven_runner)$(maven_settings)$(maven_project_file) --batch-mode docker:remove"
    echo "Removing images with ${mvn_docker_remove_cmd}"
    eval "${mvn_docker_remove_cmd}"

    docker images

    if docker images --format '{{ .Repository }}' |
      grep -m 1 -F -- "${docker_image_registry}/dockerfile-test" >/dev/null; then
      echo "Failed to remove all built images"
      return 1
    fi
  fi
}

main() {
  login_red_hat_docker_registry
  build_maven_project "${@}"
  run_tests "${@}"
}

main "${@}"
