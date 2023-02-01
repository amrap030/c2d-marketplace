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
    function P1() pure internal returns (G1Point memory) {
        return G1Point(1, 2);
    }
    /// @return the generator of G2
    function P2() pure internal returns (G2Point memory) {
        return G2Point(
            [10857046999023057135944570762232829481370756359578518086990519993285655852781,
             11559732032986387107991004021392285783925812861821192530917403151452391805634],
            [8495653923123431417604973247489272438418190587263600148770280649306958101930,
             4082367875863433681332203403145435568316851327593401208105741076214120093531]
        );
    }
    /// @return the negation of p, i.e. p.addition(p.negate()) should be zero.
    function negate(G1Point memory p) pure internal returns (G1Point memory) {
        // The prime q in the base field F_q for G1
        uint q = 21888242871839275222246405745257275088696311157297823662689037894645226208583;
        if (p.X == 0 && p.Y == 0)
            return G1Point(0, 0);
        return G1Point(p.X, q - (p.Y % q));
    }
    /// @return r the sum of two points of G1
    function addition(G1Point memory p1, G1Point memory p2) internal view returns (G1Point memory r) {
        uint[4] memory input;
        input[0] = p1.X;
        input[1] = p1.Y;
        input[2] = p2.X;
        input[3] = p2.Y;
        bool success;
        assembly {
            success := staticcall(sub(gas(), 2000), 6, input, 0xc0, r, 0x60)
            // Use "invalid" to make gas estimation work
            switch success case 0 { invalid() }
        }
        require(success);
    }


    /// @return r the product of a point on G1 and a scalar, i.e.
    /// p == p.scalar_mul(1) and p.addition(p) == p.scalar_mul(2) for all points p.
    function scalar_mul(G1Point memory p, uint s) internal view returns (G1Point memory r) {
        uint[3] memory input;
        input[0] = p.X;
        input[1] = p.Y;
        input[2] = s;
        bool success;
        assembly {
            success := staticcall(sub(gas(), 2000), 7, input, 0x80, r, 0x60)
            // Use "invalid" to make gas estimation work
            switch success case 0 { invalid() }
        }
        require (success);
    }
    /// @return the result of computing the pairing check
    /// e(p1[0], p2[0]) *  .... * e(p1[n], p2[n]) == 1
    /// For example pairing([P1(), P1().negate()], [P2(), P2()]) should
    /// return true.
    function pairing(G1Point[] memory p1, G2Point[] memory p2) internal view returns (bool) {
        require(p1.length == p2.length);
        uint elements = p1.length;
        uint inputSize = elements * 6;
        uint[] memory input = new uint[](inputSize);
        for (uint i = 0; i < elements; i++)
        {
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
            success := staticcall(sub(gas(), 2000), 8, add(input, 0x20), mul(inputSize, 0x20), out, 0x20)
            // Use "invalid" to make gas estimation work
            switch success case 0 { invalid() }
        }
        require(success);
        return out[0] != 0;
    }
    /// Convenience method for a pairing check for two pairs.
    function pairingProd2(G1Point memory a1, G2Point memory a2, G1Point memory b1, G2Point memory b2) internal view returns (bool) {
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
            G1Point memory a1, G2Point memory a2,
            G1Point memory b1, G2Point memory b2,
            G1Point memory c1, G2Point memory c2
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
            G1Point memory a1, G2Point memory a2,
            G1Point memory b1, G2Point memory b2,
            G1Point memory c1, G2Point memory c2,
            G1Point memory d1, G2Point memory d2
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
    function verifyingKey() pure internal returns (VerifyingKey memory vk) {
        vk.alpha = Pairing.G1Point(uint256(0x08b25335701b785ca8708b7e07bf33c242750801e08793308a9b4b86bd2fe78c), uint256(0x0bf3547f8e3c3f406ee0c36d9549bd0f52e66225246afba01e0041be71cf9f5c));
        vk.beta = Pairing.G2Point([uint256(0x01f688b999f15d60c205fc5ebd47716a73f607d7d7b1a74e3d0587305eb20871), uint256(0x12d7d85dc70594575b8de10afb736e46095d3cfde0d190b58b8de34217971c88)], [uint256(0x0724cf1b62da742193d503649593878eab4c600f01e477400d9b8eac22954709), uint256(0x24dab9cd83cd5d5bf2f94ff6d9017147084d752dc7d5b0df0120ef2df8c80e0c)]);
        vk.gamma = Pairing.G2Point([uint256(0x0380c6698b178be3a6690db0c48a53ce6551f5cdcbe776e0d946cbc7087529d6), uint256(0x2c894aff81167ad3e69d9c121f27f90321f001d2990d9a2002c689fc81eb278e)], [uint256(0x233514ec17bf268a49fb316bb0692abde95531cd1cbd3671ffab510826994267), uint256(0x00ac078dde9bdf429a181ec1704625b9d95fe9ce9d2ee07769da7625e0773b9f)]);
        vk.delta = Pairing.G2Point([uint256(0x23fe29364b32337ede7bca10b6ff5b3411c32827346a30762fd2bf505665756f), uint256(0x0dbefbb16133d81c317ec54a2d3b89d0d1611728d6bebb5358393292900f0965)], [uint256(0x2688f0cb676115ff6dc3470aa9b93d9ed84660d1b3df9daa0d5070c23de6d933), uint256(0x0df5146b512b327ee991d816e7731b018a3376e30a79fb06e7b73d0e5a8ea284)]);
        vk.gamma_abc = new Pairing.G1Point[](22);
        vk.gamma_abc[0] = Pairing.G1Point(uint256(0x22847b42fdb5ab4e573cbdebf20370fec2d72c76f31de3950bbfb969fd3c6dc4), uint256(0x2a5e12ab97bcaf857c4adfdca9395c5f0874e453df77b35d75090b86b809bdaa));
        vk.gamma_abc[1] = Pairing.G1Point(uint256(0x216c9f480b7eaa541d3b24edc57e0e380d5fea8af4727cd24ea5a2898f4945e4), uint256(0x1c978382e7f44065fd34a0fff5447e48b7b4cbe2a37b854b6a97b86ed01e1f2d));
        vk.gamma_abc[2] = Pairing.G1Point(uint256(0x29f5803b13f6d28d4261d4c33d33f39b595ce5c4047e962826b8ae316d519d1c), uint256(0x0da90ccf2c8bcffba87516bb0518c3f2d8fe7cd59a8edcf2578f5ffcdc9718a5));
        vk.gamma_abc[3] = Pairing.G1Point(uint256(0x04d322807abd6b90985428968f06592675cc8a208278752ca6a686cb67040162), uint256(0x069f8ee0630e5d879b160e7b00ee4883ed693bb8676fb116d6165a7c1633d926));
        vk.gamma_abc[4] = Pairing.G1Point(uint256(0x18953191d2c41a610ae039f3de0962da1c15dad28248877dd7784fa25889a620), uint256(0x1da9222f9d0648e4142bc1d10ce0b4407f3929844221da7da3f7a0715562d76b));
        vk.gamma_abc[5] = Pairing.G1Point(uint256(0x0d54b23a8a4dcc49cc3684ee515207659f6bd2822cfc28920dd6ba7cf53c2593), uint256(0x0c112c14f29938ce817472d0354fba86d983e208b5862269bcb538f66e048068));
        vk.gamma_abc[6] = Pairing.G1Point(uint256(0x0a30aaea5ca834cb8acc9087c10f7c1ebd7ffc54dcb7439c6373d8489c700ddd), uint256(0x08f72d495063a9fd080a627c8fc138d02b3eb04b951537f204e099322a1a833a));
        vk.gamma_abc[7] = Pairing.G1Point(uint256(0x2eecc37096b9c13d23b3ec4fcb435209a169f7f32d1351f463b233b895f03eb9), uint256(0x1be8bde0b1f900a161c8160f269751e0f72e733b23b279811b914c59d7e77167));
        vk.gamma_abc[8] = Pairing.G1Point(uint256(0x1a6f817ca1c6b70d825df891fc3c6c1851324e4267bf743c0e7882d30bad94c6), uint256(0x27145c2206b3c4cee215c354f50eca129dc493126f41ccbd708bc8c19de2063c));
        vk.gamma_abc[9] = Pairing.G1Point(uint256(0x171a7e19cc2294e13e99e2c485a5269aa6507d11d8cc59176e7cc6696641e13d), uint256(0x2ef1a3b2d194950ce39e6d2174a7bdba8c50ae707532595c088e8c8d36ce5081));
        vk.gamma_abc[10] = Pairing.G1Point(uint256(0x1aaf89cb4967a35e034fb4af9f4da52d14ebb6147f3bd0bb562e9360696336f3), uint256(0x1ef38dc5cf9cbda0f2ee215d9dca3888f48aaedde7cc1a1e7824a4942fc8f328));
        vk.gamma_abc[11] = Pairing.G1Point(uint256(0x167cda219881ea20e1ac1c57908eee11fbe5d596fc6a6803827a139c5256a9bd), uint256(0x15331233833f8b5cc01293263c51f631a69845694d8f1b144b7e1150a8e603bb));
        vk.gamma_abc[12] = Pairing.G1Point(uint256(0x25785b39e3cd82c66f83583f56cd44f1f276098caa9a3822b4b12dbc890d80ec), uint256(0x2fdae5848060c652c7567b5864371c442e554e82a3666c8d2eccef4149d952f3));
        vk.gamma_abc[13] = Pairing.G1Point(uint256(0x1762483b3f8da90ca010bb3f45b058e7c5484b42d32230f8951be0cb4534a8ff), uint256(0x03b8e8021ace4c931c82f4a0dbf070d4e009c58358e0e4568bf0ac5e8144efe0));
        vk.gamma_abc[14] = Pairing.G1Point(uint256(0x18727a2cd46ab1bdf6abdc27a482636dccfa060586b62322684208f0974b9d1d), uint256(0x2ef2e099e97306611fa46ab01c153e9081424ee0f9776bc7c629de940f19f4cf));
        vk.gamma_abc[15] = Pairing.G1Point(uint256(0x1f9c39ef971fdedc23b962ceaf8b731ddaa6cb72e48a21a8cac105e1f5206e39), uint256(0x12ef7a6189346219d071e00b42baf882844707b1b057fc5bd0918defef5dacd1));
        vk.gamma_abc[16] = Pairing.G1Point(uint256(0x1069c791ad89a848655e1a7ee896d4414acefcdb8183af5cb70069c87887b2d6), uint256(0x2f8ff4476f428f8ab65b34ca89497e31cd871e478953d6a6087148872c955eb2));
        vk.gamma_abc[17] = Pairing.G1Point(uint256(0x286636a0a6ad18347c7e71ca7573f5ada969a6f49256b2a305604a2b0f7f1368), uint256(0x2e7a9216ced83a52e33fde206a9fbf7f8586d88fb0023f5d58e2ba7381bb790c));
        vk.gamma_abc[18] = Pairing.G1Point(uint256(0x228fce2b0a4164addf4ca342bbcf57a33225a975f154d243d54db1aaa167d28f), uint256(0x2a48e6faadf2ecec7d75e1528c865f743f18d6a290742e8f05baceea3c8df8df));
        vk.gamma_abc[19] = Pairing.G1Point(uint256(0x1072cf0e9b5ba8b1dc98651a02c1b4493e94cd99bef42e386a83bf654e3c5fa3), uint256(0x13fa6c036ae9a911ad67b71b2d7826311b4a8ec64bec86108d01bc5ca89fa0ee));
        vk.gamma_abc[20] = Pairing.G1Point(uint256(0x181787242b53219f28d8c3b641858d9266298a743a5c8f939eb600a13abf3d7e), uint256(0x03d1be9fc195484de97ab40eff1efba87fd027f61bdeef943397f4f6c1e555d3));
        vk.gamma_abc[21] = Pairing.G1Point(uint256(0x01fde90760b86caa9ffdb2b2a295eb558a0c146ad52cd04476b5d49df6143009), uint256(0x16c1e0b99759384b7e60cbc58f7431e6efb6cf7fd0fda532c32963a5a3e6388d));
    }
    function verify(uint[] memory input, Proof memory proof) internal view returns (uint) {
        uint256 snark_scalar_field = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
        VerifyingKey memory vk = verifyingKey();
        require(input.length + 1 == vk.gamma_abc.length);
        // Compute the linear combination vk_x
        Pairing.G1Point memory vk_x = Pairing.G1Point(0, 0);
        for (uint i = 0; i < input.length; i++) {
            require(input[i] < snark_scalar_field);
            vk_x = Pairing.addition(vk_x, Pairing.scalar_mul(vk.gamma_abc[i + 1], input[i]));
        }
        vk_x = Pairing.addition(vk_x, vk.gamma_abc[0]);
        if(!Pairing.pairingProd4(
             proof.a, proof.b,
             Pairing.negate(vk_x), vk.gamma,
             Pairing.negate(proof.c), vk.delta,
             Pairing.negate(vk.alpha), vk.beta)) return 1;
        return 0;
    }
    function verifyTx(
            Proof memory proof, uint[21] memory input
        ) public view returns (bool r) {
        uint[] memory inputValues = new uint[](21);
        
        for(uint i = 0; i < input.length; i++){
            inputValues[i] = input[i];
        }
        if (verify(inputValues, proof) == 0) {
            return true;
        } else {
            return false;
        }
    }
}
