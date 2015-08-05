#!/bin/sh
docker rm fbserver > /dev/null 2>&1

# le path de montage DOIT correspondre à la variable FB_DB_PATH init dans le Dockerfile...
docker run --name fbserver -p 3050:3050 -v /var/lib/firebird:/srv/firebird -d padouciel/firebird
