#!/bin/bash

DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

declare -a proofs_iterative=("1" "2" "4" "8" "16")
declare -a proofs_merkle=("2" "4")
declare -a folders=("max" "mean" "median" "min" "standard_deviation" "sum" "threshold" "variance")


# for folder in "${folders[@]}"
# do
#     RESULT="$DIR/$folder/iterative/$folder.txt"
    
#     if [ ! -f "$RESULT" ] 
#     then
#         echo "proof,timestamp,compiled_size,proving_key_size,verification_key_size,verifier_size" > $RESULT
#     fi
    
#     for proof in "${proofs[@]}"
#     do
#         cd $DIR/$folder/iterative/$proof/zokrates
#         echo "Benchmarking: $proof"

#         compiled_size=$(du -kh $DIR/$folder/iterative/$proof/zokrates/out | cut -f1 | sed 's/\([0-9]\),/\1./g' | xargs)
#         proving_key_size=$(du -kh $DIR/$folder/iterative/$proof/zokrates/proving.key  | cut -f1 | sed 's/\([0-9]\),/\1./g' | xargs)
#         verification_key_size=$(du -kh $DIR/$folder/iterative/$proof/zokrates/verification.key | cut -f1 | sed 's/\([0-9]\),/\1./g' | xargs)
#         verifier_size=$(du -kh $DIR/$folder/iterative/$proof/zokrates/verifier.sol | cut -f1 | sed 's/\([0-9]\),/\1./g' | xargs)

#         cd ..
#         cd ./verification

#         #deployment_gas=$(truffle test | cut -f1 | grep "Verifier" | awk '{print $8}' | xargs)

#         row="$proof,$(date +%s),$compiled_size,$proving_key_size,$verification_key_size,$verifier_size"

#         echo $row >> $RESULT
#     done
# done

for folder in "${folders[@]}"
do
    RESULT="$DIR/$folder/merkle/$folder.txt"
    
    if [ ! -f "$RESULT" ] 
    then
        echo "proof,timestamp,deployment_gas,compiled_size,proving_key_size,verification_key_size,verifier_size" > $RESULT
    else
        rm -f "$DIR/$folder/merkle/$folder.txt"
        echo "proof,timestamp,deployment_gas,compiled_size,proving_key_size,verification_key_size,verifier_size" > $RESULT
    fi
    
    for proof in "${proofs_merkle[@]}"
    do
        cd $DIR/$folder/merkle/$proof/zokrates
        echo "Benchmarking: $proof"

        compiled_size=$(du -kh $DIR/$folder/merkle/$proof/zokrates/out | cut -f1 | sed 's/\([0-9]\),/\1./g' | xargs)
        proving_key_size=$(du -kh $DIR/$folder/merkle/$proof/zokrates/proving.key  | cut -f1 | sed 's/\([0-9]\),/\1./g' | xargs)
        verification_key_size=$(du -kh $DIR/$folder/merkle/$proof/zokrates/verification.key | cut -f1 | sed 's/\([0-9]\),/\1./g' | xargs)
        verifier_size=$(du -kh $DIR/$folder/merkle/$proof/zokrates/verifier.sol | cut -f1 | sed 's/\([0-9]\),/\1./g' | xargs)

        cp ./verifier.sol ../../../../contracts
        cp ./proof.json ../../../../contracts

        cd $DIR
        deployment_gas=$(yarn test | cut -f1 | grep "Verifier" | awk '{print $8}' | xargs)

        row="$proof,$(date +%s),$deployment_gas,$compiled_size,$proving_key_size,$verification_key_size,$verifier_size"

        echo $row >> $RESULT
    done
    sleep 5
done