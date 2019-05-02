## Présentation
## Kubernetes


--------


### Objectifs


- Connaître l'origine et l'historique du projet
- Connaître l'architecture de k8s


--------


- Kubernetes vient du mot grec **timonier**
- Le logo représente l'idée de "pilote de conteneurs"


--------


#### K8S
Le chiffre 8 représente le nombre de caractères <br/>entre la première et dernière lettre.


--------


#### Borg
- Réécriture en GO du système <br/>développé en interne chez Google
- Google Search, Maps, Gmail, Youtube <br/>reposent sur le système **Borg**


--------


#### CNCF
Partenariat de Google & Fondation Linux <br/>pour créer la **Cloud Native Computing Foundation**

<img src="Slides/Img/Presentation_de_k8s/CNCF.png" width="50%"/>


--------


Kubernetes version 1.0 sortie en Juillet 2015 <br/>et depuis géré par la CNCF


--------


#### Rôle d'un orchestrateur


- Le déploiement
- La montée en charge
- Le cycle de vie des conteneurs


--------


#### Quelques chiffres et points clés…

- Implémenté dans 40% des environnements Docker ( Datadog)
- Forte croissance : un des projets les plus en vue de 2018/2019
- Plus de 1500 contributeurs sur Github
- Fortement adopté en production par les entreprises
- Intégration par les fournisseurs de cloud : EKS, AKS, GKE...
- Intégration par les éditeurs : Docker EE, Openshift, CoreOS... RancherOS
- Conteneur-agnostique (Docker ou RKT)
- Adapté pour les architectures logicielles en microservices


--------


#### fonctionnalités


- Container grouping using pod
- Self-healing
- Auto-scalability
- DNS management
- Load balancing
- Rolling update or rollback
- Resource monitoring and logging


--------
