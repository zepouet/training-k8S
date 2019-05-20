## Ingress


--------


<img src="Slides/Img/Ingress/ingress-wall.png" width="60%" />


--------


### Overview
<img src="Slides/Img/Ingress/detail.png" width="60%" />



--------

### ingress
#### Role
<br/>
Ingress **exposes** HTTP and HTTPS routes <br/>from outside the cluster to services within the cluster.


--------

### ingress
#### Rules
<br/>
Traffic routing is **controlled by rules**
<br/>defined on the ingress resource.


--------


### ingress
#### Features
<br/>
An ingress can be configured
<br/>to give services **externally-reachable** URLs,
<br/>load balance traffic, terminate SSL,
<br/>and offer name based virtual hosting..


--------


### ingress
#### Features
<br/>
An ingress does not expose arbitrary ports or protocols.
<br/>
<br/>
Exposing services other than HTTP and HTTPS
<br/>to the internet uses a **Service type**


--------


## Ingress Controller


--------


### Ingress Controller
#### definition
<br/>
An ingress controller is responsible
<br/>for **satisfying an ingress declaration**,
<br/> usually with a **loadbalancer**,
<br/>though it may also configure the edge router
<br/>or additional frontends to help handle the traffic.


--------


### Ingress Controller
#### definition
<br/>
Kubernetes as a project currently
<br/>
supports and maintains
<br/>
GCE and nginx controllers.


--------


### Ingress Controller
#### solutions
<img src="Slides/Img/Ingress/solutions.png" width="60%" />



--------


## Ingress Type


--------


### Ingress Type
#### Single service ingress
<br/>
Basic concept integrated to Kubernetes.
<br/>
Redirect traffic to an internal Service.


--------


### Ingress Type
#### Single service ingress
<br/>
```
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: webserver
spec:
  backend:
    serviceName: webserver
    servicePort: 80
```


--------


### Ingress Type
#### Simple fanout
<br/>
A fanout configuration routes traffic
<br/>from a single IP address to more than one service,
<br/>based on the **HTTP URI** being requested



--------


### Ingress Type
#### Simple fanout
```
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: webserver
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - host: foo.bar.com
    http:
      paths:
      - path: /foo
        backend:
          serviceName: webserver
          servicePort: 80
      - path: /bar
        backend:
          serviceName: webserver2
          servicePort: 8080
```        


--------


### Ingress Type
#### Name based virtual hosting
<br/>
Name-based virtual hosts support routing HTTP traffic
<br/>to **multiple host names** at the same IP address.



--------


### Ingress Type
#### Name based virtual hosting
```
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: webserver
spec:
  rules:
  - host: foo.bar.com
    http:
      paths:
      - backend:
          serviceName: webserver
          servicePort: 80
  - host: bar.foo.com
    http:
      paths:
      - backend:
          serviceName: webserver2
          servicePort: 80
```


--------


### Ingress Type
#### TLS
<br/>
Ingress can be **secured** by specifying
<br/>a Secret that contains a TLS private key and certificate.
<br/>
<br/>
Currently the ingress only supports a single TLS port (**443**)
<br/> and assumes TLS termination.


--------


### Ingress Type
#### TLS
<br/>
```
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: webserver
spec:
  tls:
  - hosts:
    - sslexample.foo.com
    secretName: testsecret-tls
  rules:
    - host: sslexample.foo.com
      http:
        paths:
        - path: /
          backend:
            serviceName: webserver
            servicePort: 80
```            
