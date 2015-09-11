#!/bin/bash

set -e

set -vx

# Trap function
function cleanup()
{

	if [[ -z "${nosync}" ]]
	then

		echo "stopping stunnel daemon"
		killall -w stunnel || "Error ${?}"

		echo "stopping rsync daemon"
		killall -w rsync || "Error ${?}"
	fi

	echo "Stopping Firebird"
	killall -w fbguard || "Error ${?}"

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
runuser firebird -s /bin/sh -c "/usr/sbin/fbguard -forever -pidfile /var/run/firebird/firebird.pid -daemon"

if [[ -z "${nosync}" ]]
then
	echo "Starting rsync"
	# Make a "template" copy of rsyncd.conf into the scripts directory for synchro scripts...
	cp /opt/novaxel/conf/rsyncd.conf /opt/novaxel/scripts/
	# Create rsyncd.scret file
	touch /opt/novaxel/conf/rsyncd.secret && chmod 0660 /opt/novaxel/conf/rsyncd.secret
	/usr/bin/rsync --daemon --config=/opt/novaxel/conf/rsyncd.conf

	echo "Starting stunnel"
	# stunnel runs itself (exec AFAIK ?) as non-priviligied user "nobody"
	stunnel_conf="/opt/novaxel/conf/stunnel.conf"
	stunnel_pid="$(sed -n -e 's/pid\s*\=\s*\(.*\)/\1/p' ${stunnel_conf})"
	[[ -n "${stunnel_pid}" ]] && mkdir -p "$(dirname ${stunnel_pid})" && chown "$(sed -n -e 's/setuid\s*\=\s*\(.*\)/\1/p' ${stunnel_conf})" "$(dirname ${stunnel_pid})" || true

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
