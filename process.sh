PREV=""
COUNTER=1
for f in *.tif; do
    if [ -z $PREV ]; then
        PREV=$f
        continue
    else
        echo "$PREV + $f"
        # TODO: Check if one of the sides is blank and ignore it
        convert $PREV $f +append -rotate 180 -limit memory 32 -limit map 64 -units PixelsPerInch -density 72 -quality 60 -format jpg "sheet_$COUNTER.jpg"
        #rm $PREV $f
        PREV=""
    fi

    COUNTER=$((COUNTER + 1))
done
