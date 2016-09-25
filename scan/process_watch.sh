src=${1}
out=${2}
origin=$(pwd)

inotifywait -m "${src}" -e create -e moved_to |
    while read path action file; do
        if [ "$file" == "scan_done" ]; then
            tmp=$(mktemp -d)

            echo "PROCESSING @ ${tmp}"
            mv ${src}/*.tif "${tmp}/"
            ./scan.sh process ${tmp} ${out}

            rm "${src}/scan_done"
            
            echo "DONE PROCESSING"
        fi
    done
