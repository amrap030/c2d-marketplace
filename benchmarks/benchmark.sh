#!/bin/bash

DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

declare -a proofs_iterative=("1" "2" "4" "8" "16")
declare -a proofs_merkle=("2" "4")
declare -a folders=("max" "mean" "median" "min" "standard_deviation" "sum" "threshold" "variance")
#declare -a folders=("standard_deviation")

export PATH=$PATH:~/.zokrates/bin

for folder in "${folders[@]}"
do  
    RESULT="$DIR/$folder/iterative/$folder.txt"

    if [ ! -f "$RESULT" ] 
    then
        echo "proof,timestamp,constraints,deployment_gas,compiled_size,proving_key_size,verification_key_size,verifier_size,compiled_verifier" > $RESULT
    else
        rm -f "$DIR/$folder/iterative/$folder.txt"
        echo "proof,timestamp,constraints,deployment_gas,compiled_size,proving_key_size,verification_key_size,verifier_size,compiled_verifier" > $RESULT
    fi
    for proof in "${proofs_iterative[@]}"
    do
        rm -f $DIR/$folder/iterative/$proof/measurements/compilation1.txt
        rm -f $DIR/$folder/iterative/$proof/measurements/compilation2.txt
        rm -f $DIR/$folder/iterative/$proof/measurements/compilation3.txt

        rm -f $DIR/$folder/iterative/$proof/measurements/witness1.txt
        rm -f $DIR/$folder/iterative/$proof/measurements/witness2.txt
        rm -f $DIR/$folder/iterative/$proof/measurements/witness3.txt
        
        rm -f $DIR/$folder/iterative/$proof/measurements/setup1.txt
        rm -f $DIR/$folder/iterative/$proof/measurements/setup2.txt
        rm -f $DIR/$folder/iterative/$proof/measurements/setup3.txt
    
        rm -f $DIR/$folder/iterative/$proof/measurements/proof1.txt
        rm -f $DIR/$folder/iterative/$proof/measurements/proof2.txt
        rm -f $DIR/$folder/iterative/$proof/measurements/proof3.txt

        cd $DIR/$folder/iterative/$proof/zokrates
        pwd
        echo "Benchmarking: $proof"

        #cmdbench -i 1 -j ../measurements/compilation.json -A "zokrates compile -i main.zok"
        $DIR/monitor.sh zokrates compile -i $DIR/$folder/iterative/$proof/zokrates/main.zok -o $DIR/$folder/iterative/$proof/zokrates/out $DIR/$folder/iterative/$proof/measurements/compilation1.txt > $DIR/$folder/iterative/$proof/measurements/constraints.txt
        compiled_size=$(du -kh $DIR/$folder/iterative/$proof/zokrates/out | cut -f1 | sed 's/\([0-9]\),/\1./g' | xargs)
        constraints=$(cat $DIR/$folder/iterative/$proof/measurements/constraints.txt | cut -f1 | grep "constraints:" | awk '{print $4}' | xargs)
        sleep 5

        $DIR/monitor.sh zokrates compile -i $DIR/$folder/iterative/$proof/zokrates/main.zok -o $DIR/$folder/iterative/$proof/zokrates/out $DIR/$folder/iterative/$proof/measurements/compilation2.txt
        sleep 5

        $DIR/monitor.sh zokrates compile -i $DIR/$folder/iterative/$proof/zokrates/main.zok -o $DIR/$folder/iterative/$proof/zokrates/out $DIR/$folder/iterative/$proof/measurements/compilation3.txt
        sleep 5

        #cat input.txt | xargs cmdbench -i 1 -j ../measurements/witness.json -A "zokrates compute-witness -a"
        input=$(cat input.txt)
        #echo $input
        $DIR/monitor.sh zokrates compute-witness -i $DIR/$folder/iterative/$proof/zokrates/out -o $DIR/$folder/iterative/$proof/zokrates/witness -a $input $DIR/$folder/iterative/$proof/measurements/witness1.txt

        sleep 5

        $DIR/monitor.sh zokrates compute-witness -i $DIR/$folder/iterative/$proof/zokrates/out -o $DIR/$folder/iterative/$proof/zokrates/witness -a $input $DIR/$folder/iterative/$proof/measurements/witness2.txt

        sleep 5

        $DIR/monitor.sh zokrates compute-witness -i $DIR/$folder/iterative/$proof/zokrates/out -o $DIR/$folder/iterative/$proof/zokrates/witness -a $input $DIR/$folder/iterative/$proof/measurements/witness3.txt

        sleep 5

        #cmdbench -i 1 -j ../measurements/setup.json -A "zokrates setup"
        $DIR/monitor.sh zokrates setup -i $DIR/$folder/iterative/$proof/zokrates/out -p $DIR/$folder/iterative/$proof/zokrates/proving.key -v $DIR/$folder/iterative/$proof/zokrates/verification.key $DIR/$folder/iterative/$proof/measurements/setup1.txt
        proving_key_size=$(du -kh $DIR/$folder/iterative/$proof/zokrates/proving.key  | cut -f1 | sed 's/\([0-9]\),/\1./g' | xargs)
        verification_key_size=$(du -kh $DIR/$folder/iterative/$proof/zokrates/verification.key | cut -f1 | sed 's/\([0-9]\),/\1./g' | xargs)
        sleep 5

        $DIR/monitor.sh zokrates setup -i $DIR/$folder/iterative/$proof/zokrates/out -p $DIR/$folder/iterative/$proof/zokrates/proving.key -v $DIR/$folder/iterative/$proof/zokrates/verification.key $DIR/$folder/iterative/$proof/measurements/setup2.txt
        sleep 5

        $DIR/monitor.sh zokrates setup -i $DIR/$folder/iterative/$proof/zokrates/out -p $DIR/$folder/iterative/$proof/zokrates/proving.key -v $DIR/$folder/iterative/$proof/zokrates/verification.key $DIR/$folder/iterative/$proof/measurements/setup3.txt
        sleep 5

        #cmdbench -i 1 -j ../measurements/proof.json -A "zokrates generate-proof"
        $DIR/monitor.sh zokrates generate-proof -i $DIR/$folder/iterative/$proof/zokrates/out -p $DIR/$folder/iterative/$proof/zokrates/proving.key -j $DIR/$folder/iterative/$proof/zokrates/proof.json $DIR/$folder/iterative/$proof/measurements/proof1.txt
    
        sleep 5

        $DIR/monitor.sh zokrates generate-proof -i $DIR/$folder/iterative/$proof/zokrates/out -p $DIR/$folder/iterative/$proof/zokrates/proving.key -j $DIR/$folder/iterative/$proof/zokrates/proof.json $DIR/$folder/iterative/$proof/measurements/proof2.txt
    
        sleep 5

        $DIR/monitor.sh zokrates generate-proof -i $DIR/$folder/iterative/$proof/zokrates/out -p $DIR/$folder/iterative/$proof/zokrates/proving.key -j $DIR/$folder/iterative/$proof/zokrates/proof.json $DIR/$folder/iterative/$proof/measurements/proof3.txt
    
        sleep 5

        zokrates export-verifier
        verifier_size=$(du -kh $DIR/$folder/iterative/$proof/zokrates/verifier.sol | cut -f1 | sed 's/\([0-9]\),/\1./g' | xargs)
    
        cp ./verifier.sol ../../../../contracts
        cp ./proof.json ../../../../contracts

        cd $DIR
        pwd
        deployment_gas=$(yarn test | cut -f1 | grep "Verifier" | awk '{print $8}' | xargs)
        compiled_verifier=$(yarn test | cut -f1 | grep "Verifier" | awk '{print $4}' | xargs | sed 's/\(.*\)-/\1 /')

        row="$proof,$(date +%s),$constraints,$deployment_gas,$compiled_size,$proving_key_size,$verification_key_size,$verifier_size,$compiled_verifier"

        echo $row >> $RESULT

        rm -rfv $DIR/$folder/iterative/$proof/zokrates/out*
        rm -rfv $DIR/$folder/iterative/$proof/zokrates/*.json
        rm -rfv $DIR/$folder/iterative/$proof/zokrates/*.key
        rm -rfv $DIR/$folder/iterative/$proof/zokrates/*.sol
        rm -rfv $DIR/$folder/iterative/$proof/zokrates/witness
    done
    sleep 10
done

for folder in "${folders[@]}"
do  
    RESULT="$DIR/$folder/merkle/$folder.txt"

    if [ ! -f "$RESULT" ] 
    then
        echo "proof,timestamp,constraints,deployment_gas,compiled_size,proving_key_size,verification_key_size,verifier_size,compiled_verifier" > $RESULT
    else
        rm -f "$DIR/$folder/merkle/$folder.txt"
        echo "proof,timestamp,constraints,deployment_gas,compiled_size,proving_key_size,verification_key_size,verifier_size,compiled_verifier" > $RESULT
    fi
    for proof in "${proofs_merkle[@]}"
    do
        rm -f $DIR/$folder/merkle/$proof/measurements/compilation1.txt
        rm -f $DIR/$folder/merkle/$proof/measurements/compilation2.txt
        rm -f $DIR/$folder/merkle/$proof/measurements/compilation3.txt

        rm -f $DIR/$folder/merkle/$proof/measurements/witness1.txt
        rm -f $DIR/$folder/merkle/$proof/measurements/witness2.txt
        rm -f $DIR/$folder/merkle/$proof/measurements/witness3.txt
        
        rm -f $DIR/$folder/merkle/$proof/measurements/setup1.txt
        rm -f $DIR/$folder/merkle/$proof/measurements/setup2.txt
        rm -f $DIR/$folder/merkle/$proof/measurements/setup3.txt
    
        rm -f $DIR/$folder/merkle/$proof/measurements/proof1.txt
        rm -f $DIR/$folder/merkle/$proof/measurements/proof2.txt
        rm -f $DIR/$folder/merkle/$proof/measurements/proof3.txt

        cd $DIR/$folder/merkle/$proof/zokrates
        pwd
        echo "Benchmarking: $proof"

        #cmdbench -i 1 -j ../measurements/compilation.json -A "zokrates compile -i main.zok"
        constraints=$DIR/monitor.sh zokrates compile -i $DIR/$folder/merkle/$proof/zokrates/main.zok -o $DIR/$folder/merkle/$proof/zokrates/out $DIR/$folder/merkle/$proof/measurements/compilation1.txt > $DIR/$folder/merkle/$proof/measurements/constraints.txt
        compiled_size=$(du -kh $DIR/$folder/merkle/$proof/zokrates/out | cut -f1 | sed 's/\([0-9]\),/\1./g' | xargs) | grep "constraints:" | 
        constraints=$(cat $DIR/$folder/iterative/$proof/measurements/constraints.txt | cut -f1 | grep "constraints:" | awk '{print $4}' | xargs)
        sleep 5

        $DIR/monitor.sh zokrates compile -i $DIR/$folder/merkle/$proof/zokrates/main.zok -o $DIR/$folder/merkle/$proof/zokrates/out $DIR/$folder/merkle/$proof/measurements/compilation2.txt
        sleep 5

        $DIR/monitor.sh zokrates compile -i $DIR/$folder/merkle/$proof/zokrates/main.zok -o $DIR/$folder/merkle/$proof/zokrates/out $DIR/$folder/merkle/$proof/measurements/compilation3.txt
        sleep 5

        #cat input.txt | xargs cmdbench -i 1 -j ../measurements/witness.json -A "zokrates compute-witness -a"
        input=$(cat input.txt)
        echo $input
        $DIR/monitor.sh zokrates compute-witness -i $DIR/$folder/merkle/$proof/zokrates/out -o $DIR/$folder/merkle/$proof/zokrates/witness -a $input $DIR/$folder/merkle/$proof/measurements/witness1.txt

        sleep 5

        $DIR/monitor.sh zokrates compute-witness -i $DIR/$folder/merkle/$proof/zokrates/out -o $DIR/$folder/merkle/$proof/zokrates/witness -a $input $DIR/$folder/merkle/$proof/measurements/witness2.txt

        sleep 5

        $DIR/monitor.sh zokrates compute-witness -i $DIR/$folder/merkle/$proof/zokrates/out -o $DIR/$folder/merkle/$proof/zokrates/witness -a $input $DIR/$folder/merkle/$proof/measurements/witness3.txt

        sleep 5

        #cmdbench -i 1 -j ../measurements/setup.json -A "zokrates setup"
        $DIR/monitor.sh zokrates setup -i $DIR/$folder/merkle/$proof/zokrates/out -p $DIR/$folder/merkle/$proof/zokrates/proving.key -v $DIR/$folder/merkle/$proof/zokrates/verification.key $DIR/$folder/merkle/$proof/measurements/setup1.txt
        proving_key_size=$(du -kh $DIR/$folder/merkle/$proof/zokrates/proving.key  | cut -f1 | sed 's/\([0-9]\),/\1./g' | xargs)
        verification_key_size=$(du -kh $DIR/$folder/merkle/$proof/zokrates/verification.key | cut -f1 | sed 's/\([0-9]\),/\1./g' | xargs)
        sleep 5

        $DIR/monitor.sh zokrates setup -i $DIR/$folder/merkle/$proof/zokrates/out -p $DIR/$folder/merkle/$proof/zokrates/proving.key -v $DIR/$folder/merkle/$proof/zokrates/verification.key $DIR/$folder/merkle/$proof/measurements/setup2.txt
        sleep 5

        $DIR/monitor.sh zokrates setup -i $DIR/$folder/merkle/$proof/zokrates/out -p $DIR/$folder/merkle/$proof/zokrates/proving.key -v $DIR/$folder/merkle/$proof/zokrates/verification.key $DIR/$folder/merkle/$proof/measurements/setup3.txt
        sleep 5

        #cmdbench -i 1 -j ../measurements/proof.json -A "zokrates generate-proof"
        $DIR/monitor.sh zokrates generate-proof -i $DIR/$folder/merkle/$proof/zokrates/out -p $DIR/$folder/merkle/$proof/zokrates/proving.key -j $DIR/$folder/merkle/$proof/zokrates/proof.json $DIR/$folder/merkle/$proof/measurements/proof1.txt
    
        sleep 5

        $DIR/monitor.sh zokrates generate-proof -i $DIR/$folder/merkle/$proof/zokrates/out -p $DIR/$folder/merkle/$proof/zokrates/proving.key -j $DIR/$folder/merkle/$proof/zokrates/proof.json $DIR/$folder/merkle/$proof/measurements/proof2.txt
    
        sleep 5

        $DIR/monitor.sh zokrates generate-proof -i $DIR/$folder/merkle/$proof/zokrates/out -p $DIR/$folder/merkle/$proof/zokrates/proving.key -j $DIR/$folder/merkle/$proof/zokrates/proof.json $DIR/$folder/merkle/$proof/measurements/proof3.txt
    
        sleep 5

        zokrates export-verifier
        verifier_size=$(du -kh $DIR/$folder/merkle/$proof/zokrates/verifier.sol | cut -f1 | sed 's/\([0-9]\),/\1./g' | xargs)
    
        cp ./verifier.sol ../../../../contracts
        cp ./proof.json ../../../../contracts

        cd $DIR
        pwd
        test_output=$(yarn test)
        deployment_gas=$(echo $test_output | cut -f1 | grep "Verifier" | awk '{print $125}' | xargs)
        compiled_verifier=$(echo $test_output | cut -f1 | grep "Verifier" | awk '{print $50}' | xargs | sed 's/\(.*\)-/\1 /')

        row="$proof,$(date +%s),$constraints,$deployment_gas,$compiled_size,$proving_key_size,$verification_key_size,$verifier_size,$compiled_verifier"

        echo $row >> $RESULT

        rm -rfv $DIR/$folder/merkle/$proof/zokrates/out*
        rm -rfv $DIR/$folder/merkle/$proof/zokrates/*.json
        rm -rfv $DIR/$folder/merkle/$proof/zokrates/*.key
        rm -rfv $DIR/$folder/merkle/$proof/zokrates/*.sol
        rm -rfv $DIR/$folder/merkle/$proof/zokrates/witness
    done
    sleep 10
done