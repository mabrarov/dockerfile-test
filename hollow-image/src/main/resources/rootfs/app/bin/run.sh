#!/bin/sh

function calc() {
    awk "BEGIN{print $*}"
}

function int() {
    awk "BEGIN{printf \"%.0f\", $*}"
}

function split_by_colon {
    array="${1}"
    echo -e "${array//:/\n}"
}

function rm_all {
    array="${1}"
    for f in $(split_by_colon "${array}"); do
        rm -f ${f}
    done
}

function get_nth_item {
    index=${1}
    array="${2}"
    i=0
    for s in $(split_by_colon "${array}"); do
        if [[ ${i} -lt ${index} ]]; then
            i=$((i + 1))
            continue
        fi
        if [[ ${i} -gt ${index} ]]; then
            return 1
        fi
        echo "${s}"
        return 0
    done
    return 1
}

function add_prefix_and_postfix {
    prefix="${1}"
    postfix="${2}"
    array="${3}"
    first=1
    result=""
    for s in $(split_by_colon "${array}"); do
        if [[ ${first} -eq 0 ]]; then
            result="${result}:"
        fi;
        result="${result}${prefix}${s}${postfix}"
        first=0
    done
    echo "${result}"
}

function pid_alive {
    pid="${1}"
    if ps -p "${pid}" &> /dev/null; then
        echo 1
    else
        echo 0
    fi
}

function concat_all {
    delimiter="${1}"
    array="${2}"
    first=1
    result=""
    for s in $(split_by_colon "${array}"); do
        if [[ ${first} -eq 0 ]]; then
            result="${result}${delimiter}"
        fi;
        result="${result}${s}"
        first=0
    done
    echo "${result}"
}

function exist_any {
    array="${1}"
    for s in $(split_by_colon "${array}"); do
        if [[ -f "${s}" ]] || [[ -d "${s}" ]]; then
            echo "1:${s}"
            return
        fi
    done
    echo 0
}

function exist_all {
    array="${1}"
    for s in $(split_by_colon "${array}"); do
        if ! [[ -f "${s}" ]] && ! [[ -d "${s}" ]]; then
            echo 0
            return
        fi
    done
    echo 1
}

exit_code=0

echo "Preparing application configuration at ${APPLICATION_CONFIGURATION_FILE}"
j2 --import-env="" --filters "/app/bin/filters.py" -o "${APPLICATION_CONFIGURATION_FILE}" "/app/template/application.properties.j2"
exit_code=$?
if [[ ${exit_code} -ne 0 ]]; then
    echo "Failed to prepare application configuration at ${APPLICATION_CONFIGURATION_FILE}"
    echo "Exiting with ${exit_code}"
    exit ${exit_code}
fi

echo "Preparing JBoss EAP configuration at ${JBOSS_CONFIGURATION_FILE}"
j2 --import-env="" --filters "/app/bin/filters.py" -o "${JBOSS_CONFIGURATION_FILE}" "/app/template/standalone.xml.j2"
exit_code=$?
if [[ ${exit_code} -ne 0 ]]; then
    echo "Failed to prepare JBoss EAP configuration at ${JBOSS_CONFIGURATION_FILE}"
    echo "Exiting with ${exit_code}"
    exit ${exit_code}
fi

fail_markers="$(add_prefix_and_postfix "${JBOSS_DEPLOYMENTS_DIR}/" ".failed" "${DEPLOYMENTS}")"
success_markers="$(add_prefix_and_postfix "${JBOSS_DEPLOYMENTS_DIR}/" ".deployed" "${DEPLOYMENTS}")"
deploy_check_attempts="$(int "$(calc "${DEPLOY_TIMEOUT}/${DEPLOY_CHECK_INTERVAL}")")"

rm_all "${fail_markers}"
rm_all "${success_markers}"

echo "Waiting during ${DEPLOY_TIMEOUT} sec for one of $(concat_all ", " "${fail_markers}") or all of $(concat_all ", " "${success_markers}")"

/opt/eap/bin/openshift-launch.sh $@ &
jboss_pid=$!
exit_code=$?

trap "kill -TERM ${jboss_pid}" INT
trap "kill -TERM ${jboss_pid}" QUIT
trap "kill -TERM ${jboss_pid}" TERM

completed=0
attempts=0
alive=1
deployed=0
failed=0
timeout=0
failed_marker=""
while [[ ${completed} -eq 0 ]] ; do
    if [[ $(pid_alive "${jboss_pid}") -eq 0 ]]; then
        completed=1
        alive=0
        continue
    fi
    exist_any_result="$(exist_any "${fail_markers}")"
    if [[ $(get_nth_item 0 "${exist_any_result}") -ne 0 ]]; then
        completed=1
        failed=1
        failed_marker=$(get_nth_item 1 "${exist_any_result}")
        continue
    fi
    if [[ $(exist_all "${success_markers}") -ne 0 ]]; then
        completed=1
        deployed=1
        continue
    fi
    attempts=$((attempts+1))
    if [[ ${attempts} -ge ${deploy_check_attempts} ]]; then
        completed=1
        timeout=1
        continue
    fi
    sleep ${DEPLOY_CHECK_INTERVAL}
done

if [[ ${deployed} -ne 0 ]]; then
    echo "Detected completion of deployment with $(concat_all ", " "${success_markers}")"
else
    if [[ ${failed} -ne 0 ]]; then
        echo "Detected failed deployment with ${failed_marker}, stopping JBoss EAP"
        exit_code=1
    fi
    if [[ ${timeout} -ne 0 ]]; then
        echo "Deployment timeout ${DEPLOY_TIMEOUT} sec happened, stopping JBoss EAP"
        exit_code=1
    fi
    if [[ ${alive} -ne 0 ]]; then
        kill -TERM ${jboss_pid}
        alive=0
    fi
fi

if [[ ${alive} -ne 0 ]]; then
    wait ${jboss_pid}
fi

trap - TERM QUIT INT
wait ${jboss_pid}
jboss_exit_code=$?
if [[ ${exit_code} -eq 0 ]]; then
    exit_code=${jboss_exit_code}
fi

echo "Exiting with ${exit_code}"
exit ${exit_code}