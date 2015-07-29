FROM centos:6


MAINTAINER Patrick DUBUIS <pdubuis@visiativ.com>

# ENV DEBIAN_FRONTEND noninteractive

# On active la timezone France...
ENV TIMEZONE Europe/Paris

RUN echo ZONE="$TIMEZONE" > /etc/sysconfig/clock && \
    cp "/usr/share/zoneinfo/$TIMEZONE" /etc/localtime


# Ajout du dépôt EPEL + installation firebird SS
RUN	yum install -y epel-release && \
	yum -y install firebird-superserver
	
# Nous utiliserons (pour l'instant) un "bind" sur le host (docker run -v x:y)
# À voir plus tard...
# VOLUME ["/databases"]

# Les logs FB (+ éventuellement Audit, etc...)
VOLUME ["/var/log/firebird"]
# La config FB
VOLUME ["/etc/firebird"]

# Data system
VOLUME ["/var/lib/firebird/system"]

EXPOSE 3050/tcp

ENTRYPOINT ["/usr/sbin/fbguard", "-pidfile /var/run/firebird/default.pid", "-daemon", "-forever"]
