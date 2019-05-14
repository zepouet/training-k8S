## Service Discovery


--------


### Objectifs

<br/>

Associer différentes informations <br/>
avec un nom facile à retenir



--------


### Service Discovery
#### Principe

Kubernetes supporte deux modes <br/>pour découvrir un service:
* Variables d'environment
* DNS


--------


### Service Discovery
#### Variables d'environment


Quand un pod tourne sur un noeud, la **kubelet** ajoute <br/>
un ensemble de variables d'environment <br/>
pour chaque Service actif

* {SVCNAME}_SERVICE_HOST
* {SVCNAME}_SERVICE_PORT



--------


### Service Discovery
#### Variables d'environment


Le Service **redis-master** <br/>
expose le **tcp/6379** <br/>
sur le **ClusterIP** en **10.0.0.11**

```
REDIS_MASTER_SERVICE_HOST=10.0.0.11
REDIS_MASTER_SERVICE_PORT=6379
REDIS_MASTER_PORT=tcp://10.0.0.11:6379
REDIS_MASTER_PORT_6379_TCP=tcp://10.0.0.11:6379
REDIS_MASTER_PORT_6379_TCP_PROTO=tcp
REDIS_MASTER_PORT_6379_TCP_PORT=6379
REDIS_MASTER_PORT_6379_TCP_ADDR=10.0.0.11
```


--------



### Service Discovery
#### Variables d'environment
##### Inconvénient

<br/>
* L'ordre de création POD / SVC compte


--------


### EXERCICE
#### Services / Discovery / ENV


--------



### DNS
#### Méthode conseillée


--------


### DNS
#### Principe

Ceci permet aux applications de communiquer facilement<br/>
les unes avec les autres lorsqu'un pod ou un service est :<br/>
* créé
* supprimé
* déplacé d'un noeud à l'autre


--------


### DNS
#### Principe

<br/>
Ce mécanisme est basé soit sur
* KubeDNS
* CoreDNS


--------


### Service Discovery

<img src="Slides/Img/Services/servicediscovery.png" width="500px" />



--------


### KUBE DNS
#### Service

<br/>
Le **kube-dns** service antérieur à **K8S 1.11** est composé
* 3 containers dans un même pod **kube-dns**
* Le pod tournant dans le **kube-system**


--------


### KUBE DNS
#### 3 containers
<br/>

* **kube-dns** : SkyDNS, which performs DNS query resolution
* **dnsmasq** : DNS resolver et cache des responses depuis SkyDNS
* **sidecar**: a sidecar container pour les metrics et la santé du service


--------

### KUBE DNS
#### 2 Problèmes
<br/>

* **Sécurité** : dnsmasq
* **Scaling** : SkyDNS


--------

### CORE DNS
#### Service

<br/>
Fixe de nombreuses issues de **kube-dns** et apporte en plus

* DNS-based round-robin load balancing
* Améliore les temps de réponse sur les résolutions externes
* Vérifie l'existence des pods dans les namespaces


--------


### CORE DNS
#### Service

<br/>
* Standard depuis la version K8S 1.11
* Production ready
* Un seul process Go
* Un seul process container


--------


### EXERCICE
#### Services / Discovery / DNS
