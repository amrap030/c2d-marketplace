#!/bin/bash

DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

declare -a proofs_iterative=("1" "2" "4" "8" "16")
declare -a proofs_merkle=("2" "4")
declare -a folders=("max" "mean" "median" "min" "standard_deviation" "sum" "threshold" "variance")
#declare -a folders=("standard_deviation")

export PATH=$PATH:~/.zokrates/bin

for folder in "${folders[@]}"
do  
    for proof in "${proofs_iterative[@]}"
    do
        cd $DIR/$folder/iterative/$proof/zokrates
        pwd
        echo "Benchmarking: $proof"

        cmdbench -i 1 -j ../measurements/compilation.json -A "zokrates compile -i main.zok"

        sleep 5

        cat input.txt | xargs cmdbench -i 1 -j ../measurements/witness.json -A "zokrates compute-witness -a"

        sleep 5

        cmdbench -i 1 -j ../measurements/setup.json -A "zokrates setup"

        sleep 5

        cmdbench -i 1 -j ../measurements/proof.json -A "zokrates generate-proof"
    done
    sleep 10
done