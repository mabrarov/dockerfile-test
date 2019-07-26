#!/bin/sh

set -e

echo "${DOCKERHUB_PASSWORD}" | docker login -u "${DOCKERHUB_USER}" --password-stdin

mvn -f base-image/pom.xml dockerfile:push
mvn -f hollow-image/pom.xml dockerfile:push
mvn -f app-image/pom.xml dockerfile:push
