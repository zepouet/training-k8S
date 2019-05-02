port="[0-9]{1,5}$"
pwd="$(pwd)/reveal.js"
if [[ $3 ]]
  then
    pwd=$3
fi

if [[ $2 =~ $port ]]
  then
    docker container run -d -p $1:8000 -v $pwd/index.html:/reveal.js/index.html \
      -v $pwd/Slides/Cours:/reveal.js/Slides/Cours \
      -v $pwd/Slides/theme:/reveal.js/Slides/theme \
      -v $pwd/Slides/Img:/reveal.js/Slides/Img \
      -v $pwd/plugin:/reveal.js/plugin \
      sphinxgaia/sgdocker-reveal:3.6-alpine
      echo "Votre container est lancé sur le port : $1"
else
      docker container run -d -p 8000:8000 -v $pwd/index.html:/reveal.js/index.html \
        -v $pwd/Slides/Cours:/reveal.js/Slides/Cours \
        -v $pwd/Slides/theme:/reveal.js/Slides/theme \
        -v $pwd/Slides/Img:/reveal.js/Slides/Img \
        -v $pwd/plugin:/reveal.js/plugin \
        sphinxgaia/sgdocker-reveal:3.6-alpine
        echo "Votre container est lancé sur le port : 8000"
fi
