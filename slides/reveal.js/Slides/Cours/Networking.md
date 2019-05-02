## Network Policies et Kubernetes


--------


## Rappel sur les Namespaces

- Scope de travail pour les objets Kubernetes
- Assimilable à un environnement de travail
- Evite les collisions de noms
- QoS sur le namespace concerné


--------


### EXERCICE NAMESPACES



--------



## Network Policies

### Introduction

- Non actif par défaut
- Depuis la version 1.7 de Kubernetes
- ACL entre pods
- Application en temps réel (avec peu d'impact sur la performance)

Note:
Network Policies is a new Kubernetes feature to configure how groups of pods are allowed to communicate with each other and other network endpoints
In other words, it creates firewalls between pods running on a Kubernetes cluster. This guide is meant to explain the unwritten parts of Kubernetes Network Policies.



--------


## Network Policies

### Cas d'utilisation Simple

- DENY all : refuser tout le trafic vers une application
- LIMIT : limiter le trafic vers une application
- ALLOW all : autoriser tout le trafic vers une application


--------


## Network Policies

### Cas d'utilisation : DENY all

###### ![Deny_all](Slides/Img/Network_Policies/7_1_deny.gif)


--------



## Deny All
<div class="exercice"></div>

- Lancer un pod nginx écoutant sur la port 80 :

~~~bash
kubectl run web --image=nginx --labels app=bibliotheque --expose --port 80
~~~

- Lancer un pod alpine pour tester la connexion avec le premier pod

~~~bash
kubectl run --rm -i -t --image=alpine test-$RANDOM -- sh
/ # wget -qO- http://web
~~~

Note:
En cas de bug avec les images faire un docker pull avant


--------


## Deny All (2/3)
<div class="exercice"></div>

- Créer un fichier `web-deny-all.yaml`

~~~yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-ingress
  namespace: advanced-policy-demo
spec:
  podSelector:
    matchLabels: {}
  policyTypes:
  - Ingress
~~~

- Appliquer la configuration

~~~bash
kubectl apply -f web-deny-all.yaml
~~~


--------


## Deny All (3/3)
<div class="exercice"></div>

- Tester la connexion

~~~bash
kubectl run test-$RANDOM --rm -i -t --image=alpine -- sh
/ # wget -qO- --timeout=10 http://web
~~~

- Nettoyer l'environnement

~~~yaml
kubectl delete deploy web
kubectl delete service web
kubectl delete networkpolicy web-deny-all
~~~


--------


## Network Policies

### Cas d'utilisation : LIMIT

###### ![limit](Slides/Img/Network_Policies/7_2_limit.png)


--------


## Limit
<div class="exercice"></div>

- Lancer une application

~~~yaml
kubectl run apiserver --image=nginx --labels app=bibliotheque,role=api --expose --port 80
~~~

- Créer une Network policy `api-allow.yaml`

~~~yaml
kind: NetworkPolicy
apiVersion: networking.k8s.io/v1
metadata:
  name: api-allow
spec:
  podSelector:
    matchLabels:
      app: bibliotheque
      role: api
  ingress:
  - from:
      - podSelector:
          matchLabels:
            app: bibliotheque
~~~

- Appliquer la configuration

~~~bash
kubectl apply -f api-allow.yaml
~~~


--------


## Limit (2/3)
<div class="exercice"></div>

- Tester la connexion

~~~bash
kubectl run test-$RANDOM --rm -i -t --image=alpine -- sh
/ # wget -qO- --timeout=10 http://apiserver
~~~

- Tester la connexion avec les bons paramètres

~~~bash
kubectl run test-$RANDOM --rm -i -t --image=alpine --labels app=bibliotheque,role=front -- sh
/ # wget -qO- --timeout=2 http://apiserver
~~~


--------


## Limit (3/3)
<div class="exercice"></div>


- Nettoyer l'environnement

~~~yaml
kubectl delete deployment apiserver
kubectl delete service apiserver
kubectl delete networkpolicy api-allow
~~~


--------


## Network Policies

### Cas d'utilisation : ALLOW all

###### ![allow_all](Slides/Img/Network_Policies/7_3_Allow_all.png)


--------


## Network Policies

### Cas d'utilisation sur les Namespaces

- DENY all non-whitelisted traffic in the current namespace
- DENY all traffic from other namespaces (a.k.a. LIMIT access to the current namespace)
- ALLOW traffic to an application from all namespaces
- ALLOW all traffic from a namespace


--------


## ALLOW all
<div class="exercice"></div>

- Lancer une application

~~~yaml
kubectl run web --image=nginx --labels=app=web --expose --port 80
~~~

- Créer une Network policy `web-allow-all.yaml`

~~~yaml
kind: NetworkPolicy
apiVersion: networking.k8s.io/v1
metadata:
  name: web-allow-all
  namespace: default
spec:
  podSelector:
    matchLabels:
      app: web
  ingress:
  - {}
~~~

- Appliquer la configuration

~~~bash
kubectl apply -f web-allow-all.yaml
~~~


--------


## ALLOW all (2/2)
<div class="exercice"></div>

- Tester la connexion

~~~bash
kubectl run test-$RANDOM --rm -i -t --image=alpine --labels app=whitelisted -- sh
/ # wget -qO- --timeout=2 http://web
~~~

- Nettoyer l'environnement

~~~bash
kubectl delete deployment,service web
kubectl delete networkpolicy web-allow-all web-deny-all
~~~


--------


## Network Policies

### Namespaces : DENY all non-whitelisted

###### ![deny_all_namespace](Slides/Img/Network_Policies/7_3_deny_all_namespace.png)


--------


## DENY all non-whitelisted
<div class="exercice"></div>

- Lancer une application

~~~yaml
kubectl run web --image=nginx --labels=app=web --expose --port 80
~~~

- Créer une Network policy `web-allow-whitelisted.yaml`

~~~yaml
kind: NetworkPolicy
apiVersion: networking.k8s.io/v1
metadata:
  name: web-allow-all
  namespace: default
spec:
  podSelector:
    matchLabels:
      app: web
  ingress:
    - from:
      - podSelector:
          matchLabels:
            app: whitelisted
~~~

- Appliquer la configuration

~~~bash
kubectl apply -f web-allow-whitelisted.yaml
~~~


--------

## DENY all non-whitelisted (2/3)
<div class="exercice"></div>

- Tester la connexion avec les bons paramètres

~~~bash
kubectl run test-$RANDOM --rm -i -t --image=alpine --labels app=whitelisted -- sh
/ # wget -qO- --timeout=2 http://web

kubectl run test-$RANDOM --rm -i -t --image=alpine -- sh
/ # wget -qO- --timeout=2 http://web
~~~


--------

## DENY all non-whitelisted (3/3)
<div class="exercice"></div>

- Nettoyer l'environnement

~~~bash
kubectl delete deployment,service web
kubectl delete networkpolicy web-allow-all
~~~


--------


## Network Policies

### Namespaces : DENY all other namespaces

###### ![deny_from_other_namespace](Slides/Img/Network_Policies/7_4_deny_from_other_namespace.png)


--------


## DENY all other
<div class="exercice"></div>

- Création d'un second namespace

~~~bash
kubectl create namespace foo
kubectl create namespace bar

kubectl run web --namespace foo --image=nginx --labels=app=web --expose --port 80
~~~


--------


## DENY all other (2/3) BUGS
<div class="exercice"></div>

- Créer une configuration `deny-from-other-namespaces.yaml`

~~~yaml
kind: NetworkPolicy
apiVersion: networking.k8s.io/v1
metadata:
  namespace: foo
  name: deny-from-other-namespaces
spec:
  podSelector:
    matchLabels:
  ingress:
    - from:
      - podSelector:
          matchLabels: {}
~~~

- Appliquer la configuration

~~~bash
kubectl apply -f deny-from-other-namespaces.yaml
~~~


--------


## DENY all other (3/3)
<div class="exercice"></div>

- Tester la connexion

~~~bash
kubectl run test-$RANDOM --namespace=default --rm -i -t --image=alpine -- sh
/ # wget -qO- --timeout=2 http://web.foo


kubectl run test-$RANDOM --namespace=foo --rm -i -t --image=alpine -- sh
/ # wget -qO- --timeout=2 http://web.foo
/ # wget -qO- --timeout=2 http://web


kubectl run test-$RANDOM --namespace=bar --rm -i -t --image=alpine -- sh
/ # wget -qO- --timeout=2 http://web.foo
~~~

- Nettoyer :

~~~bash
kubectl delete deployment web -n foo
kubectl delete service web -n foo
kubectl delete networkpolicy deny-from-other-namespaces -n foo
kubectl delete namespace foo
kubectl delete namespace bar
~~~


--------


## Network Policies

### Namespaces : Allow from other Namespaces

###### ![allow_all_to_app](Slides/Img/Network_Policies/7_5_allow_all_to_app.png)



--------


## Allow from other
<div class="exercice"></div>

- Création d'un second namespace

~~~bash
kubectl create namespace foo
kubectl create namespace bar

kubectl run web --namespace default --image=nginx --labels=app=web --expose --port 80
kubectl run web2 --namespace default --image=nginx --labels=app=web2 --expose --port 80
~~~


--------


## Allow from other (2/3)
<div class="exercice"></div>

- Créer une configuration `web-allow-all-namespaces.yaml`

~~~yaml
kind: NetworkPolicy
apiVersion: networking.k8s.io/v1
metadata:
  namespace: foo
  name: web-allow-all-namespaces
spec:
  podSelector:
    matchLabels:
      app: web
  ingress:
  - from:
    - namespaceSelector: {}
~~~

- Appliquer la configuration

~~~bash
kubectl apply -f deny-from-other-namespaces.yaml
kubectl apply -f web-allow-all-namespaces.yaml
~~~


--------


## Allow from other (3/3)
<div class="exercice"></div>

- Tester la connexion

~~~bash
kubectl run test-$RANDOM --namespace=bar --rm -i -t --image=alpine -- sh
/ # wget -qO- --timeout=2 http://web.foo
/ # wget -qO- --timeout=2 http://web2.foo
~~~

- Nettoyer :

~~~bash
kubectl delete deployment,service web -n foo
kubectl delete deployment,service web2 -n foo
kubectl delete networkpolicy web-allow-all-namespaces -n foo
kubectl delete namespace foo
kubectl delete namespace bar
~~~


--------


## Network Policies

### Namespaces : Allow from a namespace

###### ![allow_from_namespace](Slides/Img/Network_Policies/7_6_allow_from_namespace.png)


--------


## Autorisation depuis un namespace
<div class="exercice"></div>

- Création  de 2 namesapces et d'un pod nginx

~~~bash
kubectl create namespace dev
kubectl create namespace prod

kubectl run web --namespace default --image=nginx --labels=app=web --expose --port 80
~~~

- Ajout d'un label sur les namespaces

~~~bash
kubectl label namespace/dev purpose=testing
kubectl label namespace/prod purpose=production
~~~


--------


## Autorisation depuis un namesapce (2/3)
<div class="exercice"></div>

- Création d'un fichier `web-allow-prod.yaml`

~~~yaml
kind: NetworkPolicy
apiVersion: networking.k8s.io/v1
metadata:
  name: web-allow-prod
spec:
  podSelector:
    matchLabels:
      app: web
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          purpose: production
~~~

- Appliquer la configuration

~~~bash
kubectl apply -f web-allow-prod.yaml
~~~


--------


## Autorisation depuis un namesapce (3/3)
<div class="exercice"></div>

- Tester l'accès depuis le namespace de dev :

~~~bash
kubectl run test-$RANDOM --namespace=dev --rm -i -t --image=alpine -- sh
/ # wget -qO- --timeout=2 http://web.default
~~~

- Tester l'accès depuis le namespace de prod :

~~~bash
kubectl run test-$RANDOM --namespace=prod --rm -i -t --image=alpine -- sh
/ # wget -qO- --timeout=2 http://web.default
~~~

- Nettoyage

~~~bash
kubectl delete networkpolicy web-allow-prod
kubectl delete deployment,service web
kubectl delete namespace {prod,dev}
~~~


--------


## Network Policies

### Cas d'utilisation particulier

- External
- Autorisation sur un port particulier
- Multiple sélection


--------


## Network Policies

### External

###### ![external_policy](Slides/Img/Network_Policies/7_8_external.png)


--------


## Filtrage d'accès depuis l'extérieur
<div class="exercice"></div>

- Création d'un pod nginx

~~~bash
kubectl run web --namespace default --image=nginx --labels=app=web --expose --port 80
kubectl run test-nginx --namespace default --image=nginx --labels=app=test-nginx --expose --port 80
~~~

- Exposition du pod nginx à l'extérieur et attrendre l'obtention de l'ip public

~~~bash
## erreur
## kubectl expose deployment/web --type=LoadBalancer
## watch kubectl get service

#temp :
kubectl port-forward web-669c8bff75-nw4fc 8081:80
~~~


--------


## Filtrage d'accès depuis l'extérieur (2/4)
<div class="exercice"></div>

- Création d'un fichier `web-allow-external.yaml`

~~~yaml
kind: NetworkPolicy
apiVersion: networking.k8s.io/v1
metadata:
  name: web-allow-external
spec:
  podSelector:
    matchLabels:
      app: web
  ingress:
  - from: []
~~~

- Appliquer la configuration de restriction d'accès complète et l'autorisastion d'accès au pod nginx

~~~bash
kubectl apply -f default-deny-all.yaml
kubectl apply -f web-allow-external.yaml
~~~


--------


## Filtrage d'accès depuis l'extérieur (3/4)
<div class="exercice"></div>

- Test d'accès http://EXTERNAL-IP

- Test depuis les autres pods

~~~bash
kubectl run test-$RANDOM --rm -i -t --image=alpine -- sh
/ # wget -qO- --timeout=2 http://web
/ # wget -qO- --timeout=2 http://test-nginx
~~~



--------


## Filtrage d'accès depuis l'extérieur (4/4)
<div class="exercice"></div>

- Restriction d'accès sur un port uniquement

~~~yaml
ingress:
  - ports:
    - port: 80
    from: []
~~~

- Nettoyage

~~~bash
kubectl delete deployment, service web
kubectl delete networkpolicy default-deny-all
kubectl delete networkpolicy web-allow-external default-deny-all
~~~


--------


## Network Policies

### Port particulier

###### ![allow_port](Slides/Img/Network_Policies/7_9_allow_port.png)


--------


## Filtrage sur un port particulier
<div class="exercice"></div>

- Mise en place d'un serveur et création d'un accès :

~~~bash
kubectl run apiserver --image=treeptik/nginx:alpine --labels=app=apiserver

kubectl create service clusterip apiserver \
    --tcp 8001:8000 \
    --tcp 5001:5000
~~~


--------


## Filtrage sur un port particulier (2/3)
<div class="exercice"></div>

- Création d'un fichier `api-allow-5000.yaml`

~~~yaml
kind: NetworkPolicy
apiVersion: networking.k8s.io/v1
metadata:
  name: api-allow-5000
spec:
  podSelector:
    matchLabels:
      app: apiserver
  ingress:
  - ports:
    - port: 5000
    from:
    - podSelector:
        matchLabels:
          role: monitoring
~~~

- Application de la règle

~~~bash
kubectl apply -f api-allow-5000.yaml
~~~


--------


## Filtrage sur un port particulier (3/3)
<div class="exercice"></div>

- Test de la connexion

~~~bash
kubectl run test-$RANDOM --rm -i -t --image=alpine -- sh
/ # wget -qO- --timeout=2 http://apiserver:8001
/ # wget -qO- --timeout=2 http://apiserver:5001/metrics
~~~

- Test avec un pod avec le role de monitoring

~~~bash
kubectl run test-$RANDOM --labels=role=monitoring --rm -i -t --image=alpine -- sh
/ # wget -qO- --timeout=2 http://apiserver:8001
/ # wget -qO- --timeout=2 http://apiserver:5001/metrics
~~~

- Nettoyage

~~~bash
kubectl delete deployment,service apiserver
kubectl delete networkpolicy api-allow-5000
~~~


--------


## Network Policies

### Filtre multiple

###### ![multiple_filter](Slides/Img/Network_Policies/7_10_multiple_filter.png)


--------


## Filtre multiple
<div class="exercice"></div>

- Mise en place d'une base redis :

~~~bash
kubectl run db --image=redis:4 --port 6379 --expose --labels app=bookstore,role=db
~~~

- Création d'une règle de filtrage `redis-allow-services.yaml`

~~~yaml
kind: NetworkPolicy
apiVersion: networking.k8s.io/v1
metadata:
  name: redis-allow-services
spec:
  podSelector:
    matchLabels:
      app: bookstore
      role: db
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: bookstore
          role: search
    - podSelector:
            matchLabels:
              app: bookstore
              role: api
    - podSelector:
            matchLabels:
              app: inventory
              role: web
~~~


--------


## Filtrage sur un port particulier (2/3)
<div class="exercice"></div>

- Appliquer la règle

~~~bash
kubectl apply -f redis-allow-services.yaml
~~~

- Test de la configuration

~~~bash
kubectl run test-$RANDOM --labels=app=inventory,role=web --rm -i -t --image=alpine -- sh
/ # nc -v -w 2 db 6379
~~~

- Test de la configuration

~~~bash
kubectl run test-$RANDOM --labels=app=other --rm -i -t --image=alpine -- sh
/ # nc -v -w 2 db 6379
~~~


--------


## Filtrage sur un port particulier (3/3)
<div class="exercice"></div>

- Nettoyage de l'environnement

~~~bash
kubectl delete deployment db
kubectl delete service db
kubectl delete networkpolicy redis-allow-services
~~~


--------


## Network Policies

### Gestion du trafic sortant (Egress)

- DENY egress traffic from an application
- DENY all non-whitelisted egress traffic in a namespace
- LIMIT egress traffic from an application to some pods
- ALLOW traffic only to Pods in a namespace
- LIMIT egress traffic to the cluster (DENY external egress traffic)


--------


## Network Policies

### Interdire tout le trafic sortant

###### ![multiple_filter](Slides/Img/Network_Policies/7_11_deny_egress.png)


--------


## Interdire tout le trafic sortant
<div class="exercice"></div>

- Mise en place d'un pod nginx :

~~~bash
kubectl run web --image=nginx --port 80 --expose --labels app=web
~~~

- Création d'une règle de blocage de tout le trafic sortant `foo-deny-egress.yaml`

~~~yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: foo-deny-egress
spec:
  podSelector:
    matchLabels:
      app: foo
  policyTypes:
  - Egress
  egress: []
~~~

- Appliquer la règle

~~~bash
kubectl apply -f foo-deny-egress.yaml
~~~

--------


## Interdire tout le trafic sortant (2/4)
<div class="exercice"></div>

- Test de la configuration

~~~bash
kubectl run test-$RANDOM --labels=app=foo --rm -i -t --image=alpine -- sh
/ # wget -qO- --timeout 1 http://web:80/
/ # wget -qO- --timeout 1 http://www.example.com/
/ # ping google.com
~~~


--------


## Filtrage sur un port particiluer (3/4)
<div class="exercice"></div>

- Edition pour ouvrir les ports DNS

~~~yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: foo-deny-egress
spec:
  podSelector:
    matchLabels:
      app: foo
  policyTypes:
  - Egress
  egress:
  # allow DNS resolution
  - ports:
    - port: 53
      protocol: UDP
    - port: 53
      protocol: TCP
~~~


--------


## Filtrage sur un port particulier (4/4)
<div class="exercice"></div>

- Edition pour ouvrir les ports DNS

~~~bash
kubectl run --rm --restart=Never --image=alpine -i -t -l app=foo test -- ash
/ # wget --timeout 1 -O- http://web
/ # wget --timeout 1 -O- http://www.example.com
/ # ping google.com
/ # exit
~~~

- Nettoyage de l'environnement

~~~bash
kubectl delete deployment,service cache
kubectl delete deployment,service web
kubectl delete networkpolicy foo-deny-egress
~~~


--------


## Network Policies
###### TO DO

### Gestion du trafic sortant (Egress)

- DENY egress traffic from an application
- DENY all non-whitelisted egress traffic in a namespace
- LIMIT egress traffic from an application to some pods
- ALLOW traffic only to Pods in a namespace
- LIMIT egress traffic to the cluster (DENY external egress traffic)


--------


## Network Policies

### Deny all non-whitelisted egress

###### ![multiple_filter](Slides/Img/Network_Policies/7_12_deny_egress.png)


--------


## Network Policies

### Allow egress to some pods

###### ![multiple_filter](Slides/Img/Network_Policies/7_13_egress_some_pods.png)


--------


## Network Policies

### Allow egress to specific namespace

###### ![multiple_filter](Slides/Img/Network_Policies/7_14_egress_to_namespace.png)


--------


## Network Policies

### Allow egress to cluster only

###### ![multiple_filter](Slides/Img/Network_Policies/7_15_egress_to_cluster_only.png)



--------


# Nettoyage de l'installation


- Pour nettoyer votre installation

~~~bash
# stop the cluster
./dind-cluster-v1.8.sh down

# remove DIND containers and volumes
./dind-cluster-v1.8.sh clean
~~~
