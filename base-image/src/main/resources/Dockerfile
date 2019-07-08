FROM @base-image.repository@:@base-image.version@

USER root

RUN echo "Enabling rhel-7-server-rpms YUM repository, requires Docker host with Red Hat subscription" && \
    yum-config-manager --enable rhel-7-server-rpms > /dev/null && \
    echo "rhel-7-server-rpms YUM repository is confugured" && \
    echo "Installing OpenSSL" && \
    yum install -y openssl && \
    echo "OpenSSL installed" && \
    openssl version && \
    echo "Enabling EPEL YUM repository" && \
    rpm -ivh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm && \
    echo "EPEL YUM repository is confugured" && \
    echo "Installing pip..." && \
    yum install -y python2-pip && \
    echo "pip installed" && \
    pip --version && \
    echo "Installing Jinja2 Command-Line Tool (j2cli)..." && \
    yum install -y python-jinja2 && \
    yum install -y python2-pyyaml && \
    pip install --no-cache-dir j2cli[yaml]==@j2cli.version@ && \
    echo "j2cli installed" && \
    j2 --version && \
    echo "Cleaning YUM cache" && \
    yum clean all

USER @base-image.user@

LABEL name="@dockerfile.repository@" \
    version="@project.version@" \
    git-commit="@buildNumber@"