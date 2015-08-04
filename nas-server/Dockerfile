########################################################################################################################
# Serveur d'application Novaxel
# Installe :
# - moteur de script (depuis nas-toolbox)
# - binaires NAS (64 bits)
# - Fichiers WEB
########################################################################################################################


FROM padouciel/nas-toolbox:latest

MAINTAINER Patrick DUBUIS <pdubuis@visiativ.com>

# On active la timezone France
ENV TIMEZONE Europe/Paris

RUN echo ZONE="$TIMEZONE" > /etc/sysconfig/clock && \
    cp "/usr/share/zoneinfo/$TIMEZONE" /etc/localtime


# Install packages xkeybord (pas trouvé comment les traiter directement dans l'arborescence du NAS :-( )
# TODO : find a "no-deps" workaround for the xkeyb* packages (yum don't support no-deps option :-( )
# epel is for p7zip (TODO : see if "makecache" is mandatory ?)
RUN	yum install -y epel-release && \
	yum makecache && \
	yum install -y xkeyboard-config xorg-x11-xkb-utils tar p7zip

# Lien libc pour mono
RUN	cd /lib64 && \
	ln -s libc.so.6 libc.so

COPY novaappserver.tar.gz /

# Dernier package WEB from Kma
# TODO : ask kma to use a "no-version like" filename ???
ADD http://www.novaxel2.com/jmb/livraisons/www/www_2.8.4.21_NAS2.6.9.0_APP1.46.6_BASE_V40.7z /

# Préparation du répertoire de destination
RUN	mkdir -p /opt/novaxel/novaappserver && \
	cd / && \
	tar xzvf /novaappserver.tar.gz && \
	rm -f /novaappserver.tar.gz && \
	mkdir -p /opt/novaxel/htdocs && \
	cd /opt/novaxel/htdocs && \
	7za e -y /www_2.8.4.21_NAS2.6.9.0_APP1.46.6_BASE_V40.7z && \
	rm -f /www_2.8.4.21_NAS2.6.9.0_APP1.46.6_BASE_V40.7z
	
# Création utilisateur NAS
RUN useradd -r -c "NAS system User" -d /opt/novaxel/novaappserver -M -s /bin/bash novaappserver
	
# Port HTTP NAS par défaut
EXPOSE 8080/tcp

# TODO Port HTTPS

# TODO : DB Domain & event à activer si non présente

# Volumes LOG
VOLUME ["/var/log/novaappserver"]
# Volume config (certs, etc...)
VOLUME ["/et/opt/novaappserver"]

# Droits d'écriture sur le répertoire temp pour l'utilisateur système NAS
RUN	mkdir -p /opt/novaxel/htdocs/tmp && \
	chown -R novaappserver:novaappserver /opt/novaxel/htdocs/tmp

COPY conf/ /etc/opt/novaappserver/

# TODO
# ENTRYPOINT ["/usr/sbin/fbguard", "-pidfile /var/run/firebird/default.pid", "-daemon", "-forever"]
ENTRYPOINT ["/bin/bash"]

