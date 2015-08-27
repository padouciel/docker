# This image is made for holding Customer's datas (the FDB from our customers)
# So, it needs the NAS toolboxes and stunnel/rsync for for shynchronizing the FDB files

FROM centos:6

MAINTAINER Patrick DUBUIS <pdubuis@visiativ.com>

# French Timezone (for updating correctly the date in databases)
ENV TIMEZONE Europe/Paris

RUN echo ZONE="$TIMEZONE" > /etc/sysconfig/clock && \
    cp "/usr/share/zoneinfo/$TIMEZONE" /etc/localtime


# Install the Firebird super-server from EPEL and glibc.i686 for nas tools (32 bts)
RUN 	yum install -y epel-release && \
	yum install -y firebird-superserver tar glibc.i686 stunnel rsync


# TODO ADD from a repo
COPY nas-toolbox.tar.gz /tmp/

ENV DOCKER_NAS_FB_VERSION=1

# Unpack the nas-toolbox tar archive AND add usefull env variables into the rights files
RUN     cd / && \
        tar xzvf /tmp/nas-toolbox.tar.gz && \
        rm -f /nas-toolbox.tar.gz && \
        chown -R root:root /opt && \
        echo "export LD_LIBRARY_PATH=/opt/novaxel/novatools/libs" >> /etc/profile.d/nastools.sh  && \
        echo "PATH=$PATH:/opt/novaxel/novatools/bin" >> /etc/profile.d/nastools.sh

	
# Nous utiliserons (pour l'instant) un "bind" sur le host (docker run -v x:y) qui DOIT pointer sur cette variables
ENV "NAS_DB_PATH=/srv/nas"
VOLUME ["$NAS_DB_PATH"]

# Les logs FB (+ éventuellement Audit, etc...)
VOLUME ["/var/log/firebird"]

# La config FB
VOLUME ["/etc/firebird"]

# Data system (security.fdb, udf Novaxel, etc...)
VOLUME ["/var/lib/firebird/system"]


# Copy du fichier de configuration Firebird spécifique
COPY firebird.conf /etc/firebird/

# UDF Novaxel
COPY udf/* /var/lib/firebird/system/udf/

# The firebird port
EXPOSE 3050/tcp
# The synchronization port (via stunnel)
EXPOSE 60443/tcp

USER firebird:firebird

ENTRYPOINT ["/usr/sbin/fbguard", "-pidfile /var/run/firebird/default.pid", "-daemon", "-forever"]

USER root

ENV TERM=xterm
