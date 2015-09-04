#!/bin/bash

# Mettre à 1 pour des détails sur les transferts en erreur...
DEBUG=0

tempfile=$(mktemp -u)

# Si un fichier est passé en argument, on le traite, sinon on considère que c'est STDIN et on sauvegarde cette entrée dans un fichier temporaire
if [[ -n "${1}" ]]
then
	if [[ ! -f "${1}" ]] 
	then
		echo "Impossible de lire le fichier ${$1}" >&2
		exit 1
	fi
	cp ${1} "${tempfile}"
else # STDIN
	if [[ -t 0 ]]
	then
		echo "rien n'est disponible dans STDIN" >&2
		exit 1
	fi
	cp /dev/stdin "${tempfile}"
fi

trap "rm ${tempfile} && exit" SIGINT SIGTERM EXIT

# On ne tient compte QUE des transferts in/out pour des fichiers de synchros (pas les demandes/réponses de synchros
re1="^(.*) (.*) (\[[[:digit:]]*\]) (rsync on|rsync to) ([[:digit:]]{10}).*/(.*) from (.*)@.*$"

num=0

# Ligne header
echo "PID;TYPE;OWNER;FILE;DATE;LIB;STATE;COMMENT"

while read -r line
do
	# Ligne en cours
	((num++))
	if [[ "${line}" =~ ${re1} ]]
	then
		transdatedeb="${BASH_REMATCH[1]}"
		# Extraction du jour courant pour recherche du jour + 1
		transdatefin=$(printf "%.0f" ${transdatedeb:8}) # on supprime les 0 en head le cas échéant
		transdatedebsed=${transdatedeb:0:8}$(printf "%02i" $(($transdatefin - 1)))
		transdatefin=${transdatedeb:0:8}$(printf "%02i" $(($transdatefin + 1)))

		transtime="${BASH_REMATCH[2]}"

		transpid="${BASH_REMATCH[3]}"
		transpid=${transpid#[}
		transpid=${transpid%]}
		if [[ ${BASH_REMATCH[4]} = "rsync to" ]]
		then
			transtype="receive"
		else
			transtype="send"
		fi

		translib="${BASH_REMATCH[5]}"
		transfile="${BASH_REMATCH[6]}"
		transwho="${BASH_REMATCH[7]}"

		# RE de recherche de fin de transfert Ok
		re2="(send|recv).*${transfile}"

		# On récupère les 10 lignes suivantes dans le log pour essayer de chercher la terminaison du transfert
		blocstart=$((num + 1))
		blocend=$((num + numrow))

		# Recherche  des x lignes suivantes dans le fichier correspondant au même PID et à la même date ou J+1...
		cmd="sed -ne '${blocstart},$ {/^\(${transdatedeb//\//\\/}\|${transdatefin//\//\\/}\|${transdatedeb//\//\\/}\) [[:digit:]]\{2\}\:[[:digit:]]\{2\}\:[[:digit:]]\{2\} \[${transpid}\]/p}' ${tempfile}"
		#echo $cmd
		transsuite=$(eval ${cmd})

		if [[ ${transsuite} =~ ${re2} ]]
		then
			transend="success"
			transcom=""
		else
			transend="failure"
			case ${transsuite} in
				*timeout* )
					transcom="timeout"
				;;
				*Broken\ pipe* )
					transcom="connexion lost"
				;;
				*exec\ returned\ failure* )
					transcom="rsync script error"
				;;
				*No\ space\ left\ on\ device* )
					transcom="disk space"
				;;
				*Permission\ denied* )
					transcom="Permission"
				;;
				*No\ such\ file\ or\ directory* )
					transcom="File not found"
				;;
				*connection\ unexpectedly\ closed* )
					transcom="connexion close"
				;;
				*Connection\ reset\ by\ peer* )
					transcom="connexion reset"
				;;
				* )
					transcom="unknown error"
				;;
			esac
		fi

		transdatedeb=${transdatedeb:8}/${transdatedeb:5:2}/${transdatedeb:0:4}

		echo "${transpid};${transtype};${transwho};${transfile};${transdatedeb} ${transtime};$(printf "%.0f" ${translib});${transend};${transcom}"

		if [[ ${transcom} = "unknown error" && ${DEBUG} -ne 0 ]]
		then
				echo -e "\tSuite : $transsuite"
		fi

	fi
done < "${tempfile}"