FROM centos:6


MAINTAINER Patrick DUBUIS <pdubuis@visiativ.com>

# On active la timezone France
ENV TIMEZONE Europe/Paris

RUN echo ZONE="$TIMEZONE" > /etc/sysconfig/clock && \
    cp "/usr/share/zoneinfo/$TIMEZONE" /etc/localtime

RUN yum install -y tar glibc.i686

COPY novatools.tar.gz /

# Préparation du répertoire de destination
RUN	mkdir -p /opt/novaxel/novatools && \
	cd / && \
	tar xzvf /novatools.tar.gz && \
	rm -f /novatools.tar.gz && \
	chown -R root:root /opt/novaxel && \
	echo "export LD_LIBRARY_PATH=/opt/novaxel/novatools/libs" >> $HOME/.bashrc && \
	echo "export FIREBIRD=/opt/novaxel/novatools/libs" >> $HOME/.bashrc && \
	echo "PATH=${PATH}:/opt/novaxel/novatools:/opt/novaxel/novatools/bin" >> $HOME/.bashrc
	
# TODO
# ENTRYPOINT ["/usr/sbin/fbguard", "-pidfile /var/run/firebird/default.pid", "-daemon", "-forever"]
ENTRYPOINT ["/bin/bash"]
