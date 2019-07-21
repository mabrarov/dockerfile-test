FROM @base-image.repository@:@base-image.version@

ADD rootfs.tar /

ENV DEPLOYMENTS="${DEPLOYMENTS}:ear.ear"

LABEL name="@dockerfile.repository@" \
    version="@project.version@" \
    git-commit="@buildNumber@"