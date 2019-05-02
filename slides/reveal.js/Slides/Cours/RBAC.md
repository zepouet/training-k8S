## RBAC


--------


### NEEDS


--------


Have multiple users with different properties,
<br/>establishing a proper authentication mechanism.


--------


Have full control over which operations each user
<br/>or group of users can execute.


--------


Have full control over which operations each process
<br/>inside a pod can execute.


--------


Limit the visibility of certain resources of namespaces.


--------


### The key to understanding
### RBAC in Kubernetes


--------


<img src="Slides/Img/rbac/rbac0.png" />


--------


#### Subjects

<br/>
The set of users and processes that want to access the Kubernetes API.


--------


#### Resources
<br/>
The set of Kubernetes API Objects available in the cluster.
<br/>
<br/>Examples include Pods, Deployments, Services, Nodes,
<br/>and PersistentVolumes, among others.


--------


#### Verbs
<br/>
The set of operations that can be executed to the resources above.

<br/>
<br/>Different verbs are available
<br/>(examples: get, watch, create, delete, etc.),


--------


### Understanding RBAC API Objects


--------


#### Roles

Definition of the permissions for each Kubernetes resource type


--------


#### RoleBindings

Definition of what Subjects have which Roles


--------


<img src="Slides/Img/rbac/rbac4.png" />


--------


<img src="Slides/Img/rbac/rbac1.png" />


--------


<img src="Slides/Img/rbac/rbac6.png" />


--------


### Users and ... ServiceAccounts


--------


#### Users


These are global, and meant for humans
<br/>or processes living outside the cluster.


--------


#### ServiceAccounts


These are namespaced and meant
<br/>for intra-cluster processes running inside pods.


--------


### ClusterRoles
### ClusterRoleBindings


--------


#### Give permissions for

* non-namespaced resources like nodes
* permissions for resources in all the namespaces of a cluster
* permissions for non-resource endpoints like /healthz


--------


```
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: example-clusterrole
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "watch", "list"]
```  


--------


```
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: example-clusterrolebinding
subjects:
- kind: User
  name: example-user
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: example-clusterrole
  apiGroup: rbac.authorization.k8s.io
```  
