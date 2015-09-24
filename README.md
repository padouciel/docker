Images Docker pour Serveur d'application Firebird
=======
Ce projet contient 2 images :

# Une image de base : _novaxel/firebird_
* source ubuntu:14:04
* serveur Firebird 64 bits (installation package distribution upstream)
* outils Novaxel clients 32 bits (/opt/novaxel/novatools)
* moteur de script Novaxel (nscript)
* utilitaire de cryptographie Novaxel (crypto)
* les dépendances (lib 32 bits)
* outils pour synchronisation :
   * stunnel
   * rsync
* fichiers de configuration adaptés pour Firebird, rsync, stunnel
* certificat SSL autosigné (localhost)
* scripts Novaxel dédiés au contexte (synchronisation)
* udf Firebird nécessaire à la recherche fulltext

# Une image spécifique au serveur d'application : _novaxel/nas-server_
* source novaxel/firebird (ie. mêmes éléments que ci-dessus)
* le serveur d'application (/opt/novaxel/novaappserver) + dépendances libs 64 bits
* le client WEB actuel

C'est cette dernière image qui sera installée sur un poste de Développement...

# installation poste de Développement
Il s'agit donc de l'image *novaxel/nas-server*
* Prérequis :
   * installation de [_docker toolbox_](https://www.docker.com/toolbox)
   * Lancement de docker-machine
