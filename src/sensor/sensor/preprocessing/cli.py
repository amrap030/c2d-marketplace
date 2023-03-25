from argparse import ArgumentParser, Namespace
from zokrates import write_zokrates_input, createMerkleRoot

parser = ArgumentParser()

parser.add_argument('-i', '--input', type=int, nargs='+')
parser.add_argument('-m', '--merkle', action='store_true')

args: Namespace = parser.parse_args()

if args.merkle == True:
    print(" ".join(createMerkleRoot(args.input)))
else:
    print(" ".join(write_zokrates_input(args.input)))

# example
# 
# python3 cli.py -i 0 4294967295 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 4294967295 0 0 0 0 0 0 0 0 0 0 0 0 0 4294967295