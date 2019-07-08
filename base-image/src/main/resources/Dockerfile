FROM @base-image.repository@:@base-image.version@

USER root

RUN echo "Enabling rhel-7-server-rpms YUM repository, requires Docker host with Red Hat subscription" && \
    yum-config-manager --enable rhel-7-server-rpms > /dev/null && \
    echo "rhel-7-server-rpms YUM repository is confugured" && \
    echo "Installing OpenSSL" && \
    yum install -y openssl && \
    echo "OpenSSL installed" && \
    openssl version && \
    echo "Installing pip..." && \
    curl -sL @python-pip.package.url@ -o @python-pip.package.rpm.path@ && \
    rpm -i @python-pip.package.rpm.path@ && \
    rm -f @python-pip.package.rpm.path@ && \
    echo "pip installed" && \
    pip --version && \
    echo "Installing Jinja2 Command-Line Tool (j2cli)..." && \
    pip install --no-cache-dir j2cli[yaml]==@j2cli.version@ && \
    echo "j2cli installed" && \
    j2 --version

USER @base-image.user@

LABEL name="@dockerfile.repository@" \
    version="@project.version@" \
    git-commit="@buildNumber@"