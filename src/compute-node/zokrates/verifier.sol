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
        vk.alpha = Pairing.G1Point(uint256(0x2639e99c77ba37d88295d4826352e60f29076ab174960781ff568c13c7b432b2), uint256(0x213f289d8e0a931c9e255088b80a275b2325231357b5645bb8ffab1099c77e8e));
        vk.beta = Pairing.G2Point([uint256(0x0a47f38197b452beadf0df9b7da616f060b3ae4814f4aba07dc4189b3a83c0e0), uint256(0x09e6e0a4f988bdb995ac7d1c0981211a2551cac6d543efb40ba2107113173c99)], [uint256(0x279013935ef54bef1c606fdc9e283e4b2a2d76928978ef23ab971c1eb074ef92), uint256(0x1c127a0d0818d6870f468f09fb18c73555c9ad7cafeb0cd98b948cbf7117664e)]);
        vk.gamma = Pairing.G2Point([uint256(0x298a2c9914c0de38a36acfa922d2504fa4a5e5e4c5f62d396f362478966bb56d), uint256(0x03b9bf063eccb6a39577a8b9e25219d883988d6e15c0402e0bd8f780d155a766)], [uint256(0x263979832fca0d72fa404308717946ecd4ef4229c6b55ea7ffb56ff20b87171b), uint256(0x2157d34acf6373b6a12be765f1a997eb2f5db876c90870f1ad2bbc20e1b7f301)]);
        vk.delta = Pairing.G2Point([uint256(0x27ad9c6fc806673bfe63f935004dccd22eeb1298045ed63db0d237553af274df), uint256(0x1e509ff3e80b19d796e5ef497d55e81732c0d5a9654b169d839710a19736e50f)], [uint256(0x2a9aa5ec0c4a2362a57b98a3871635c40e6a3a0441fecdb33e6c1d08fb5145ab), uint256(0x07fbe71b604e00d5b5dbc424b008587bf8cee18f4b69f58206f9469bf6655a44)]);
        vk.gamma_abc = new Pairing.G1Point[](29);
        vk.gamma_abc[0] = Pairing.G1Point(uint256(0x09ab702962d2743d0c416cd05098233137e72bf4ea0579ae151aa18781c18cf7), uint256(0x2e54ae0544330b93b1b2e91f3d30bc36729142178cfc594f050013eb1dfc8c4a));
        vk.gamma_abc[1] = Pairing.G1Point(uint256(0x206879f392d343055db16e2f50ce0baf20ab550f2969d1bc2ffb59efad0056d7), uint256(0x1b14e2590a09d0b24ff0eef276b95fb62e50820221fdabd8da0ef3a33db11d07));
        vk.gamma_abc[2] = Pairing.G1Point(uint256(0x292a0dd1e5e1701c762bbf955e5fd8dfb58ab4b08ccdb534408738631e08aa03), uint256(0x2a205adf36540765ad8649c3b9b739f770d1d898030121a6ac4f695902542460));
        vk.gamma_abc[3] = Pairing.G1Point(uint256(0x00822c0819190b5d94fe91fc8611f37b792b2fd49906313543edcad48b7acd3f), uint256(0x1e672146b0ea035470d1fea5e3e5f31f1f5aa57d540d682f4b39d36f175b0b08));
        vk.gamma_abc[4] = Pairing.G1Point(uint256(0x119347e2c20b0f37ffe4f8e0df7e42f6c24d1b17591a8c55ac3556d8dac360af), uint256(0x1ac727eb8b84855000388955dc6092055b89092c826cd6cf60454e755558d8fd));
        vk.gamma_abc[5] = Pairing.G1Point(uint256(0x22bd9698c49aca9f8550b80906af7bbd5773bbdb12f1d91547501ddd2954c4c9), uint256(0x29a4648a9e9e2f1f4e68fead323d78944243621a45462f524eece566bd2402f6));
        vk.gamma_abc[6] = Pairing.G1Point(uint256(0x1743cf7dc11561ee5988490b4e89d075a5da81d3fa3315052e53b95a21533ecc), uint256(0x1d0d6f8c1d19fef5a535836f634af1e166ca9662819cde8b19b4e9b3d76be9b4));
        vk.gamma_abc[7] = Pairing.G1Point(uint256(0x296b1da9450f812d275f37c04b89fe704182fe4f12d64c28b954512b610b807a), uint256(0x13fab689ebe1ef668968f38c724ea9234ea4b3c0499a72e40a6c7a69b3f455d9));
        vk.gamma_abc[8] = Pairing.G1Point(uint256(0x1431e4a276fdac83c225d0e947875288f7411d5aa69eb121f68289a9c6f1aebd), uint256(0x1c5766137650462d84388d484dfeac5aa5fea6d7c6cae3ea7e45100a9568e65d));
        vk.gamma_abc[9] = Pairing.G1Point(uint256(0x1e48d6b2f7af68a34d99bfbe15143e6970613fba8cfd5138d63d76e676e83478), uint256(0x2c474abdd7f0023d59525e1672244cd34e776bd624a2956412aaa52ef7562aee));
        vk.gamma_abc[10] = Pairing.G1Point(uint256(0x1cafa079e0f138e2b76879a15fb061b7d1f7da8ea622a33b6774363a729d2bfc), uint256(0x177e813fe7aeaa7f286149b1fe81e1187171f4c80d55fec2ccf6aa9448530e0b));
        vk.gamma_abc[11] = Pairing.G1Point(uint256(0x0469e564fccab3574d626636d40054f2a6987482e9412cea0065dd61ec8fb1f5), uint256(0x0ee7376d3cc9dd16ba738971c4a1d4ae8a67e5763274ffa67ab6965521447682));
        vk.gamma_abc[12] = Pairing.G1Point(uint256(0x1642f42a6fc4df4c9e2e20428052bb81f39a2129fd84fa04bb9b2272bed1b9d1), uint256(0x063595b37e76908e8566974a54e0c7d714fd57a3ac6037c754abd7ce43d6b8be));
        vk.gamma_abc[13] = Pairing.G1Point(uint256(0x241f8274bae058257aece981e823bc96efff166ff8f0a96f879226079f1083d6), uint256(0x1b7ac7bbc8640aaa94cc04935d1fb70ac9a71d3f518edaf28a1690bd814c962f));
        vk.gamma_abc[14] = Pairing.G1Point(uint256(0x013041c71628070d7515ab81902bae9eee12dac04e10bfcbea09a87e59ff81ab), uint256(0x079dffabb5acaefd7802f831bcd18329d5db53aeedd14b3baaad32bf37967fcd));
        vk.gamma_abc[15] = Pairing.G1Point(uint256(0x1d3b929bb2f3669ec0e1382cb7166add3727b5993244bffe7bc17b01afe80f9e), uint256(0x005ffb5f50397ab9b001e793eba419ee0cc890b441199c45f9e272d73d24135d));
        vk.gamma_abc[16] = Pairing.G1Point(uint256(0x034473ce6fec27ba134e9caa71a37ee5dc51d97145ebdb2dc04b995877cff390), uint256(0x160ad15f5cb2580c3ad58f4e4f0b9408b9e8a56329616323a9e4b7a46d193dfc));
        vk.gamma_abc[17] = Pairing.G1Point(uint256(0x05305bba2b7b1244593f1c11b47349bf375ecd8378fa64899a3b424fb47e65b6), uint256(0x056728e67a725563210b69c47c19c5fb17ea2e36803435332079c051b7b848b9));
        vk.gamma_abc[18] = Pairing.G1Point(uint256(0x1e5f1e0deb602594f285e8b7cf10a66a7a5b1ccb0321de2031494e1110644daf), uint256(0x210f8e774b2adb44995b05f30fc4dd9b97df8cbaef86eb03cd2a1c0e68f505bd));
        vk.gamma_abc[19] = Pairing.G1Point(uint256(0x2fd4998e27abec0821b08d051ea4126f0c0c1ce7f59c544007b65cf605699a24), uint256(0x06f0291b8e26517ee1639e3081fe9c84b5177f67dbb4d99230367189f257ce8b));
        vk.gamma_abc[20] = Pairing.G1Point(uint256(0x302d3135fa8f7061a8e1db2db5bedf80366fb5f1cdb7dbb3dd1bd924f1db414a), uint256(0x054570b924aeaf5bb90ae7e7d1671e4392c5cda81b4647cc271521923cd91713));
        vk.gamma_abc[21] = Pairing.G1Point(uint256(0x1d145d0980037249c3d7ceca83d55425dec7f0d5eeb6ec7ca1b5a3bb9712777d), uint256(0x14578b96e0b9202a9b06a1bd0118c8ab0d59faf5b64adf5fe099b4f10890864e));
        vk.gamma_abc[22] = Pairing.G1Point(uint256(0x11b089ea96efb75cc1ef470d6bf3197b2856eee56ac738a6b4b38081b339364c), uint256(0x1c66310c27e3deba1fffb018900ebd3b1ac519cb21a868bbe83ca7140b816347));
        vk.gamma_abc[23] = Pairing.G1Point(uint256(0x2a964827d23cd87733f9af008b764da1e15d15cd0b43461894c9d7d8b958e900), uint256(0x2d9c5f9f2684ee768354176a5e6c78207de4cb89a44f5ff584be1033159be819));
        vk.gamma_abc[24] = Pairing.G1Point(uint256(0x01cfab7a6c0883cd68c31917ed90cd0a7a9f197fca9d31bfef6a12da342de397), uint256(0x239777dc74b3156e1f6327dd4b59400035e0dff2a1a4d3932f9e14dc8528cb10));
        vk.gamma_abc[25] = Pairing.G1Point(uint256(0x1ecdfb5884a224448a6613c902d8550c844598ad07e3f18474b39ccb398108ad), uint256(0x2f432093474ff947dacd746a1a6b0f8bef8de755e4ceb3e1a115164f096be7a5));
        vk.gamma_abc[26] = Pairing.G1Point(uint256(0x1eedda000e326f2ea0cc4fcf31c2f847efff419d02fb368c85b81c3cb1ff137b), uint256(0x0af6e500e8c1bf8af5bb9aec31a1bc6781da24bba47f7672537cbbd3deefea7c));
        vk.gamma_abc[27] = Pairing.G1Point(uint256(0x060bddb41af6174c0b4a041032fbc8e9b5a8c5a088e823c41de1ba5dbad34a92), uint256(0x1b87f724376becf615bff220d9a5b2cd57b1a2261c68466428ff370ebc84c9d0));
        vk.gamma_abc[28] = Pairing.G1Point(uint256(0x203557be5e83696eb382541cc683174b68e9cf044625a37e8f2651cebd66e582), uint256(0x228ee07a8002322b16579f3f24e8d52c8b49c4590c43d1f010538aa64881e96d));
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
            Proof memory proof, uint[28] memory input
        ) public view returns (bool r) {
        uint[] memory inputValues = new uint[](28);
        
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
