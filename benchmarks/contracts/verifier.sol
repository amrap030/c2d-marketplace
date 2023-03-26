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
        vk.alpha = Pairing.G1Point(uint256(0x04651edfad01de2bb76768c273aec0089195a92c8f88cde6299dae4aef7c4bc4), uint256(0x09667a718d7cd8500e5075253e3149674f0fd4ab0866872a9cacdef5e381cbac));
        vk.beta = Pairing.G2Point([uint256(0x2540920fcc0412b5b302f71e70d6181cd6e55e1f64eeec02305d5269876b1efc), uint256(0x1890ea22d1a9f08dd98208c1f357069a453360d54449b1064dae1f24124fc6de)], [uint256(0x03b9c36affe2541e8c91d91b9a47ac1d91c08394800a3f58ec64e9511ff35086), uint256(0x21b0b314996e1261b012d10dee24479741a3a4409a32179c927110c85c5f1b51)]);
        vk.gamma = Pairing.G2Point([uint256(0x13c2a419249c128ad90d819d6fdb7263cbcd1c36839f55816c09610e5721af6a), uint256(0x2278f39e454886886940b7069147f867d8720da35841a9174b92e60402ea612a)], [uint256(0x2153052a71ad197f8f98dcb5288638b1ca98b07d508a89d1950e4bd25776cc0d), uint256(0x05a86b53680d0ac2c55ceb4145b5cbef2f9e8d0094072261a495261d6f4216c1)]);
        vk.delta = Pairing.G2Point([uint256(0x0f79ca382e9b2340ca31265734adc92b402715900f0c44c1db2cabcccf006566), uint256(0x202599dd4394206045a3e796614c23c720e89cb1c118ce618c2ea46c0195f95c)], [uint256(0x13b94ce0a7b01f0ba397cd10161b722e16054777ad57def319c229323b17a916), uint256(0x0f19ebfbb2d4c811774bdd5aa84cd063660d10f083918d84a55dcaf5ca0afdb4)]);
        vk.gamma_abc = new Pairing.G1Point[](12);
        vk.gamma_abc[0] = Pairing.G1Point(uint256(0x0a47a26c71401fa2bcd6ba80290224f78df21e6e8e6ed3d64448d89a10c14f18), uint256(0x30379fece9d633cdc154fb7c3a406a0e6c962fade2f47428d8948f3dac5e6064));
        vk.gamma_abc[1] = Pairing.G1Point(uint256(0x17938353026b1bcfd9d982e661c31e7751c79606117e4ecb58129049b3c9356d), uint256(0x2a9c9cf9b7f1811f6cafa6f068b03e78b966b5c9aab127f1406f7d1b60b73b25));
        vk.gamma_abc[2] = Pairing.G1Point(uint256(0x13658d66a1e6acc1d8ab2dcab1e7f84cec105a7f8ed94df754fc03b4562db4be), uint256(0x17c781f69a1b6d639e718d4a0440cd51bd3bd96cc1c1b8b63f96f767873dc3b3));
        vk.gamma_abc[3] = Pairing.G1Point(uint256(0x069f28ca9261eb0a35c807b3dce983a52c9994ea11e61861672255a22737be25), uint256(0x0717f2061194a24d5da773040f0da353b046f14284c99f9cbe0615fe1258984f));
        vk.gamma_abc[4] = Pairing.G1Point(uint256(0x2d514a0793f5981aef8540436b3bac5af298e9e57bc585a6c1a97ba46e2fc4bf), uint256(0x08bb7ed2a9b6ce38cbc8db3d2acd633f22272019229b9d555af77db656131f5c));
        vk.gamma_abc[5] = Pairing.G1Point(uint256(0x2d92802afd304ccd029547addd0e1e018c7d207ba8cc0e5794d94ea6149f18bb), uint256(0x2d373f93c51fb4630271bb2f2ca444cd97fb3a546c4945519a043af0b6571492));
        vk.gamma_abc[6] = Pairing.G1Point(uint256(0x1adeeacffea5ba08790fe7c59bc5d67ebfd393b5ea3f1e48b6e6c70141e7468f), uint256(0x1ea288e71484f7aa321a311526d1ebd3cf1995161447ede7e5a438da9e7ba881));
        vk.gamma_abc[7] = Pairing.G1Point(uint256(0x1a997600ae956fda12c23fda64107e20c90da47dab8c496ee16b51353f3c0c52), uint256(0x1190642595d1a0c01f0c19439b80a98de087de728e7d08d3b5a1ef158ebc8f6f));
        vk.gamma_abc[8] = Pairing.G1Point(uint256(0x12f722ff6cfb00c977b0ea454ae4b455029f3a6b6dbc54db7548e85707cc89ed), uint256(0x2bf18d90e6bf813de0148c4b1df5ab8dc3d187e73049793a523cbf15a53a50ff));
        vk.gamma_abc[9] = Pairing.G1Point(uint256(0x17a7fe957287846566055adc628a1db6710f04639bd661ee29c248b444e153ca), uint256(0x17e73319db5b71ae91a334f730adebcd22646ff0732247b6ce341521ceb8dd29));
        vk.gamma_abc[10] = Pairing.G1Point(uint256(0x05ceb54b4a80ad69d968ead5597a3ba24a9e73cf2c058262c083f49b264f3a0e), uint256(0x247cfe479cfaca6fe4078f5eec239da9b95aecd3e4749808887d01c66b72c192));
        vk.gamma_abc[11] = Pairing.G1Point(uint256(0x09efa8539a2353a560097175ada03364da0fcc0598c96a93c35f46a63f669b79), uint256(0x2948841eb1b80b700628ed62e40fb4b4576697769278f47c9347dbbe8d3e7f79));
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
            Proof memory proof, uint[11] memory input
        ) public view returns (bool r) {
        uint[] memory inputValues = new uint[](11);
        
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
