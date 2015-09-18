# Images Docker pour Serveur d'application Firebird

Ce projet contient 2 images :
- Une image de base : novaxel/firebird (source ubuntu:latest) qui embarque :
-- serveur(+ utilitaires clients) Firebird 64 bits (installation package distribution upstream)
-- outils Novaxel clients 32 bits (/opt/novaxel/novatools)
--- moteur de script (nscript)
--- utilitaire de cryptographie (crypto)
--- les dépendances (lib 32 bits) 
-- outils pour synchronisation :
--- stunnel
--- rsync (mode daemon)
-- fichiers de configuration adaptés pour Firebird, rsync, stunnel
-- certificat SSL autosigné (localhost)
-- scripts Novaxel dédiés au contexte (synchronisation)
-- udf Firebird nécessaire à la recherche fulltext

- une image spécifique au serveur d'application : novaxel/nas-serveur (source novaxel/firebird) qui embarque
-- les mêmes éléments que l'image de base (serveur Firebird dédié au base domaine/event)
-- le serveur d'application (/opt/novaxel/novaappserver) + dépendances libs 64 bits
-- le client WEB
-- 
