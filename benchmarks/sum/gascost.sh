#!/bin/bash

DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

declare -a proofs=("sum_32" "sum_64" "sum_128" "sum_256" "sum_512" "sum_768")

SUMS="$DIR/sum.txt"

if [ ! -f "$SUMS" ] 
then
	echo "proof,timestamp,deployment_gas,compiled_size,proving_key_size,verification_key_size" > $SUMS
fi

for proof in "${proofs[@]}"
do
    cd $DIR/$proof/zokrates
    echo "Benchmarking: $proof"

    compiled_size=$(du -kh $DIR/$proof/zokrates/out | cut -f1 | sed 's/\([0-9]\),/\1./g' | xargs)
	proving_key_size=$(du -kh $DIR/$proof/zokrates/proving.key  | cut -f1 | sed 's/\([0-9]\),/\1./g' | xargs)
	verification_key_size=$(du -kh $DIR/$proof/zokrates/verification.key | cut -f1 | sed 's/\([0-9]\),/\1./g' | xargs)

    cd ..
    cd ./verification

    deployment_gas=$(truffle test | cut -f1 | grep "Verifier" | awk '{print $8}' | xargs)

    row="$proof,$(date +%s),$deployment_gas,$compiled_size,$proving_key_size,$verification_key_size"

    echo $row >> $SUMS
done