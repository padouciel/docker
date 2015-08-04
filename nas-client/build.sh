#!/bin/sh
docker build -t padouciel/nas-client:1 -t padouciel/nas-client:latest . && docker tag -f padouciel/nas-client:latest  padouciel/nas-client:1
[[ "${?}" -eq 0 && -n "${1}" ]] && docker run -it --rm padouciel/nas-client
