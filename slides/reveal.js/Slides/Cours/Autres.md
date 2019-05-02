## Autres cas d'usage


- StatefulSets
- Jobs et CronJobs


--------


### StatefulSets


--------


- Un StatefulSet ressemble à un ReplicaSet mais avec un lot de fonctionnalités avancées pour gérer les clusters qui nécessitent une certaine continuité en terme d’adressage réseau, de volume et un ordonnancement dans le démarrage des pods.
- Cela permet de déployer dans Kubernetes des applications clusterisées comme des bases de données.


--------


### Lancement

3 étapes permettent de créer un StatefulSet :
- Création des volumes si nécessaire
- Démarrage des éventuels conteneurs init du pod
- Démarrage des conteneurs classiques des pods

Kubernetes attend que le readinessProbe soit bon avant de déployer le réplica suivant


--------


#### StatefulSets


- Déploiement de 3 pods avec 3 volumes différentes `simple-statefulset.yaml`

~~~bash
kubectl create -f simple-statefulset.yml
kubectl get po,pvc,pv,svc
~~~

- Nous avons donc 3 volumes différents

~~~bash
kubectl exec -it nginx-statefulset-1 /bin/bash
echo '<p>Hello world!</p>' > /usr/share/nginx/html/index.html
exit
~~~


--------


### Exemple d'utilisation (2/2)

Les cycles de vie sont indépendants des pods :

~~~bash
kubectl delete -f simple-statefulset.yml
kubectl get pvc,pv
kubectl create -f simple-statefulset.yml
kubectl exec nginx-statefulset-1 cat /usr/share/nginx/html/index.html
~~~


--------


## StatefulSets
### DL


Voir le lien d'objectif libre pour la mise en place d'un article ou autre ...
https://www.objectif-libre.com/fr/blog/2017/08/22/kubernetes-et-galera/


--------

## Les jobs


- Les jobs servent à lancer des pods voués à se terminer,
- contrairement aux autres types de contrôleurs (ReplicaSet, StatefulSet, DaemonSet).
- Il existe deux types de jobs : les **Jobs** et les **CronJobs**


--------


### Job à usage unique


- Un Job est exécuté qu’une seule fois.
- Il peut être utilisé pour exécuter un batch ou sauvegarder une base de données.

- Créer le fichier `job.yaml`
~~~yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: pi
spec:
  template:
    metadata:
      name: pi
    spec:
      containers:
      - name: pi
        image: perl
        command: ["perl",  "-Mbignum=bpi", "-wle", "print bpi(2000)"]
      restartPolicy: Never
~~~


--------


### Les Jobs simples

~~~bash
$ kubectl get job
$ kubectl describe job pi

$ pods=$(kubectl get pods  --show-all --selector=job-name=pi --output=jsonpath={.items..metadata.name})
$ kubectl logs $pods
~~~


--------


### CronJobs

- Les CronJobs sont des Jobs destinés à être joués à intervalle régulier.
- Création d'un fichier `cronjob.yaml`

~~~yaml
apiVersion: batch/v2alpha1
kind: CronJob
metadata:
  name: hello
spec:
  schedule: "*/1 * * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: hello
            image: busybox
            args:
            - /bin/sh
            - -c
            - date; echo Hello from the Kubernetes cluster
          restartPolicy: OnFailure
~~~


--------



### EXERCICE FINAL: WORDPRESS-MYSQL


