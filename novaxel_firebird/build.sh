#!/bin/bash
docker build -t padouciel/firebird:latest . && docker tag -f padouciel/firebird:latest  padouciel/firebird:1
[[ "${?}" -eq 0 && -n "${1}" ]] && docker run -it --rm padouciel/firebird
