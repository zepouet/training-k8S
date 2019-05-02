## Contexte historique


--------


### Objectifs

- Techniquement ce qu'est la containerisation
- Bienfaits des conteneurs pour votre SI
- Différences entre les VMs et les conteneurs


--------


## Evolution de la virtualisation et des applications


--------

#### Serveur physique

De manière historique, le serveur physique était la plateforme de référence pour le déploiement d'une application. Certaines limites sur ce modèle sont apparues et ont été identifiées:

- Les temps de déploiements peuvent être longs
- Les coûts peuvent être élevés
- Beaucoup de ressources perdues
- Difficultés à mettre à l'échelle pour de la haute disponibilité
- Complexité de migration


--------


#### Représentation d'une application sur serveur physique


###### ![Application](Slides/Img/Evolutions_de_la_virtualisation_et_des_applications/3_4_Application.png)


--------


#### Virtualisation basée sur hyperviseur


- Un serveur physique peut héberger plusieurs applications distinctes
- Chaque application tourne dans une machine virtuelle

###### ![Hyperviseur](Slides/Img/Evolutions_de_la_virtualisation_et_des_applications/3_5_Hyperviseur.png)


--------


#### Avantages du modèle de machine virtuelle

- Un serveur physique est divisé en plusieurs machines virtuelles
- Plus facile à mettre à l'échelle qu'un serveur physique
- Modèle de Cloud et paiement à la demande (AWS, Azure, Rackspace..)


--------


#### Limitations du modèle de machine virtuelle


- Chaque VM nécessite une allocation de CPU, de stockage dédié, de RAM et un OS complet
- Modèle linéaire: l'augmentation du nombre de VM nécessite des ressource supplémentaires
- L'utilisation d'un système hôte complet entraîne une surcharge
- La portabilité des applications n'est toujours pas garantie


--------


#### Historique du modèle d’isolation de processus


- UNIX chroot (1979-1982)
- BSD Jail (1998)
- Parallels Virtuozzo (2001)
- Solaris Containers (2005)
- Linux LXC (2008)
- Docker (2013)

Docker est une évolution de LXC qui a permis de rendre le container utilisable par un plus grand nombre d'utilisateurs grâce à son API et son client convivial.


--------


- La containerisation utilise le kernel du système hôte pour démarrer de multiples systèmes de fichiers racine
- Chaque système de fichier racine est appelé container
- Chaque container possède ses propres processus, mémoires, carte réseau

###### ![img](Slides/Img/Evolutions_de_la_virtualisation_et_des_applications/3_8_Virtu_appli.png)


--------


#### Pourquoi utiliser les containers ?

- Les containers sont plus légers et rapides que les VMs
- Pas besoin d'installer un système d'exploitation complet
- En conséquence, les besoins en CPU, RAM et stockage sont moins contraignants
- On peut faire tourner bien plus de containers sur un serveur que de VMs
- Le concept assure une meilleure portabilité
- Les containers représentent une meilleure solution pour développer et déployer des applications microservices


--------


###### ![img](Slides/Img/Evolutions_de_la_virtualisation_et_des_applications/3_9_Docker_bouteille.png)


--------


#### La mission de docker

###### ![img](Slides/Img/Evolutions_de_la_virtualisation_et_des_applications/3_10_Mission_docker.png)


--------


### Docker et le noyau Linux


--------

#### NAMESPACES

- l'isolation des processus et du système de fichier
- l'isolation réseau et de disposer de ses propre interfaces


--------

#### CGROUPS

- de mesurer et limiter les ressources (RAM, CPU, block I/O, network)
- de donner l'accès au différents périphériques (/dev/)


--------

#### IPTABLES

- d'assurer la communication entre containers sur le même hôte
- d'assurer d'éventuelles communication entre les containers et l'extérieur


--------


#### Le cycle de vie d'un container diffère de celui d'une VM


A l'opposé d'une VM, le conteneur n'est pas destiné à une existence perpétuelle.
L'orchestrateur se chargera de redémarrer le container sur un autre hôte en cas de défaillance.

Cycle de vie basique d'un container:
- Création d'un container à partir d'une image
- Démarrage d'un container avec un processus
- Le processus se termine et le container s'arrête
- Le container est détruit


--------


#### Applications modernes: architecture micro services

Une architecture microservices est un ensemble complexe d'applications décomposé en plusieurs processus indépendants et faiblement couplés.

Ces processus communiquent les uns avec les autres en utilisant des API.
L'API REST est souvent employée pour relier chaque microservice aux autres.


--------

###### ![Microservices](Slides/Img/Evolutions_de_la_virtualisation_et_des_applications/3_13_Microservices.png)
