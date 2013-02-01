#!/bin/bash
echo "bootstrapping buildout"
python bootstrap.py
echo "running buildout"
bin/buildout -c buildout-salt.cfg
echo "sync and migrate"
bin/django syncdb --noinput --migrate
echo "collect static files"
bin/django collectstatic -l --noinput 
echo "download example data"
wget https://dl.dropbox.com/u/172498/code/store.tar.gz
tar -xvzf store.tar.gz -C var/store
wget https://dl.dropbox.com/u/172498/code/exampledata.json
bin/django loaddata exampledata.json

echo 
echo "changed=true"
