# training-k8s-provisioning
VMs provisioning for the k8s by Treeptik training

## Prerequisites
### Binaries
Here is the list of binaries needed to execute this scripts :
* Ansible > 2.4.0
* Doctl > 1.7.0

### Credential

Export in your environment (.profile or else) credentials for Digitalocean authentication. Here is an example :
```
#- DigitalOcean
export DO_API_VERSION='2'
export DO_API_TOKEN=YOURTOKEN
export DIGITALOCEAN_ACCESS_TOKEN=YOURTOKEN
```

## To do before

* Clone this repository

* Duplicate **env.sh.example** file as **env.sh**

* Adapt configuration in **env.sh**


## VMs provisioning

Execute script **create_vms.sh**

It creates VMs on Digitalocean function of parameters set up in **env.sh**.
After VMs creation it generates :
* List of droplets for trainer in **./summary.txt**
* Ansible inventory of all VMs for the trainer in **./playbooks/hosts**
* Ansible config file in **./playbooks/ansible.cfg**
* Each user kubespray inventory in **./playbook/roles/install_k8s/files**

## Préparation des VMs

This playbook is inspired by [this article](https://treeptik.atlassian.net/wiki/spaces/BDCT/pages/99090433/k8s+-+Installer+cluster+avec+kubespray+sur+DO?atlOrigin=eyJpIjoiYjRkNjliZDgyMzE3NDk1YmJjNjk3NzY3ZmE2YjllMTciLCJwIjoiYyJ9)

Each Ansible role uses somes defaults variables stored in its **default/main.yml** file

Execute ansible playbook **prepare_vms.yml** :
```
cd playbooks
ansible-playbook prepare_vms.yml
```

This playbooks :
* Prepare all VMs
  * Install somes packages
* Prepare user master nodes
  * Clone Kubespray repository in **/home/centos/kubespray**
  * Clone Treeptik resources repository **Treeptik/training-k8s-resources** in **Treeptik-resources**
* Install kubernetes via Kubespray
  * Install Kubespray requirements
  * Initialize user Kubespray inventory
  * Push Kubespray cluster config files
  * Update default port range for NodePort
  * Run Kubespray installation playbook

## TODO
* View realtime shell output when running kubespray installation plugin
* Deploy GlusterFS
