#!/bin/bash

set -e

# DEBUG
set -vx

function cleanup()
{
	# On arrive ici après le trap
	echo "Stopping NAS"

	killall -w novaappserver || echo "Error ${?}"

	# no matter to wait for the process end...
	killall Xvfb || echo "Error : ?{1}"

	killall -w fbguard || echo "Error ${?}"

	echo "Exited"
}

# Pour reprendre la main si on stop le container...
trap "cleanup" HUP INT QUIT KILL TERM


# On vérifie si des bases domain/event sont présentes
if [[ -z "${NAS_DB_PATH_DOMAIN}" ]]
then
	echo "The environnement variable NAS_DB_PATH_DOMAIN must be set (in Dockerfile)"
	exit 1
else
	 [[ ! -f "${NAS_DB_PATH_DOMAIN}/domain.fdb" ]] && CREATE_DB_DOM=0
	 [[ ! -f "${NAS_DB_PATH_DOMAIN}/event.fdb" ]] && CREATE_DB_EVENT=0
fi

echo "Starting Firebird"
runuser firebird -s /bin/sh -c "/usr/sbin/fbguard -pidfile /var/run/firebird/firebird.pid -daemon -forever"

if [[ -n "${CREATE_DB_DOM}" || -n "${CREATE_DB_EVENT}" ]]
then
        mkdir -p  "${NAS_DB_PATH_DOMAIN}" && chown -R firebird:firebird "${NAS_DB_PATH_DOMAIN}"
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

	# update NAS conf with the right env variable...
	sed -i -e 's|\(DOMAIN_DATABASE_URL=\)\(.*\)|\1localhost:'"${NAS_DB_PATH_DOMAIN}"'/domain.fdb|' /opt/novaxel/novaappserver.conf
	sed -i -e 's|\(EVENT_DATABASE_URL=\)\(.*\)|\1localhost:'"${NAS_DB_PATH_DOMAIN}"'/event.fdb|' /opt/novaxel/novaappserver.conf

fi


# Lancement du serveur NAS en arrière plan
echo "Starting NAS"
/opt/novaxel/novaappserver/novaappserver.sh -c /opt/novaxel/novaappserver.conf
# waiting NAS initialization...
sleep 1

if [[ -n "${CREATE_DB_DOM}" ]]
then
	mkdir -p "${NAS_DB_PATH}/demo" && cd "${NAS_DB_PATH}/demo"
	# On init la base et créé le compte DEMO
	7za x /tmp/bibdemo-min.7z
	chown -R firebird:firebird "${NAS_DB_PATH}"
	sed -i -e 's|\(cBIB_REP=\)\(.*\);|\1'"'${NAS_DB_PATH}/demo/';"'|' /opt/novaxel/sql_domain/init_domain.xnov
	sed -i -e 's|\(.*demo2.*;\)|//\1|I' /opt/novaxel/sql_domain/init_domain.xnov
	/opt/novaxel/novatools/bin/nscript /opt/novaxel/sql_domain/init_domain.xnov
fi

# wait indefinetely
while true
do
  tail -f /dev/null & wait ${!}
done
