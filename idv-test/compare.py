import math, operator
from pyhiccup.core import html
from html5print import HTMLBeautifier
from os import listdir
from os.path import isfile, join
from PIL import ImageChops
from PIL import Image

# Path for test images
TEST_PATH = "/home/idv/test-output/"
mypath = TEST_PATH + "results/"

myfiles = [ f for f in listdir(mypath) if isfile(join(mypath,f)) ]

# http://code.activestate.com/recipes/577630-comparing-two-images/
def rmsdiff(i1, i2):
    "Calculate the root-mean-square difference between two images"
    im1, im2 = Image.open(i1), Image.open(i2)
    diff = ImageChops.difference(im1, im2)
    h = diff.histogram()
    sq = (value*(idx**2) for idx, value in enumerate(h))
    sum_of_squares = sum(sq)
    rms = math.sqrt(sum_of_squares/float(im1.size[0] * im1.size[1]))
    return rms

myfiles = [("./baseline/" + f,
             "./results/" + f,
             rmsdiff(TEST_PATH + "baseline/" + f, TEST_PATH + "results/" + f))
             for f in listdir(mypath) if isfile(join(mypath,f)) ]

sortimgs = sorted(myfiles, key=lambda img: img[2])

data = [['ul', {'align' : 'left'} ],
        [['li',
          ['p', x[0]],
          [[['span', {'style':'white-space: nowrap'}],
            ['img', {'src' : x[0]}],
            ['img', {'src' : x[1]}]]]]
         for x in sortimgs[::-1]]]

myhtml = html(data)

pretty = HTMLBeautifier.beautify(myhtml, 2)

f = open(TEST_PATH + 'compare.html','w')
f.write(pretty)
f.close()
