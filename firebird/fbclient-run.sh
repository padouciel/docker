#!/bin/sh
docker run --name fbclient --rm  --link fbserver:fbserver  --volumes-from fbserver -ti --entrypoint=/bin/bash novaappserver/firebird:3
