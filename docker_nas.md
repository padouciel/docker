# Mise en place docker pour novaappserver
## Environnement serveur Dev

Les éléments suivants ont été installés sur le serveur dev.cloudnovaxel.fr :

- bash_completion (from epel)

- Dernière version docker :
  - Ajout du dépôt docker-project via le script (cf http://blog.docker.com/2015/07/new-apt-and-yum-repos/) :
```shell
curl -sSL https://get.docker.com/ | sh
```

- activation completion docker :
```shell
cp /usr/share/bash_completion/completion/docker /etc/bas_completion.d
```

- docker-compose, 
  - binaire directement à partir de https://docs.docker.com/compose/install/
```shell
mkdir /opt/docker-tools
curl -L https://github.com/docker/compose/releases/download/1.3.3/docker-compose-`uname -s`-`uname -m` > /opt/docker-tools/docker-compose
chmod a+x /opt/docker-tools/docker-compose
```

- docker-compose bash completion : (https://docs.docker.com/compose/completion/)
```shell
 curl -L https://raw.githubusercontent.com/docker/compose/$(docker-compose --version | awk 'NR==1{print $NF}')/contrib/completion/bash/docker-compose > /etc/bash_completion.d/docker-compose
```
**_TODO : don't work (docker-compose not in path ???)_**


- docker registry (cf https://docs.docker.com/registry/)
   - latest
```shell
docker pull registry
```

## Mise en place registry

Voir [installation serveur](#Environnement-serveur-Dev)