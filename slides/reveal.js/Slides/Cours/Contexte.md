## Contexte


--------


### Objectifs


- Rappel Containers
- Différences entre les VMs et les conteneurs
- Bienfaits des conteneurs pour votre SI
- Principes de l'orchestration


--------


### Questions
<br/>
#### Qui a déjà utilisé Docker ?


--------


### Questions
<br/>
#### Qui a déjà utilisé K8S ?



--------



### Différences VM / Conteneurs


--------


#### Serveur physique


<img src="Slides/Img/Contexte/physique.png" width="480px" />


--------


#### Serveur physique


<br/>
- Temps de déploiements peuvent être longs
- Coûts peuvent être élevés
- Beaucoup de ressources perdues
- Difficultés à mettre à l'échelle pour de la haute disponibilité
- Complexité de migration


--------


#### Virtualisation

<img src="Slides/Img/Contexte/vm.png" width="480px" />


--------


#### Virtualisation
##### Avantages
<br/>

- Un serveur physique est divisé en plusieurs machines virtuelles
- Plus facile à mettre à l'échelle qu'un serveur physique
- Modèle de Cloud et paiement à la demande (AWS, Azure, Rackspace..)
- Chaque application tourne dans une machine virtuelle


--------


#### Virtualisation
##### Inconvénients


- Chaque VM nécessite une allocation de CPU, de stockage dédié, de RAM et un OS complet
- Modèle linéaire: l'augmentation du nombre de VM nécessite des ressource supplémentaires
- L'utilisation d'un système hôte complet entraîne une surcharge
- La portabilité des applications n'est toujours pas garantie


--------


#### containers
##### Historique

<br/>
- UNIX chroot (1979-1982)
- BSD Jail (1998)
- Parallels Virtuozzo (2001)
- Solaris Containers (2005)
- Linux LXC (2008)
- Docker (2013)


--------


#### containers
##### Docker

<br/>
* Evolution de LXC à ses débuts
* Implémentation runC
* Client convivial


--------


### Questions
<br/>
#### Donner une définition<br/> d'un container


--------


#### containers
##### Principe

<br/>
* Utilise le kernel du système hôte pour démarrer de multiples systèmes de fichiers racine
* Chaque système de fichier racine est appelé container
* Chaque container possède ses propres processus, mémoires, carte réseau



--------


#### containers
##### Principe


<img src="Slides/Img/Contexte/container.png" width="480px" />



--------


#### Containers
##### Pourquoi les utiliser ?
<br/>
- Plus légers et rapides que les VMs
- Pas besoin d'installer un système d'exploitation complet
- Besoins en CPU, RAM et stockage sont moins contraignants
- Meilleure portabilité
- Architecture Microservices


--------


#### Containers
##### Cycle de vie basique

<br/>
* Création d'un container à partir d'une image
* Démarrage d'un container avec un processus
* Le processus se termine et le container s'arrête
* Le container est détruit


--------


#### Containers
##### Orchestration


<img src="Slides/Img/Contexte/orchestration.png" width="600px" />


--------


#### Containers
##### Orchestration outils


<img src="Slides/Img/Contexte/outils.png" width="480px" />



--------


#### La mission de docker


<img src="Slides/Img/Evolutions_de_la_virtualisation_et_des_applications/3_10_Mission_docker.png" width="800px" />


--------



### Docker
&
#### Le noyau Linux



--------


#### NAMESPACES
<br/>
- Introduit en Kernel 2.4.19 en 2002
- Réellement utilisable en 2006
- Stable depuis 3.8 avec les *User namespaces*


--------


#### NAMESPACES
##### Principaux
<br/>
- Mount
- Process
- Network
- UTS
- IPC
- User
- Control Group


--------


#### Control GROUP
<br/>
* Introduit en 2016 avec le Kernel 4.6
* Mesurer et limiter les ressources (RAM, CPU, block I/O, network)
* Donner l'accès au différents périphériques (/dev/)


--------


#### IPTABLES
<br/>
* Assurer la communication entre containers sur le même hôte
* Assurer d'éventuelles communication entre les containers et l'extérieur


--------


#### Applications modernes
##### Architecture micro-services

<img src="Slides/Img/Evolutions_de_la_virtualisation_et_des_applications/3_13_Microservices.png" />
