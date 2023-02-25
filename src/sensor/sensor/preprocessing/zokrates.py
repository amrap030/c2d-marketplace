import hashlib
import struct
from zokrates_pycrypto.eddsa import PrivateKey, PublicKey
from zokrates_pycrypto.field import FQ
from zokrates_pycrypto.utils import write_signature_for_zokrates_cli

field = FQ(4119294109970220640150288050462269036920476551472432758423588320001472495115)
signKey = PrivateKey(field)
verifyKey = PublicKey.from_private(signKey)

def int_to_bytes(num: int):
    "Transforms the input into a 32 bit integer."
    return int.to_bytes(num, 4, "big")

def get_bytes_packed(numbers: list[int]):
    bytes_packed_list = [int_to_bytes(numbers[i]) for i in range(0,len(numbers))]
    bytes_packed = bytes_packed_list[0]
    for i in range(1, len(bytes_packed_list)):
        bytes_packed += bytes_packed_list[i]
    return bytes_packed

def get_sha_256(val: bytes):
    "Calculates a SHA256 hash for the input."
    return hashlib.sha256(val).digest()

def write_zokrates_input(numbers: list[int]):
    sha256_hash = get_sha_256(get_bytes_packed(numbers))
    sha256_hash += sha256_hash
    signature = signKey.sign(sha256_hash)
    return [
        " ".join([str(i) for i in struct.unpack(">%dI" % len(numbers), get_bytes_packed(numbers))][-len(numbers):]),
        write_signature_for_zokrates_cli(verifyKey, signature, sha256_hash)
    ]

def write_signature_for_zokrates_cli(pk, sig, msg):
    "Writes the input arguments for verifyEddsa in the ZoKrates stdlib to file."
    sig_R, sig_S = sig
    args = [sig_R.x, sig_R.y, sig_S, pk.p.x.n, pk.p.y.n]
    args = " ".join(map(str, args))
    M0 = msg.hex()[:64]
    M1 = msg.hex()[64:]
    b0 = [str(int(M0[i:i+8], 16)) for i in range(0,len(M0), 8)]
    b1 = [str(int(M1[i:i+8], 16)) for i in range(0,len(M1), 8)]
    args = args + " " + " ".join(b0 + b1)
    return args

output = write_zokrates_input([0,4294967295,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4294967295,0,0,0,0,0,0,0,0,0,0,0,0,0,4294967295])
print(" ".join(output))
