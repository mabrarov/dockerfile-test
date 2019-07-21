FROM abrarov/dockerfile-test-base:@project.version@

CMD ["/app/bin/run.sh"]

ADD rootfs.tar /

ENV ENABLE_ACCESS_LOG="true" \
    JBOSS_CONFIGURATION_FILE="${JBOSS_HOME}/standalone/configuration/standalone-openshift.xml" \
    JBOSS_DEPLOYMENTS_DIR="/deployments" \
    APPLICATION_CONFIGURATION_FILE="/app/config/application.properties" \
    DEPLOYMENTS="activemq-rar.rar" \
    DEPLOY_TIMEOUT=120 \
    DEPLOY_CHECK_INTERVAL=0.5 \
    GREETING="Hello from j2cli"

LABEL name="@dockerfile.repository@" \
    version="@project.version@" \
    git-commit="@buildNumber@"