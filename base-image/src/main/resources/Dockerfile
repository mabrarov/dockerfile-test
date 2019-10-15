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

FROM registry.redhat.io/jboss-eap-6/eap64-openshift:1.9-23.1561731010

USER root

RUN echo "Installing pip..." && \
    rpm -i @python-pip.package.url@ && \
    echo "pip installed" && \
    pip --version && \
    echo "Installing Jinja2 Command-Line Tool (j2cli)..." && \
    pip install --no-cache-dir --disable-pip-version-check j2cli[yaml]==@j2cli.version@ && \
    echo "j2cli installed" && \
    j2 --version

USER 185

LABEL name="@docker.repository@" \
    version="@project.version@" \
    release="@project.version@" \
    build-date="@buildTimestamp@" \
    vcs-type="git" \
    vcs-ref="@buildNumber@"