# docker-by-treeptik
echo 'Building Docker By Treetpik'
docker container run --rm -v `pwd`:/source sphinxgaia/pandoc-docker:2.0.6 $(ls reveal.js/Slides/Cours/*.md) \
 --toc --variable title='Docker By Treeptik' \
 --pdf-engine=xelatex \
 --resource-path='./reveal.js/' \
 --highlight-style=tango \
 -o $1.pdf
