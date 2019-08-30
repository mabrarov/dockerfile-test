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

FROM abrarov/dockerfile-test-base:@project.version@

CMD ["/app/bin/run.sh"]

COPY rootfs /

ENV ENABLE_ACCESS_LOG="true" \
    JBOSS_CONFIGURATION_FILE="${JBOSS_HOME}/standalone/configuration/standalone-openshift.xml" \
    JBOSS_DEPLOYMENTS_DIR="/deployments" \
    APPLICATION_CONFIGURATION_FILE="/app/config/application.properties" \
    DEPLOYMENTS="activemq-rar.rar" \
    DEPLOY_TIMEOUT=120 \
    DEPLOY_CHECK_INTERVAL=0.5 \
    GREETING="Hello from j2cli"

LABEL name="@docker.repository@" \
    version="@project.version@" \
    git-commit="@buildNumber@"