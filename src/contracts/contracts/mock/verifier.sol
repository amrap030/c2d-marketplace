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
        0x295992cec9c46cee9e3330fd5f2acd1c7a32b35f0e40ca0c98a93591592fc4cd
      ),
      uint256(
        0x04176183d6291d8afe6798d98e914b7207510e8277292ae6b7f4a4a101e0dacb
      )
    );
    vk.beta = Pairing.G2Point(
      [
        uint256(
          0x2065433ffb4c15d234d4148ff1efd772c47a991c8141defe2472164c8f54cc9f
        ),
        uint256(
          0x0119385a3bb9b64f46ef618137867592cf56feb19be2b5afa42bfbe8919c2bb8
        )
      ],
      [
        uint256(
          0x077a7930d57bc85e63dda54f43b9db582c691722578755eb77cbf2529169c5a4
        ),
        uint256(
          0x2942fc716f0ddc5b8d13f4bb23dc6074b36e76ee2f913152f94a5ed5b706692b
        )
      ]
    );
    vk.gamma = Pairing.G2Point(
      [
        uint256(
          0x1350112c8bc8ead266345b768e61a9f8290e4ed57b2ff2a4ae02cc2a98bb9473
        ),
        uint256(
          0x1f74cfdc70030b394ca7036db81f5e8599ef15cdf648ebdb9d0116e80254b7b5
        )
      ],
      [
        uint256(
          0x0884b69402a2ff26b30cc2b3b60e9fa590552e78ada28db4c403556e93423e72
        ),
        uint256(
          0x1ab5ce0a549c1531f5d84a4dc3839899bac0513bf61accf2149fcc6cd5322679
        )
      ]
    );
    vk.delta = Pairing.G2Point(
      [
        uint256(
          0x108abe372c9384fc97fdf6a5de6e602ee23867cb740589c59c0802b4652e2a54
        ),
        uint256(
          0x11a320803a42805b861916837a2d0c333920c9e475f97735bf62658d3608538b
        )
      ],
      [
        uint256(
          0x01411b0df972b858158c3c634728a0879b4a70134cdc1ca5ab3bb99249b25192
        ),
        uint256(
          0x057c5ad45a239c24eb4a79af79992e9bc472a7d4a91d818f991d143555216e50
        )
      ]
    );
    vk.gamma_abc = new Pairing.G1Point[](20);
    vk.gamma_abc[0] = Pairing.G1Point(
      uint256(
        0x227633b3d80cecf1b2532e822203222bb962b3a7ae6a08e84723cbdc5129ec94
      ),
      uint256(
        0x03e9207ba44592b6f9e631869b16bee76f31e89a90467d95a058b17dcdf56152
      )
    );
    vk.gamma_abc[1] = Pairing.G1Point(
      uint256(
        0x12c4210abdc7b680540d99062ef94e040ed500c690ddca8547e956446e43e961
      ),
      uint256(
        0x1dc38ff5453879104009703783070c0f47c59034dea9237d96aa5dfee39125d0
      )
    );
    vk.gamma_abc[2] = Pairing.G1Point(
      uint256(
        0x01a3e53bf4a8700f28b49b99a14d5b312142203277d40735e5e4ef71da4fae84
      ),
      uint256(
        0x2eb89c2d309b3c460db430036ac7e6ab85f0cf270c01cfadc27103ced3822909
      )
    );
    vk.gamma_abc[3] = Pairing.G1Point(
      uint256(
        0x1ac1c3c26b1aa9fd17bcf2db8a2ea43b937e95c45bd95c0341651a722933f4b1
      ),
      uint256(
        0x19eabcca9fe7632538745e4f6340c739111bb5621f8603bb0200896297609704
      )
    );
    vk.gamma_abc[4] = Pairing.G1Point(
      uint256(
        0x0d6689347e3441723cb04c654df7e6e5578cbeed2b7997c4094b69d2767bac28
      ),
      uint256(
        0x140aa7f111d9c51e348d6d1c9724f8b4520f1348bdea4e82d7c67734f37a36c9
      )
    );
    vk.gamma_abc[5] = Pairing.G1Point(
      uint256(
        0x193127de18753a11b157e4d2b7fcd2e407a055b948daf7c95e73186ea02bc6fe
      ),
      uint256(
        0x1b41ee1b146dfca3e3932b46c4c780722ef99b4cc334dc4b01cd906878865834
      )
    );
    vk.gamma_abc[6] = Pairing.G1Point(
      uint256(
        0x002aa2787ee3d852e6e8fc23b361d7b2bd11d695df941a833b701cabd1bf4a75
      ),
      uint256(
        0x1785bdce3ff1bf9ae726a0bb34bbe0ce0422e0c6b2cfa8a58d1407705d82a486
      )
    );
    vk.gamma_abc[7] = Pairing.G1Point(
      uint256(
        0x11b0b6c067dd508a2b260ae05a2ec7d796185eec754955bc0445486eed9a353d
      ),
      uint256(
        0x2f17e7dad1aa963c8a4705cc4f53bd8cdd9e33d4ebf4668b78b15444e43dc227
      )
    );
    vk.gamma_abc[8] = Pairing.G1Point(
      uint256(
        0x15ef92f0371a223633a04a8b87f9298f2a7ca8329e5acc306159eaa76045f1c6
      ),
      uint256(
        0x1b7f5c37650933546d8050c1c7fe86dbd9edc40a8a1e887d04284cf255dbb2eb
      )
    );
    vk.gamma_abc[9] = Pairing.G1Point(
      uint256(
        0x04ef26250774e09238c7ea4efa8533191ae70e9aa8d89a1e5f07e717c0c471d4
      ),
      uint256(
        0x071bb18e63d445c549c81e046cc73cf0e03832892740781617e3a243e1016813
      )
    );
    vk.gamma_abc[10] = Pairing.G1Point(
      uint256(
        0x19a0575bdfc74997e5991af2cec82ee8256315f6c7c3ee545950b0e456799856
      ),
      uint256(
        0x07cc50f1b9b7dc97707656b6b0192e67fe879ae78906de8a6cc75c18f1e3c9eb
      )
    );
    vk.gamma_abc[11] = Pairing.G1Point(
      uint256(
        0x1b71ff5f34fa640cc1dfd248c146462e55fd2b8bc2ce7d996f3a15f2d85794d4
      ),
      uint256(
        0x2a43c6b2aece4c86128d2620ceaf6e3ad4cee299002004e019aaebc00ae2a163
      )
    );
    vk.gamma_abc[12] = Pairing.G1Point(
      uint256(
        0x1e7c325d7f25d29b44eef8ed1da40ebc9e6718bf82d6dfbc4d7ca653a1aa260a
      ),
      uint256(
        0x2713752b70bbaff4b2193ddba55bdc57c31eaf9f01e240bbf926ecf26595e42a
      )
    );
    vk.gamma_abc[13] = Pairing.G1Point(
      uint256(
        0x149939cf79bcf9c9d151374132e07a04b9e142a0ed1320c15256b53f3506240f
      ),
      uint256(
        0x30588da7e327f16e9ea2be0c37c2fbc97a84b074c2be990594ca4a7266f821d8
      )
    );
    vk.gamma_abc[14] = Pairing.G1Point(
      uint256(
        0x2120d8e1b149e718fd42318b04360b440c7ca7a3921cbe210472162725b6b20a
      ),
      uint256(
        0x01d1081b4f658533d0181423097ce8c37c0c85c97d0e69b81accdd27eefdc825
      )
    );
    vk.gamma_abc[15] = Pairing.G1Point(
      uint256(
        0x07741ee6998acbf062148f6e8cdc3a332e7c4e23128d212737064d526957afea
      ),
      uint256(
        0x109cf689ee9ff21d9f9e6d09368cb0b61133c0e72bb2eafa2e6db18a4feb30b0
      )
    );
    vk.gamma_abc[16] = Pairing.G1Point(
      uint256(
        0x056fa262eb485d346616b43021c498439dd17e524522b0088a9b5c7aa1eaf6f7
      ),
      uint256(
        0x211b9453d1fbfc6f71f84d3032302b8b4e7556b67e32bd4cf85b87a0f0c6d5b0
      )
    );
    vk.gamma_abc[17] = Pairing.G1Point(
      uint256(
        0x0e0bdff707da664e274cda9486cc5e8a3509855e0a19a8323e74f7fd7a37c7c8
      ),
      uint256(
        0x02a44cb107cb6d77eb4ec21d62dc3d71f7fae445273fde411e3c91ef7d23c6ea
      )
    );
    vk.gamma_abc[18] = Pairing.G1Point(
      uint256(
        0x2692cc4c8a370ce12a2d01321f5516a144d8721f5c124534308a6dd29e43a25f
      ),
      uint256(
        0x0c1312e0dd062b1c9b42b2d30589c660b91619b7316ceb6e5a41d327cbb77adb
      )
    );
    vk.gamma_abc[19] = Pairing.G1Point(
      uint256(
        0x2b7b59123b3439264b216f8c45bc0b9d469859cee84e8b275defd90e1c9479c2
      ),
      uint256(
        0x1dae914cbce16dc7dc19972bca4c360f223e0927e8c7a7d75df4b063b02b2c41
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
    uint[] memory input
  ) public view returns (bool r) {
    uint[] memory inputValues = new uint[](19);

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
