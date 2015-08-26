# This image is made for holding Customer's datas (the FDB from our customers)
# So, it needs the NAS toolboxes and stunnel/rsync for for shynchronizing the FDB files

FROM novaxel/nas-toolbox:latest

MAINTAINER Patrick DUBUIS <pdubuis@visiativ.com>

# French Timezone (for updating correctly the date in databases)
ENV TIMEZONE Europe/Paris

RUN echo ZONE="$TIMEZONE" > /etc/sysconfig/clock && \
    cp "/usr/share/zoneinfo/$TIMEZONE" /etc/localtime

# Firebird install
# TODO : have a repository for that and use "ADD" instead
COPY	firebird*.rpm /tmp/

RUN yum -y localinstall /tmp/firebird-*.rpm && \
	rm -f /tmp/firebird*.rpm

# Nous utiliserons (pour l'instant) un "bind" sur le host (docker run -v x:y) qui DOIT pointer sur cette variables
# ENV "FB_DB_PATH=/srv/firebird"

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

# The firebird port
EXPOSE 3050/tcp
# The synchronization port (via stunnel)
EXPOSE 60443/tcp

USER firebird:firebird

# ENTRYPOINT ["/usr/sbin/fbguard", "-pidfile /var/run/firebird/default.pid", "-daemon", "-forever"]
