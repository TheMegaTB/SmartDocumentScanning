#!/bin/bash
mkdir -p out
for category in $(cat ../categories | awk '{print $1}'); do
    ./create_qr.py "${category}" 177 15 20 20
    mv out.tif out/${category}.tif
    echo "Created QR code for ${category}"
done
rm qr.png
