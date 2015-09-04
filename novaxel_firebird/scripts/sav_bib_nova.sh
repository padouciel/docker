#!/bin/bash
LANG=fr_FR.UTF-8

# rsync des fichiers sauvegardés localement vers un serveur distant (backup.novaxelcloud.fr)

# Ajout 28/11/2012
# - Activation du 2ème FS pour nouveaux clients
# - Gestion des path d'origine multiples (ie. firebird => sav/firebird et firebird02==>/sav/firebird02, ...)



########################################################################"
# Variables globales utilisées :
########################################################################"

SAV_LOG='/var/log/novasav_distant.log';

# Fichier contenant la liste des bib DÉJÀ sauvegardées (et sur quel serveur de backup)
# Forme :
# LIBID:SSH_HOST (cf. ci-dessous)
SAV_LST="$(dirname ${0})/sav_bib.lst"

# Récupération des variables dans le fichier include.xnov
for i in $(sed -ne 's/^\s*\(\w*\)\s*=\s*\(.*\)\s*;\s*$/\1=\2/p' $(dirname ${0})/local_inc.xnov);do eval $(echo "$i");done

# Si non initialisé, on prend une valeur par défaut...
NAS_THIS_SAV_DEST=${NAS_THIS_SAV_DEST:-'/srv/bib_sav'}

# Variables pour la sauvegarde distante...

# hosts SSH cible sauvegarde
#SSH_HOST[1]="backup.novaxelcloud.fr"
#SSH_HOST[2]="backup2.novaxelcloud.fr"
SSH_HOST[1]="backup.cloudnovaxel.fr"

# port SSH à utiliser (TOUS les serveurs de backup doivent être initialisés de la même manière pour TOUS les éléments SSH)
SSH_PORT="8222"
# User ssh
SSH_USER="backupadmin"
# Fichier de Clé privée (répertoire en cours et à protéger convenablement)
SSH_PRIVKEY="$(dirname $0)/backup_novaxecloud_fr_np"
# Fichier de Clé publique du serveur
SSH_HOSTKEY="$(dirname $0)/backup_host"
# Utilisateur spécifique rsync (idem SSH_USER si non initialisé)
RSYNC_USER=""
# Options rsync à utiliser par défaut
RSYNC_OPT="-arz -v --stats"
# Répertoire distant sauvegarde
DEST_DIR="/home/sav/bib_clients/$(hostname -s)"

# Construction de la chaine de commande ssh
SSH_CMD="-i ${SSH_PRIVKEY} -p ${SSH_PORT} -l ${SSH_USER} -o UserKnownHostsFile=${SSH_HOSTKEY} -o BatchMode=yes"

# Si les bases domaine/event sont situées sur ce serveur, le spécifier ici
DOMDB="/srv/databases/domain.fdb"
EVENTDB="/srv/databases/event.fdb"


function usage() {
	echo "Appel incorrect : vous devez préciser un répertoire contenant des fichiers de bibliothèques Novaxel en paramètre" >&2
	[[ -z $1 ]] || echo "Répertoire donné : $1" >&2
	exit 1
}

# Ecrit des messages dans le fichier de log défini
# $1 ==> message par lui-même
# $2 ==> fichier de log
function logger() {
        [ $# -ne 2 ] && return 1 #==> mauvais appel

        pref=$(date +"%Y-%m-%d %H:%M:%S")
        caller=$(caller 0|cut -f 1,2 -d " ")
        echo "${pref} $(hostname): ${caller} - ${1}" >> $2
        return 0
}


# Renvoi le Nom d'un SSH_HOST
# $1 : lib_id
# $2 = Taille de la bib à sauvegarder
function get_sav_srv() {
	[ $# -ne 2 ] && return 1 #==> mauvais appel

	local bib_id=${1}
	local bib_size=${2}
	local sav_free=0
	local sav_df=0

	logger "Recherche d'un serveur de sauvegarde pour la lib ${bib_id}" $SAV_LOG
	
	# Parcours de la liste des serveurs possibles et recherche d'un serveur Ok
	for i in ${SSH_HOST[*]}
	do
		# Taille restante sur le serveur...
		# Le répertoire final peut ne pas encore exister lors de cet appel
		sav_df=$(ssh ${SSH_CMD} "${i}" df "$(dirname ${DEST_DIR})"|tail -1|tr -s ' ' ';')
		# Taille disponible doit être supérieure à 90 %
		if [[ "$(echo "${sav_df}"|cut -f 5,5 -d ';'|tr -d '%'||tr -d ' ')" -lt 90 ]]
		then
			# Assez de place pour manger la nouvelle bib
			if [[ "$(echo ${sav_df}|cut -f 4,4 -d ';'|tr -d ' ')" -gt "${bib_size}" ]]
			then
				logger "le serveur de sauvegarde \"${i}\" prend en charge la lib ${bib_id}... " $SAV_LOG
				echo "${i}"
				return 0
			else
				logger "le serveur de sauvegarde \"${i}\" ne peut pas prend en charge la lib ${bib_id} car il n'a pas assez d'espace libre... " $SAV_LOG
			fi
		else
			logger "Attention : le serveur de sauvegarde \"${i}\" dispose de moins de 90% d'espace libre... " $SAV_LOG
		fi
	done

	# Aucun serveur trouvé :-(
	return 1
}

# $1 = DB à sauvegarder
function sav_db () {
	[ $# -ne 1 ] && return 1 #==> mauvais appel

	DB="${1}"

	if [[ ! -f "${DB}" ]]
	then
		logger "La base ${DB} est introuvable" $SAV_LOG
		return 1
	fi

	# Arbitrairement
	SSH_HOST_SAV="backup.cloudnovaxel.fr"


	# Ficier auth FB ...
	[[ ! -f $(dirname $0)/local_fb.sh ]] && exit 1

	. $(dirname $0)/local_fb.sh

	logger "Synchronisation de la base ${DB}" $SAV_LOG

	# gbak -user "${FBADMIN}" -password "${FBPASSWD}" -b "${DB}" $(dirname ${DOMDB})/$(basename ${DOMDB}).fbk

	local cmd=$(nbackup -user "${FBADMIN}" -password "${FBPASSWD}" -L "${DB}" 2>&1)
	[[ $? -ne 0 ]] && logger "Erreur lors du verrouillage de la base ${DB} avec le message $cmd" $SAV_LOG && return 1
	cmd=$(cp "${DB}" "${NAS_THIS_SAV_DEST}/$(basename ${DB})" 2>&1)
	[[ $? -ne 0 ]] && logger "Erreur lors de la copie de la base ${DB} vers ${NAS_THIS_SAV_DEST} avec le message $cmd" $SAV_LOG
	cmd=$(nbackup -user "${FBADMIN}" -password "${FBPASSWD}" -N "${DB}" 2>&1)
	[[ $? -ne 0 ]] && logger "Erreur lors de la libération du verrou de la base ${DB} avec le message $cmd" $SAV_LOG 
 	cmd=$(nbackup -user "${FBADMIN}" -password "${FBPASSWD}" -F "${NAS_THIS_SAV_DEST}/$(basename ${DB})" 2>&1)
	[[ $? -ne 0 ]] && logger "Erreur lors de la libération du verrou de la base "${NAS_THIS_SAV_DEST}/$(basename ${DB})" avec le message $cmd" $SAV_LOG

	SAV_DEST="${DEST_DIR}/$(dirname ${DB})"
	cmd=$(ssh ${SSH_CMD} ${SSH_HOST_SAV} mkdir -p "${SAV_DEST}" 2>&1 && rsync -e "ssh ${SSH_CMD}" -az --delete "${NAS_THIS_SAV_DEST}/$(basename ${DB})" ${RSYNC_USER}@${SSH_HOST_SAV}:${SAV_DEST} 2>&1)
	ret=$?
	if [[ $ret -ne 0 ]]
	then
		logger "Erreur lors de la synchro distante de la base ${DB} avec le code de retour $ret et le message $cmd" $SAV_LOG
	else
		logger "Synchronisation base ${DB} distante effectuée correctement" $SAV_LOG
	fi
	
}

# C'est parti...
logger "" $SAV_LOG
logger "" $SAV_LOG
logger "=================================== Sauvegarde des bases... ==============================================" $SAV_LOG
logger "" $SAV_LOG

# On lance le script xnov de sauvegarde locale qui nous renvoir une liste des bib sauvegardées
# STDOUT sous la forme
#/LIB_ID > LIB_TILE > path/db/prod > /pad/db/sav
# Par exemple :
# 90 > Mon joli titre > /var/lib/firebird/novaxelcloud/0000000010/0000000090 > /tmp/bib_sav/0000000010/0000000090

cmd=$(/opt/novaxel/novatools/nscript.sh /opt/novaxel/novatools/scripts/sav_bib.xnov 2>&1)
ret=$?
if [[ $ret -ne 0  ]]
then
	logger "Erreur lors de la sauvegarde locale avec le code de retour $ret et le message ${cmd}" $SAV_LOG
	exit 1
fi

if [[ ! -f "${SAV_LST}" ]]
then
	logger "Attention : Fichier de liste des sauvegardes "${SAV_LST}" non trouvé, un nouveau sera créé..." $SAV_LOG
fi

# Rsync avec le serveur distant pour chaque base
# Substitution si RSYNC_USER est vide...
RSYNC_USER="${RSYNC_USER:-$SSH_USER}"

logger "Lancement des synchros sauvegarde locales" $SAV_LOG
OIFS=$IFS
# It works; but why ??? ==> pseudo variable bash ???
IFS=$'\n'

for SAV in $cmd
do
	IFS=$OIFS
	LIBID=$(echo ${SAV}|tr -d " "|cut -f1 -d ">")
	LIBTITLE="$(echo ${SAV}|cut -f2 -d ">")"
	SAV_SRC="$(echo ${SAV}|tr -d " "|cut -f4 -d ">")/"
	SAV_ORIG=$(echo ${SAV}|tr -d " "|cut -f3 -d ">")
	SAV_DEST="${DEST_DIR}/${SAV_ORIG}/";
	append_list=""

	# Recherche du serveur de Backup à utiliser
	SSH_HOST_SAV=$(grep "${LIBID}:" "${SAV_LST}"|cut -f2 -d ":"|tr -d " ")

	# Serveur non trouvé (première SAV)
	if [[ -z "${SSH_HOST_SAV}" ]]
	then
		logger "Librairie non trouvée dans le fichier ${SAV_LST} : lancement d'une recherche de serveur pouvant prendre en charge..." $SAV_LOG
		SSH_HOST_SAV="$(get_sav_srv ${LIBID} $(du -S ${SAV_SRC} --max-depth=0|cut -f1,1))"
		append_list="0"
	fi

	if [[ -n "${SSH_HOST_SAV}" ]]
	then
		logger "Synchro de  \"${SAV_SRC}\" vers \"${SSH_HOST_SAV}:${SAV_DEST}\"" $SAV_LOG
		# On demande la création du path distant, puis on copie dans ce path... (rsync n'a pas d'option pour créer un path distant)
		cmd=$(ssh ${SSH_CMD} ${SSH_HOST_SAV} mkdir -p "${SAV_DEST}" 2>&1 && rsync -e "ssh ${SSH_CMD}" -az --delete ${SAV_SRC} ${RSYNC_USER}@${SSH_HOST_SAV}:${SAV_DEST} 2>&1)
		ret=$?
		if [[ $ret -ne 0 ]]
		then
			logger "Erreur lors de la synchro distante effectuée avec le code de retour $ret et le message $cmd" $SAV_LOG
			logger "$cmd" $SAV_LOG
			echo "Erreur lors de la sauvegarde de ${SAV_ORIG} avec le code ${ret}, voir le fichier ${SAV_LOG} pour plus de détails"|mail -s "Erreur Sauvegarde de bibliothèque ${LIBTITLE} (${LIBID})" novapad@free.fr
		else
			# TODO : récupérer email admin...
			echo "La sauvegarde de la bibliothèque ${SAV_ORIG} s'est correctement déroulée sur le serveur ${SSH_HOST_SAV}"|mail -s "Sauvegarde de la bibliothèque ${LIBTITLE} (${LIBID})" novapad@free.fr
			logger "Synchronisation distante effectuée correctement" $SAV_LOG
			# Ajout de la nouvelle bib dans lia liste...
			[[ -n "${append_list}" ]] && echo "${LIBID}:${SSH_HOST_SAV}" >> ${SAV_LST}
		fi
	else
		logger "Synchronisation distante impossible car aucun serveur de backup ne peut prendre en charge la librairie..." $SAV_LOG
		echo "Aucun serveur de backup distant pour prendre en charge ${SAV_ORIG}"|mail -s "Erreur Sauvegarde de la bibliothèque ${LIBTITLE} (${LIBID})" novapad@free.fr



	fi
	
done

[[ -f "$DOMDB" ]] && sav_db "$DOMDB"

[[ -f "$EVENTDB" ]] && sav_db "$EVENTDB"

exit 0
