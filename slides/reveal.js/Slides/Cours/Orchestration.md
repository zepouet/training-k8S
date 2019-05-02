## Orchestration


--------


### Questions

- __Pod__
- __ReplicaSet__  
- __Deployement__
- __Service__


--------


#### Controller

Ils gèrent l'orchestration suivant les stratégies décidées pour maintenir et faire évoluer les fonctions applicatives
- Stratégie de placement
- Stratégie de mise à jour


--------


#### Scheduler et strategie


- Kubernetes fournit un orchestrateur : __kube-scheduler__.
- Possibilité d'implémenter des "customs" schedulers.
- Stratégie « Un (et un seul) Pod sur chaque nœud » : **DaemonSet**
- Stratégie « N copies, un Pod par nœud si possible » : **ReplicatSet** (et Replication Controller), **Deployment** ( via leur ReplicatSet)


--------


### Stratégie de placement par défaut

- Trouver là où il y a de la place sur des nœuds éligibles
- Répartir les pods correspondant à un même service sur plusieurs nœuds


--------


#### Stratégie node Selector

Au préalable, il faut labelliser les noeuds :

```
kubectl label nodes k8s-foo-node1 disktype=ssd
```

Puis on peut choisir où lancer le pod :

```
apiVersion: v1
kind: Pod
metadata:
  name: nginx
  labels:
    env: test
spec:
  containers:
  - name: nginx
    image: nginx
    imagePullPolicy: IfNotPresent
  nodeSelector:
    disktype: ssd
```


--------



#### Build-in node Labels

Labels pré-configurés mais **dépendant** de la plateforme.

```
kubernetes.io/hostname
failure-domain.beta.kubernetes.io/zone
failure-domain.beta.kubernetes.io/region
beta.kubernetes.io/instance-type
beta.kubernetes.io/os
beta.kubernetes.io/arch
```


--------


#### Deux types d'affinités

> Successeur de **nodeSelector**

* **node affinity**
* **inter-pod affinity/anti-affinity**


--------


#### Stratégie node affinity


> Plus expressif que **nodeSelector** sur base de **regexp**

* *requiredDuringSchedulingIgnoredDuringExecution* (hard)
* *preferredDuringSchedulingIgnoredDuringExecution* (soft)


--------


#### Stratégie node affinity


> Dans un futur plus ou moins proche

* *requiredDuringSchedulingRequiredDuringExecution* (hard)


--------


#### Exemple
```
apiVersion: v1
kind: Pod
metadata:
  name: with-node-affinity
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: kubernetes.io/e2e-az-name
            operator: In
            values:
            - Europa-North
            - Europa-South
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 1
        preference:
          matchExpressions:
          - key: disktype
            operator: In
            values:
            - ssd
  containers:
  - name: with-node-affinity
    image: k8s.gcr.io/pause:2.0
```


--------


#### Les opérateurs de nodeSelectorTerms

* In
* NotIn
* Exists
* DoesNotExist
* Gt
* Lt.

> Utiliser **NotIn** et **DoesNotExist** pour **anti-affinity**



--------


#### Règles de mix


> Si **nodeSelector** et **nodeAffinity** les deux doivent être **vrais**

> Si plusieurs **nodeSelectorTerms** avec **nodeAffinity** alors au moins un **nodeSelectorTerms** vrai

> Si plusieurs **matchExpressions** avec **nodeSelectorTerms** alors toutes les **matchExpressions** doivent être vraies


--------


#### __(Anti)Affinity__


> Un Pod peut être schédulé ou non sur un noeud en fonction des pods qui sont déjà présents ou non.

> topologyKey : clé du noeud que K8S utilisera pour définir une topologie des pods


--------


####  Exemple simple

> Pod sur la même zone mais sans avoir d'autres pods à côté avec le label **security=S1**

```
apiVersion: v1
kind: Pod
metadata:
  name: with-pod-affinity
spec:
  affinity:
    podAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
      - labelSelector:
          matchExpressions:
          - key: security
            operator: In
            values:
            - S1
        topologyKey: failure-domain.beta.kubernetes.io/zone
    podAntiAffinity:
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 100
        podAffinityTerm:
          labelSelector:
            matchExpressions:
            - key: security
              operator: In
              values:
              - S2
          topologyKey: kubernetes.io/hostname
  containers:
  - name: with-pod-affinity
    image: k8s.gcr.io/pause:2.0
```



--------


####  Exemple : colocation sur le même noeud // REDIS


> Chacun des trois réplicas redis doit se trouver sur un noeud différent

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: redis-cache
spec:
  selector:
    matchLabels:
      app: store
  replicas: 3
  template:
    metadata:
      labels:
        app: store
    spec:
      affinity:
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchExpressions:
              - key: app
                operator: In
                values:
                - store
            topologyKey: "kubernetes.io/hostname"
      containers:
      - name: redis-server
        image: redis:3.2-alpine
```


--------


####  Exemple : colocation sur le même noeud // WEBSERVER


> Chacun des trois réplicas des nginx doit être avec un unique REDIS


```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-server
spec:
  selector:
    matchLabels:
      app: web-store
  replicas: 3
  template:
    metadata:
      labels:
        app: web-store
    spec:
      affinity:
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchExpressions:
              - key: app
                operator: In
                values:
                - web-store
            topologyKey: "kubernetes.io/hostname"
        podAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchExpressions:
              - key: app
                operator: In
                values:
                - store
            topologyKey: "kubernetes.io/hostname"
      containers:
      - name: web-app
        image: nginx:1.12-alpine
```        


--------


### EXERCICE ORCHESTRATION


--------



### TAINTS & TolerationS


--------

#### Stratégie de placement de Pods : __Taints & Tolerations__

- Notion de boules puantes

- Une **Taint** permet à un noeud de refuser qu'un Pod soit schedulé si le pod ne possède les **Toleration** correpondantes

- **Taint** et **Toleration** consiste en une pair de Key/Value plus un "effect" (lorsque Key=Value)



--------


#### Stratégie de placement de Pods : __Taints & Tolerations__


Par exemple : on définit 3 "Taints" sur le Node 1 :

```
$ kubectl taint nodes node1 key1=value1:NoSchedule // "NoSchedule" = effect
$ kubectl taint nodes node1 key1=value1:NoExecute  // "NoExecute" = effect
$ kubectl taint nodes node1 key2=value2:NoSchedule
```


--------


#### Stratégie de placement de Pods : __Taints & Tolerations__

On définit pour un Pod les **Tolerations** suivantes :

```
tolerations:
- key: "key1"
  operator: "Equal"
  value: "value1"
  effect: "NoSchedule"
- key: "key1"
  operator: "Equal"
  value: "value1"
  effect: "NoExecute"
```

__Le Pod ne sera pas Schedulé__ car il n'y a pas de **Toleration** correpondant à la 3eme **Taint** du Noeud
