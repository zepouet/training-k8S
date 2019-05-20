# ingress

## Overview

At the end of this module, you will :
* Learn to manage the external access of internal resources
* Learn to manage ingress controller
* Learn to secure the cluster access

## Prerequisites

Create the directory **data/ingress** in your home folder to manage the YAML file needed in this module.

In order for the ingress resource to work, the cluster must have an ingress controller running :

* Contour
* F5 Networks
* HAproxy
* Istio
* Kong
* Nginx
* Traefik

The create command can create a Ingress object based on a yaml file definition.

Check that nginx-ingress-controller and default-http-backend is running

```
kubectl get pods -n ingress-nginx

NAME                                        READY   STATUS    RESTARTS   AGE
nginx-ingress-controller-76c86d76c4-knc2t   1/1     Running   0          2m1s
```

Else deploy a Nginx Ingress Controller following :

https://github.com/kubernetes/ingress-nginx/blob/master/docs/deploy/index.md#verify-installation

Quickly :
```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/mandatory.yaml

# NodePort Usage
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/provider/baremetal/service-nodeport.yaml
```

To check if the ingress controller pods have started, run the following command:

```
kubectl get pods --all-namespaces -l app.kubernetes.io/name=ingress-nginx --watch
```

## Exercise 1

First, deploy two static website in two different deployments.
Then, expose each one on the port 80.

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webserver1
spec:
  replicas: 2
  selector:
    matchLabels:
      app: webserver1
  template:
    metadata:
      labels:
        app: webserver1
    spec:
      containers:
      - name: static
        image: dockersamples/static-site
        env:
        - name: AUTHOR
          value: Nicolas
        ports:
        - containerPort: 80
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webserver2
spec:
  replicas: 2
  selector:
    matchLabels:
      app: webserver2
  template:
    metadata:
      labels:
        app: webserver2
    spec:
      containers:
      - name: static
        image: dockersamples/static-site
        env:
        - name: AUTHOR
          value: Nausicaa
        ports:
        - containerPort: 80
```

Expose each on of the Deployment on port 80.

```
apiVersion: v1
kind: Service
metadata:
  name: webserver1
spec:
  ports:
  - port: 80
    protocol: TCP
    targetPort: 80
  selector:
    app: webserver1
---
apiVersion: v1
kind: Service
metadata:
  name: webserver2
spec:
  ports:
  - port: 80
    protocol: TCP
    targetPort: 80
  selector:
    app: webserver2
```

Create an Ingress resource to expose an Nginx pod Service's on port 80.


```
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
  name: myfirstingress
spec:
  rules:
  - host: training.treeptik.io
    http:
      paths:
      - backend:
          serviceName: webserver1
          servicePort: 80
        path: /path1
      - backend:
          serviceName: webserver2
          servicePort: 80
        path: /path2
```

Once the Pods are up and running, you should be able to connect to this two urls :
* http://training.training.io:<NODEPORT>/path1
* http://training.training.io:<NODEPORT>/path2

## Get command

### Resume

The get command list the object asked. It could be a single object or a list of multiple objects comma separated. This command is useful to get the status of each object. The output can be formatted to only display some information based on some json search or external tools like tr, sort, uniq.

The default output display some useful information about each services :
* Name : the name of the newly created resource
* Hosts : the host to apply the newly created resource
* Address : the address exposed by the newly created resource
* Ports : the ports exposed by the resource
* Age : the age since his creation

### Exercise

List the current Ingress resources created.

```
kubectl get ingress
```
