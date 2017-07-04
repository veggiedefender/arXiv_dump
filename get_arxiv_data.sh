#!/usr/bin/bash

s3cmd get 's3://arxiv/src/arXiv_src_manifest.xml' --requester-pays
mkdir -p out
mapfile -t filenames < <(grep -oP 'arXiv_.*\.tar' arXiv_src_manifest.xml)

for filename in "${filenames[@]}"
do
    echo "$filename"
    s3cmd get "s3://arxiv/src/$filename" out --requester-pays
    cd out || exit

    tar -xf "$filename"
    rm "$filename"
    cd "$(echo "$filename" | cut -d '_' -f 3)" || exit

    find . -maxdepth 1 -type f -not -name "*.gz" -delete

    mapfile -t papers < <(ls -- *.gz)
    for paper in "${papers[@]}"
    do
        folder=$(echo "$paper" | cut -d '.' -f 1)
        mkdir "$folder"
        mv "$paper" "$folder"
        cd "$folder" || exit

        if tar -xf "$paper" 2>/dev/null
        then
            rm "$paper"
        else          
            if ! gunzip "$paper" 2>/dev/null
            then
                echo "FAILED EXTRACTING $paper WITH BOTH tar -xf AND gunzip!"
                rm "$paper"
            fi
        fi
        cd ..
    done
    cd ..
done
