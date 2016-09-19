#!/usr/bin/python3.5
import sys

import cv2
import imutils

from shapedetector import ShapeDetector

if len(sys.argv) < 2:
    print("Please specify a input file")
    exit(1)

# load the image and resize it to a smaller factor so that
# the shapes can be approximated better
image = cv2.imread(sys.argv[1])
ratio = image.shape[0] / float(image.shape[0])

# convert the image to grayscale, blur it slightly,
# and threshold it
gray = image[:, :, 1] #cv2.cvtColor(resized[:, :, 2], cv2.COLOR_BGR2GRAY)
blurred = cv2.GaussianBlur(gray, (5, 5), 0)
thresh = cv2.threshold(blurred, 60, 255, cv2.THRESH_BINARY)[1]
inverted = (255-thresh)


# find contours in the inverted image and initialize the
# shape detector
cnts = cv2.findContours(inverted.copy(), cv2.RETR_EXTERNAL,
                        cv2.CHAIN_APPROX_SIMPLE)
cnts = cnts[0] if imutils.is_cv2() else cnts[1]
sd = ShapeDetector()

# loop over the contours
for c in cnts:
    # compute the center of the contour, then detect the name of the
    # shape using only the contour
    M = cv2.moments(c)
    cX = int((M["m10"] / M["m00"]) * ratio)
    cY = int((M["m01"] / M["m00"]) * ratio)
    shape = sd.detect(c)

    # multiply the contour (x, y)-coordinates by the resize ratio,
    # then draw the contours and the name of the shape on the image
    c = c.astype("float")
    c *= ratio
    c = c.astype("int")
    if shape == "square":
        xoff = c[0][0][0] - 1
        yoff = c[0][0][1] - 1
        width = c[3][0][0] - c[0][0][0] + 3
        height = c[1][0][1] - c[0][0][1] + 3

    qr_img = imutils.resize(cv2.imread("qr.png"), width=width, height=height)
    tl = (int(width / 3.5), int(height / 2.5))
    br = (int(tl[0] * 2.68), int(tl[1] * 1.5))
    cv2.rectangle(qr_img, tl, br, (255, 255, 255), -1)
    cv2.putText(qr_img, "Deutsch", (tl[0], int(br[1] - (br[1] - tl[1]) * 0.25)), fontFace=cv2.FONT_HERSHEY_COMPLEX_SMALL, color=(0, 0, 0), fontScale=1)
    image[yoff:yoff+height, xoff:xoff+width] = qr_img

    cv2.imwrite("out.tif", image)

    # show the output image
    # cv2.imshow("Image", image)
    # cv2.waitKey(0)