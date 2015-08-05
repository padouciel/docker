#!/bin/sh
docker run --name fbserver -p 3050:3050 -v /var/lib/firebird:/srv/firebird -d padouciel/firebird
