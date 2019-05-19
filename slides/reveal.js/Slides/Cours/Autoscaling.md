## Autoscaling


--------

## Objectives

* Understand the notion of Autoscaling
* Understand the management principles of this object
* Manage the different aspects of Autoscaling
* To be able to relate the notion to concrete cases
* Identify the prerequisites necessary for the implementation of these principles


--------


## Autoscaling
### Horizontal Pod Autoscaler
<br/>
The Horizontal Pod Autoscaler (HPA) automatically scales the number of pods in
a replication controller, deployment or replica set based on observed CPU, memory utilization or custom metrics


--------


## Autoscaling
### Horizontal Pod Autoscaler
<img src="Slides/Img/Autoscaling/hpa.png" width="30%" />


--------


## Autoscaling
### Vertical Pod Autoscaler

<br/>
Vertical Pods Autoscaler (VPA) allocates <br/>
more (or less) cpu or memory to existing pods.
<br/>
<br/>
This feature is **not production** ready yet


--------


## Autoscaling
### Cluster Autoscaler

<br/>
[Documentation GKE](https://cloud.google.com/kubernetes-engine/docs/concepts/cluster-autoscaler)

```
gcloud container clusters create example-cluster \
  --zone us-central1-a \
  --node-locations us-central1-a,us-central1-b,us-central1-f \
  --num-nodes 2
  --enable-autoscaling --min-nodes 1 --max-nodes 4
```


--------


## Autoscaling
### Horizontal Scaler

<br/>
HPA does not apply to objects
<br/>that can’t be scaled like DaemonSets


--------


## Autoscaling
### Horizontal Scaler

<br/>
The HPA is implemented as a control loop,
<br/>with a period controlled
<br/>by the controller manager’s (default 30s)


--------


## Autoscaling
### Horizontal Scaler

<br/>
**Heapster** or **Metrics Server**
<br/>has to be deployed
<br/>to get metrics from Pods.
<br/>
<br/>The Pods resources must be defined
<br/>to allow HPA controller to automatically scale


--------


### Horizontal Pod Autoscaler
#### Process

HPA **continuously checks metrics** values configured during setup intervals.


--------


### Horizontal Pod Autoscaler
#### Process

HPA attempts to **increase the number of pods** If the specified threshold is met.


--------


### Horizontal Pod Autoscaler
#### Process

HPA mainly **updates the number of replicas** inside the deployment or replication controller.


--------


### Horizontal Pod Autoscaler
#### Process

The Deployment/Replication Controller would then **roll-out any additional needed pods**


--------


### Horizontal Pod Autoscaler
#### Keep in mind

<br/>
The default HPA check interval is 30 seconds.
<br/>
<br/>
This can be configured through the 
<br/>
**horizontal-pod-autoscaler-sync-period**
<br/>flag of the controller manager


--------


### Horizontal Pod Autoscaler
#### Keep in mind

<br/>
Default HPA relative metrics tolerance is 10%


--------


### Horizontal Pod Autoscaler
#### Keep in mind

<br/>
HPA waits for 3 minutes after the last scale-up events
<br/>to allow metrics to stabilize.
<br/>
<br/>
This can also be configured through
<br/>**horizontal-pod-autoscaler-upscale-delay** flag


--------


### Horizontal Pod Autoscaler
#### Keep in mind

<br/>

HPA waits for 5 minutes from the last scale-down event
<br/>to avoid autoscaler thrashing.

<br/>
Configurable through 
<br/>**horizontal-pod-autoscaler-downscale-delay** flag


--------


### Horizontal Pod Autoscaler
#### Keep in mind

<br/>
HPA works best with deployment objects
<br/>as opposed to replication controllers.
<br/>
<br/>
Does **not** work with rolling update
<br/>using direct manipulation of replication controllers.
<br/>


--------


### Horizontal Pod Autoscaler
#### Keep in mind
<br/>
It depends on the deployment object
<br/>to manage the size of underlying replica sets
<br/>when you do a deployment


--------


### Horizontal Pod Autoscaler
#### Limitations
<br/>
When using HPA on memory metrics,
<br/>the memory has to be released
<br/>by the application itself


--------


### Horizontal Pod Autoscaler
#### Limitations
<br/>
Kubernetes **cannot** handle the **memory released process**


--------


### Horizontal Pod Autoscaler
#### Limitations
<br/>
If an OOM occurred, the application will be rescheduled


--------


### Horizontal Pod Autoscaler
#### Limitations
<br/>
The autoscaling definition will override the ReplicaSet
<br/>if the definition is under the minimum required replicas


--------


#### Example with CPU

```
apiVersion: autoscaling/v2beta2
kind: HorizontalPodAutoscaler
metadata:
  name: webserver
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: webserver
  minReplicas: 3
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 80
```

```
kubectl autoscale deployment php-apache --cpu-percent=80 --min=3 --max=10
```


--------


## Exercises
### Autoscaling
