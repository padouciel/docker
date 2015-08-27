#!/bin/sh
docker run --name fbclient --rm  --link firebird:fbserver --env FB_SERVER_HOST=fbserver --volumes-from firebird -ti --entrypoint=/bin/bash -u root:root novaxel/firebird
