#!/bin/bash

set -e

set -vx

# Trap function
function cleanup()
{

	if [[ -z "${nosync}" ]]
	then

		echo "stopping stunnel daemon"
		pkill stunnel || "Error ${?}"

		echo "stopping rsync daemon"
		pkill rsync || "Error ${?}"
	fi

	echo "Stopping Firebird"
	pkill fbguard || "Error ${?}"

	kill "${tail_pid}" || true

	echo "Exited"
}

function usage ()
{
	cat << EOF
$0 -b -n -h

-b : don't stay in foreground (ie the daemons are runned in background and you MUST kill then yourself !)
-n : don't run the synchro daemons (stunnel + rsync)
-h : this help

EOF

	exit 0
}

while getopts "bnh" option
do
        case "$option" in
        n)
                nosync=1
                ;;
        b)
                noforeground=1
                ;;
	h)
		usage
		;;
        \?)
                exit 1
        esac
done

shift $((OPTIND-1))

# run the services
echo "Starting Firebird"
sudo -u firebird /usr/sbin/fbguard -forever -pidfile /var/run/firebird/firebird.pid -daemon

if [[ -z "${nosync}" ]]
then
	echo "Starting rsync"
	rsyncd_conf="/opt/novaxel/conf/rsyncd.conf"
	# Make a "template" copy of rsyncd.conf into the scripts directory for synchro scripts...
	cp "${rsyncd_conf}" /opt/novaxel/scripts/
	# Create rsyncd.scret file
	rsync_secrets_file="$(sed -n -e 's/secrets file\s*\=\s*\(.*\)/\1/p' ${rsyncd_conf})"
	[[ -n "${rsync_secrets_file}" ]] && touch "${rsync_secrets_file}" && chmod 0660 "${rsync_secrets_file}"
	/usr/bin/rsync --daemon --config="${rsyncd_conf}"

	echo "Starting stunnel"
	# stunnel exec  as non-priviligied user "nobody" (CentOS) or "stunnel4" (Debian/Ubuntu)
	stunnel_conf="/opt/novaxel/conf/stunnel.conf"
	stunnel_pid="$(sed -n -e 's/pid\s*\=\s*\(.*\)/\1/p' ${stunnel_conf})"
	[[ -n "${stunnel_pid}" ]] && mkdir -p "$(dirname ${stunnel_pid})" && chown "$(sed -n -e 's/setuid\s*\=\s*\(.*\)/\1/p' ${stunnel_conf})" "$(dirname ${stunnel_pid})" || true
	stunnel_log="$(sed -n -e 's/output\s*\=\s*\(.*\)/\1/p' ${stunnel_conf})"
	[[ -n "${stunnel_log}" ]] && touch "${stunnel_log}" && chown "$(sed -n -e 's/setuid\s*\=\s*\(.*\)/\1/p' ${stunnel_conf})" "${stunnel_log}" || true
	/usr/bin/stunnel "${stunnel_conf}"
fi

if [[ -z "${noforeground}" ]]
then
	# trap signals and call the cleanup function
	trap "cleanup" HUP INT QUIT KILL TERM

	# wait indefinetely
	while true
	do
	  tail -f /dev/null & tail_pid=${!} && wait "${tail_pid}"
	done
fi
