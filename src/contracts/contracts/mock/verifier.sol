// This file is MIT Licensed.
//
// Copyright 2017 Christian Reitwiessner
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
pragma solidity ^0.8.0;

library Pairing {
  struct G1Point {
    uint X;
    uint Y;
  }
  // Encoding of field elements is: X[0] * z + X[1]
  struct G2Point {
    uint[2] X;
    uint[2] Y;
  }

  /// @return the generator of G1
  function P1() internal pure returns (G1Point memory) {
    return G1Point(1, 2);
  }

  /// @return the generator of G2
  function P2() internal pure returns (G2Point memory) {
    return
      G2Point(
        [
          10857046999023057135944570762232829481370756359578518086990519993285655852781,
          11559732032986387107991004021392285783925812861821192530917403151452391805634
        ],
        [
          8495653923123431417604973247489272438418190587263600148770280649306958101930,
          4082367875863433681332203403145435568316851327593401208105741076214120093531
        ]
      );
  }

  /// @return the negation of p, i.e. p.addition(p.negate()) should be zero.
  function negate(G1Point memory p) internal pure returns (G1Point memory) {
    // The prime q in the base field F_q for G1
    uint q = 21888242871839275222246405745257275088696311157297823662689037894645226208583;
    if (p.X == 0 && p.Y == 0) return G1Point(0, 0);
    return G1Point(p.X, q - (p.Y % q));
  }

  /// @return r the sum of two points of G1
  function addition(
    G1Point memory p1,
    G1Point memory p2
  ) internal view returns (G1Point memory r) {
    uint[4] memory input;
    input[0] = p1.X;
    input[1] = p1.Y;
    input[2] = p2.X;
    input[3] = p2.Y;
    bool success;
    assembly {
      success := staticcall(sub(gas(), 2000), 6, input, 0xc0, r, 0x60)
      // Use "invalid" to make gas estimation work
      switch success
      case 0 {
        invalid()
      }
    }
    require(success);
  }

  /// @return r the product of a point on G1 and a scalar, i.e.
  /// p == p.scalar_mul(1) and p.addition(p) == p.scalar_mul(2) for all points p.
  function scalar_mul(
    G1Point memory p,
    uint s
  ) internal view returns (G1Point memory r) {
    uint[3] memory input;
    input[0] = p.X;
    input[1] = p.Y;
    input[2] = s;
    bool success;
    assembly {
      success := staticcall(sub(gas(), 2000), 7, input, 0x80, r, 0x60)
      // Use "invalid" to make gas estimation work
      switch success
      case 0 {
        invalid()
      }
    }
    require(success);
  }

  /// @return the result of computing the pairing check
  /// e(p1[0], p2[0]) *  .... * e(p1[n], p2[n]) == 1
  /// For example pairing([P1(), P1().negate()], [P2(), P2()]) should
  /// return true.
  function pairing(
    G1Point[] memory p1,
    G2Point[] memory p2
  ) internal view returns (bool) {
    require(p1.length == p2.length);
    uint elements = p1.length;
    uint inputSize = elements * 6;
    uint[] memory input = new uint[](inputSize);
    for (uint i = 0; i < elements; i++) {
      input[i * 6 + 0] = p1[i].X;
      input[i * 6 + 1] = p1[i].Y;
      input[i * 6 + 2] = p2[i].X[1];
      input[i * 6 + 3] = p2[i].X[0];
      input[i * 6 + 4] = p2[i].Y[1];
      input[i * 6 + 5] = p2[i].Y[0];
    }
    uint[1] memory out;
    bool success;
    assembly {
      success := staticcall(
        sub(gas(), 2000),
        8,
        add(input, 0x20),
        mul(inputSize, 0x20),
        out,
        0x20
      )
      // Use "invalid" to make gas estimation work
      switch success
      case 0 {
        invalid()
      }
    }
    require(success);
    return out[0] != 0;
  }

  /// Convenience method for a pairing check for two pairs.
  function pairingProd2(
    G1Point memory a1,
    G2Point memory a2,
    G1Point memory b1,
    G2Point memory b2
  ) internal view returns (bool) {
    G1Point[] memory p1 = new G1Point[](2);
    G2Point[] memory p2 = new G2Point[](2);
    p1[0] = a1;
    p1[1] = b1;
    p2[0] = a2;
    p2[1] = b2;
    return pairing(p1, p2);
  }

  /// Convenience method for a pairing check for three pairs.
  function pairingProd3(
    G1Point memory a1,
    G2Point memory a2,
    G1Point memory b1,
    G2Point memory b2,
    G1Point memory c1,
    G2Point memory c2
  ) internal view returns (bool) {
    G1Point[] memory p1 = new G1Point[](3);
    G2Point[] memory p2 = new G2Point[](3);
    p1[0] = a1;
    p1[1] = b1;
    p1[2] = c1;
    p2[0] = a2;
    p2[1] = b2;
    p2[2] = c2;
    return pairing(p1, p2);
  }

  /// Convenience method for a pairing check for four pairs.
  function pairingProd4(
    G1Point memory a1,
    G2Point memory a2,
    G1Point memory b1,
    G2Point memory b2,
    G1Point memory c1,
    G2Point memory c2,
    G1Point memory d1,
    G2Point memory d2
  ) internal view returns (bool) {
    G1Point[] memory p1 = new G1Point[](4);
    G2Point[] memory p2 = new G2Point[](4);
    p1[0] = a1;
    p1[1] = b1;
    p1[2] = c1;
    p1[3] = d1;
    p2[0] = a2;
    p2[1] = b2;
    p2[2] = c2;
    p2[3] = d2;
    return pairing(p1, p2);
  }
}

contract Verifier {
  using Pairing for *;
  struct VerifyingKey {
    Pairing.G1Point alpha;
    Pairing.G2Point beta;
    Pairing.G2Point gamma;
    Pairing.G2Point delta;
    Pairing.G1Point[] gamma_abc;
  }
  struct Proof {
    Pairing.G1Point a;
    Pairing.G2Point b;
    Pairing.G1Point c;
  }

  function verifyingKey() internal pure returns (VerifyingKey memory vk) {
    vk.alpha = Pairing.G1Point(
      uint256(
        0x29c781bfa66d8c6d6edaebd67ff4250742121148bc6bf14e78fe518297dcf01f
      ),
      uint256(
        0x2a4baf020582198c9e22be8d6284ace356cd46f3ae04c9cca4a3d04652f346b2
      )
    );
    vk.beta = Pairing.G2Point(
      [
        uint256(
          0x2ca485909a5e7076afd812b0696eef731fd66ed5a5bf8c9d4412dd8877cf1a81
        ),
        uint256(
          0x13a54a0e48b8b2ce027d481b09789bdf29463888cc5e02376da4d43af8fbff63
        )
      ],
      [
        uint256(
          0x179427c4a7a69a3aef2c3e2ca1c30d4ba09f4cd9fd91ce6948a7d3873862ac6f
        ),
        uint256(
          0x11ed8ff00cb0ec7145b31b1d71f23a97d8eaf2100e79514079c0b2d24ac8982a
        )
      ]
    );
    vk.gamma = Pairing.G2Point(
      [
        uint256(
          0x2a595b5bcc619c6689be1fedba61618ccba4cbfe6b3f7c9b6a7f17e934cbebb8
        ),
        uint256(
          0x16255364a4ffcfbece4d4876418cf33f6a5446ef1fbf5492fbd6a42598cdd4c9
        )
      ],
      [
        uint256(
          0x021d30efe383282974632a6a169173f93520e97947488c1c79e68e5ebf9e2879
        ),
        uint256(
          0x2a45573f110f34a96c890f6357ef71ae046c9dbd76096404b541d4cc06f6301c
        )
      ]
    );
    vk.delta = Pairing.G2Point(
      [
        uint256(
          0x0a1a512c28a84603c9128a80fdf0bccc8897d28191235f4101955d936bbca3a3
        ),
        uint256(
          0x0f04727d5d3e855fc6a7e3260b286fb61aada842f0416832ae381cca09d66fdb
        )
      ],
      [
        uint256(
          0x122d2b293f216577bc5692801da7ca432b4c9bec02285395cc499f8189370672
        ),
        uint256(
          0x29d0ed34c866b7ff5ee25b9cd69a732dab83d44a05d60142ab3333aca85f0a0b
        )
      ]
    );
    vk.gamma_abc = new Pairing.G1Point[](29);
    vk.gamma_abc[0] = Pairing.G1Point(
      uint256(
        0x172862d89dd0d9fa5e20a58b15a97d01ada38d8645c3e9d32d6cc430471ddcb9
      ),
      uint256(
        0x29b64acf6864bcb582598683d5b45822fe7b6d2c33d5083a74e29c237bbe230f
      )
    );
    vk.gamma_abc[1] = Pairing.G1Point(
      uint256(
        0x02e04f2ba959cfea5f9f954b6d8937a3b2fa36c10277d9f0347385dbb7240140
      ),
      uint256(
        0x0dcf667a3f7b3f50e6dd981126fb9fe38ab1e6ef4d74059ab75fd5742765eaa1
      )
    );
    vk.gamma_abc[2] = Pairing.G1Point(
      uint256(
        0x1580b24e780867a7e369accf56ef2196b9c4cf662e894d645c89472fc5e49290
      ),
      uint256(
        0x05d737816d7ea594293fc295e0d767b6c941a5b4126d3dd053cc2c0b84abbf4f
      )
    );
    vk.gamma_abc[3] = Pairing.G1Point(
      uint256(
        0x05bc6106fb35407f3ba83e4d05a320ad75fbe5ae4958ae68fec6f5d7dce461f2
      ),
      uint256(
        0x0451ca2dcb2a6fb73ac44d2294045aeb24a415f324f3e5f200dea1317cddb941
      )
    );
    vk.gamma_abc[4] = Pairing.G1Point(
      uint256(
        0x19e3a2ccd19afa8d3a7684926883e035d5e4c8e1a357921cade0f9e90b9b9bc3
      ),
      uint256(
        0x2e7f223a1d43721a617b3b36580e64bc12f650ee5ff618c3fac702d811e4b513
      )
    );
    vk.gamma_abc[5] = Pairing.G1Point(
      uint256(
        0x0e8230a590cae5a1b0e54c66e19e344c33684de8ef60eb563159be1532de091f
      ),
      uint256(
        0x0c625b683752668f36b54a6e1d75dc42f3736141117d84e7d50ac3976315d8d6
      )
    );
    vk.gamma_abc[6] = Pairing.G1Point(
      uint256(
        0x2618a1bb4ec933fcef72d25f8326aac161599a09752de432d5bb2cce264ce980
      ),
      uint256(
        0x2d5f9c0c6cde3b1370599feebf9eff05627f797f3fbbe5c0be6458cbdfe401e9
      )
    );
    vk.gamma_abc[7] = Pairing.G1Point(
      uint256(
        0x1a9b4485bc1504abfbc5fd9628b59aadc4a4ee4b27ac7a6014e3ca84c28667b2
      ),
      uint256(
        0x0765cf43c2a3ead59c7320f94e8e7a0724d463fd336f7d76425ee629f0e67bff
      )
    );
    vk.gamma_abc[8] = Pairing.G1Point(
      uint256(
        0x11d44720b43c0a7d58d5b4c1ee9b9481c82fff6b14da96f3777d5cd6b2847b36
      ),
      uint256(
        0x1c6d7bf126fe137b769a811ac1d646615ffa5758ad33f02cfcc32455613fac99
      )
    );
    vk.gamma_abc[9] = Pairing.G1Point(
      uint256(
        0x135c76cb085833b8448f145be5dc9bec7e9a3d12f42490a9400946234cdf2fbe
      ),
      uint256(
        0x0137f56c42ed66a7b5c3ceb8012e0d14a2174137b8e66eeb2b964a6c01b67fff
      )
    );
    vk.gamma_abc[10] = Pairing.G1Point(
      uint256(
        0x0478f692aab9b7148c5869f0d90333c82f931e1ae28c7436ce4d40a3de2b818c
      ),
      uint256(
        0x0b3b4cb0ab9f72feb111ad85e634e300f6f3285785ae73a23c403b7e8bbc2dc6
      )
    );
    vk.gamma_abc[11] = Pairing.G1Point(
      uint256(
        0x1be81ea0b63eab28cb82346f1b6f8c887105adb9a4c116a39a73322e34457b1d
      ),
      uint256(
        0x254d96796cc0742bdc0ff116d8ae79917ed219fe65c88ff778bacd266675df37
      )
    );
    vk.gamma_abc[12] = Pairing.G1Point(
      uint256(
        0x1a20916eb7f5bf063b631ece2e9cb5b3f9e63aec0038f7c57d36fd9e8ee093e2
      ),
      uint256(
        0x29030482ccd9ba42e1b3f150c9655574a17ddc297bd3238728caf423e54279bb
      )
    );
    vk.gamma_abc[13] = Pairing.G1Point(
      uint256(
        0x1893be9694d754c4a60d7c95ceefafb3e9f934260980f7bb89cad672dd14bed5
      ),
      uint256(
        0x2bbc0167693d21c38dc5ba8a9609892b3f262511b00f11035b5e5b8b712efa25
      )
    );
    vk.gamma_abc[14] = Pairing.G1Point(
      uint256(
        0x0f66de7419ce77831189387087ea71c9018d24f23f79e334d51ad1ff9da550cc
      ),
      uint256(
        0x177a75b32121f1b9da08666ded61082360caed3d14320e252853c416bda9087e
      )
    );
    vk.gamma_abc[15] = Pairing.G1Point(
      uint256(
        0x06a72ea91f3b4680eb2a613a61fcd0099e2f96a95b83a3631e27a9533dc9e858
      ),
      uint256(
        0x21c40967e9f9ddd706cbce09830ba520da9cd8a17725daf00d35ac71cb9b0721
      )
    );
    vk.gamma_abc[16] = Pairing.G1Point(
      uint256(
        0x2e30515781c48651333bdd61720fbc2b1dd6c63f9ed9d7fd1fa7eedcdcf7c82d
      ),
      uint256(
        0x240aa07dc941099d0cf4814773014f2633b8a2e52c9382b427dae751767d0a11
      )
    );
    vk.gamma_abc[17] = Pairing.G1Point(
      uint256(
        0x0a5a1f0c6d5ebf1770cf2123b13a0e0f7a24677a51497edbcdf45db56e4d7555
      ),
      uint256(
        0x2c58428651a9fc17645293c9a12e2947e5683f3ae0161f2688756daca92d9a87
      )
    );
    vk.gamma_abc[18] = Pairing.G1Point(
      uint256(
        0x2523993249dec4890253652f87465506490efd48f834a3b534852f9816c145bf
      ),
      uint256(
        0x27d59f6b3af2f759d58b5729758343456b1c191b6d948bee0e959752961a3aac
      )
    );
    vk.gamma_abc[19] = Pairing.G1Point(
      uint256(
        0x04a62accf3e26e44425beee270586529163aa09d51a50534e2831c3a4f73b77e
      ),
      uint256(
        0x022c584f5bd9eae93e6499627555105a39eb5ffeaf1ba57335813dca340a14c2
      )
    );
    vk.gamma_abc[20] = Pairing.G1Point(
      uint256(
        0x1d54708268815d8bd4c543a19d6f8f35d53af7443cd6d2b0d866cc37b55003bf
      ),
      uint256(
        0x0e3e38f69885cf9059a539f77c88e595fd9c2843da572d97d2ec7d981dc2c3eb
      )
    );
    vk.gamma_abc[21] = Pairing.G1Point(
      uint256(
        0x28de2093b8969ce31f72c9342b4641f50bf925437e3771809ee8767d50b9a93d
      ),
      uint256(
        0x281d34437bed1e6ec98d25899775887207c408708c4f776fe3632344beb0ab32
      )
    );
    vk.gamma_abc[22] = Pairing.G1Point(
      uint256(
        0x0af07d6269137a9690d6856ef1144852416c04bff2cd3df498d77df27419d10f
      ),
      uint256(
        0x01b9c1e6d75d9ac05fc477dd1a329a781b5d340c224d5fb2691cb6f5bca036c6
      )
    );
    vk.gamma_abc[23] = Pairing.G1Point(
      uint256(
        0x209ba7db4aa1aa8469e59a0756b1d5f68261109ea840405d1cd2b09c9e94a28f
      ),
      uint256(
        0x15a3b97638db25f4973f8b7d3b71d53a351b02be32c72c982c11c9d64785e282
      )
    );
    vk.gamma_abc[24] = Pairing.G1Point(
      uint256(
        0x233739a31ed81a4b5f485136f7a54aacfac173de3df50e61c4afc66e9b70c72a
      ),
      uint256(
        0x235a335f2d148d952f283b8b32671b5a975c156bef83cd1e002e35f2ad322a48
      )
    );
    vk.gamma_abc[25] = Pairing.G1Point(
      uint256(
        0x08df740640f8bbde04ac7a5e337110518f9ef3d902420f71229daf1051045b1f
      ),
      uint256(
        0x2ab62767c600e5ca685de70b3c391ba3db91ed76e2e01a6e8d2cdc6ede7cabca
      )
    );
    vk.gamma_abc[26] = Pairing.G1Point(
      uint256(
        0x1da175f787e2127ca3916f8e66500fe96eca5fa082edf93f903b5e511203234c
      ),
      uint256(
        0x21cfdf0b5ff07b25f9edf6e8a43ef0638ad618a3949839bc7ea400693456babe
      )
    );
    vk.gamma_abc[27] = Pairing.G1Point(
      uint256(
        0x2f0d9ecd9ee46d5aed35e898820fa68b24cf491425d37d317dbce5dc1a35ac35
      ),
      uint256(
        0x13bdfcde6a95c447e703a6f077000c68695893f55803af5b267fa822ea77af47
      )
    );
    vk.gamma_abc[28] = Pairing.G1Point(
      uint256(
        0x17186d7004126f20a7a68dc72315ce62b78b78ace58085cf9b6f6d7611cc893c
      ),
      uint256(
        0x0bd4b7db98a790708bd73233d2e6aac3d8678314c44e4fe1f01073c58735b10a
      )
    );
  }

  function verify(
    uint[] memory input,
    Proof memory proof
  ) internal view returns (uint) {
    uint256 snark_scalar_field = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
    VerifyingKey memory vk = verifyingKey();
    require(input.length + 1 == vk.gamma_abc.length);
    // Compute the linear combination vk_x
    Pairing.G1Point memory vk_x = Pairing.G1Point(0, 0);
    for (uint i = 0; i < input.length; i++) {
      require(input[i] < snark_scalar_field);
      vk_x = Pairing.addition(
        vk_x,
        Pairing.scalar_mul(vk.gamma_abc[i + 1], input[i])
      );
    }
    vk_x = Pairing.addition(vk_x, vk.gamma_abc[0]);
    if (
      !Pairing.pairingProd4(
        proof.a,
        proof.b,
        Pairing.negate(vk_x),
        vk.gamma,
        Pairing.negate(proof.c),
        vk.delta,
        Pairing.negate(vk.alpha),
        vk.beta
      )
    ) return 1;
    return 0;
  }

  function verifyTx(
    Proof memory proof,
    uint[] memory input // needs to be uint[] and not uint[28]
  ) public view returns (bool r) {
    uint[] memory inputValues = new uint[](28);

    for (uint i = 0; i < input.length; i++) {
      inputValues[i] = input[i];
    }
    if (verify(inputValues, proof) == 0) {
      return true;
    } else {
      return false;
    }
  }
}
