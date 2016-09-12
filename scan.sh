OUT=$1
ORIGIN=$(pwd)
TMP_DIR=$(mktemp -d)

if [ -z $OUT ]; then
    echo "Please specify a output directory (absolute path)"
    exit 1
fi

echo $TMP_DIR
chmod -R 777 $TMP_DIR
cd $TMP_DIR
scanimage --format=tiff -b --mode Color --resolution 600 --ald=yes --source="ADF Duplex" --sleeptimer 1

$ORIGIN/process.sh
#mogrify -limit memory 32 -limit map 64 -units PixelsPerInch -density 72 -quality 60 -format jpg *.tif

#rm *.tif

mv *.jpg $OUT/

#rm -r $TMP_DIR
