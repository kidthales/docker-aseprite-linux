#!/bin/sh

set -e

if [ "${1#-}" != "$1" ]; then
	set -- aseprite "$@"
fi

exec "$@"
