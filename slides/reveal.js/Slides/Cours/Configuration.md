## Les solutions de configuration

- Variables d'environnements
- ConfigMaps
- Secrets


--------

### Les variables d'environnement

- Définies en **statique** par défaut dans le Dockerfile
- Surchargées en **dynamique** au runtime via des Containers ou Pod
- Dans notre cas évidemment des pods


--------

#### Variable d'environnement Pods

~~~yaml
apiVersion: v1
kind: Pod
metadata:
  name: envs-demo
spec:
  containers:
  - name: envs-demo
    image: treeptik/envs-demo
    env:
    - name: SIMPLE_SERVICE_VERSION
      value: "1.0"
~~~


--------

~~~shell
kubectl exec envs-demo -- printenv

PATH=/usr/local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
HOSTNAME=envs-demo
SIMPLE_SERVICE_VERSION=1.0
KUBERNETES_PORT_53_UDP_ADDR=172.30.0.1
KUBERNETES_PORT_53_TCP_PORT=53
ROUTER_PORT_443_TCP_PROTO=tcp
DOCKER_REGISTRY_PORT_5000_TCP_ADDR=172.30.1.1
KUBERNETES_SERVICE_PORT_DNS_TCP=53
ROUTER_PORT=tcp://172.30.246.127:80
~~~


--------


### Les configMaps

- Découplage d'une application et de sa configuration
- Portabilité
- But : limiter les variables d'environment
- Existe dans un namespace


--------


#### Deux configurations globales

~~~
apiVersion: v1
  kind: ConfigMap
  metadata:
    name: env-config
    namespace: default
  data:
    log_level: INFO

apiVersion: v1
  kind: ConfigMap
  metadata:
    name: special-config
    namespace: default
  data:
    special.how: very
~~~


--------

#### Configurations référencées par leurs clés
~~~
apiVersion: v1
   kind: Pod
   metadata:
     name: dapi-test-pod
   spec:
     containers:
       - name: test-container
         image: k8s.gcr.io/busybox
         command: [ "/bin/sh", "-c", "env" ]
         env:
           - name: SPECIAL_LEVEL_KEY
             valueFrom:
               configMapKeyRef:
                 name: special-config
                 key: special.how
           - name: LOG_LEVEL
             valueFrom:
               configMapKeyRef:
                 name: env-config
                 key: log_level
     restartPolicy: Never
~~~     


--------

#### Classic file
hardcoded.js
~~~
var http = require('http');
var server = http.createServer(function (request, response) {
  const language = 'English';
  const API_KEY = '123-456-789';
  response.write(`Language: ${language}\n`);
  response.write(`API Key: ${API_KEY}\n`);
  response.end(`\n`);
});
server.listen(3000);
~~~



--------

#### Un peu mieux...
Avec les variables d'environnement

~~~
var http = require('http');
var server = http.createServer(function (request, response) {
  const language = process.env.LANGUAGE;
  const API_KEY = process.env.API_KEY;
  response.write(`Language: ${language}\n`);
  response.write(`API Key: ${API_KEY}\n`);
  response.end(`\n`);
});
server.listen(3000);
~~~


--------


#### Avec Docker ça va encore mieux
A la construction
~~~
FROM node:6-onbuild
EXPOSE 3000
ENV LANGUAGE English
ENV API_KEY 123-456-789
~~~

Et même au lancement
~~~
docker run -e LANGUAGE=Spanish -e API_KEY=09876 \
           -p 3000:3000 \
           -ti envtest
~~~


--------

#### Avec Kubernetes on s'approche encore du mieux
~~~
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: envtest
spec:
  replicas: 1
  template:
    metadata:
      labels:
        name: envtest
    spec:
      containers:
      - name: envtest
        image: gcr.io/<PROJECT_ID>/envtest
        ports:
        - containerPort: 3000
        env:
        - name: LANGUAGE
          value: "English"
        - name: API_KEY
          value: "123-456-789"
~~~


--------


#### Création de notre première ConfigMaps

~~~
kubectl create configmap language --from-literal=LANGUAGE=English

kubectl get configmap
NAME      DATA    AGE
language  1       1m
~~~


--------

#### Référencer la ConfigMap lors du déploiement
~~~
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: envtest
spec:
  replicas: 1
  template:
    metadata:
      labels:
        name: envtest
    spec:
      containers:
      - name: envtest
        image: gcr.io/nicolas/envtest
        env:
        - name: LANGUAGE
          valueFrom:
            configMapKeyRef:
              name: language
              key: LANGUAGE                  
~~~


--------

#### Mettre à jour la configuration

~~~
kubectl create configmap language --from-literal=LANGUAGE=Spanish \
        -o yaml --dry-run | kubectl replace -f -
~~~


--------


#### Allons plus loin avec les fichiers

~~~bash
mkdir config
echo '{"LANGUAGE":"English"}' > ./config/config
~~~

Puis mettons à jour le fichier :
~~~Javascript
var http = require('http');
var fs = require('fs');
var server = http.createServer(function (request, response) {
  fs.readFile('./config/config.json', function (err, config) {
    if (err) return console.log(err);
    const language = JSON.parse(config).LANGUAGE;
    fs.readFile('./secret/secret.json', function (err, secret) {
      if (err) return console.log(err);
      const API_KEY = JSON.parse(secret).API_KEY;
      response.write(`Language: ${language}\n`);
      response.write(`API Key: ${API_KEY}\n`);
      response.end(`\n`);
    });
  });
});
server.listen(3000);
~~~


--------


#### Avec Docker, nous faisons
~~~
docker run -p 3000:3000 -ti \
  -v $(pwd)/config/:/usr/src/app/config/ \
  envtest
~~~


--------


#### Avec K8S, nous faisons également
~~~
kubectl create configmap my-config --from-file=./config/config.json

kubectl get configmap
NAME        DATA        AGE
my-config   1           56s
~~~


--------


#### Utiliser ceci dans le Deployment

~~~
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: envtest
spec:
  replicas: 1
  template:
    metadata:
      labels:
        name: envtest
    spec:
      containers:
      - name: envtest
        image: gcr.io/smart-spark-93622/envtest:file5
        ports:
        - containerPort: 3000
        volumeMounts:
          - name: my-config
            mountPath: /usr/src/app/config
      volumes:
      - name: my-config
        configMap:
          name: my-config
~~~


--------


#### MISE A JOUR SANS DOWNTIME

- Mise à jour dynamique des volumes
- Attention à l'inconsistence possible si plusieurs containers
- Si problème sévère lié à l'inconsistence, ne pas utiliser et tout recréer dont le Deployment
~~~
echo '{"LANGUAGE":"Klingon"}' > ./config/config.json
kubectl create configmap my-config \
  --from-file=./config/config.json \
  -o yaml --dry-run | kubectl replace -f -
~~~


--------


### EXERCICE CONFIGMAPS


--------



### Les secrets


--------


#### Bonnes pratiques


> Ne jamais coder de mots de passe dans des fichiers ou images


--------


#### Objectifs


- Protéger les données sensibles
- Dissocier les consommateurs / producteurs via une API


--------


#### Utilisation des Secrets

- Ils sont définis dans un **namespace** donné
- Deux types d'accès : **volume** ou **variable d'environnement**
- Les secrets sont stockés dans un **tmpfs**
- Limite de 1 Mo
- L'API Server stocke le secret en *plaintext* dans ETCD


--------


#### Différents types de Secrets


- Generic
- Docker-Registry
- TLS


--------


#### Cas d'usage **Generic**


--------


### EXERCICE SECRETS



--------

#### Pour aller plus loin


~~~shell
kubectl create secret \
                generic couple \
                --from-literal=user=nicolas \
                --from-literal=password=hk6504q
~~~

~~~
kubectl get secrets

NAME                  TYPE                                  DATA      AGE
chanson               Opaque                                1         1h
couple                Opaque                                2         19s
default-token-l7tvd   kubernetes.io/service-account-token   3         5d
~~~


--------

#### describe

~~~
kubectl describe secrets couple
~~~

~~~
Name:         couple
Namespace:    default
Labels:       <none>
Annotations:  <none>

Type:  Opaque

Data
====
user:      7 bytes
password:  7 bytes
~~~


--------


#### Toutes les informations dont celle en base64

~~~
kubectl get secrets couple -o yaml
~~~

~~~yaml
apiVersion: v1
data:
  password: aGs2NTA0cQ==
  user: bmljb2xhcw==
kind: Secret
metadata:
  creationTimestamp: 2018-06-18T13:07:38Z
  name: couple
  namespace: default
  resourceVersion: "735530"
  selfLink: /api/v1/namespaces/default/secrets/couple
  uid: 936632d1-72f8-11e8-9d8f-7a2fde66199e
type: Opaque
~~~


--------


#### Injection manuelle de Secrets

Créer à la main la Base64

~~~
echo -n "J'aime bien le rosé de Puyloubier" | base64
SidhaW1lIGJpZW4gbGUgcm9zw6kgZGUgUHV5bG91Ymllcg==
~~~

Créer le fichier : **monSecret.yml**
~~~YAML
apiVersion: v1
kind: Secret
metadata:
  name: mon-secret
data:
  dictondeprovence: SidhaW1lIGJpZW4gbGUgcm9zw6kgZGUgUHV5bG91Ymllcg==
~~~


--------


Créer le secret en ligne de commande:
~~~SH
kubectl create -f monSecret.yml
~~~


--------

#### Fichier pod.yml
~~~
apiVersion: v1
kind: Pod
metadata:
  name: afficheur-secret
spec:
  containers:
  - name: shell
    image: centos:7
    command:
      - "bin/bash"
      - "-c"
      - "sleep 10000"
    volumeMounts:
      - name: mondicton
        mountPath: "/etc/dicton"
        readOnly: true
  volumes:
  - name: mondicton
    secret:
      secretName: mon-secret
~~~


--------


On peut afficher le contenu du secret:
~~~
kubectl exec afficheur-secret cat /etc/dicton/dictondeprovence
~~~


--------


#### Variable d'environnement

- La grande différence avec Docker !

~~~
apiVersion: apps/v1
kind: Deployment
metadata:
  name: demo-frontend
spec:
  selector:
      matchLabels:
        app: demo-frontend
  replicas: 1
  template:
    metadata:
      labels:
        app: demo-frontend
    spec:
      containers:
        - name: nicolas
          image: nicolas:latest
          imagePullPolicy: Never
          ports:
            - containerPort: 8081
          env:
            - name: DEMO.PATH
              value: "Hello from the environment"
            - name: SECRETS.DEMO.PATH
              valueFrom:
                secretKeyRef:
                  name: spring-k8s-secrets
                  key: path
~~~


--------


#### Cas d'usage Docker-Registry

- Authentification sur une Registry Docker
- Récupération des images privées


--------


Création du Secret
~~~
kubectl create secret docker-registry nexus-credentials \
  --docker-server=nexus.foo.dev \
  --docker-username=admin \
  --docker-password=admin123 \
  --docker-email=n.muller@treeptik.fr
~~~


--------


Exploitation du Secret
~~~
apiVersion: v1
kind: Pod
metadata:
  name: private-tomcat
spec:
  containers:
  - name: chaton
    image: treeptik/tomcat:private
  imagePullSecrets:
  - name: nexus-credentials
~~~


--------


#### Cas d'usage TLS

- Gestion des PKI
- Création à partir d'un couple clé public/privée


--------


Création des clés
~~~
openssl req -newkey rsa:2048 -nodes -keyout key.pem \
            -x509 -days 365 -out cert.pem
~~~


--------


Création du Secret à partir des clés
~~~
kubectl create secret tls my-domain-certs --cert cert.pem -key key.pem
~~~


--------


Exploitation du Secret
~~~
apiVersion: v1
kind: Pod
metadata:
  name: proxy
spec:
  containers:
  - name: proxy-nginx
    image: nginx:1.2
    volumeMounts:
    - name: tls
      mountPath: "/etc/ssl/certs/"
  volumes:
  - name: tls
    secret:
      secretName: my-domain-certs
~~~
