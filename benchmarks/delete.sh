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
        rm -rfv ./out* ./*json ./*.key ./*.sol ./witness
    done
done