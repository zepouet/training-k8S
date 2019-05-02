## Stratégies de déploiement


--------

#### Plusieurs types

> De nombreuses stratégies sont possibles <br/>mais elles ont un coût différent

- Sur l'infrastructure
- Sur le consommateur


--------


#### Les différentes stratégies


- Suppression/création
- Rampe
- Blue/green
- Canary
- A/B Testing
- Shadow


--------


#### Recreate

- La version A est supprimée
- La version B est démarrée


--------


<img src="Slides/Img/Orchestration/recreate.gif" />


--------


### Recreate
<br/>
#### Avantages
- Facile à mettre en oeuvre
- Etat de l'application entièrement neuf

<br/>
#### Inconvénients
- Coupure du consommateur


--------


#### Ramped - RollingUpdate - Incremental

> Changement lent et progressif <br/>des instances A <br/>par des instances B

En fonction de l'orchestrateur, il est possible de changer :
- le parallélisme
- le nombre d'instance max indisponibles
- le nombre de nouvelles instances B à ajouter (exemple 130%)


--------


#### Ramped - RollingUpdate - Incremental

<img src="Slides/Img/Orchestration/ramped.gif" />


--------


### Ramped - RollingUpdate - Incremental
<br/>
#### Avantages
- Facile à mettre en oeuvre
- Versions lentement mises à jour sans interruption de Services
- Parfait pour les applications StateLess
- Peut convenir **toutefois** aux applications StateFull !

<br/>
#### Inconvénients
- Rollback peut prendre du temps
- Difficulté de supporter différentes API en //
- Pas de contrôle sur le traffic.




--------


#### Blue / Green


> Après déploiement de la nouvelle version et tests de conformité<br/>tout le traffic est redirigé dessus


--------


#### Blue / Green


<img src="Slides/Img/Orchestration/blue-green.gif" />



--------



### Blue / Green
<br/>
#### Avantages
- Rollback instantané
- Pas de collision de version tout est changé en one shot !

<br/>
#### Inconvénients
- Coûteux car nécessite le double de ressources
- Besoin de jouer des tests sur la version nouvellement déployée
- La gestion d'applications avec états peut être compliquée


--------



### EXERCICE BLUEGREEN



--------



#### Canary


> Même famille que le Blue/Green
> <br/>Graduellement traffic redirigé de la version A à la version B

Par exemple :
- 90% des requêtes vont à la version A
- 10% des requêtes vont à la version B

> Bien pratique quand on ne peut tester le B/G



--------



#### Canary


<img src="Slides/Img/Orchestration/canary.gif" />



--------



### Canary
<br/>
#### Avantages
- Version disponibles seulement pour un sous-ensemble d'utilisateurs
- Parfait pour tester le monitoring et des métriques sur la nouvelle version
- Rollback rapide et facile

<br/>
#### Inconvénients
- Même que Blue/Green (attention au cas des tests)


--------


#### A/B Testing


> Redirection des utilisateurs sous conditions <br/>vers une des deux versions

> Permet de prendre des décisions business <br/>sur base de statistiques



--------



#### A/B Testing

conditions:
- Cookies
- Query Parameters
- Geo location
- Browser (version, os...)
- Langue



--------




#### A/B Testing


<img src="Slides/Img/Orchestration/a-b.gif" />



--------



### A/B Testing
<br/>
#### Avantages
- Plusieurs versions disponibles en parallèle
- Contrôle totale de la distribution du traffic
- Rollback rapide et facile

#### Inconvénients
- Nécessite un LB dit "intelligent"
- Difficile de débogguer les erreurs pour une session donnée
- Besoin d'utiliser de distribution tracing (zipkin, sleuth...)



--------


#### A/B Testing


> Redirection des utilisateurs sous conditions <br/>vers une des deux versions

> Permet de prendre des décisions business <br/>sur base de statistiques



--------


#### Shadow

> Duplication des applications et des flux réseaux. <br/>Chaque version recevant la copie du flux.



--------




#### Shadow


<img src="Slides/Img/Orchestration/shadow.gif" />



--------



### Shadow
<br/>
#### Avantages
- Test de la nouvelle application avec un vrai traffic
- Aucun impact sur l'utilisateur
- Aucun changement jusqu'à obtenir les garanties en terme de stabilité et performance

#### Inconvénients
- Coûteux car nécessite le double de ressources
- Limite de l'exercice quand on doit écrire en base de données...
- Compliqué à mettre en oeuvre (écriture...)
- Nécessite des Mocks pour certains services --> effet de bords



--------


<img width="80%" src="Slides/Img/Orchestration/decision-diagram.png" />
