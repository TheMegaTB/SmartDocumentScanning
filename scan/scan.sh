#!/bin/sh
OUT=$1
ORIGIN=$(pwd)
TMP_DIR=$(mktemp -d)

if [ -z $OUT ]; then
    echo "Please specify a output directory (absolute path)"
    exit 1
fi

function process() {
    echo "Processing pages . . ."
    PREV=""
    COUNTER=1
    for f in $(ls -v *\.tif); do
        if [ -z $PREV ]; then
            PREV=$f
            continue
        else
            PAGES=""
            $ORIGIN/is_empty.py $PREV
            if [ $? -eq 0 ]; then
                PAGES="$PREV"
            fi
            $ORIGIN/is_empty.py $f
            if [ $? -eq 0 ]; then
                PAGES="$PAGES $f"
            fi
            echo $PAGES
            if [ ! -z "$PAGES" ]; then
                convert $PAGES -background black -fuzz 75% -deskew 50% -trim +repage \
                    +append -rotate 0 -limit memory 32 -limit map 64 -units PixelsPerInch -density 72 -quality 60 -format jpg "sheet_$COUNTER.jpg"
            else
                echo "Skipping empty double page!"
            fi
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

mv *.jpg $OUT/

#rm -r $TMP_DIR
