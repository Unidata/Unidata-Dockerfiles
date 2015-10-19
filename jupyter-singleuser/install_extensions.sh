#!/bin/bash
source activate py3
git clone --depth=1 https://github.com/merqurio/jupyter_themes

jupyter nbextension install --user jupyter_themes
jupyter nbextension enable jupyter_themes/theme_selector

git clone --depth=1 https://github.com/ipython-contrib/IPython-notebook-extensions nbexts

cd nbexts/nbextensions/usability

for ext in runtools ruler ; do
    jupyter nbextension install --user $ext
    jupyter nbextension enable $ext/main
done;

