# Utiliser les Deployments

## Nettoyer l'environnement précédent

`kubectl delete daemonsets,replicasets,services,deployments,pods,rc --all`

## Pourquoi utiliser les Deployments ?

Un ReplicaSet ne peut fournir de service de rolling-update que les ReplicationController savent faire.
Pour faire une action de rolling-update ou de rollout sur un ReplicaSet, il est nécessaire d'utiliser un Deployment de façon déclarative.

## Créer son premier Deployment

Copier le contenu dans le fichier **nginx0.yaml**

```
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: nginx
spec:
  replicas: 3
  template:
    metadata:
      labels:
        service: http-server
    spec:
      containers:
      - name: nginx
        image: nginx:1.10.2
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 80
```

Créer le déploiement:

```
kubectl create -f nginx0.yaml
deployment "nginx" created
```

Afficher l'état du déploiement et du ReplicatSet:

```
kubectl get deployment
NAME                DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
nginx               3         3         3            3           8m

kubectl get rs
NAME                DESIRED   CURRENT   AGE
nginx-3322722759    3         3         8m

kubectl get pod -l "service in (http-server)"
NAME                     READY     STATUS    RESTARTS   AGE
nginx-3322722759-7vp34   1/1       Running   0          14m
nginx-3322722759-ip5w2   1/1       Running   0          14m
nginx-3322722759-q97b7   1/1       Running   0          14m
```

Editer le fichier **nginx0.yaml** et passer le nombre de réplicas à 5

```
kubectl replace -f nginx0.yaml
deployment.extensions/nginx replaced
```


## ROLLING UPDATE

Ajouter ceci dans la **premier** bloc **.spec**. Pas le second
```
minReadySeconds: 5
strategy:
  # indicate which strategy we want for rolling update
  type: RollingUpdate
  rollingUpdate:
    maxSurge: 1
    maxUnavailable: 1
```

Explications:
* minReadySeconds: attente minimale entre la création de deux pods
* maxSurge: nombre de pods qui vont s'ajouter au nombre désiré (absolu ou pourcentage)
* maxUnavailable: nombre de pods qui peuvent être indisponible durant la mise à jour

```
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      service: http-server
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 1
  minReadySeconds: 5
  template:
    metadata:
      labels:
        service: http-server
    spec:
      containers:
      - name: nginx
        image: nginx:1.10.2
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 80
```

Déployons la nouvelle version :
```
kubectl apply -f nginx.yaml --record
```

## Mise à jour de l'image

### Choix 1 - Redéfinition du tag Image

Le format de la mise à jour est le suivant:
`kubectl set image deployment <deployment> <container>=<image> --record`

Dans notre cas, ce serait:
`kubectl set image deployment nginx nginx=nginx:1.11.5 --record`

### Choix 2 - Replacement

Modifier la version de l'image dans le fichier **nginx.yaml**

```
spec:
  containers:
  - name: nginx
    # newer image version
    image: nginx:1.11.5
    imagePullPolicy: IfNotPresent
    ports:
    - containerPort: 80
```

Appliquez la mise à jour avec **replace**

```
kubectl replace -f nginx.yaml
```

### Choix 3 - Edition directe

```
kubectl edit deployment nginx --record
```

Modifier la valeur

```
# Please edit the object below. Lines beginning with a '#' will be ignored,
# and an empty file will abort the edit. If an error occurs while saving this file will be
# reopened with the relevant failures.
#
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  annotations:
    deployment.kubernetes.io/revision: "1"
    kubectl.kubernetes.io/last-applied-configuration: '{"kind":"Deployment","apiVersion":"extensions/v1beta1","metadata":{"name":"nginx","creationTimestamp":null},"spec":{"replicas":10,"template":{"metadata":{"creationTimestam
...
    spec:
      containers:
      - image: nginx:1.10.2
        imagePullPolicy: IfNotPresent
        name: nginx
...
```

### Rollout status

```
kubectl rollout status deployment nginx
```

### Pause Rolling Update

```
kubectl rollout pause deployment nginx
```

### Resume Rolling Update

```
kubectl rollout resume deployment nginx
```

## Rollback

Vous souhaitez revenir en arrière sur une des versions.

```
kubectl rollout history deployment nginx
deployments "nginx":
REVISION  CHANGE-CAUSE
1   kubectl apply -f nginx.yaml --record
2   kubectl set image deployment nginx nginx=nginx:1.11.5 --record
```

Allons restaurer la version 1:

```
# to previous revision
kubectl rollout undo deployment nginx

# example
kubectl rollout undo deployment nginx --to-revision=1
```

Pour avoir un historique plus complet :

```
...
spec:
  replicas: 10
  selector:
    matchLabels:
      service: http-server
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 1
  minReadySeconds: 5
  revisionHistoryLimit: 10
...
```

Vous obtiendrez alors:

```
kubectl rollout history deployment/nginx
deployments "nginx":
REVISION  CHANGE-CAUSE
2   kubectl set image deployment nginx nginx=nginx:1.11 --record
3   kubectl set image deployment nginx nginx=nginx:1.11.5 --record
4   kubectl set image deployment nginx nginx=nginx:1.10 --record
5   kubectl set image deployment nginx nginx=nginx:1.10.2 --record
```
