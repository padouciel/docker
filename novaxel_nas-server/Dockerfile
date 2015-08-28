########################################################################################################################
# Serveur d'application Novaxel
# Installe :
# - moteur de script (depuis nas-toolbox)
# - binaires NAS (64 bits)
# - Fichiers WEB
########################################################################################################################


#FROM padouciel/nas-toolbox:latest
FROM novaxel/firebird:latest

MAINTAINER Patrick DUBUIS <pdubuis@visiativ.com>

# Install packages xkeybord (pas trouvé comment les traiter directement dans l'arborescence du NAS :-( )
# TODO : find a "no-deps" workaround for the xkeyb* packages (yum don't support no-deps option :-( )
# epel is for p7zip (TODO : see if "makecache" is mandatory ?)
RUN	yum install -y epel-release && \
	yum install -y xkeyboard-config xorg-x11-xkb-utils

# Lien libc pour mono
RUN	cd /lib64 && \
	ln -s libc.so.6 libc.so

ENV DOCKER_NAS_VERSION=1

# we "isolate" this step (layer)...
RUN	mkdir -p /opt/novaxel && \
	cd /tmp && \
	curl -O http://www.novaxel2.com/depotDocker/nas-server/nas-docker.7z && \
	curl -O http://www.novaxel2.com/jmb/livraisons/www/www_2.8.4.21_NAS2.6.9.0_APP1.46.6_BASE_V40.7z && \
	curl -O http://www.novaxel2.com/depotDocker/nas-server/sql-domain.7z && \
	curl -O http://www.novaxel2.com/depotDocker/nas-server/bibdemo-min.7z

RUN	cd /opt/novaxel && \
	7za x -y /tmp/nas-docker.7z && \
	rm -f /tmp/nas-docker7z && \
	mkdir -p /opt/novaxel/htdocs && \
	cd /opt/novaxel/htdocs && \
	7za x -y /tmp/www_2.8.4.21_NAS2.6.9.0_APP1.46.6_BASE_V40.7z && \
	chmod -R a+rX /opt/novaxel/htdocs && \
	rm -f /tmp/www_2.8.4.21_NAS2.6.9.0_APP1.46.6_BASE_V40.7z
	
# Création utilisateur NAS
RUN useradd -r -c "NAS system User" -d /opt/novaxel/novaappserver -M -s /bin/bash novaappserver

# Droits d'écriture sur le répertoire temp pour l'utilisateur système NAS
RUN	mkdir -p /opt/novaxel/htdocs/tmp && \
	chown -R novaappserver:novaappserver /opt/novaxel/htdocs/tmp
	
# Port HTTP NAS par défaut
EXPOSE 80/tcp
EXPOSE 443/tcp

# Volumes LOG
VOLUME ["/var/log/novaappserver"]
# Volume config (certs, etc...)
VOLUME ["/etc/opt/novaappserver"]

COPY conf/* /opt/novaxel/

# Path DB Domain
ENV 	NAS_DB_PATH_DOMAIN="${NAS_DB_PATH}/domain" 

# TODO
COPY entrypoint.sh /
ENTRYPOINT ["/bin/bash","-cl", "/entrypoint.sh"]

