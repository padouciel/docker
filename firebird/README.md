# Firebird image for for Novaappserver

Sorry for my poor (very) poor english, blame only me for that, my teatchers have make what they can do, but not me, I suppose ;-)

Based on :
- CentOS 6.6 (latest)
- Firebird 2.5.4

## Download :
```
docker pull padouciel/firebird 
```
Notice : *the repository is private for now*

## Use (for example) :
```
docker run --name fbserver -p 3050:3050 -v /var/lib/firebird:/srv/firebird -d padouciel/firebird:latest
```
Where :
```
--name : the name on the container
-p : expose the legacy Firebird port to the host (not mandatory)
-v : bind of a host directory containing databases (not a volume)
-d for detaching the fbguard process
```
Note that the Dockerfile use an ENTRYPOINT to start the fbguard process, so if you want running another command, you must use the "--entrypoint" option of "docker run", eg :
```
docker run --name fbclient --rm  --link fbserver:fbserver  --volumes-from fbserver -ti --entrypoint=/bin/bash padouciel/firebird:latest
```
I use it to start a container for viewing log or other things for a running "fbserver" container...

