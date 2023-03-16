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
        vk.alpha = Pairing.G1Point(uint256(0x2d5f4059cc11f2581ee237f0bf0b910cafd53c36139119dba898c690d043ae43), uint256(0x1c3ca7a5b4d34e3a7bd585933244ac938ad0e8971104aa3cc966a43b0e4071a4));
        vk.beta = Pairing.G2Point([uint256(0x0993f31d1db2b2b2b6228262ee0ae56119bd6245a3571f7f1439d960d98c3c1a), uint256(0x0d07d3be03081eb0aab0f38fcf86cc996df5dd76e576708b742575524a695cd0)], [uint256(0x00371760b4299535e091b3587291352e6ec5c8b3942d7fa84448d98f19a484b9), uint256(0x1419b45e29fdc28e54bb6ce91b9d70fa00a1a37a22dfb6e657ac9bc916360ec0)]);
        vk.gamma = Pairing.G2Point([uint256(0x205adf2765c2a3ea4a5aad3a581bd2b3951f4b25775e8441b507d3f43a248e59), uint256(0x144b3ea627ad2a961b0e074cf10353e672702d4a31e1ff73f6878e2449c86b61)], [uint256(0x19327039785fe11e1a7328cfcf6f68e082f3180ecafac72be1321655b6b12253), uint256(0x195e22021c06770c6cf5c7476a26bf626d3e1decc94ce37fd38c6f693011764e)]);
        vk.delta = Pairing.G2Point([uint256(0x2df2b7f755942215c084145bd19e31800451ff19c61df30a75a93dc6bafdc84f), uint256(0x1de1d9ac400631e48bd681fa7fabb861bd6a69fb04666f9aa218bb4c6684d342)], [uint256(0x2d4d1232bf0bd9f2f2f160d16a840531452cbf2ff78c748f49588e9471f25a39), uint256(0x2f0c2b7e9f0d6e7e19080cebf2cddc40670fe9c3e5a9127aac86cdc230f4882d)]);
        vk.gamma_abc = new Pairing.G1Point[](68);
        vk.gamma_abc[0] = Pairing.G1Point(uint256(0x1befbf4f4e266dc2344140aaeb0af2f84c6f554c9e437a7a935dbe846802759e), uint256(0x10e7f584535b2611b8f98630b576674813a3f8e1ede516ae1b12076a40a12a8f));
        vk.gamma_abc[1] = Pairing.G1Point(uint256(0x002181457c6ab1d7ad94a30321d8fc390b441cc75b83c61f15984c41d1397746), uint256(0x035cecd0d912388fbfbbe587caa3cd0d061ddc701943a6b937337d3b5416a9db));
        vk.gamma_abc[2] = Pairing.G1Point(uint256(0x0b15d4736c24f62e5aa0714540b7cfc3780037cc679d28b3480c5948dbdc2fd3), uint256(0x29531512fb91c86645483ecfc615d95052dd0b9e34699959fce3034abcffd2d5));
        vk.gamma_abc[3] = Pairing.G1Point(uint256(0x303ebee703d6bfe917b80f681d930b1e5c3da0355f74848d7c8961400c47fbb1), uint256(0x2d23194e6d4f0da84b687c8273b00000dbb28065db4e01999d23e72f28788012));
        vk.gamma_abc[4] = Pairing.G1Point(uint256(0x25a33344177e5137f03e0902c063468ac63ae0937d8b2f25fe0b1635810ecea4), uint256(0x2e282900dae0d1b6da20cb85d862fe86b3d1dc579a2558fb607bc83d85d0ed9a));
        vk.gamma_abc[5] = Pairing.G1Point(uint256(0x20ecbbea9c82523840c3438f7a0f12cd8178d70f1ce845b01fa2f120e68cf807), uint256(0x289b9320594bd8fdb742c3f8b40e36f131c4d3e3be6e7cd01f2e314687560c3e));
        vk.gamma_abc[6] = Pairing.G1Point(uint256(0x1761b0b74f458e65bd028a14ab8f07cfa51f06fd5bbbf54a4c976dac1d8469ee), uint256(0x2b2e18773f25762775fdc17f80e3cda4c6ad3853dcce792e7d32349f7e83d684));
        vk.gamma_abc[7] = Pairing.G1Point(uint256(0x017ef02cde0cdfe782ee7091a34e3b4cb05dd01ba5af27f9548591ad5db885d7), uint256(0x0f74d2c4bcc9abd84f3169468275f014d23cecd9e7a08d30b2e756aa7382ada8));
        vk.gamma_abc[8] = Pairing.G1Point(uint256(0x04e54572be0538ed6f61631b123d4739ad06a592b62a1fbdd584336ee1809299), uint256(0x21d1f1ff1e7f0dc43d3e19e54c878c7e4f10c5b2038742326a6107e72f235e6d));
        vk.gamma_abc[9] = Pairing.G1Point(uint256(0x0e2ed9ccc8bd25caed33811e6ace5dcf314fe1e6f99e97cfc8ed2815ceee39d5), uint256(0x1a931318e8c7d234b0661cc46d1a443f5892762a1d3c6ccb92fce0aa7b47342c));
        vk.gamma_abc[10] = Pairing.G1Point(uint256(0x26dceb79644809c960928d6563710054e63ccd921da62878e8e73f40caa84d11), uint256(0x10084953f949e04da29ad78f54e5dc824e25d9912fe575619daafc2a43236f50));
        vk.gamma_abc[11] = Pairing.G1Point(uint256(0x0d5f31d5d5b5b6f013216019f8d8170d4b6765391003a7eea33ac0937c991bfa), uint256(0x0c255eea3afcc1f8f98cb3da22b1c2d132414f23a210e58f34068992fee6a983));
        vk.gamma_abc[12] = Pairing.G1Point(uint256(0x256fb92979162ab3c08c006cd7d42e24acecf4504c6187d5d6fe9ce0ab3e63b0), uint256(0x0dafadb0219f499a3696c52205c1b1c98cec38586343f4b59ffbf87f2d504f7b));
        vk.gamma_abc[13] = Pairing.G1Point(uint256(0x09088e44f6146ce3a9e741ff2c93eb0f1249c62cb1a7f0e557a14a373b5e13fa), uint256(0x2b40bcc520f6945045d6edd3052201cc1ac46ee83ef6b5c50731825a47337eee));
        vk.gamma_abc[14] = Pairing.G1Point(uint256(0x0d125bdf25147aa5f7c6e9dc3949f6b9f9d7f0312918886b810108880b7788da), uint256(0x14e856e03fd406220ed40a30b77705581f6772e26f1f94a605a8648d67c6ec4b));
        vk.gamma_abc[15] = Pairing.G1Point(uint256(0x24fb8685bc9616442634e484dfcd5174a7822307ec6c20712e535e839473b0a2), uint256(0x045d7cf3d837b6ab28c6770a2cc320c3b8a79a974b153765fa74015faa3d2d5d));
        vk.gamma_abc[16] = Pairing.G1Point(uint256(0x26e172599750e3d807213740e6318a7adb8ca52dcf6562637694bc9f983a4e42), uint256(0x2aa35140384a3f4e12763d8b2a5c8c319be413e1d752daf136ab05935cc288c0));
        vk.gamma_abc[17] = Pairing.G1Point(uint256(0x2889e45e11c9ad0b82a9d82a93947652d2dd4459b58c6a33266f1cd65c944da8), uint256(0x2ed166b44c88087be411effcb34d78e98e7dcdaa2b553ae65daff29d0c9d8e76));
        vk.gamma_abc[18] = Pairing.G1Point(uint256(0x18d786394e0fae9d814a61f74e9aa485a25389d44b9ba7d0a6afcd823b46a00c), uint256(0x1251cd24d66fc4229011c169217d449eab89f6486602a2c5feada9cbad786bd0));
        vk.gamma_abc[19] = Pairing.G1Point(uint256(0x0772a87879202ce238587b6b2eb7acb27b69038f48a30285bb03824d93f1530e), uint256(0x07e6aff852e9748b3c0e5cbf3e0129d044cc8daed0b554f2039d8ac38f47a0a4));
        vk.gamma_abc[20] = Pairing.G1Point(uint256(0x29f0ac59874cd19d2ab109ad8f8e9ca9b525ca68b44547cf8ae298b0fccfba03), uint256(0x07a05c775548eec34dd951929ae75078786c2d0d6d394002f07147c1da9cda4f));
        vk.gamma_abc[21] = Pairing.G1Point(uint256(0x0b3f3b292c2460bc4f235807ee08dd61523ac886c8ebe42ead26468241de272c), uint256(0x07aa84eab3ba30cf8520b05f71f1c7eb4f9c9e56b3a3badb667a86fb162d9746));
        vk.gamma_abc[22] = Pairing.G1Point(uint256(0x03e178fd88d87d259e016dbd9d020990b9106bc09137c13fcc7cca31c6d106e9), uint256(0x282ac00c8a794e38e671618fb1d7b369e92fc443f9a9b35589679ba23d286bfb));
        vk.gamma_abc[23] = Pairing.G1Point(uint256(0x0117fa97451ab354ae2b33d0a8bd7eb06bc417b871e2fa8692f5d117eb14d1f5), uint256(0x23c4bd54acc7134822c4739f1244725c1c6ec0d80dc39fb41a8e36f41d128644));
        vk.gamma_abc[24] = Pairing.G1Point(uint256(0x195ef4a854d8ba76652d68863a77876b5c09796f675eec60b2b1df6790a3a4ae), uint256(0x21a3286339b982947de24cb1ac340498ea393b856954bf2364584547ad3e483c));
        vk.gamma_abc[25] = Pairing.G1Point(uint256(0x02a4abd9b1da74546c7c533841f0127dbdebff35687bbc9aa09b31bfe253b521), uint256(0x1b682da26a6d28d47ad41a443c54d5e348a60618c9a7b6f208a403fc1de76e63));
        vk.gamma_abc[26] = Pairing.G1Point(uint256(0x1247187b7d4042d89df69668a146a9cb30e192d8bd6529630f8355e7bc4212d7), uint256(0x2e73a6a93fb7881d85cc557d2044e41d3793cefd90dded78d37e82fb568bfa0e));
        vk.gamma_abc[27] = Pairing.G1Point(uint256(0x1d3952b51fcf97b6c4025d919ebeb9cd7427df1682ca07eb273a350042f21c07), uint256(0x18a3c56a4968e111509913c36e5614b232a05e25b6cb4ea796d6a7417e562afc));
        vk.gamma_abc[28] = Pairing.G1Point(uint256(0x1b5a0533cddbf78b7e8175616c4a1ba30913cac97c7ae5c945a8a7515cab98d2), uint256(0x1e13d514177cfcb51f1d377e85aff85e0c7195e075d91dcd745ffa6e9deab420));
        vk.gamma_abc[29] = Pairing.G1Point(uint256(0x07be5f6a43ba0f10fde4ebb9975d57dc5c1ee705a5fe809ac2102cfd74cae73b), uint256(0x0adf4e7b77bc062a855b29c2b9086d10ffb0015b3b8bae0bfb04e0ae05171944));
        vk.gamma_abc[30] = Pairing.G1Point(uint256(0x2160c4429f0a09a02a3b9312366a6f34a4c5eb2f871b1c8a3ece282889c38424), uint256(0x19555685201c00734ad9986bab067320a8322f1f0ac206c955622bc298944ec5));
        vk.gamma_abc[31] = Pairing.G1Point(uint256(0x0ca52b0f562171dbbf112273650b3831e441da03e299a52a2617b44d3fc3e616), uint256(0x0bb08a2d95486789d2a5f9dc30ef37c92c5ec5c890ea7e81c78cc6a6cf5673c4));
        vk.gamma_abc[32] = Pairing.G1Point(uint256(0x097742b2b2b95f41029ce1e2e4c37c810b1f54535328d9ddebce111336823c6c), uint256(0x28ca6eeddeebca6c20beb92a97ae2ea785f2c23a9d182bafbf3d7286751ba1a9));
        vk.gamma_abc[33] = Pairing.G1Point(uint256(0x1e6513d6e6bd26a81a41420fbccd42cc1ba77ddabb3677ee3a01f8707769daa5), uint256(0x0455f6a5127c2cf37e2c805e68711539c7d72d50a526780d2209de34e0e2556a));
        vk.gamma_abc[34] = Pairing.G1Point(uint256(0x22551ef21a0c6896ccbcf2bd7ca22eaca8ac9ca4c3c7b0c2a4a8838536330849), uint256(0x1874e2e029818a783849045deeb9a280535b697b71c9e5c6177d8c23bbddcf6e));
        vk.gamma_abc[35] = Pairing.G1Point(uint256(0x13a1624812cc8f559d25b812e4b5921ab05dd8cfcca654e860d9f32f7ddc78c2), uint256(0x2911310db2e126e08997793ddd4ed0bfcd550b691f663a8e791a4f6832bf09c9));
        vk.gamma_abc[36] = Pairing.G1Point(uint256(0x1837ad9c1dfdbee986b9ea750bd6af5032a3c68849eb42ad4b9ad8173c000223), uint256(0x2aa5a6826ffe1326685482c95fa6790286d8780682f27d807754b713b6ca4dd4));
        vk.gamma_abc[37] = Pairing.G1Point(uint256(0x15af9b4d47ea364fa1980adfc23d1b237a6578afdca356ec67deaa2635cabb49), uint256(0x2ac1b4ced70bb5698aa6802dc0fcc8f04da2e8ae3d3facb14a84403c47911b5d));
        vk.gamma_abc[38] = Pairing.G1Point(uint256(0x10ddde256a0148d9853f0a41b6e83cf201fbc73733eaaafda419d5c5dd185709), uint256(0x16ebd12a919fb0606f420039674dbe4d4395862566d97924b6e6fd5a0d6f3028));
        vk.gamma_abc[39] = Pairing.G1Point(uint256(0x26a1ee80e870506d607d9d46a42cb64099ae1568d0ffe5e25b6c938614658b6b), uint256(0x0046784a20b00eae5a5af9ae2b65ccfc244063a0f027345609965e2720cffcc2));
        vk.gamma_abc[40] = Pairing.G1Point(uint256(0x2b62fe510b749332798f8babd276ee3b427c0f829bfbf6e4d4d3f5b7f3b2b6a9), uint256(0x300527001946e3e04d9d3cf28006a651c8bc05c14c0a8ea7c070fca96c87f4aa));
        vk.gamma_abc[41] = Pairing.G1Point(uint256(0x29d848053542c5083db4798e104ee6aa990d50e01a8de3b054d78d7241475556), uint256(0x1e4b9add3eda8f083809022836f804ccc8fd98a31a86f9a4a942bc306a2ed3fe));
        vk.gamma_abc[42] = Pairing.G1Point(uint256(0x03ae2b72d48fb59193061588d75485dceb7e732aaf13326c314d9a9965a4a12b), uint256(0x2d4acba158e4bc40097110b8c3eda173ff77ca3245996f0087eb5fcfd8737668));
        vk.gamma_abc[43] = Pairing.G1Point(uint256(0x0ad73ee617d78e272083770b6b2280c5ffb00b4d91e76b93fb1ef54f0146ecaf), uint256(0x14777f4c92946e3e6abbb510101f900a2aa6c3f1b38630f8ce1d6b67a16175b7));
        vk.gamma_abc[44] = Pairing.G1Point(uint256(0x2c37305a2f304a6f25c61b2176761698cc4e1f048c43c944ecd5f6d6dd466370), uint256(0x1c18ff4bea2173a5e0145d5944b130766fbfe748c379137640a5deeedc96e5f5));
        vk.gamma_abc[45] = Pairing.G1Point(uint256(0x13ad90e0149d6b09b7de9d9f45e55e60c680094872c8d27afe4cd3121cb23a7f), uint256(0x1c56942af5a14f01640ecfe9162b505f4f00479c9a255c4e29a4628550bddf3c));
        vk.gamma_abc[46] = Pairing.G1Point(uint256(0x103a2ee2600e0e0f87be27b6d08f392ec5155cb0d01af6abbee42df33e48a507), uint256(0x24212b7a399b062456a42d4ae4c07d0b4e75048df19f912e41f1210a53399cfa));
        vk.gamma_abc[47] = Pairing.G1Point(uint256(0x272425493fa2a809942345a26d5004c1a89ae15df3f3518669abac8ec6c14eab), uint256(0x1ae8bf90400ada5df37a0abbadb891c3f76fb4f652276089a36c9df1427f4a71));
        vk.gamma_abc[48] = Pairing.G1Point(uint256(0x25e8df75791d2e5587972285ee44bdbd9748fc09d4f79c0e289b6c84b662137b), uint256(0x10025ab2086b247e9b41ac9da166601e915b8789c1cdd78f4999c996a18a124e));
        vk.gamma_abc[49] = Pairing.G1Point(uint256(0x0cab62a66cbdca3349eeb51f32101dd87c43d96ce09e2af44a0514ed8e64b30a), uint256(0x00aebffe0ea40a19ac2919eae8e4dbd765ce8e7695f0d5486fc26dab58eb73be));
        vk.gamma_abc[50] = Pairing.G1Point(uint256(0x0b831df8fabcba07571bbeb903f544e5863b31d3fa5fac82e8b565a55365d25f), uint256(0x10790e0824472d81f755931188a5cadab7aa7353b9abe264d4868712db9fc6e4));
        vk.gamma_abc[51] = Pairing.G1Point(uint256(0x158e8eb7230efc1b6f44a2d735deb1ab4fed65be763a318fc0a12a9924fbbd5e), uint256(0x2255fdcf0226bb41d1de952fd45f100e982f194643f2e0775b43acebee17d019));
        vk.gamma_abc[52] = Pairing.G1Point(uint256(0x03de4d8cfe9414e52f5766b6d8c0eb5b425d9f9f44fcaccb13519c88e7fdb6ec), uint256(0x0df66d88b6a285aad99c51995b6bba8e6e3d11e75f0d60fc8b6f1644e61f2bcf));
        vk.gamma_abc[53] = Pairing.G1Point(uint256(0x09dbf60f24da17c26e4ba2a716353bfdf79218e01e8edda88fc03cd12c8b32cd), uint256(0x0d93d7156015b67f3718579188c31c3b4df52b8a7216b5f5e2b67081dc2a6978));
        vk.gamma_abc[54] = Pairing.G1Point(uint256(0x0aca518e2b762213b604c973876a5488c6a84262f6421a89537f42a43cbb5b4d), uint256(0x1527aeb16c35ccfb27f79663f5f3a9546b30ab920753513c682c56a67870e1fa));
        vk.gamma_abc[55] = Pairing.G1Point(uint256(0x260d0e5be61eb8af7968573f6d902495f1e21c1e233e817f5680aea33cd216ae), uint256(0x1543f3c44eb50e0fdc1eca3969834dce4d6e284f5c3384bd757b6c25d356be7b));
        vk.gamma_abc[56] = Pairing.G1Point(uint256(0x219c78d0a4cb4661f24467021cfe9e81457a3797afec5fc135f0590d34bc5a87), uint256(0x1a7e8f8ba14409eedb8867f8c2d99633a5ae5aae5e5e53134e71d5f04443c2f3));
        vk.gamma_abc[57] = Pairing.G1Point(uint256(0x15a7ba9acd75d355d82799f43c0df86329406515cd57f01ee4d4a33f4c1eb916), uint256(0x05a63b57f8015128698af79350c82e3f482ed8a10af984cbee2c399c7174a5f4));
        vk.gamma_abc[58] = Pairing.G1Point(uint256(0x103372c794ad06f6e3b828a657a2a92f7b550a54d9031f712dc7d9296af71d83), uint256(0x24e3c8c9128b4c4093667ab1f2302333e7084a3e256fc479f17abb7d06afc3d8));
        vk.gamma_abc[59] = Pairing.G1Point(uint256(0x27c144a64bb689eb281ec5525f1e2c6b83bff461029703712b54b2ac61d8a41a), uint256(0x0a0014d3a31131ec2133ea2886ad7165696eae2ba10be3a4b20778c4d6c75fd0));
        vk.gamma_abc[60] = Pairing.G1Point(uint256(0x1300155e67a493f830d83f0ee8f761ce6b295bdc06f71b157b84b433f6c87d3b), uint256(0x271a2305d4a4f760798622a8647c86eb4dd373c25134d03664a4ea563004360c));
        vk.gamma_abc[61] = Pairing.G1Point(uint256(0x2243b019ddf182073f1fbfdeed335293d9fc2e8d54388c0c8c5e69bd02c1deb3), uint256(0x23ce61661e8725152bc1687474d7fce5a3b50bd04fe82b71f99e5ce277af0ead));
        vk.gamma_abc[62] = Pairing.G1Point(uint256(0x1ff768e8bd27f85b7dc9ad2a479a9df2418c28847ed471eaf24a9c96d3c9bb59), uint256(0x0afa11572ba3788ae6d1e7338d8eeff80454aa6535ab827b9bbcb144c4774458));
        vk.gamma_abc[63] = Pairing.G1Point(uint256(0x15a578e0d810a2efec9fdb26aeb4c60fe22ff4e4fd9636d6587a3dd2a486f27f), uint256(0x03b602b163e51167927873d57e100934e85796047d17b46bde1b792bc948514d));
        vk.gamma_abc[64] = Pairing.G1Point(uint256(0x2dac6b4a9ac0dcb2a21dd3fca02eca63c17b4526d3df2a1bc03fea69c7f2ff77), uint256(0x1d2a1c0013fb28385db35f70b406a76cc07be49ca0c3c1a6b709c9d4856c18e6));
        vk.gamma_abc[65] = Pairing.G1Point(uint256(0x17aa44f4d97b6647c3c3e8c9bf669a4e832c58a6a5b7fd01811c1f6ff2fe986e), uint256(0x0fb963247c32b9bb36e81ee84cf465d7285deac5ac39ed42e590ac2547b77dd7));
        vk.gamma_abc[66] = Pairing.G1Point(uint256(0x264dc66f7f2b371cb17fac054308c7be76181ae8040eceb0f69058674dede8f2), uint256(0x1ba1677815e51f22a9b2f5bb09f846c32f65e0b1eddabb1b8770f89df192c3a6));
        vk.gamma_abc[67] = Pairing.G1Point(uint256(0x024e1a63f34f539fb8fc80baeae18f0222fe6bc7a4b0cc8e74207b5a1634d967), uint256(0x1762df61dc668cdf9d8b9a349878409adbc56f9973d2047f5af83bee2192b591));
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
            Proof memory proof, uint[67] memory input
        ) public view returns (bool r) {
        uint[] memory inputValues = new uint[](67);
        
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
