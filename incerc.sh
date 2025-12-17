

#!usr/bin/env bash

file=$1

while read -r line; do
    echo -e "$line\n"
done <$file 
