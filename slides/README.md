# How to run it 

Lancement rapide :
- Lancer run_test [PORT PATH]
- Par défaut le script utilise le chemin absolue vers le répertoire courant + `reveal.js`/...

ou
Build :
~~~bash
docker build -t your_name .
~~~

- le build utilise l'instruction ONBUILD vers le répertoire `reveal.js` et copie le fichier `index.html` et le dossier `Slides`

# treeptik-formations

Création d'un template de formation

la technologie retenue est reveal.js :
- Simple à utiliser
- Markdown compatible
- Fichier externe compatible
- Génération de PDFs (même avec conteneur supplémentaire)
- Animation possible via Markdown
- Gestion du CSS pour le visuel


# How to index.html:

- Les fichiers doivent être écrit en markdown et intégrés comme suit dans le html :

~~~html
<section data-markdown="Slides/Cours/Presentation_de_Docker.md"
         data-separator="^\r\n\r\n----\r\n\r\n|\n\n----\n\n"
         data-separator-vertical="^\n\n--------\n\n|\r\n\r\n--------\r\n\r\n"
         data-separator-notes="^Note:"
         data-charset="utf8">
</section>
~~~

> Sélection du fichier markdown
>
> > data-markdown="Chemin vers fichier .md"
>
> Séparateur permettant de créer plusieurs diapo avec un seul fichier md
>
> > data-separator="regexp du séparateur horizontal"
>
> > data-separator-vertical="regexp du séparateur horizontal"
>
> Gestion du séparateur des notes présentateur
>
> > data-separator-notes="^Note:"

- Intégration des plugins :

~~~js
Reveal.initialize({
  margin: 0.1,
  minScale: 0.8,
  maxScale: 1,

  dependencies: [
    { src: 'plugin/markdown/marked.js' },
    { src: 'plugin/markdown/markdown.js' },
    { src: 'plugin/zoom-js/zoom.js', async: true },
    { src: 'plugin/notes/notes.js', async: true },
    { src: 'plugin/highlight/highlight.js', async: true, callback: function() { hljs.initHighlightingOnLoad(); } },
    { src: 'plugin/title-footer/title-footer.js', async: true, callback: function() { title_footer.initialize(); } }
  ]
});
~~~

> Plugins permettant l'intégration de markdown
>
> > { src: 'plugin/markdown/marked.js' },
> >
> > { src: 'plugin/markdown/markdown.js' },
>
> Plugin zoom (Alt + Click)
>
> > { src: 'plugin/zoom-js/zoom.js', async: true },
>
> Plugin de gestion des notes présentateur :
>
> > { src: 'plugin/notes/notes.js', async: true },
>
> Plugin de mise en forme du code
>
> > { src: 'plugin/highlight/highlight.js', async: true, callback: function() {hljs.initHighlightingOnLoad(); } },
>
> Plugin de gestion du footer :
>
> > { src: 'plugin/title-footer/title-footer.js', async: true, callback: function() { title_footer.initialize(); } }
>

# Thème treeptik :

- Première Slide :
  - les titres H1 / H2 / H3 doivent impérativement être saisi afin de nommé le footer


- Slide d'exercice
  - Affichage du template grâce à une insertion de code html au début de la slide markdown :

~~~htlm
    <div class="exercice"></div>
~~~


> ajoute l'image :
> > <img src="reveal.js/Slides/theme/exercice.png" width="150">


- Utilisations des titres :
  - Titre inter slide : h1 (bleu et centré auto)
  - Titre Principale d'une slide : h2 (bleu et gauche auto)
  - Titre Secondaire : h3 (gris et gauche auto)
  - Titre tertiaire : h4 (rouge et gauche auto)

~~~txt
# titre H1
## titre H2
### titre H3
#### titre H4
~~~

- Utilisations des images :
  - mettre # devant la balise image pour centrer celle-ci
  - sinon ne rien mettre l'image sera alignée sur la gauche

~~~txt
###### ![alt text](path/to/image)
ou
 ![alt text](path/to/image)

 ~~~

 # Comment lancer la présentation :
 ## méthode 1 :
  - lancer le script avec toutes les options:
 ~~~bash
 ./run_test.sh [port] [absolute_path_to_reveal.js]
 ~~~
 ou
  - lancer juste le script à condition que :
    - le port 8000 soit disponible
    - que le dossier reveal.js se trouve dans le même répertoire que le script
 ~~~bash
 ├── reaveal.js
 │       ├── Slides
 │       └── index.html
 └── run_test.sh
 ~~~

 ## méthode 2 :

  - Construire l'image :
~~~bash
docker image build - t k8sbytreeptik .
~~~
  - Démarrer le conteneur :
~~~bash
docker container run -d -p 8000:8000 k8sbytreeptik
~~~

  - Accéder à la présentation à l'adresse http://127.0.0.1:8000
