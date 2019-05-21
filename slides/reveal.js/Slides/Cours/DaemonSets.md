## Les DaemonSets


- Ce contrôleur assure qu'un pod tourne sur tous les noeuds ou une sélection
- Lors d'un ajout de noeud, le pod est automatiquement déployé
- Les DaemonSets sont utilisés pour les applications systèmes comme:
<br/> - un système de stockage comme Gluster, Ceph
<br/> -  un système de gestion de logs comme FluentD, logstash...
<br/> -  un système de monitoring comme Prometheus, CollectD...


--------


<img src="Slides/Img/Architecture/daemonset.yaml.png" width="60%" />


--------


<img src="https://cdn-images-1.medium.com/max/1600/1*QPFPOV-dDiWjL9H_O4_GUw.png" />


--------


```
apiVersion: extensions/v1beta1
kind: DaemonSet
metadata:
  name: logging
spec:
  template:
    metadata:
      labels:
        app: logging-app
    spec:
      nodeSelector:
        app: logging-node
      containers:
        - name: webserver
          image: nginx
          ports:
          - containerPort: 80
  ```        
