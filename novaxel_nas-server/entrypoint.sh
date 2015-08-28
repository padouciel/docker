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

	killall -w fbguard || "Error ${?}"

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

if [[ -n "${CREATE_DB_DOM}" ]]
then
	mkdir -p  "${NAS_DB_PATH_DOMAIN}" && chown -R firebird:firebird "${NAS_DB_PATH_DOMAIN}"
	echo "CREATE DATABASE '${NAS_DB_PATH_DOMAIN}/domain.fdb' PAGE_SIZE 16384 DEFAULT CHARACTER SET UTF8;"|isql-fb -user sysdba -password masterkey
	isql-fb -user sysdba -password masterkey -b -i /opt/novaxel/sql/domain.sql "'${NAS_DB_PATH_DOMAIN}/domain.fdb"
fi

if [[ -n "${CREATE_DB_EVENT}" ]]
then
	mkdir -p  "${NAS_DB_PATH_DOMAIN}"  && chown -R firebird:firebird "${NAS_DB_PATH_DOMAIN}"
	echo "CREATE DATABASE '${NAS_DB_PATH_DOMAIN}/event.fdb' PAGE_SIZE 16384 DEFAULT CHARACTER SET UTF8;"|isql-fb -user sysdba -password masterkey
	isql-fb -user sysdba -password masterkey -b -i /opt/novaxel/sql/event.sql "'${NAS_DB_PATH_DOMAIN}/event.fdb"
fi

# update NAS conf with the right env variable...
sed -i -e 's|\(DOMAIN_DATABASE_URL=\)\(.*\)|\1localhost:'"${NAS_DB_PATH_DOMAIN}"'/domain.fdb|' /opt/novaxel/novaappserver.conf
sed -i -e 's|\(EVENT_DATABASE_URL=\)\(.*\)|\1localhost:'"${NAS_DB_PATH_DOMAIN}"'/event.fdb|' /opt/novaxel/novaappserver.conf


# Lancement du serveur NAS en arrière plan
echo "Starting NAS"
/opt/novaxel/novaappserver/novaappserver.sh -c /opt/novaxel/novaappserver.conf

# Récupération du PID 
NAS_PID=$(pgrep novaappserver)

# wait indefinetely
while true
do
  tail -f /dev/null & wait ${!}
done
