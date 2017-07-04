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

    cd ..
done
