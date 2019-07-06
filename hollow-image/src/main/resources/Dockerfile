FROM @base-image.repository@:@base-image.version@

LABEL name="@image.repository@" \
    version="@project.version@" \
    git-commit="@buildNumber@"

ADD rootfs.tar /

ENV JBOSS_CONFIGURATION_FILE="${JBOSS_HOME}/standalone/configuration/@base-image.jboss.configuration.filename@" \
    APPLICATION_CONFIGURATION_FILE="/app/config/application.properties" \
    GREETING="Hello from j2cli"

CMD ["/app/bin/run.sh"]