#!/usr/bin/bash

# get manifest and extract urls
s3cmd get 's3://arxiv/src/arXiv_src_manifest.xml' --requester-pays
mapfile -t filenames < <(grep -oP 'arXiv_.*\.tar' arXiv_src_manifest.xml)

mkdir -p out
cd out || exit

for filename in "${filenames[@]}"
do
    echo "$filename"
    s3cmd get "s3://arxiv/src/$filename" --requester-pays

    # untar archive and delete, then cd into resulting folder
    # example: arXiv_src_0001_001.tar => 0001/
    #          arXiv_src_0001_002.tar => 0001/ as well
    #          arXiv_src_1407_006.tar => 1407/
    tar -xf "$filename"
    rm "$filename"
    cd "$(echo "$filename" | cut -d '_' -f 3)" || exit

    # remove all non *.gz files (sometimes there are PDFs and 
    # other assorted junk mixed in).
    find . -maxdepth 1 -type f -not -name "*.gz" -delete

    # iterate over all *.gz files in cwd
    mapfile -t papers < <(ls -- *.gz)
    for paper in "${papers[@]}"
    do
        # each .gz contains a bunch of files/folders
        # keep it organized by creating a folder for its contents
        # with a similar name, then cd into it.
        # example: astro-ph0001001.gz => astro-ph0001001/
        folder=$(echo "$paper" | cut -d '.' -f 1)
        mkdir "$folder"
        mv "$paper" "$folder"
        cd "$folder" || exit

        # WEIRD PART: every file is a .gz but they're not
        # actually all gzipped! Some (most) are actually tarred
        # so try `tar -xf` and `gunzip` in case it fails.
        # output a scary error message if BOTH fail.
        if tar -xf "$paper" 2>/dev/null
        then
            # clean up the folder
            rm "$paper"
        else          
            if gunzip "$paper" 2>/dev/null
            then
                # gunzip will turn quant_ph0001105.gz into quant_ph0001105
                # just add a .tex extension
                mv "$folder" "$folder.tex"
            else
                echo "FAILED EXTRACTING $paper WITH BOTH tar -xf AND gunzip!"
                rm "$paper"
            fi
        fi
        cd ..
    done
    cd ..
done
