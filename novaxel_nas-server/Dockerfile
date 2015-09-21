########################################################################################################################
# Serveur d'application Novaxel
# Installe :
# - binaires NAS (64 bits)
# - Fichiers WEB
########################################################################################################################


#FROM padouciel/nas-toolbox:latest
FROM novaxel/firebird:latest

MAINTAINER Patrick DUBUIS <pdubuis@visiativ.com>

# Path to DB Domain
ENV 	NAS_DB_PATH_DOMAIN="${NAS_DB_PATH:-/srv/databases}/domain" \
	NAS_DOCKER_NAS_VERSION=2


# Install packages xkeybord for embedded Xvfb dependencies
# TODO : find a "no-deps" workaround for the xkeyb* packages (yum don't support no-deps option :-( )
RUN	DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y xvfb

# link libc for embedded mono
RUN	cd /lib64 && \
	ln -s libc.so.6 libc.so

# we "isolate" this step (layer) for test/debug step (not downloading anymore this packages if this layer is Ok)
RUN	mkdir -p /opt/novaxel && \
	cd /tmp && \
	curl -O ${NAS_PACK_URL}/nas-server/nas-docker.7z && \
	curl -O ${NAS_PACK_URL}/nas-server/client_WEB.7z && \
	curl -O ${NAS_PACK_URL}/nas-server/conf.7z && \
	curl -O ${NAS_PACK_URL}/nas-server/scripts_nas.7z && \
	curl -O ${NAS_PACK_URL}/nas-server/sql-domain.7z && \
	curl -O ${NAS_PACK_URL}/nas-server/sqlged.7z && \
	curl -O ${NAS_PACK_URL}/nas-server/bibdemo.7z && \
	curl -O ${NAS_PACK_URL}/nas-server/bibdemo-5c.7z

RUN	mkdir -p /opt/novaxel && \
	cd /opt/novaxel && \
		7za x -y /tmp/nas-docker.7z && \
		chmod a+rX /opt/novaxel/novaappserver && \
		chmod -Rf +x /opt/novaxel/novaappserver/*.sh /opt/novaxel/novaappserver/novaappserver /opt/novaxel/novaappserver/rtf2html /opt/novaxel/novaappserver/wkhtmltoimage-amd64 /opt/novaxel/novaappserver/bin/* || true && \
		rm -f /tmp/nas-docker.7z && \
	mkdir -p /opt/novaxel/htdocs && \
        cd /opt/novaxel/htdocs && \
                7za x -y /tmp/client_WEB.7z && \
                chmod -R a+rX /opt/novaxel/htdocs && \
		rm -f /tmp/client_WEB.7z

RUN	mkdir -p /opt/novaxel/conf/ && \
	cd /opt/novaxel/conf && \
		ls -la && \
		7za e -y /tmp/conf.7z && \
		rm -f /tmp/conf.7z && \
		ls -la && \
	mkdir -p /opt/novaxel/scripts_nas && \
	cd /opt/novaxel/scripts_nas && \
		7za x -y /tmp/scripts_nas.7z && \
		rm -f /tmp/scripts_nas.7z && \
	cd /opt/novaxel/novaappserver && \
		7za x -y /tmp/sqlged.7z && \
		rm -f /tmp/sqlged.7z && \
	useradd -r -c "NAS system User" -d /opt/novaxel/novaappserver -M -s /bin/bash novaappserver && \
	mkdir -p /opt/novaxel/tmp && \
		chown -R novaappserver:novaappserver /opt/novaxel/tmp && \
	cd /opt/novaxel/scripts_nas/ && \
		ln -sf ../scripts/func_nas.xnov ../scripts/local_inc.xnov ./

# Default NAS Ports
EXPOSE 80/tcp
EXPOSE 443/tcp

# TODO
COPY entrypoint.sh /
ENTRYPOINT ["/bin/bash","-cl", "/entrypoint.sh"]

