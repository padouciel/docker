FROM centos:6


MAINTAINER Patrick DUBUIS <pdubuis@visiativ.com>

# On active la timezone France
ENV TIMEZONE Europe/Paris

RUN echo ZONE="$TIMEZONE" > /etc/sysconfig/clock && \
    cp "/usr/share/zoneinfo/$TIMEZONE" /etc/localtime

RUN yum install -y tar glibc.i686

COPY nas-toolbox.tar.gz /

# Préparation du répertoire de destination
RUN	mkdir -p /opt && \
	cd / && \
	tar xzvf /nas-toolbox.tar.gz && \
	rm -f /nas-toolbox.tar.gz && \
	chown -R root:root /opt && \
	echo "export LD_LIBRARY_PATH=/opt/novaxel/novatools/libs" >> $HOME/.bashrc && \
	echo "PATH=${PATH}:/opt/novaxel/novatools:/opt/firebird/bin" >> $HOME/.bashrc
	
# TODO
ENTRYPOINT ["/bin/bash"]
