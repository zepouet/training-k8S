## Les principaux objets


--------


### Pods

<img src="Slides/Img/Architecture/pod.png" width="60%" />


--------


#### Pods

- La plus petite unité avec laquelle on peut travailler
- On doit respecter le pattern : "Un processus par container" même dans le cas d'un Pod
- Une unique IP au sein d'un Pod pour tous les containers
- Ils sont démarrés sur le même noeud
- Le nombre de containers au sein d'un pod ne peut être modifié après lancement
- Les containers peuvent discuter via IPC ou des FS partagés
- En général un pod contient un container sauf Sidecar Pattern
- Ils ne sont pas exposés par défaut


--------



#### Pods . Phase

- Pending : Requête accepté mais pod non encore créé
- Running : Le pod a été démarré sur un noeud avec au moins un container
- Succeeded : Tous les containers du pod sont bien démarrés
- Failed : Tous les containers du pod sont arrêtés avec a minima un container en échec
- Unknown : impossible de se connecter au pod pour lui demander son état



--------



#### Pods . Probe

- Elles remplacent les Healtcheck de docker
- Il existe deux types de sonde :
<br/>  - livenessProbe
<br/>  - readinessProbe
- Il existe trois types d'action
<br/>  - ExecAction
<br/>  - TcpSocketAction
<br/>  - HttpGetAction



--------



<img src="Slides/Img/Architecture/execActionProbe.png" width="80%" />



--------



<img src="Slides/Img/Architecture/tcpActionProbe.png" width="80%" />



--------



<img src="Slides/Img/Architecture/httpActionProbe.png" width="80%" />


--------



### EXERCICE
#### PODS



--------



### EXERCICE
#### LABELS



--------




### La réplication

- Pourquoi ?
- Comment ?


--------


#### A quoi sert la réplication avec K8S ?

- Reliability (fiabilité)
- Load balancing
- Scaling


--------


#### Dans quel cas ?


- Microservices-based applications
- Cloud native applications
- Mobile applications


--------


#### Les différents types de réplication avec K8S


- Replication Controller
- Replica Sets
- Deployments


--------


#### Overview

<img src="Slides/Img/objets/replicas.png" width="60%" />


--------



### Les ReplicaSets

- Les **ReplicaSets** permettent de dupliquer sur le cluster le pod en question
- Permet de maintenir l'état désiré dans le Cluster
- Doit être manipulé directement si l'on veut faire sa propre orchestration (déconseillé)



--------


#### ReplicationController // ReplicaSets


- Les ReplicaSet disposent de presque toutes les mêmes commandes que les ReplicationController
- Plus de possibilités avec les Selectors que les ReplicationController
- Ne permet d'utiliser la commande **rolling-update rc/...** qui est déclarative
- Il vaut mieux utiliser les **Deployment** pour configurer une réplication



--------



### EXERCICE
#### REPLICASETS



--------





#### Alternatives aux ReplicaSet

- Bare Pods : Equivant à revenir directement à "Docker run"
- Les Jobs pour les tâches qui doivent se terminer
- Les DaemonSets : chapitre à venir
- Les Deployment : chapitre à venir



--------


### Les Deployments

- On utilise désormais l'objet **Deployment** plutôt que **ReplicaSet**
- **Attention** ceci s'applique aux applications StateLess
- Un **Deployment** fournit à la fois la déclaration implicite des Pods et des ReplicaSets


<img src="Slides/Img/Architecture/deployments.png" width="50%" />


--------


<img src="Slides/Img/Architecture/deployments.yaml.png" />



--------



### EXERCICE
#### DEPLOYMENTS
