#
# Copyright (c) 2019 Marat Abrarov (abrarov@gmail.com)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

FROM registry.redhat.io/jboss-eap-6/eap64-openshift:1.9-23

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

USER 185

LABEL name="@dockerfile.repository@" \
    version="@project.version@" \
    git-commit="@buildNumber@"