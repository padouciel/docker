#!/bin/sh
docker build -t padouciel/nas-server:latest . && docker tag -f padouciel/nas-server:latest  padouciel/nas-server:1
