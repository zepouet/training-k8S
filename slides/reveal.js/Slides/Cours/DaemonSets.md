## Helm


<img src="Slides/Img/Helm/logo-helm-k8s.png" width="50%" />


--------


#### Pourquoi ?

<br/>
Arrêter de manipuler les fichiers K8S à la main


--------


#### Définition

<br/>
* **Helm** : Outils de gestion de déploiement d'application
* **Charts** : Ensemble de ressources K8S configurable
* **Release** : Livrable versionnable


--------


#### Cas d'utilisations

<br/>
Helm est utilisé pour :
* Fabriquer ses fameux livrables configurables
* Mettre à jour, supprimer et inspecter les livrables


--------


#### Architecture

<br/>
Helm est composé de deux parties distinctes :
- **helm** client : créer, récupérer, rechercher et valider les **charts**
- **tiller** server : agent dans le cluster K8S


--------


![Architecture](Slides/Img/Helm/architecture-helm.png)


--------



#### Charts

<br/>
- Ensemble d'objet K8S correspondant à une application
- Instance d'une application Kubernetes
- Exportable sous forme de package

<br/>
~~~bash
helm create mychart
~~~


--------

#### Chart

L'arborescence d'un chart est la suivante :
~~~bash
mychart
|-- Chart.yaml
|-- charts
|-- templates
|   |-- NOTES.txt
|   |-- _helpers.tpl
|   |-- deployment.yaml
|   |-- ingress.yaml
|   `-- service.yaml
`-- values.yaml
~~~


--------

#### Chart

<br/>
Décrivons les fichiers d'un chart :
* **Chart.yaml** : Manifest de l'application
* **charts** : Dossier avec les dépendances du chart
* **templates** : Dossier avec les définitions des objets K8S
* **values.yaml** : Fichier avec les valeurs des variables


--------


![Charts](Slides/Img/Helm/three-tier-kubernetes-architecture.png)


--------


#### Templates

<br/>
- Dossier de fichiers configurables
- Fichiers yaml classiques étendus par helm.
- Système de variables globales utilisables dans les fichiers yaml.


--------


#### Templates

<br/>
Exemple de fichier template :
~~~bash
apiVersion: v1
kind: Service
metadata:
  name: {{ include "mychart.fullname" . }}
  labels:
    app.kubernetes.io/name: {{ include "mychart.name" . }}
    helm.sh/chart: {{ include "mychart.chart" . }}
    app.kubernetes.io/instance: {{ .Release.Name }}
    app.kubernetes.io/managed-by: {{ .Release.Service }}
spec:
  type: {{ .Values.service.type }}
  ports:
    - port: {{ .Values.service.port }}
      targetPort: http
      protocol: TCP
      name: http
  selector:
    app.kubernetes.io/name: {{ include "mychart.name" . }}
    app.kubernetes.io/instance: {{ .Release.Name }}
~~~

Par exemple {{ .Values.service.port }} est le nom d'une variable.



--------


#### Variables


Dans le fichier values.yaml :
~~~bash
image:
  repository: nginx
~~~

Au lancement de helm :
~~~bash
helm install --name example ./mychart --set image.repository=alpine
~~~


--------



#### Installation 1 // 4

<br/>
Télécharger helm avec la commande suivante :
~~~bash
curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get
  > get_helm.sh
~~~
Puis installer le avec les commandes suivantes :
~~~bash
chmod 700 get_helm.sh
./get_helm.sh
~~~


--------


#### Installation 2 // 4

<br/>
Vérifier si le cluster role cluster-admin est présent sur le cluster :
~~~bash
kubectl get clusterrole cluster-admin
~~~
Si le résultat de la commande ressemble à ce qui suit passer directement a la diapo Instalation (4/4)
~~~bash
NAME            AGE
cluster-admin   4h42m
~~~
Sinon il faut créer ce cluster role.


--------

#### Installation 3 // 4

Créer un fichier clusterrole.yaml :
~~~bash
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
    annotations:
      rbac.authorization.kubernetes.io/autoupdate: "true"
    labels:
      kubernetes.io/bootstrapping: rbac-defaults
    name: cluster-admin
rules:
- apiGroups:
  - '*'
  resources:
  - '*'
  verbs:
  - '*'
- nonResourceURLs:
  - '*'
  verbs:
  - '*'
~~~
Puis créer le ClusterRole :
~~~bash
kubectl create -f clusterrole.yaml
~~~


--------

#### Installation 4 // 4

Créer un service account avec la commande suivante :
~~~bash
kubectl create serviceaccount -n kube-system tiller
~~~
Associer le avec le cluster role cluster-admin :
~~~bash
kubectl create  clusterrolebinding tiller-cluster-rule
                --clusterrole=cluster-admin
                --serviceaccount=kube-system:tiller
~~~
Et enfin initialiser helm :
~~~bash
helm init --service-account tiller
~~~


--------


#### Pour continuer

https://github.com/helm/monocular

<img src="Slides/Img/Helm/MonocularScreenshot.gif" width="50%" />





--------



### EXERCICE

#### HELM


--------


Dans un premier terminal
```
helm serve
Regenerating index. This may take a moment.
Now serving you on 127.0.0.1:8879
```

Dans un second terminal
```
helm search local
NAME            VERSION DESCRIPTION
local/mychart   0.1.0   A Helm chart for Kubernetes
helm install --name example4 local/mychart --set service.type=NodePort
To setup a remote repository you can follow the guide in the Helm documentation.
```


--------


#### Dépendences


```
cat > ./mychart/requirements.yaml <<EOF
dependencies:
- name: mariadb
version: 0.6.0
repository: https://kubernetes-charts.storage.googleapis.com
EOF
```

```
helm dep update ./mychart
Hang tight while we grab the latest from your chart repositories...
...Unable to get an update from the "local" chart repository (http://127.0.0.1:8879/charts):
    Get http://127.0.0.1:8879/charts/index.yaml: dial tcp 127.0.0.1:8879: getsockopt: connection refused
...Successfully got an update from the "stable" chart repository
...Successfully got an update from the "incubator" chart repository
Update Complete. *Happy Helming!*
Saving 1 charts
Downloading mariadb from repo [https://kubernetes-charts.storage.googleapis.com](https://kubernetes-charts.storage.googleapis.com)
ls ./mychart/charts
mariadb-0.6.0.tgz
```

```
helm install --name example5 ./mychart --set service.type=NodePort
NAME:   example5
LAST DEPLOYED: Wed May  3 16:28:18 2017
NAMESPACE: default
STATUS: DEPLOYED

RESOURCES:
==> v1/Secret
NAME              TYPE    DATA  AGE
example5-mariadb  Opaque  2     1s

==> v1/ConfigMap
NAME              DATA  AGE
example5-mariadb  1     1s

==> v1/PersistentVolumeClaim
NAME              STATUS  VOLUME                                    CAPACITY  ACCESSMODES  AGE
example5-mariadb  Bound   pvc-229f9ed6-3015-11e7-945a-66fc987ccf32  8Gi       RWO          1s

==> v1/Service
NAME              CLUSTER-IP  EXTERNAL-IP  PORT(S)       AGE
example5-mychart  10.0.0.144  <nodes>      80:30896/TCP  1s
example5-mariadb  10.0.0.108  <none>       3306/TCP      1s

==> extensions/v1beta1/Deployment
NAME              DESIRED  CURRENT  UP-TO-DATE  AVAILABLE  AGE
example5-mariadb  1        1        1           0          1s
example5-mychart  1        1        1           0          1s
```

--------


## CHART repository


--------


#### Exposer ses packages à distance

Ceci est possible avec
* GitHub
* JFrog
* Google Container Registry
* Azure Container Registry
* Tout serveur HTTP



--------



### DEFINITION

<br/>
* Serveur HTTP hébergeant un fichier **index.yaml**
* [ Option ] Les Charts associés


--------


#### Exemple

**https://example.com/charts** pourrait répondre

```
charts/
  |
  |- index.yaml
  |
  |- alpine-0.1.2.tgz
  |
  |- alpine-0.1.2.tgz.prov
```


--------


#### Index.yaml


* Contient les *metadata* du package
* Incluant le contenu des fichiers *Chart.yaml*
* Obligatoire pour que le repository soit valide
* La commande **helm repo index <dir>** génére le fichier


--------


```
apiVersion: v1
entries:
  mychart:
  - apiVersion: v1
    appVersion: "1.0"
    created: 2018-11-21T09:04:24.931099051Z
    description: A Helm chart for Kubernetes
    digest: 134c76a7a43932e47afec8b9655064d11d85e60f86c5e0efea361d5612ad4014
    name: mychart
    urls:
    - mychart-0.1.0.tgz
    version: 0.1.0
generated: 2018-11-21T09:04:24.929984579Z
```


--------


```
helm repo index my-first-chart
helm repo index my-first-chart --url https://fantastic-charts.storage.googleapis.com
```


```
helm repo add fantastic-charts https://fantastic-charts.storage.googleapis.com
$ helm repo list
fantastic-charts    https://fantastic-charts.storage.googleapis.com
```

```
$ helm repo add fantastic-charts https://fantastic-charts.storage.googleapis.com --username my-username --password my-password
$ helm repo list
fantastic-charts    https://fantastic-charts.storage.googleapis.com
```


--------


## HOOKS


--------


### Objectif

* Intervenir dans le cycle de vie de la livraison
* Executer une tâche de backup de base de données avant déploiement du nouveau chart par exemple puis enchaîner un autre job pour les restaurer
* Lancer un job de suppression de ressources externes avant de supprimer la release


--------


### Déclaration comme annotations

```
apiVersion: ...
kind: ....
metadata:
  annotations:
    "helm.sh/hook": "pre-install"
# ...
```


--------


### Hooks disponibles

* pre-install
* post-install
* pre-delete
* post-delete
* pre-upgrade
* post-upgrade
* pre-rollback have been rolled back
* post-rollback
* crd-install


--------


```
apiVersion: batch/v1
kind: Job
metadata:
  name: "{{.Release.Name}}"
  labels:
    app.kubernetes.io/managed-by: {{.Release.Service | quote }}
    app.kubernetes.io/instance: {{.Release.Name | quote }}
    helm.sh/chart: "{{.Chart.Name}}-{{.Chart.Version}}"
  annotations:
    # This is what defines this resource as a hook. Without this line, the
    # job is considered part of the release.
    "helm.sh/hook": post-install
    "helm.sh/hook-weight": "-5"
    "helm.sh/hook-delete-policy": hook-succeeded
spec:
  template:
    metadata:
      name: "{{.Release.Name}}"
      labels:
        app.kubernetes.io/managed-by: {{.Release.Service | quote }}
        app.kubernetes.io/instance: {{.Release.Name | quote }}
        helm.sh/chart: "{{.Chart.Name}}-{{.Chart.Version}}"
    spec:
      restartPolicy: Never
      containers:
      - name: post-install-job
        image: "alpine:3.3"
        command: ["/bin/sleep","{{default "10" .Values.sleepyTime}}"]        
```


--------


### Trois sorties possibles


```
annotations:
    "helm.sh/hook-delete-policy": hook-succeeded
```

```
annotations:
    "helm.sh/hook-delete-policy": hook-failed
```

```
annotations:
    "helm.sh/hook-delete-policy": before-hook-creation
```


--------


### Exemple NGINX complet
<br/>
https://github.com/helm/helm/tree/master/docs/examples/nginx
