FROM abrarov/dockerfile-test/hollow-image:@project.version@

ADD rootfs.tar /

ENV DEPLOYMENTS="${DEPLOYMENTS}:ear.ear"

LABEL name="@dockerfile.repository@" \
    version="@project.version@" \
    git-commit="@buildNumber@"