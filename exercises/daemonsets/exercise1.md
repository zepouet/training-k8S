# DaemonSets and NodeSelector

## Node Label

### List your nodes

```
kubectl get nodes
```

### Add label to your nodes

```
kubectl label nodes <worker1> ssd=true
```

### Filter nodes based on label

```
kubectl get nodes --selector ssd=true
```

## DaemonSet

Create daemonset from the **daemonset.yml**

```
apiVersion: extensions/v1beta1
kind: "DaemonSet"
metadata:
  labels:
    app: nginx
    ssd: "true"
  name: nginx-fast-storage
spec:
  template:
    metadata:
      labels:
        app: nginx
        ssd: "true"
    spec:
      nodeSelector:
        ssd: "true"
      containers:
        - name: nginx
          image: nginx:1.10.0
```          

### Check the nodes where nginx was deployed

```
kubectl get pods -o wide
```

### Add label ssd=true to another worker node

```
kubectl label nodes <other-worker> ssd=true
```

nginx should be deployed there automatically

### Check the nodes where nginx was deployed

It should be also another node with **ssd=true** label

### Clean up

```
kubectl delete ds nginx-fast-storage
```
