FROM @base-image.repository@:@base-image.version@

LABEL name="@image.repository@" \
    version="@project.version@" \
    git-commit="@buildNumber@"

USER root

RUN echo "Installing pip..." && \
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