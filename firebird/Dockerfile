FROM centos:6


MAINTAINER Patrick DUBUIS <pdubuis@visiativ.com>

# On active la timezone France pour MAJ Date FB OK...
ENV TIMEZONE Europe/Paris

RUN echo ZONE="$TIMEZONE" > /etc/sysconfig/clock && \
    cp "/usr/share/zoneinfo/$TIMEZONE" /etc/localtime


# Installaiton des packages firebird
COPY	firebird*.rpm /tmp/

WORKDIR	/tmp

RUN yum -y localinstall firebird-*.rpm && \
	rm -f firebird*.rpm

WORKDIR /

# Nous utiliserons (pour l'instant) un "bind" sur le host (docker run -v x:y) qui DOIT pointer sur cette variables
ENV "FB_DB_PATH=/srv/firebird"

# Les logs FB (+ éventuellement Audit, etc...)
VOLUME ["/var/log/firebird"]

# La config FB pour NAS
VOLUME ["/etc/firebird"]

# Data system (security.fdb, udf Novaxel, etc...)
VOLUME ["/var/lib/firebird/system"]

# Copy du fichier de configuration Firebird spécifique
COPY firebird.conf /etc/firebird/

# UDF Novaxel
COPY udf/* /var/lib/firebird/system/udf/

EXPOSE 3050/tcp

#USER firebird:firebird

ENTRYPOINT ["/usr/sbin/fbguard", "-pidfile /var/run/firebird/default.pid", "-daemon", "-forever"]
