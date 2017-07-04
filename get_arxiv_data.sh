#!/usr/bin/bash

s3cmd get 's3://arxiv/src/arXiv_src_manifest.xml' --requester-pays
filenames=($(grep -oP 'src\/.+\.tar' arXiv_src_manifest.xml))

for filename in "${filenames[@]}"
do
    echo "$filename"
done