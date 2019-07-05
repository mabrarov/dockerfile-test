#!/bin/sh

set -e

j2 --import-env="" "/app/templates/greeting.txt.j2"

exec "@base-image.cmd@" $@