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
	rm -f /novatools.gz
	
# TODO
# ENTRYPOINT ["/usr/sbin/fbguard", "-pidfile /var/run/firebird/default.pid", "-daemon", "-forever"]
ENTRYPOINT ["/bin/bash"]
