## Quotas and Limits


--------

## Quotas and Limits
### Definition

<br/>
> Limiter les utilisateurs<br/>dans un monde **fini** en ressources



--------


## Quotas and Limits
### Goal
<br/>
- Learn the format of a YAML Resource Quota and Limit Range file
- Learn how to automatically define limits to Pods
- Learn the composition of a ResourceQuota


--------


## Quotas
### Pods resources
<br/>
Pods resources are measurable quantities that can be <br/>**requested**, **allocated**, and **consumed**
<br/><br/>


--------


### Pods resources

<br/>
Although requests and limits <br/>can only be specified on **individual Containers**,
<br/>it is convenient to talk about Pod resource requests and limits.


--------


### Pods resources
#### Resource type
<br/>
**CPU** and **memory** are each a resource type.


--------



### Pods resources
### Creation
<br/>
The most basic resource metrics for a pod are CPU and memory.
<br/><br/>
Kubernetes provides requests and limits <br/>to pre-allocate resources and limit resource usage, respectively.


--------


### Pods resources

<img src="Slides/Img/Quota/pod.png" width="50%" />



--------



### Pods resources
#### Eviction Rules

<br/>
Limits restrict the resource usage of a pod as follows if :
<br/>
<br/>
- Its memory usage exceeds the memory limit, this pod is out of memory (OOM) **killed**.
- Its CPU usage exceeds the CPU limit, this pod is **not killed**, but its CPU usage is restricted to the limit.




--------



### Pods resources
#### CPU
<br/>
Limits and requests for CPU resources <br/>are measured in **CPU units**.



--------


### Pods resources
#### MEMORY
<br/>
Limits and requests for memory are measured in **bytes**.
<br/><br/>
Memory can express as a plain integer <br/>or as a fixed-point integer using one of these suffixes :
<br/><br/>E, P, T, G, M, K
<br/>or
<br/>Ei, Pi, Ti, Gi, Mi, K



--------


### Pods resources
#### YAML FILES

```
apiVersion: v1
kind: Pod
metadata:
  name: webserver
spec:
  containers:
  - image: nginx
    name: http
    resources:
      requests:
        memory: "64Mi"
        cpu: "250m"
      limits:
        memory: "128Mi"
        cpu: "500m"
```        


--------


### Resource quotas
#### MEMORY
<br/>
Limits and requests for memory are measured in **bytes**.
<br/><br/>
Memory can express as a plain integer <br/>or as a fixed-point integer using one of these suffixes :
<br/><br/>E, P, T, G, M, K
<br/>or
<br/>Ei, Pi, Ti, Gi, Mi, K


--------


## Quotas
### ResourceQuota
<br/>
Kubernetes provides the **ResourceQuota** object to set constraints on the number of Kubernetes objects by type and the amount of resources (CPU and memory) in a namespace.



--------


## Quotas
### ResourceQuota
<br/>
One or more **ResourceQuota** objects <br/>can be created in a namespace.


--------


## Quotas
### ResourceQuota
<br/>
- If the **ResourceQuota** object is configured in a namespace, **requests** and **limits** must be set during deployment; <br/>otherwise, pod creation is rejected.
<br/><br/>
- To avoid this problem, the **LimitRange** object can be used to set the default requests and limits for each pod.


--------


### Resource Quotas


<img src="Slides/Img/Quota/quota.png" width="60%" />


--------


### Resource Quotas Type
#### CPU

<br/>
Limit the amount of CPU resources requested


--------


### Resource Quotas Type
#### MEMORY

<br/>
Limit the amount of memory resources requested.


--------


### Resource Quotas Type
#### Storage

<br/>
Limit the total sum of storage resources <br/>
that can be requested in a given namespace.


--------


### Resource Quotas Type
#### Object

<br/>
Limit the amount of each object <br/>that can be created in a namespace.


--------


### Resource Quotas Type YAML

```
apiVersion: v1
kind: ResourceQuota
metadata:
  name: compute-resources
  namespace: development
spec:
  hard:
    pods: "4"
    requests.cpu: "1"
    requests.memory: 1Gi
    limits.cpu: "2"
    limits.memory: 2Gi
    requests.nvidia.com/gpu: 4
```    


--------


### Limit Range
#### Rules
<br/>
The **LimitRange** object is used to set the <br/>**default resource requests and limits**
<br/>as well as minimum and maximum constraints
<br/>for each pod in a namespace



--------


### Limit Range
#### Rules
<br/>
If a container is created in a namespace <br/>that has a default memory or CPU limit, <br/>and the container does not specify its own memory or CPU limit, <br/>then the container is assigned the default memory or CPU limit


--------


### Limit Range
#### YAML FILE

```
apiVersion: v1
kind: LimitRange
metadata:
  namespace: example
spec:
  limits:
  - default:  # default limit
      memory: 512Mi
      cpu: 2
    defaultRequest:  # default request
      memory: 256Mi
      cpu: 0.5
    max:  # max limit
      memory: 800Mi
      cpu: 3
    min:  # min request
      memory: 100Mi
      cpu: 0.3
    maxLimitRequestRatio:  # max value for limit / request
      memory: 2
      cpu: 2
    type: Container
    # limit type, support: Container / Pod / PersistentVolumeClaim
```    


--------


### Limit type
#### Default
<br/>
Indicates default limits.


--------


### Limit type
#### defaultRequest
<br/>
Indicates default requests.


--------


### Limit type
#### max / min

<br/>
Indicates maximum / minimum limits.


--------


### Limit type
#### maxLimitRequestRatio
<br/>
Indicates the maximum ratio of a limit to a request. Because a node schedules resources based on pod requests, resources can be oversold.

<br/>The maxLimitRequestRatio parameter indicates the maximum oversold ratio of pod resources.


--------


## Qos & Pod Eviction



--------


### Qos Class Definition
#### Guaranteed
<br/>
Limits and requests are set for all containers in a pod. Each limit is equal to the corresponding request.
<br/><br/>If a limit is set but the corresponding request is not set, the request is automatically set to the limit value



--------


```
spec:
  containers:
    ...
    resources:
      limits:
        cpu: 700m
        memory: 200Mi
      requests:
        cpu: 700m
        memory: 200Mi
...
  qosClass: Guaranteed
```  


--------


### Qos Class Definition
#### Burstable
<br/>
Limits are not set for certain containers in a pod, or certain limits are not equal to the corresponding requests. During node scheduling, this type of pod may overclock nodes


--------


### Qos Class Definition
#### BestEffort
<br/>
Limits and requests are not set for any containers in a pod.


--------


### Pod Eviction
#### Rules

If the memory and CPU resources of a node are insufficient and this node starts to evict its pods, the QoS level also affects the eviction priority as follows


--------


### Pod Eviction
#### Rules 1/4


The kubelet preferentially evicts pods whose QoS level is BestEffort and pods whose QoS level is Burstable with resource usage larger than preset requests.


--------


### Pod Eviction
#### Rules 2/4

Then, the kubelet evicts pods whose QoS level is Burstable with resource usage smaller than preset requests.


--------


### Pod Eviction
#### Rules 3/4


At last, the kubelet evicts pods whose QoS level is Guaranteed. The kubelet preferentially prevents pods whose QoS level is Guaranteed from being evicted due to resource consumption of other pods.

--------


### Pod Eviction
#### Rules 4/4


If pods have the same QoS level, the kubelet determines the eviction priority based on the pod priority (QosClass)


--------


### Exercises
#### QuotasLimits
