FROM centos:6

MAINTAINER Patrick DUBUIS <pdubuis@visiativ.com>

# Packages needed for this imaages (NAS tools uses 32 bits)
RUN yum install -y tar glibc.i686

# This archive contents the NAS tools by theirself (32 bits) AND the firebird CLI utils(32 bits)
COPY nas-toolbox.tar.gz /

# Unpack the tar archive AND add usefull env variables into the rights files
RUN	cd / && \
	tar xzvf /nas-toolbox.tar.gz && \
	rm -f /nas-toolbox.tar.gz && \
	chown -R root:root /opt && \
	echo "export LD_LIBRARY_PATH=/opt/novaxel/novatools/libs" >> /etc/profile.d/nastools.sh  && \
	echo "PATH=$PATH:/opt/novaxel/novatools/bin" >> /etc/profile.d/nastools.sh
	

ENTRYPOINT ["/bin/bash"]
