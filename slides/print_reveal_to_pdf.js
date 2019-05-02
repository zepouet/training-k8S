#!/bin/bash
chmod 0777 pdf
docker build -t revealtmp .
docker network create reveal
docker container run --net=reveal -d --name revealweb -p 8000:8000 revealtmp

docker run --rm --net=reveal -v `pwd`:/slides sphinxgaia/reveal_exportpdf:2.6.3 -s 1920x1080 http://$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' revealweb):8000 pdf/$1.pdf
docker container rm -f revealweb
docker network rm reveal
