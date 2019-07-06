#!/bin/sh

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

"@base-image.cmd@" $@ &
jboss_pid=$!
exit_code=$?

# Forward stop signals to JBoss EAP process
trap "kill -TERM ${jboss_pid}" INT
trap "kill -QUIT ${jboss_pid}" QUIT
trap "kill -TERM ${jboss_pid}" TERM

# todo: monitor deployment status, use jboss_pid to monitor status of JBoss EAP process

wait ${jboss_pid}
trap - TERM QUIT INT
wait ${jboss_pid}
exit_code=$?

echo "Exiting with ${exit_code}"
exit ${exit_code}