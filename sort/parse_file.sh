#!/bin/sh
FILE=$1
QR=$(zbarimg --raw ${FILE})
if [ $? -eq 0 ]; then
    echo "$QR"
else
    echo "No QR found"
fi