## Volumes


--------


<img src="Slides/Img/Architecture/volumes.png" width="60%" />


--------



Applications Statefuls mais pas que...



--------


#### Persistent Volumes

- Aucune garantie d'avoir un pod fonctionnant indéfinimment sur le même noeud
- Le système de fichier persistant n'est pas géré par le cluster via ETCD
- Des disques locaux ou distants peuvent être montés


--------



EXERCICE VOLUMES



--------

### Problématique

- Les containers sont éphémères par leur conception même.
- Les Volumes permettent de sauvegarder les données qui méritent d'être persistées.


--------

#### Pourquoi les utiliser ?

- Communication / Synchronisation entre pods
- Découpler les données du cycle de vie d'un pods et de ses containers
- Point de montage avec le système de fichiers local


--------


### Les Différents types de Volume


--------

- Locaux aux noeuds : **emptyDir** ou **hostPath**
- Partage de fichiers : **nfs**
- Cloud Provider  : **gcePersistentDisk**, **awsElasticBlockStore**...
- Système distribué : **glusterfs**, **cephfs**...
- Spéciaux comme **secret**, **gitRepo**


--------


https://kubernetes.io/docs/concepts/storage/volumes/#types-of-volumes


--------


#### emptyDir

- Vide à la création
- Suit le cycle de vie d'un pod
- Pas de suppression si un des containers du pod crash
- Peut-être monté en RAM (tmpfs)
- Peut-être montés n-fois dans n-containers d'un pod


--------


### EXERCICE VOLUME INTRA PODS


--------


#### hostPath

> Monter une ressource de l'hôte dans le Pod


--------


#### Types de HostPath

- Directory
- File
- Socket
- CharDevice
- BlockDevice


--------


#### Cas d'utilisation

- Monitoring de la machine hôte
- Socket Docker
- Monter un GPU :)


--------

Exemple
~~~
apiVersion: v1
kind: Pod
metadata:
  name: test-pd
spec:
  containers:
  - image: k8s.gcr.io/test-webserver
    name: test-container
    volumeMounts:
    - mountPath: /test-pd
      name: test-volume
  volumes:
  - name: test-volume
    hostPath:      
      path: /data
~~~


--------


### objets


- PersistenceVolume (PV)
- PersistenceVolumeClaim (PVC)
- StorageClass


--------


#### Persistence Volume


- **Abstraction** de la gestion des volumes
- Stockage provisionné statiquement ou dynamiquement (via **StorageClass**)
- Nombreux **types** Différents (NFS, gcePersistentDisk, Ceph...)


--------


Persistent Volume

~~~
apiVersion: v1
kind: PersistentVolume
metadata:
  name: "pv"
spec:
  storageClassName: manual
  capacity:
    storage: "1Gi"
  accessModes:
    - "ReadWriteOnce"
  hostPath:
    path: /data/pv
~~~

~~~
kubectl get pv
NAME      CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM     STORAGECLASS   REASON    AGE
pv        1Gi        RWO            Retain           Available             manual                   5m
~~~



--------



#### Persistent Volume Claim


- Une demande de stockage
- Consomme un Persistent Volume
- Spécifie des contraintes supplémentaires
- Création d'un binding entre PVC et PV


--------


Persistent Volume Claim

~~~
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: requetevolume
spec:
  storageClassName: manual
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
~~~

~~~
kubectl create -f pvc.yml
persistentvolumeclaim "requetevolume" created

kubectl get pvc
NAME            STATUS    VOLUME    CAPACITY   ACCESS MODES   STORAGECLASS   AGE
requetevolume   Bound     pv        1Gi        RWO            manual         13s
~~~


--------

Création container Mongo

~~~
apiVersion: v1
kind: Pod
metadata:
  name: mongo
spec:
  containers:
    - name: mongo
      image: mongo:3.6
      volumeMounts:
      - mountPath: /data/db
        name: data-db
  volumes:
    - name: data-db
      persistentVolumeClaim:
        claimName: requetevolume
~~~


--------


~~~
kubectl create -f mongo.yml
pod "mongo" created

ls /data/pv
mongo.yml  pvc.yml  pv.yml
root@user1:~/volumes# ls /data/pv/
collection-0-7031728124031270860.wt  index-1-7031728124031270860.wt  _mdb_catalog.wt  storage.bson      WiredTiger.lock
collection-2-7031728124031270860.wt  index-3-7031728124031270860.wt  mongod.lock      WiredTiger        WiredTiger.turtle
diagnostic.data                      journal                         sizeStorer.wt    WiredTigerLAS.wt  WiredTiger.wt
~~~


--------



### EXERCICE VOLUMECLAIM WITH MONGO


--------



### EXERCICE VolumeClaim Sharing
