# Firebird image for the Novaxel Application Server

Sorry for my bad English ... My teachers did what they could , but obviously not me ;-)

*Notice : the "NAS" accronyme stands for "Novaxel Application Server" in the context of this file...*

Based on :
- CentOS 6.6 (latest)

This image install :
- The Firebird server
- A Stunnel daemon (for DB syncchronisation)
- A rsync daemon (for DB syncchronisation)
- The binaries of NAS tools (nscript, encrypt)
- A series of scripts file for managing the regular NAS processes (DB sync, backu), etc)
- A series of configuration file to manage the various daemons in the context of this image

## Download :
```
docker pull novaxel/firebird 
```
*Notice : for now (no private docker repository available), you must clone/get my github repository : https://github.com/padouciel/docker.git*

## Use (at least) :
```
docker run --name fbserver -p 3050:3050 -v /var/lib/firebird:/srv/firebird -d novaxel/firebird:latest
```
Where :
```
--name : the name on the container
-p : expose the legacy Firebird port to the host (however not mandatory)
-v : bind of a host directory containing databases
-d for detaching the main process (see below)
```
Note that the Dockerfile use an ENTRYPOINT to start the fbguard process, so if you want running another command, you must use the "--entrypoint" option of "docker run", eg :
```
docker run --name fbclient --rm  --link fbserver:fbserver  --volumes-from fbserver -ti --entrypoint=/bin/bash padouciel/firebird:latest
```
I use it to start a container for viewing log or other things for a running "fbserver" container...

See the Dockerfile for more information...
