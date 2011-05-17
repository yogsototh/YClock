#!/bin/bash

# options='-label %f -geometry 200x200'
options='-geometry 200x200'
for i in `seq 1 12`; do
    echo -n "image $i composition."
    composite arriere.png fond.png tmp.png
    echo -n "."
    composite -geometry +140+140 motif$i.png tmp.png tmp.png
    echo "."
    composite -geometry +140+140 dessus.png tmp.png tmpMotif$i.png
    options="$options -label $i tmpMotif$i.png"
done

echo "montage $options res.jpg"

montage $options res.jpg

echo "suppression des fichiers temporaires..."
\rm -f tmpMotif* tmp*
