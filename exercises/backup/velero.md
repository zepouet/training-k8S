# ARK 

## Overview

Ark gives you tools to back up and restore your Kubernetes cluster resources and persistent volumes. Ark lets you:
* Take backups of your cluster and restore in case of loss.
* Copy cluster resources to other clusters.
* Replicate your production environment for development and testing environments.

Ark consists of:
* A server that runs on your cluster
* A command-line client that runs locally

You can run Ark in clusters on a cloud provider or on-premises. 

## Install it !

As CRD, it is installed into the cluster itself.

```
mkdir velero-demo
cd velero-demo
wget https://github.com/heptio/velero/releases/download/v0.11.0/velero-v0.11.0-linux-amd64.tar.gz
tar xvf velero-v0.11.0-linux-amd64.tar.gz
```

## Use Minio as Storage platform

Minio is an option if you want to keep your backup data on-premises and you are not using another storage platform that offers an S3-compatible object storage API.

Edit the file to change **ClusterIP** to **NodePort**
```
vi config/minio/00-minio-deployment.yaml
```

Then start the server and the local storage service. In the Ark directory, run:

```
kubectl apply -f config/common/00-prereqs.yaml
kubectl apply -f config/minio/
```

Check to see that both the Ark deployment is successfully created:

```
kubectl get deployments,po  --namespace=heptio-ark
```

Display the Service Port for **minio**

```
kubectl get svc -n heptio-ark minio 
```

And one the Node IP 
```
kubectl get nodes -o wide
```

To uncomment and update the field **publicUrl** 
 
```
vi config/minio/05-ark-backupstoragelocation.yaml
```

Example : **publicUrl: http://206.189.20.158:30829**

And apply it :

```
kubectl apply -f config/minio/05-ark-backupstoragelocation.yaml
``` 
 
## Deploy Nginx

```
kubectl apply -f config/nginx-app/base.yaml
kubectl get deployments --namespace=nginx-example
```
 
## Back up

Create a backup for any object that matches the app=nginx label selector:

```
ark backup create nginx-backup --selector app=nginx --include-namespaces nginx-example
ark backup get
```

## Simulate a disaster

```
kubectl delete namespace nginx-example

kubectl get deployments --namespace=nginx-example
kubectl get services --namespace=nginx-example
kubectl get namespace/nginx-example 
```

## Restore

```
ark restore create --from-backup nginx-backup
```

The restore can take a few moments to finish. During this time, the STATUS column reads InProgress.

```
ark restore get
```

You can duplicate the namespaced environment. Please wait :) 
```
ark restore create --from-backup nginx-backup --namespace-mappings nginx-example:production
ark restore create --from-backup nginx-backup --namespace-mappings nginx-example:production2
ark restore create --from-backup nginx-backup --namespace-mappings nginx-example:production3
...
```

Wait for the end of duplication and you will find new namespaces.

```
kubectl get ns
NAME            STATUS   AGE
default         Active   12h
heptio-ark      Active   65m
kube-public     Active   12h
kube-system     Active   12h
nginx-example   Active   40m
production      Active   19m
production2     Active   62s
production3     Active   31s
```

