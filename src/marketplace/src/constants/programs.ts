export const zokratesSum32 = `import "hashes/sha256/1024bitPadded.code" as sha256_1024;
import "hashes/sha256/512bitPadded.code" as sha256_512;
import "hashes/sha256/256bitPadded.code" as sha256_256;
import "signatures/verifyEddsa.code" as verifyEddsa;
import "ecc/babyjubjubParams.code" as context;
import "utils/pack/u32/nonStrictUnpack256.code" as unpack;
import "utils/pack/u32/pack256.code" as pack256;
import "utils/casts/u32_to_field.code" as u32_to_field;
from "ecc/babyjubjubParams" import BabyJubJubParams;

def main(private u32[32] values, private field nonce, private field[2] R, private field S, field[2] A, u32[8] M0, u32[8] M1) -> (bool, bool, field) {
    // verify signature
    BabyJubJubParams context = context();
    bool isVerified = verifyEddsa(R, S, A, M0, M1, context);
    assert(isVerified);

    // calculate hash of input values from dataset
    u32[8] hash = sha256_1024(values[0..8],values[8..16],values[16..24],values[24..32]);

    // check integrity of input values
    bool isHashMatching = hash == M0 && hash == M1;
    assert(isHashMatching);

    // computation of sum
    field mut sum = 0;
    for u32 i in 0..32 {
        sum = sum + u32_to_field(values[i]);
    }

    // create merkle tree
    u32[8] h_computation = sha256_256(unpack(sum));
    u32[8] h_nonce = sha256_256(unpack(nonce));

    field result = pack256(sha256_512(h_computation, h_nonce));

    return (isVerified, isHashMatching, result);
}`;