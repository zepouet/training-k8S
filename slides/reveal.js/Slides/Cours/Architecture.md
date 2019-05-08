## Architecture


--------


### Notions clés

<br/>
- Noeuds
- Cluster
- Les deux Modes
- Les différents composants

--------


### Noeuds


<img src="Slides/Img/Services/nodes.png" width="50%" />


--------


### Noeuds

<br/>
- La plus petite unité **physique** de calcul
- Peut-être aussi bien :
<br/> - Une machine bare-metal
<br/> - Une machine virtuelle dans une datacenter (GKE...)
<br/> - Une RaspberryPI


--------


### Cluster


<img src="Slides/Img/Architecture/cluster.png" width="50%" />


--------


### Mode
#### Déclaratif

<br/>
- On décrit le **quoi**, pas le **comment** (impératif)
- Kubernetes est un système où l'on définit l'état désiré d'un objet
- Quelles applications doivent être démarrées...
- Sur quels noeuds ses applications doivent être démarrées
- Quelle politique doit être appliqué à ses applications
- Quelles port de mon application doit être utilisé
- La commande **apply** en particulier


--------


### Mode
#### Impératif

<br/>
- On décrit le **comment**, pas le **quoi** (déclaratif)
- Les commandes
<br/> - create
<br/> - delete
<br/> - update


--------


### architecture
#### interne
<br/>
<img src="Slides/Img/Presentation_de_k8s/5_2_k8s_architecture.png" width="600px" />


--------


<img src="Slides/Img/Presentation_de_k8s/architecture.png" width="80%" />



--------


### Composants
#### API SERVER
<br/>
- Point central de toutes les actions sur le cluster Kubernetes
- Tous les appels internes et externes passent ici
- Toutes les actions sont validés avant d'être exécutés
- Seul composant qui écrit dans la base ETCD
- Processus maître du cluster qui nécessite aussi d'être loadbalancé


--------


### Composants
#### KUBE SCHEDULER
<br/>
- Détermine quel pod doit tourner sur quel noeud en fonction des ressources
- Capable d'attendre et de retenter l'affectation dans le temps (disponibilité de volumes par exemple)


--------

### Composants
#### KUBE CONTROLLER MANAGER
<br/>
- Daemon fonctionnant en boucle infini qui interagit avec l'API-SERVER pour déterminer l'état du cluster
- Si l'état n'est pas celui souhaité, ce contrôleur va contacter le contrôleur adéquate
- Il existe de nombreux contrôleurs : EndPoint, Replication... Namespace...


--------

### Composants
#### WORKER Node

<br/>
- Précédemment appelé Minion
- Ce sont les noeuds applicatifs
- Ils contiennent tous une **kubelet** et un **kube-proxy**
- Le **kubelet** pilote Docker ou RKT
- Le **kube-Proxy** est en charge de gérer la connection aux réseaux



--------


### Composants
#### Kubelet
<br/>
- Responsable des changements d'état et de la configuration des noeuds WORKER
- Il accepte les requêtes au format YAML ou JSON respectant la spécification PodSpec
- Assure la création et l'accès aux pods pour les objets de type Storage, Secrets et ConfigMaps
