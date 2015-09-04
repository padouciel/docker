docker run --name nas-server \
	-v /home/patrick/Technique/docker-nas-server-cont/dbs:/srv/nas \
	-v /home/patrick/Technique/docker-nas-server-cont/firebird_logs:/var/log/firebird \
	-v /home/patrick/Technique/docker-nas-server-cont/novaxel_logs:/var/log/novaxel \
	-p  61080:80 -p 61443:443 -p 63050:3050 -p 60443:60443 \
	-d \
	novaxel/nas-server "${@}"

#	-ti --entrypoint /bin/bash \
