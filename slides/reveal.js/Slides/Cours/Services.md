## Les différents services

> L'objet Service peut être vu naïvement comme un LoadBalancer entre pods

>Il s'agit surtout de proposer plusieurs points d'accès en fonction du type de ressource.


--------


#### Trois types différents

- ClusterIP
- NodePort
- LoadBalancer

Ainsi que la notion de *Ingress*



--------


### ClusterIP

> Type par défaut

> Une IP virtuelle est fourni par K8S pour l'accès entre Pods


--------



<img src="Slides/Img/Services/clusterIp.yaml.png" />



--------


<img src="Slides/Img/Services/clusterIp.png" width="40%" />



--------


#### Cluster IP

- Pas d'accès externe. Uniquement interne
- Accessible via un ReverseProxy **kube-proxy**

> kubectl proxy --port=8080



--------


#### Accès via kube-proxy

<p>
 http://localhost:8080/api/v1/proxy/namespaces/<NAMESPACE>/services/<SERVICE-NAME>:<PORT-NAME>/
<p/>

<p>
 http://localhost:8080/api/v1/proxy/namespaces/default/services/my-internal-service:http/
</p>


--------


#### Quand utiliser Kube Proxy ?


- Debugger des services directement depuis votre poste
- Autoriser des traffics externes (Client Mysql...)
- Afficher des dashboards internes
- Attention à ne pas exposer sur Internet !


--------


### NodePort


--------


## Traffic extérieur


> Approche la plus basique pour exposer un pod vers l'extérieur.

Ouvre un port sur tous les nodes


--------



<img src="Slides/Img/Services/nodeport.png" width="40%" />



--------



<img src="Slides/Img/Services/nodeport.yaml.png" />



--------


#### Champ spécifique

- **nodePort** est optionnel
- Il permet de choisir le port à exposer
- Il est conseillé de laisser K8S le fixer lui-même


--------


#### Inconvénients de NodePort

- Seulement un accès d'un service pour un port donné
- Plage restreinte de 30000 à 32767
- Si les IPs de vos nodes changent, vous devez gérer ceci en amont 


--------


#### Cas d'usage de NodePort

> Usage possible mais peu recommandé en production

- Utile pour des demos
- Potentiellement utilisable avec un ReverseProxy type Traefik


--------

### LoadBalancer


--------

<img src="Slides/Img/Services/loadbalancer.png" width="40%" />


--------


#### Cas d'usage de LoadBalancer

> Exposer directement un service sur Internet

- Tout le traffic sera redirigé vers le service
- Pas de filtering, routing...
- Tout type de traffic est routé : HTTP, gRPC, UDP, WebSocket...
- S'utilise avec les Cloud providers

--------


#### Inconvénients de LoadBalancer

> Le coût sur le Cloud Public

- Chaque service va exposer un Load Balancer avec sa propre IP
- https://cloud.google.com/compute/docs/load-balancing/network/.


--------

#### Service avec Selecteur

- Il permet de renvoyer le trafic vers un ensemble de pods présents dans le même namespace.
- L’identification des pods vers lesquels diriger le trafic est basée sur des labels et des sélecteurs.

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


#### Service sans Selecteur

Il permet de renvoyer le trafic vers des pods présents dans un autre namespace ou vers des services extérieurs au cluster K8S.

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

- Un service headless consiste à désactiver le clusterIP.
- La résolution DNS interne renverra l’adresse IP de chaque pod.
- Ce type de service est principalement utilisé pour demander au serveur DNS interne de Kubernetes de renvoyer l’adresse IP des pods à la place d’une IP de loadbalancer.

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


--------


### Ingress

#### PAS UN SERVICE MAIS...


--------


<img src="Slides/Img/Services/ingress-wall.png" width="60%" />


--------


<img src="Slides/Img/Services/ingress.png" width="70%" />



--------


> SMART ROUTER

- Il gère les entrypoints pour votre cluster
- Il existe de nombreux Ingress Controller
- Par défaut GKE démarrera un HTPP(s) Load Balancer


--------


<img src="Slides/Img/Services/ingress.yaml.png" width="80%" />



--------


#### Cas d'usage de Ingress

> Le plus puissant mais le plus compliqué

- Volonté d'exposer différents services sous la même IP
- Nécessité d'utiliser le même protocole L7 (typiquement HTTP)
- Ne payer qu'un seul LoadBalancer sur GKE tout en profitant avec Nginx de SSL, Auth, Routing...
- Peut devenir un point de contention // LoadBalancer en option précédente.


--------


### EXERCICE SERVICES


--------



### DEMO

<p>
  https://github.com/sozu-proxy/sozu-demo/tree/master/kubernetes-using-tube-cheese
</p>
