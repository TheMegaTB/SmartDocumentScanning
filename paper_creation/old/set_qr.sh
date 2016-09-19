#!/bin/sh
CONTENT=$1
PAPER=$2
qrencode -o qr.png -lH -d600 -m0 -s100 "$CONTENT"
./set_qr.py ${PAPER}
rm qr.png
