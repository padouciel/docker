# This image is made for holding Customer's datas (the FDB from our customers)
# So, it needs the NAS toolboxes and stunnel/rsync for for shynchronizing the FDB files
# It's also used as the base image for the NAS image (that needs FB, NAS toolbox, etc too)

FROM ubuntu

MAINTAINER Patrick DUBUIS <pdubuis@visiativ.com>

	# The location of the NAS & tools packages, DB, etc...
ENV 	NAS_PACK_URL="http://www.novaxel2.com/depotDocker" \
	# Where the DBs are located (this env variable is used by many tools in this image AND others) \
	NAS_DB_PATH="/srv/nas" \
	NAS_DOCKER_FB_VERSION=5 \
	TIMEZONE="Europe/Paris" \
	LC_ALL="C.UTF-8" \
	# The entrypoint stuff... \
	NAS_ENTRYPOINT_FB="/entrypoint_fb.sh" \
	# We must reinitialized this variable ! I don't know why, but after the entrypoint above, we have "TERM=dumb" (instead of "TERM=xterm") ? \
	TERM=xterm

# French Timezone && locale(for updating correctly the date in databases)
RUN 	echo "$TIMEZONE" > /etc/timezone && \
	dpkg-reconfigure -f noninteractive tzdata && \
	update-locale LANG=C.UTF-8

# Add Firebird PPA into sources list (the install of "software-properties-common" costs a lot of time & disk space :-( )
# Install needed packages
RUN	export DEBIAN_FRONTEND=noninteractive && \
	apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EF648708 && \
	echo "deb http://ppa.launchpad.net/mapopa/ppa/ubuntu $(lsb_release -cs) main" > /etc/apt/sources.list.d/firebird.list && \
	dpkg --add-architecture i386 && \
	apt-get -y update && \
	apt-get -y upgrade && \
 	apt-get -y --no-install-recommends install firebird2.5-super stunnel rsync p7zip-full curl libc6:i386 && \
	cd /usr/bin && \
	ln -sf stunnel4 stunnel
 
# Unpack the nas-toolbox tar archive AND add usefull env variables into the rights files (bash *login*)
RUN     mkdir -p /opt/novaxel && \
	cd /tmp && \
	curl -O ${NAS_PACK_URL}/firebird/nas-toolbox.7z  && \
	cd /opt/novaxel && \
        7z x -y /tmp/nas-toolbox.7z && \
        rm -f /tmp/nas-toolbox.7z && \
        chown -R root:root /opt/novaxel && \
        echo "export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/novaxel/novatools/libs" >> /etc/profile.d/nastools.sh  && \
        echo "PATH=$PATH:/opt/novaxel/novatools/bin" >> /etc/profile.d/nastools.sh && \
        echo "touch /tmp/$(basename $0).ok" >> /etc/profile.d/nastools.sh

	
# Root DB Path : the domain & event DBs are located in this path under "domain" subdir, and the customer's DBs in "tenants ID" subdir (eg. 0000000180/000000253)
# Logs (for DB, possibly Audit, etc...)
# FB config
# FB Data system (security.fdb [FB users ans rôles], udf Novaxel, etc...)
# a  volume for adding new certs and keep there persistents
VOLUME ["$NAS_DB_PATH", "/var/log/firebird", "/var/log/novaxel", "/etc/firebird", "/opt/novaxel/conf" , "/var/lib/firebird/system", "/opt/novaxel/certs"]

# We provide a conf file for Novaxel (the ubuntu firebird package use a sub-dir in conf...)
COPY conf/firebird.conf /etc/firebird/2.5/

# Tools conf
# Copy configuration file in right places
COPY conf/stunnel.conf conf/rsyncd.conf /opt/novaxel/conf/

# UDF Novaxel
COPY /udf/* /var/lib/firebird/system/udf/

# Dummy certificates for stunnel & other (NAS too)
COPY certs/* /opt/novaxel/certs/

# NAS toolbox scripts
COPY scripts/* /opt/novaxel/scripts/

# The firebird port
EXPOSE 3050/tcp

# The synchronization port (via stunnel)
EXPOSE 60443/tcp

# Note : We do not expose the rsync port as it's only used internally


COPY entrypoint_fb.sh "${ENTRYPOINT_FB}"
# Don't work :-(
#ENTRYPOINT ["/bin/bash", "-l", "-c", "${ENTRYPOINT_FB}"]
ENTRYPOINT ["/bin/bash","-lc", "/entrypoint_fb.sh"]

