#/bin/bash

# all containers (not running)
cont=$(docker ps -aq)
if [[ -n "${cont}" ]] 
then
	echo "removing containers" 
	docker rm -v ${cont}
else
	echo "no container to remove"
fi

# "dangling" images (not use anymore)
dangling=$(docker images --filter "dangling=true" -q)
if [[ -n "${dangling}" ]]
then
	echo "removing dangling images" 
	docker rmi ${dangling}
else
	echo "no dangling images found"
fi
