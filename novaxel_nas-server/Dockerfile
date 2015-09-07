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

# Path to DB Domain
ENV 	NAS_DB_PATH_DOMAIN="${NAS_DB_PATH:-/srv/nas}/domain" \
	NAS_DOCKER_NAS_VERSION=2


# Install packages xkeybord for embedded Xvfb dependencies
# TODO : find a "no-deps" workaround for the xkeyb* packages (yum don't support no-deps option :-( )
RUN	yum install -y xkeyboard-config xorg-x11-xkb-utils

# link libc for embedded mono
RUN	cd /lib64 && \
	ln -s libc.so.6 libc.so

# we "isolate" this step (layer) for test/debug step (not downloading anymore this packages if this layer is Ok)
RUN	mkdir -p /opt/novaxel && \
	cd /tmp && \
	curl -O ${NAS_PACK_URL}/nas-server/nas-docker.7z && \
	curl -O http://www.novaxel2.com/jmb/livraisons/www/www_2.8.4.21_NAS2.6.9.0_APP1.46.6_BASE_V40.7z && \
	curl -O ${NAS_PACK_URL}/nas-server/sql-domain.7z && \
	curl -O ${NAS_PACK_URL}/nas-server/bibdemo-min.7z

RUN	cd /opt/novaxel && \
	7za x -y /tmp/nas-docker.7z && \
	rm -f /tmp/nas-docker.7z && \
	mkdir -p /opt/novaxel/htdocs && \
	cd /opt/novaxel/htdocs && \
	7za x -y /tmp/www_2.8.4.21_NAS2.6.9.0_APP1.46.6_BASE_V40.7z && \
	chmod -R a+rX /opt/novaxel/htdocs && \
	rm -f /tmp/www_2.8.4.21_NAS2.6.9.0_APP1.46.6_BASE_V40.7z && \
	useradd -r -c "NAS system User" -d /opt/novaxel/novaappserver -M -s /bin/bash novaappserver && \
	mkdir -p /opt/novaxel/tmp && \
	chown -R novaappserver:novaappserver /opt/novaxel/tmp
	

# Default NAS Ports
EXPOSE 80/tcp
EXPOSE 443/tcp

# The conf of the NAS (note : this volume is already declared in the base image)
COPY conf/* /opt/novaxel/conf/

# The NAS scripts
COPY 	scripts_nas/* /opt/novaxel/scripts_nas/
# This links are mandatory 
RUN	cd /opt/novaxel/scripts_nas/ && \
	ln -sf ../scripts/func_nas.xnov ../scripts/local_inc.xnov ./

# TODO
COPY entrypoint.sh /
ENTRYPOINT ["/bin/bash","-cl", "/entrypoint.sh"]

