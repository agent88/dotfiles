#!/bin/bash
i=1; temp=$(mktemp -p .); for file in "$1"*
do
mv "$file" $temp;
mv $temp $(printf "$2_%0.3d.$3" $i)
i=$((i + 1))
done
