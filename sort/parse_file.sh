#!/bin/sh
timestamp=$(date +%s)

FILE=$1
filename=$(basename "$FILE")
extension="${filename##*.}"
filename="${filename%.*}"

OUTPUT="$2"
QR=$(zbarimg --raw ${FILE} 2> /dev/null)
if [ $? -eq 0 ]; then
    echo "Sorting into $QR"
else
    QR="Other"
    echo "No QR found"
fi

CATEGORY=$(sed -n "/\b${QR}\b/p" ../categories | awk '{print $2}')

if [ ! -z "${CATEGORY}" ]; then
    QR="${CATEGORY}"
fi

mkdir -p "${OUTPUT}/${QR}"
cp "${FILE}" "${OUTPUT}/${QR}/${timestamp}.${extension}"

echo "Deduplicating files"
fdupes -rsId out