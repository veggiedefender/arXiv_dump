#!/usr/bin/bash

s3cmd get 's3://arxiv/src/arXiv_src_manifest.xml' --requester-pays
mkdir -p out

filenames=($(grep -oP 'arXiv_.*\.tar' arXiv_src_manifest.xml))

for filename in "${filenames[@]}"
do
    echo "$filename"
    s3cmd get "s3://arxiv/src/$filename" out --requester-pays
    cd out

    tar -xf "$filename"
    rm "$filename"
    cd $(echo "$filename" | cut -d '_' -f 3)

    find -maxdepth 1 -type f -not -name "*.gz" -delete

    papers=($(ls *.gz))
    for paper in "${papers[@]}"
    do
        folder=$(echo "$paper" | cut -d '.' -f 1)
        mkdir "$folder"
        mv "$paper" "$folder"
        cd "$folder"

        tar -xf "$paper" 2>/dev/null
        if [ $? -eq 0 ]; then
            echo "Extracted $paper with tar -xf"
            rm "$paper"
        else
            echo "Failed extracting $paper with tar -xf"
            gunzip "$paper" 2>/dev/null
            if [ $? -eq 0 ]; then
                echo "EXTRACTED $paper with gunzip"
            else
                echo "Failed extracting $paper with gunzip"
                rm "$paper"
            fi
        fi
        cd ..
    done
    cd ..
done
