## Services


--------


### Definition

<br/>
```text
L'objet Service peut être vu naïvement comme un LoadBalancer entre pods.
```


--------


### Différents types

- ClusterIP
- NodePort
- LoadBalancer
- ExternalName

<br/>
* *Ingress* n'est pas un Service au sens K8S
* L'objet **EndPoint** sera vu par contre


--------


### ClusterIP
#### Type par défaut

<br/>
> Une IP virtuelle est fournie<br/>
> par K8S pour l'accès entre Pods


--------


<img src="Slides/Img/Services/clusterIp.png" width="40%" />



--------


<img src="Slides/Img/Services/clusterIp.yaml.png" />



--------


#### Cluster IP

<br/>
- Pas d'accès externe. Uniquement interne
- Accessible via un ReverseProxy **port-forward**

<br/>
```shell
kubectl port-forward
        svc/my-internal-service 8080:80
```


--------


#### Quand utiliser port-forward ?

<br/>
- Debugger des services directement depuis votre poste
- Autoriser des traffics externes (Client Mysql...)
- Afficher des dashboards internes
- Attention à ne pas exposer sur Internet !


--------



### NodePort
#### Traffic extérieur


> Approche la plus basique pour exposer un pod vers l'extérieur.

<br/>
* Se marie bien avec un F5 par exemple
* Ouvre un port sur tous les nodes



--------



<img src="Slides/Img/Services/nodeport.png" width="40%" />



--------



<img src="Slides/Img/Services/nodeport.yaml.png" />



--------

### NodePort
#### Spécificités

<br/>
- Champs **nodePort** est optionnel
- Permet de choisir le port à exposer
- Conseillé de laisser K8S le fixer lui-même
- Un **ClusterIP** est créé automatiquement



--------


### NodePort
#### Cas d'usage
<br/>

> Peu recommandé en production

- Devrait se trouver derrière un F5
- Utilisable avec un ReverseProxy type **Traefik**



--------


### NodePort
#### Inconvénients

<br/>
- Seulement un accès d'un service pour un port donné
- Plage restreinte de 30000 à 32767
- Si les IPs de vos nodes changent, vous devez gérer ceci en amont


--------


### LoadBalancer


<br/>
> Exposer directement un service sur Internet


--------

<img src="Slides/Img/Services/loadbalancer.png" width="40%" />


--------


### LoadBalancer
#### Spécificités
<br/>
* Création automatique **NodePort** et **ClusterIP**
* Disponible *de facto* sur les Cloud provider
* Doit s'installer indépendamment on-premise (Metal LB) https://metallb.universe.tf/



--------



### LoadBalancer
#### Avantages


<br/>
- Tout le traffic sera redirigé vers le service
- Gère la charge dynamiquement
- Gestion de la sécurité (WAF)
- Gère tout type de traffic : HTTP, gRPC, UDP, WebSocket...


--------


### LoadBalancer
#### Inconvénients

<br/>
> Le coût sur le Cloud Public

<br/>
- Chaque service va exposer un LoadBalancer avec sa propre IP
- Attention si les noeuds sont publics aux accès direct **NodePort**



--------


### External Name
#### Résolution DNS

<br/>
```
kind: Service
apiVersion: v1
metadata:
  name: my-service
  namespace: prod
spec:
  type: ExternalName
  externalName: my.database.example.com
```


--------


### Propriétés des services
#### Service avec Selecteur

<br/>
- Permet de renvoyer le trafic vers un ensemble de pods présents dans le même namespace.
- Identification des pods vers lesquels diriger le trafic est basée sur des labels et des sélecteurs.


--------


### nodePort
#### Exemple

<br/>
~~~
apiVersion: v1
kind: Service
metadata:
  name: nginx
spec:
  type: NodePort
  selector:
    app: nginx
    version: red
  ports:
    - port: 80
    targetPort: 80
~~~


--------


### EndPoint
#### Définition
<br/>

> Abstraction d'un ensemble de ressources internes <br/>ou externes au cluster avec respect de **policy**

<br/>
Le **EndPoint** n'utilise pas les sélecteurs <br/>de labels contrairement aux **Service**


--------


### EndPoint
#### Service sans Selecteur


~~~
apiVersion: v1
kind: Service
metadata:
  name: ws-external
spec:  
  ports:
    - port: 80
    targetPort: 80
---
apiVersion: v1
kind: Endpoints
metadata:
  name: ws-external
subsets:
  addresses:
    - ip: xxx.xxx.xxx.xxx
    ports:
      - port: 80   
~~~


--------


#### Service Headless

- Un service headless consiste à désactiver le clusterIP (**None**)
- La résolution DNS interne renverra l’adresse IP de chaque pod
- Utilisé pour demander au serveur DNS interne de Kubernetes de renvoyer l’adresse IP des pods à la place d’une IP de loadbalancer (Besoin d'un LB applicatif )

~~~
apiVersion: v1
kind: Service
metadata:
  name: pgpool
spec:  
  ports:
    - name: pg
      port: 1234
    ClusterIP: None
    selector:
      app: pgpool
~~~
