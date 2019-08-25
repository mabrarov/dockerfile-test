#!/bin/sh

#
# Copyright (c) 2019 Marat Abrarov (abrarov@gmail.com)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

calc() {
  awk "BEGIN{print $*}"
}

int() {
  awk "BEGIN{printf \"%.0f\", $*}"
}

split_by_colon() {
  array="${1}"
  if [ "${array}" = "" ]; then
    return
  fi
  number_of_params="${#}"
  from_index_defined=0
  till_index_defined=0
  if [ "${number_of_params}" -ge 2 ]; then
    from_index="${2}"
    from_index_defined=1
    if [ "${number_of_params}" -ge 3 ]; then
      till_index="${3}"
      till_index_defined=1
    fi
  fi
  i=0
  while true; do
    s="${array%%\:*}"
    if [ "${from_index_defined}" -eq 0 ]; then
      echo "${s}"
    else
      if [ "${till_index_defined}" -ne 0 ]; then
        if [ "${i}" -gt "${till_index}" ]; then
          break
        fi
      fi
      if [ "${i}" -ge "${from_index}" ]; then
        echo "${s}"
      fi
    fi
    if [ "${array}" = "${s}" ]; then
      break
    fi
    array="${array#*\:}"
    i=$((i+1))
  done
}

rm_all() {
  array="${1}"
  for f in $(split_by_colon "${array}"); do
    rm -f "${f}"
  done
}

get_nth_item() {
  index="${1}"
  array="${2}"
  split_by_colon "${array}" "${index}" "${index}"
}

add_prefix_and_postfix() {
  prefix="${1}"
  postfix="${2}"
  array="${3}"
  first=1
  result=""
  for s in $(split_by_colon "${array}"); do
    if [ "${first}" -eq 0 ]; then
      result="${result}:"
    fi
    result="${result}${prefix}${s}${postfix}"
    first=0
  done
  echo "${result}"
}

pid_alive() {
  pid="${1}"
  if ps -p "${pid}" > /dev/null 2>&1; then
    echo 1
  else
    echo 0
  fi
}

concat_all() {
  delimiter="${1}"
  array="${2}"
  first=1
  result=""
  for s in $(split_by_colon "${array}"); do
    if [ "${first}" -eq 0 ]; then
      result="${result}${delimiter}"
    fi
    result="${result}${s}"
    first=0
  done
  echo "${result}"
}

exist_any() {
  array="${1}"
  for s in $(split_by_colon "${array}"); do
    if [ -f "${s}" ] || [ -d "${s}" ]; then
      echo "1:${s}"
      return
    fi
  done
  echo 0
}

exist_all() {
  array="${1}"
  for s in $(split_by_colon "${array}"); do
    if ! [ -f "${s}" ] && ! [ -d "${s}" ]; then
      echo 0
      return
    fi
  done
  echo 1
}

main() {
  exit_code=0

  echo "Preparing application configuration at ${APPLICATION_CONFIGURATION_FILE}"
  j2 --import-env="" --filters "/app/bin/filters.py" \
    -o "${APPLICATION_CONFIGURATION_FILE}" \
    "/app/template/application.properties.j2"
  exit_code=$?
  if [ "${exit_code}" -ne 0 ]; then
    echo "Failed to prepare application configuration at ${APPLICATION_CONFIGURATION_FILE}"
    echo "Exiting with ${exit_code}"
    exit "${exit_code}"
  fi

  echo "Preparing JBoss EAP configuration at ${JBOSS_CONFIGURATION_FILE}"
  j2 --import-env="" --filters "/app/bin/filters.py" \
    -o "${JBOSS_CONFIGURATION_FILE}" \
    "/app/template/standalone.xml.j2"
  exit_code=$?
  if [ "${exit_code}" -ne 0 ]; then
    echo "Failed to prepare JBoss EAP configuration at ${JBOSS_CONFIGURATION_FILE}"
    echo "Exiting with ${exit_code}"
    exit "${exit_code}"
  fi

  fail_markers="$(add_prefix_and_postfix "${JBOSS_DEPLOYMENTS_DIR}/" \
    ".failed" "${DEPLOYMENTS}")"
  success_markers="$(add_prefix_and_postfix "${JBOSS_DEPLOYMENTS_DIR}/" \
    ".deployed" "${DEPLOYMENTS}")"
  deploy_check_attempts="$(int "$(calc \
    "${DEPLOY_TIMEOUT}/${DEPLOY_CHECK_INTERVAL}")")"

  rm_all "${fail_markers}"
  rm_all "${success_markers}"

  echo "Waiting during ${DEPLOY_TIMEOUT} sec for one of $(concat_all ", " \
    "${fail_markers}") or all of $(concat_all ", " "${success_markers}")"

  /opt/eap/bin/openshift-launch.sh "$@" &
  jboss_pid=$!
  exit_code=$?

  # shellcheck disable=SC2064
  trap "kill -HUP \"${jboss_pid}\"" HUP
  # shellcheck disable=SC2064
  trap "kill -TERM \"${jboss_pid}\"" INT
  # shellcheck disable=SC2064
  trap "kill -QUIT \"${jboss_pid}\"" QUIT
  # shellcheck disable=SC2064
  trap "kill -PIPE \"${jboss_pid}\"" PIPE
  # shellcheck disable=SC2064
  trap "kill -TERM \"${jboss_pid}\"" TERM

  attempts=0
  alive=1
  deployed=0
  failed=0
  timeout=0
  failed_marker=""
  while true; do
    if [ "$(pid_alive "${jboss_pid}")" -eq 0 ]; then
      alive=0
      break
    fi
    exist_any_result="$(exist_any "${fail_markers}")"
    if [ "$(get_nth_item 0 "${exist_any_result}")" -ne 0 ]; then
      failed=1
      failed_marker="$(get_nth_item 1 "${exist_any_result}")"
      break
    fi
    if [ "$(exist_all "${success_markers}")" -ne 0 ]; then
      deployed=1
      break
    fi
    attempts=$((attempts+1))
    if [ "${attempts}" -ge "${deploy_check_attempts}" ]; then
      timeout=1
      break
    fi
    sleep "${DEPLOY_CHECK_INTERVAL}"
  done

  if [ "${deployed}" -ne 0 ]; then
    echo "Detected completion of deployment with $(concat_all ", " \
      "${success_markers}")"
  else
    if [ "${failed}" -ne 0 ]; then
      echo "Detected failed deployment with ${failed_marker}, stopping JBoss EAP"
      exit_code=1
    fi
    if [ "${timeout}" -ne 0 ]; then
      echo "Deployment timeout ${DEPLOY_TIMEOUT} sec happened, stopping JBoss EAP"
      exit_code=1
    fi
    if [ "${alive}" -ne 0 ]; then
      kill -TERM "${jboss_pid}"
      alive=0
    fi
  fi

  if [ "${alive}" -ne 0 ]; then
    wait "${jboss_pid}"
  fi

  trap - HUP INT QUIT PIPE TERM
  wait "${jboss_pid}"
  jboss_exit_code=$?
  if [ "${exit_code}" -eq 0 ]; then
    exit_code="${jboss_exit_code}"
  fi

  echo "Exiting with ${exit_code}"
  return "${exit_code}"
}

main "$@"
