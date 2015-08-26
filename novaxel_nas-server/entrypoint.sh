#!/bin/bash

set -e

# DEBUG
set -vx

function cleanup()
{
	# On arrive ici après le trap
	echo "Stopping NAS"

	kill $NAS_PID && killall Xvfb

	echo "Exited ${?}"
}

# Pour reprendre la main si on stop le container...
trap "cleanup" HUP INT QUIT KILL TERM

# TODO : tester présente serveur FB...

# On vérifie si des bases domain/event sont présentes
if [[ -z "${FBSERVER_ENV_FB_DB_PATH}" ]]
then
	echo "La variable d'environnement FBSERVER_ENV_FB_DB_PATH doit-être initialisée pour que le NAS sache où chercher ses bases..."
	exit 1
fi

# TODO Création des bases domain/event si non présentes

# Lancement du serveur NAS en arrière plan
echo "Starting NAS"
/opt/novaxel/novaappserver/novaappserver.sh

# Récupération du PID 
NAS_PID=$(pgrep novaappserver)

# wait indefinetely
while true
do
  tail -f /dev/null & wait ${!}
done
