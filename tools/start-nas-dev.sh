#!/bin/bash
docker run -d --name nas-dev -p 80:80 -p 443:443 -p 3050:3050 -p 60443:60443 novaxel/nas-server
