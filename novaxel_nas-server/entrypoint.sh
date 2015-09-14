#!/bin/bash

set -e

# DEBUG
set -vx

function cleanup()
{
	# On arrive ici après le trap
	echo "Stopping NAS"

	pkillnovaappserver || echo "Error ${?}"

	# no matter to wait for the process end...
	pkill Xvfb || echo "Error : ?{?}"

	pkill fbguard || echo "Error ${?}"

	# Kill other daemons if the've been lauched by this script...
	pkill rsync || true
	pkill stunnel || true

	kill "${tailpid}" || true

	echo "Exited"
}

# Pour reprendre la main si on stop le container...
trap "cleanup" HUP INT QUIT KILL TERM

if [[ ! -x "${NAS_ENTRYPOINT_FB}" ]]
then
	echo "The environnement variable ENTRYPOINT_FB must be set and pointing to an executable script (in Dockerfile)"
	exit 1
fi

mkdir -p  "${NAS_DB_PATH_DOMAIN}" && chown -R firebird:firebird "${NAS_DB_PATH_DOMAIN}"

# On vérifie si des bases domain/event sont présentes
if [[ -z "${NAS_DB_PATH_DOMAIN}" ]]
then
	echo "The environnement variable NAS_DB_PATH_DOMAIN must be set (in Dockerfile)"
	exit 1
else
	 [[ ! -f "${NAS_DB_PATH_DOMAIN}/domain.fdb" ]] && CREATE_DB_DOM=0
	 [[ ! -f "${NAS_DB_PATH_DOMAIN}/event.fdb" ]] && CREATE_DB_EVENT=0
fi

# we start the firebird image entrypoint.sh in background
${NAS_ENTRYPOINT_FB} -b

if [[ -n "${CREATE_DB_DOM}" || -n "${CREATE_DB_EVENT}" ]]
then
	mkdir -p /opt/novaxel/sql_domain && cd /opt/novaxel/sql_domain
	7za e -y  /tmp/sql-domain.7z

	if [[ -n "${CREATE_DB_DOM}" ]]
	then
		echo "CREATE DATABASE '${NAS_DB_PATH_DOMAIN}/domain.fdb' PAGE_SIZE 16384 DEFAULT CHARACTER SET UTF8;"|isql-fb -user sysdba -password masterkey
		isql-fb -user sysdba -password masterkey -b -i /opt/novaxel/sql_domain/domain.sql "'${NAS_DB_PATH_DOMAIN}/domain.fdb"
	fi

	if [[ -n "${CREATE_DB_EVENT}" ]]
	then
		echo "CREATE DATABASE '${NAS_DB_PATH_DOMAIN}/event.fdb' PAGE_SIZE 16384 DEFAULT CHARACTER SET UTF8;"|isql-fb -user sysdba -password masterkey
		isql-fb -user sysdba -password masterkey -b -i /opt/novaxel/sql_domain/event.sql "'${NAS_DB_PATH_DOMAIN}/event.fdb"
	fi

fi


# update NAS conf with the right env variable...
sed -i -e 's|\(DOMAIN_DATABASE_URL=\)\(.*\)|\1localhost:'"${NAS_DB_PATH_DOMAIN}"'/domain.fdb|' /opt/novaxel/conf/novaappserver.conf
sed -i -e 's|\(EVENT_DATABASE_URL=\)\(.*\)|\1localhost:'"${NAS_DB_PATH_DOMAIN}"'/event.fdb|' /opt/novaxel/conf/novaappserver.conf

# Lancement du serveur NAS en arrière plan
echo "Starting NAS"
# Undex ubuntu, we start a xvfb process before the NAS itself
/usr/bin/Xvfb :0 -ac -nolisten tcp -fp /opt/novaxel/novaappserver/fonts/ -tst > /tmp/Xvfb.log 2>&1 &
/opt/novaxel/novaappserver/novaappserver.sh -c /opt/novaxel/conf/novaappserver.conf -l /var/log/novaxel/novaappserver.log
# waiting NAS initialization...
sleep 2

if [[ -n "${CREATE_DB_DOM}" ]]
then
	mkdir -p "${NAS_DB_PATH}/demo" && cd "${NAS_DB_PATH}/demo"
	# On init la base et créé le compte DEMO
	7za x -y /tmp/bibdemo-min.7z
	chown -R firebird:firebird "${NAS_DB_PATH}"
	sed -i -e 's|\(cBIB_REP=\)\(.*\);|\1'"'${NAS_DB_PATH}/demo/';"'|' /opt/novaxel/sql_domain/init_domain.xnov
	sed -i -e 's|\(.*demo2.*;\)|//\1|I' /opt/novaxel/sql_domain/init_domain.xnov
	/opt/novaxel/novatools/bin/nscript /opt/novaxel/sql_domain/init_domain.xnov
fi

# wait indefinetely
while true
do
  tail -f /dev/null & tailpid=${!} && wait "${tailpid}"
done
