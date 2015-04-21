from pyhiccup.core import html
from html5print import HTMLBeautifier
from os import listdir
from os.path import isfile, join

mypath = "/home/idv/test-output/results/"

onlyfiles = [ f for f in listdir(mypath) if isfile(join(mypath,f)) ]

data = ['table', [['tr',
                   ['td', ['img', {'src' : str("./baseline/" + x)}]],
                   ['td', ['img', {'src' : str("./results/" + x)}]]]
                  for x in onlyfiles]]

myhtml = html(data)

pretty = HTMLBeautifier.beautify(myhtml, 2)

f = open('./test-output/compare.html','w')
f.write(pretty)
f.close()
