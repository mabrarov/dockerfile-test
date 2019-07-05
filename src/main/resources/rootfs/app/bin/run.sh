#!/bin/sh

exit_code=0

j2 --import-env="" "/app/templates/standalone-openshift.xml.j2" -o ${JBOSS_HOME}/standalone/configuration/@base-image.jboss.configuration.filename@
exit_code=$?

if [[ ${exit_code} -ne 0 ]]; then
    echo "Failed to fill JBoss EAP configuration template"
else
    echo "Filled JBoss EAP configuration template, starting JBoss EAP..."

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

    echo "JBoss EAP stopped with ${exit_code}"
fi

echo "Exiting with ${exit_code}"
exit ${exit_code}