#!/bin/bash
docker build -t padouciel/nas-toolbox:latest . && docker tag -f padouciel/nas-toolbox:latest  padouciel/nas-toolbox:1
[[ "${?}" -eq 0 && -n "${1}" ]] && docker run -it --rm padouciel/nas-toolbox
