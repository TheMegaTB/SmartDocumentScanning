#!/bin/bash
OUT=${1%/}
ORIGIN=$(pwd)
TMP_DIR=$(mktemp -d)

if [ -z $OUT ]; then
    echo "Please specify a output directory (absolute path)"
    exit 1
fi

function get_category {
    echo "Searching for QR code in $1"
    ZBAR_OUT=$(zbarimg --raw $1 2> /dev/null)
    if [ $? -eq 0 ]; then
        CATEGORY=$(sed -n "/\b${ZBAR_OUT}\b/p" ${ORIGIN}/../categories | awk '{print $2}')
        if [ ! -z "${CATEGORY}" ]; then
            QR=${CATEGORY}
        else
            QR=${ZBAR_OUT}
        fi
        echo "Sorting into $QR"
    fi
}

function process {
    echo "Processing pages . . ."
    PREV=""
    COUNTER=1
    for f in $(ls -v *\.tif); do
        # Convert to JPEG and downscale
        convert "$f" -background black -fuzz 75% -deskew 50% -trim +repage \
            -limit memory 32 -limit map 64 -units PixelsPerInch -density 72 -quality 60 -format jpg "$f.jpg"
        # Try categorizing the image by a QR code
        get_category "${f}.jpg"
        if [ -z $PREV ]; then
            PREV="$f.jpg"
            continue
        else
            # Set the fallback category
            if [ -z "${QR}" ]; then
                QR="Other"
            fi

            timestamp=$(date +%s)

            # Check the files for content and move it to its corresponding output folder
            $ORIGIN/is_empty.py ${PREV}
            if [ $? -eq 0 ]; then
                mkdir -p "${OUT}/${QR}"
                mv "${PREV}" "${OUT}/${QR}/${timestamp}-P1"
            fi
            $ORIGIN/is_empty.py ${f}
            if [ $? -eq 0 ]; then
                mkdir -p "${OUT}/${QR}"
                mv "${f}.jpg" "${OUT}/${QR}/${timestamp}-P2"
            fi

            QR=""
            PREV=""
        fi

        COUNTER=$((COUNTER + 1))
    done
}

echo $TMP_DIR
chmod -R 777 $TMP_DIR
cd $TMP_DIR

echo "Scanning images . . ."
scanimage --format=tiff -b --mode Color --resolution=600 --variance=255 --emphasis=100 --ald=yes --source="ADF Duplex" --sleeptimer=1 --bgcolor=Black

process

# mv *.jpg $OUT/

#rm -r $TMP_DIR
