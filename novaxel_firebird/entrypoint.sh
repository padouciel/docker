#!/bin/bash

set -e

# DEBUG
#set -vx

# Trap function
function cleanup()
{
	echo "stopping stunnel daemon"
	killall -w stunnel || "Error ${?}"

	echo "stopping rsync daemon"
	killall -w rsync || "Error ${?}"

	echo "Stopping Firebird"
	killall -w fbguard || "Error ${?}"

	echo "Exited"
}

# trap signals and call the cleanup function
trap "cleanup" HUP INT QUIT KILL TERM

# run the services
echo "Starting Firebird"
runuser firebird -s /bin/sh -c "/usr/sbin/fbguard -pidfile /var/run/firebird/firebird.pid -daemon -forever"

echo "Starting rsync"
/usr/bin/rsync --daemon --config=/opt/novaxel/rsyncd.conf

echo "Starting stunnel"
/usr/bin/stunnel /opt/novaxel/stunnel.conf

# wait indefinetely
while true
do
  tail -f /dev/null & wait ${!}
done
