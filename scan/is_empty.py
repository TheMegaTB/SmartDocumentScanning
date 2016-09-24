#!/usr/bin/python2
from __future__ import division
import numpy as np
import cv2
import sys
import time

if len(sys.argv) < 2:
    print("Please specify a input file")
    exit(1)

# load the image, crop 10% at the borders, convert it to grayscale, and blur it slightly
image = cv2.imread(sys.argv[1])

height, width, channels = image.shape
vertical_crop = int(height * 0.02)
horizontal_crop = int(width * 0.05)
cropped = image[vertical_crop: height - vertical_crop, horizontal_crop: width - horizontal_crop]

gray = cv2.cvtColor(cropped, cv2.COLOR_BGR2GRAY)
blurred = cv2.GaussianBlur(gray, (7, 7), 0)

# apply Canny edge detection using a wide threshold, tight
# threshold, and automatically determined threshold
canny = cv2.Canny(blurred, 225, 250)

pixels = canny.size
edges = (np.asarray(canny) > 0).sum()
edge_percentage = edges / pixels * 100

print(edge_percentage)

cv2.imwrite(str(time.time()) + "_edges.tif", canny)

if edge_percentage > 0.04:
    exit(0)
else:
    print("EMPTY PAGE!")
    exit(404)
