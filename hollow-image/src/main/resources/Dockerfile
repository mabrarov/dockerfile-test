FROM @base-image.repository@:@base-image.version@

CMD ["/app/bin/run.sh"]

ADD rootfs.tar /

ENV ENABLE_ACCESS_LOG="true" \
    JBOSS_CONFIGURATION_FILE="${JBOSS_HOME}/standalone/configuration/@base-image.jboss.configuration.filename@" \
    APPLICATION_CONFIGURATION_FILE="/app/config/application.properties" \
    GREETING="Hello from j2cli"

LABEL name="@dockerfile.repository@" \
    version="@project.version@" \
    git-commit="@buildNumber@"