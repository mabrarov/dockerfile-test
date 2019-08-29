#!/bin/sh

set -e

echo "${DOCKERHUB_PASSWORD}" | docker login -u "${DOCKERHUB_USER}" --password-stdin

mvn -f base-image/pom.xml docker:push "-Ddocker.push.retries=${DOCKER_PUSH_RETRIES}"
mvn -f hollow-image/pom.xml docker:push "-Ddocker.push.retries=${DOCKER_PUSH_RETRIES}"
mvn -f app-image/pom.xml docker:push "-Ddocker.push.retries=${DOCKER_PUSH_RETRIES}"
