#!/usr/bin/python3.5

import cv2, imutils, sys, os
import numpy as np
from subprocess import call

scale = 35
A4 = (297, 210)

# Set canvas size (A4 dimensions * scale)
(height, width) = tuple(scale * x for x in A4)

# Create white canvas
canvas = np.full((height, width, 3), 255, np.uint8)
print("Created canvas w/ dimensions " + str((height, width)))

# Read the input data
data = sys.argv[1]

# Set QR size and load it
(qrx, qry) = (int(float(sys.argv[2]) * scale), int(float(sys.argv[3]) * scale))
(qrw, qrh) = (int(float(sys.argv[4]) * scale), int(float(sys.argv[5]) * scale))

print("Creating QR code @ " + str((qrx, qry)) + " w/ dimensions " + str((qrw, qrh)))
call(["qrencode", "-o", "qr.png", "-lH", "-d600", "-m0", "-s100", data])
qr = cv2.imread("qr.png")

# Add information square
cv2.rectangle(qr, (1400, 1400), (2100, 2100), (0, 0, 0), -1)  # Draw big black rectangle for border
cv2.rectangle(qr, (1500, 1500), (2000, 2000), (255, 255, 255), -1)  # Draw smaller white rectangle for fill

# Add label to info square
font = cv2.FONT_HERSHEY_SIMPLEX
font_scale = 5
font_thickness = 3
text_size = cv2.getTextSize(data, font, font_scale, font_thickness)[0]
offset = (int(text_size[0] / 2), int(text_size[1] / 2))
cv2.putText(qr, data, (1750 - offset[0], 1750 + offset[1]), font, font_scale, (0, 0, 0), font_thickness)

# Insert QR code into canvas
canvas[qry:qry+qrh, qrx:qrx+qrw] = imutils.resize(qr, width=qrw, height=qrh)

cv2.imwrite("out.tif", canvas)
os.remove("qr.png")
