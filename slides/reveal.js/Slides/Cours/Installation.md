
# Installation (A REPRENDRE)


--------



## Installation de Kubernetes
### Les différentes possibilités d'installer Kubernetes

En local avec minikube :
- VT-x ou AMD-v virtualization doivent être activer dans le BIOS
- Installer un hypervieur (virtualbox)
- Installer Kubectl (client qui permet de communiquer avec le cluster)
- Installer Minikube (outil qui permet de déployer tous les composants de kubernetes dans une VM)
- Minikube installe par défault les outils réseaux permettant la communication au sein du cluster

Sur un serveur avec kubedam :
- Outil qui permet de déployer un cluster Kubernetes facilement
- Utiliser CentOS ou Ubuntu
- 2GB par serveur
- 2CPUS ou plus pour le master
- Installer Docker
- Kubeadm n'installe pas par défault les outils réseaux permettant la communication au sein du cluster


--------


## Installation de Kubernetes
### Installation en local avec minikube (1/2)


- Installer kubectl sur Linux

~~~bash
$  curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl

~~~

- Installer kubectl sur MacOS

~~~bash
$  curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/darwin/amd64/kubectl

~~~

Rendre le binaire éxecutable

~~~bash
$  chmod +x kubectl

~~~

Déplacer le binaire dans votre PATH

~~~bash
$  sudo mv kubectl /usr/local/bin/kubectl

~~~


--------


## Installation de Kubernetes
### Installation en local avec minikube (2/2)

- Installation de minikube

Récupérer le dernière version de minikube correspondant à votre OS:
[https://github.com/kubernetes/minikube/releases](https://github.com/kubernetes/minikube/releases)

~~~bash
$  minikube start
~~~

Il est possible de spécifier l'hyperviseur lors du démarrage de minikube

~~~bash
$  minikube start --driver=xxx
~~~


--------


## Installation de Kubernetes
### Installation sur un serveur avec kubeadm (1/5)


Sur l'ensemble des serveurs :


Installer Docker avec la version recomandée 1.12. Les versions 1.11, 1.13, et 17.03 fonctionnent également
~~~bash
$  apt-get install docker.io
~~~


Installer kubelet, kubeadm, kubectl

~~~bash
apt-get update && apt-get install -y apt-transport-https
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF
apt-get update
apt-get install -y kubelet kubeadm kubectl
~~~


--------


## Installation de Kubernetes
### Installation sur un serveur avec kubeadm (2/5)


Initialiser le master (cela peut prendre plusieurs minutes)
~~~bash
sudo kubeadm init --pod-network-cidr=10.244.0.0/16
~~~


L'installation effectue les actions suivantes :
- Création des clés et certificats
- Ecriture sur le disque les fichiers de configurations dans /etc/kubernetes
- Déploiement des composants du cluster
- Affiche la Token qui permet de joindre des noeuds

Notez bien cette token, elle sera utilisée dans la suite de l'installation


Par défault, l'installation de Kubernetes n'installe pas de CNI (Container Network Interface) qui est nécessaire pour la communication entre les pods


--------


## Installation de Kubernetes
### Installation sur un serveur avec kubeadm (3/5)

Une fois l'installation du master terminé, exportez le fichier de configuration de Kubernetes dans votre home pour pouvoir intéragir avec le cluster

~~~bash
$mkdir -p $HOME/.kube
$sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
$sudo chown $(id -u):$(id -g) $HOME/.kube/config
~~~


Installer un CNI pour la communication entre les pods
Le CNI utilisé sera Flannel

~~~bash
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/v0.9.1/Documentation/kube-flannel.yml
~~~


--------


## Installation de Kubernetes
### Installation sur un serveur avec kubeadm (4/5)


Vérifier que tous les composants sont dans l'état "Ready" et avec le status "Running"
~~~bash
$kubectl get pods --all-namespaces
~~~

###### ![Img_install_kubeadm_output](Slides/Img/Presentation_de_k8s/5_5_k8s_install_kubeadm_output.png)


--------


## Installation de Kubernetes
### Installation sur un serveur avec kubeadm (5/5)

Une fois les pods "kube-dns" sont démarrés, le cluster est prêt à accepter d'autres membres dans le cluster

Pour ajouter un membre dans le cluster, récupérer la token affichée sur le terminal à la fin de l'installation, et la coller sur le serveur que l'on souhaite joindre au cluster


Si n'avez pas noter la token, il est possible d'en générer une nouvelle

~~~bash
$kubeadm token create --print-join-command
~~~


Depuis le master, vérifier que le serveur est présent dans le cluster
~~~bash
$kubectl get nodes
~~~
