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
        vk.alpha = Pairing.G1Point(uint256(0x0fe95023fbc29f2f88cdeb2b5d54c0bb80fa4958469c158a5b17f2eb0a910639), uint256(0x1fe443e0726c2dc8c9f845691ac62a01525d783ce5c6c76c52b479084020427c));
        vk.beta = Pairing.G2Point([uint256(0x091a0346d0a45b1e7768fcbb731ae0f959f35b9c813ec5c223ee00171657ec4e), uint256(0x10a529d87d478b40ae33f31cfcc7b60d45587080f24919881727b13cd2338f81)], [uint256(0x25cadf06964d8c82aa1d602a835804c4529f8cf988c8632ab16cf85c6139aa11), uint256(0x11e770bee9181cb8d53cc045f148281789e5036f64f15403aa19c3af3fba372c)]);
        vk.gamma = Pairing.G2Point([uint256(0x0cac6624eef7ca939a8f0c4dcb3f05ebd1337ee5b881e55cd44d4d3f93352ce3), uint256(0x13d626995d2c46974f2e69347daef4f4e073755384fedb848f0eb487e6271b3a)], [uint256(0x082f1fc6639de64ff73390aa9a63e959ada6dd3aebf7cfa196a463bb40919311), uint256(0x12495a51d52bf3b638e0d622aeb1ca96b95208170f1580c6a829b9b1ca23e620)]);
        vk.delta = Pairing.G2Point([uint256(0x0ad7baf0993ba831e635a8c391d2b3c5e2670b418a14026cde3381959c19dd65), uint256(0x0cdb1d46305f67f1f6d88c087495bfb5435b0e2caeb7137c53df5ed4101ad094)], [uint256(0x03362c8b4ddb4a7dc87dacc5a98665b0fb06797e7ad1cef143be636eef798c24), uint256(0x26f95a8628f0332a6a8357c75c07e29180505cdf7e7118394b75ee98ded206c9)]);
        vk.gamma_abc = new Pairing.G1Point[](132);
        vk.gamma_abc[0] = Pairing.G1Point(uint256(0x29d85bef29ca0be1b466ca81dd5f8e5146fef278a66d29062a5b56cc010ecdf8), uint256(0x27c94d495f46baad2062b87b3d39876bd9e15375389a14e1d5167cbbc3f085a9));
        vk.gamma_abc[1] = Pairing.G1Point(uint256(0x1f831f215de4c83f686c934131623e9aebeae4cd326fc3273e0164ac55451a6a), uint256(0x002bea6876be2ed37e20276a013c37143a5debd338f1f9896bfbeb284447213f));
        vk.gamma_abc[2] = Pairing.G1Point(uint256(0x1af814ad788f6bc37f5c28fb80993e0d553af2130a4a1ef3323858a600985091), uint256(0x041be7b7ec28164cc8095a0f7b28ed125b607ae9a074b9160f7dbdf5e20a2e96));
        vk.gamma_abc[3] = Pairing.G1Point(uint256(0x03b64900990744c0c9863a6017d6db61386b082a6f10318b24faf944d1ea277c), uint256(0x08156f0ea512620d2390b0b9b5109e6bcd42f89fbd1c1d3a598e78b215a0ae5d));
        vk.gamma_abc[4] = Pairing.G1Point(uint256(0x050871b455584108b409992e0c193937d1908f58ee89da92a065f30e720577eb), uint256(0x07fac6db1d0befce29767e2c87b54548277e08e6d50892edff1b1b7186356b2a));
        vk.gamma_abc[5] = Pairing.G1Point(uint256(0x294d34f408cb05bf3b22c438a27715cb68635e99296b0a1d1cd4999008d442d1), uint256(0x0a582958d9cafdbb3463fad0115880b61276481a807bea5b0f00f4ca6102766c));
        vk.gamma_abc[6] = Pairing.G1Point(uint256(0x15cf80b3d20b28d5376b3ee7f1c752a592b815199174b937e0ef512f326e1cca), uint256(0x1fb2ff369dc53164d9decdbc22cfee58b5cc520fa2d97c3eace2d46a3f15f222));
        vk.gamma_abc[7] = Pairing.G1Point(uint256(0x2299613dbc5f687893cc470c90f175b68618c8cab1a050f7c112ef25af44dbc6), uint256(0x20351a1da24821c381097140bf1af31de5b8a21c90d7276f4dc335fee8513f0f));
        vk.gamma_abc[8] = Pairing.G1Point(uint256(0x23e5b5840ba7d922fd14287b9869d9903458fafca45b44f4ca06a157da65aeab), uint256(0x1f29352a33b2f0022d03de0622a6f4ae9369071d5d233c9b8b4e6619a64519dd));
        vk.gamma_abc[9] = Pairing.G1Point(uint256(0x02a8f1cc3011180890c7c71098bd047fb3bb63741ccd5ecdefae10ba74a0fe5b), uint256(0x19f5e792f67b757412fc9d6a5e84d51175f63a02a45a10d7442d64463d24d5d6));
        vk.gamma_abc[10] = Pairing.G1Point(uint256(0x19292fb7793fda9b59b4a090b79d631f1afcce69e4dd2da9db7f2f35162a8f05), uint256(0x158993219aa0b27777c1b717ede66d577e0df9883e2cdb20d96f60c16301e955));
        vk.gamma_abc[11] = Pairing.G1Point(uint256(0x11470314f9d9bc50ea9021db08b2105dcc0a0759888a1643ce2a22f4ff7248d3), uint256(0x1be369d65daeb67c66e01d8ddd4017fe1c6bd82e3e4171303879d0de63f6891e));
        vk.gamma_abc[12] = Pairing.G1Point(uint256(0x1c513ac563bb3ee4bdb4c2314b6f40bdf98cf4223d63ace668db3fb84371c4a2), uint256(0x01fa0e31ab5fc04dc5377825c5242e186f73c60d6cd24c8badc1e3ae7a69e2be));
        vk.gamma_abc[13] = Pairing.G1Point(uint256(0x23c0818b71c86446592341303088203dafb1a62831aa7948237df75d55611f98), uint256(0x06e369aa7ca8489db4135e13d30e81a076a5c0d4d8111bb3c47767eefa8310d6));
        vk.gamma_abc[14] = Pairing.G1Point(uint256(0x14aa7c01a372adfe6f46aba9b86c0a24aeee664cbfb40c18f4a245dc350024f8), uint256(0x22f38f6c3a5618249e356d0bcac5680c2fc678ced850fb5e277aae9a82815fdb));
        vk.gamma_abc[15] = Pairing.G1Point(uint256(0x1fafbe683347923f130984e84b4c497848067e35203f5cc7abd340c17bf89f4d), uint256(0x0a9484d7f008f31c4f4d87138a2bed5361487d1ceff06fc836f664f0bc2215e0));
        vk.gamma_abc[16] = Pairing.G1Point(uint256(0x18a09b3d61536525180155d9e0a1dccf6f0776a7988fbbb5dcec1dc0105502a2), uint256(0x252dd8e9a69ef04630633ac76b326f0f43f66760b708043523bef4b8e82dc83a));
        vk.gamma_abc[17] = Pairing.G1Point(uint256(0x1b377b81ad8c6d1c80d777e900cc0071a329246c1cb8fb4611616b470b4d1067), uint256(0x0f9729a48a2658efcfe27f0fde30da058e478d0ecd2dd7528a34417d7751fd0c));
        vk.gamma_abc[18] = Pairing.G1Point(uint256(0x1e3e2ef03c2e9fbe46d7e48ef0266c16034eb8e00c65cc8459e9b5cc71c95737), uint256(0x1191ca833ab9755b7d20e6c3d053004d48eefc7bcd5841ac96085dd3c29c20da));
        vk.gamma_abc[19] = Pairing.G1Point(uint256(0x2876649cb1c8f347c90cfb07f2363a8e985859e685fc61462a7e581aca6ec487), uint256(0x26442017fa677ac5bf1a96d8b52bff9b26b6b4ea782c281cf819c9e63c0e262e));
        vk.gamma_abc[20] = Pairing.G1Point(uint256(0x1e07e9c9eb414547ad5e0e63fce29ed79ea9f2002f4ca56f250a989fc917027b), uint256(0x1975a5ee7dca83d4a32fc76eed9cee52cbf6129b1aabdb4cccb3c82231710576));
        vk.gamma_abc[21] = Pairing.G1Point(uint256(0x20e113342f62a456c8e79983f523034fb338b4973577a084cd26e4c416da74ec), uint256(0x11e65f63c0e0ba966a67196eec0845f5a2bbe8fb9bd3daf1321ed7aab8024ab5));
        vk.gamma_abc[22] = Pairing.G1Point(uint256(0x0d4279f8b2b895346d0fc10777936c925c8da67d22485f241a17a8d6a7c5a693), uint256(0x23ffde6d301b5c10ece1c3b79269ac1659d47cead629ffbc877c783525f824c3));
        vk.gamma_abc[23] = Pairing.G1Point(uint256(0x057b135c0d77f513cf29b35074b364855ae6b28649871f5d2a951fdf15542354), uint256(0x26660a12d6bdadb642d21882eddde8777dcbb34312861d18e9d2d054d11607b4));
        vk.gamma_abc[24] = Pairing.G1Point(uint256(0x20634c6e7ff1d14fbe0434a2096a34d1771f5499edbc99030da8e39e5dcd1dbb), uint256(0x11de1cd1dec2d8e6be7612223f020b280bce6252c331186d85bf7cec51f0bbd6));
        vk.gamma_abc[25] = Pairing.G1Point(uint256(0x18b406ea5d6b67fc5eaf7e825389c9fb8925eef4bb5148cb8de0a7e02abbdf0d), uint256(0x186a889d1921643edf6d13687c71dc2e4fe5e462cea9eda088a95abbdf6222dd));
        vk.gamma_abc[26] = Pairing.G1Point(uint256(0x16bf65aaacd07cee015eb9e5ab42f338ba31e9d51da68eacb7b85314300e4c23), uint256(0x1ef0b5f4dfaae06c28633f20c1b4c079fe9af690c71289aec8b70d08c4f467ef));
        vk.gamma_abc[27] = Pairing.G1Point(uint256(0x15441166a59e6dfd9d135090e4a46fa4246381faeaa3ea60469beaedf445a784), uint256(0x0f8286594b31dba623c90ab6b2be35259bf4d414f1e047ca2f4edeb0813c328a));
        vk.gamma_abc[28] = Pairing.G1Point(uint256(0x0f08878eda834034f6d9c63fe701b709eb0d6e61f293df49a479214d5844ac0d), uint256(0x11d731b12aa15b9223a1cc0a943d70a2979d3dac4a5b4401b32f901160e0c6a3));
        vk.gamma_abc[29] = Pairing.G1Point(uint256(0x2b4c3febe25ddeb0d19fb0573758a24fa94abc37bda55902824f9d467a168ffc), uint256(0x1959020f686f4bdb3dd86761e559763b7a9305d6302367b727221ffad4b426b5));
        vk.gamma_abc[30] = Pairing.G1Point(uint256(0x05707b94adbdb2e4b982c8acc74b55cd05a4c0a00b0b7802c08fcbf88f4b294c), uint256(0x213966fe30522a472547fc25809f0b14235d68c6d586fb80e0d112ec56764d4c));
        vk.gamma_abc[31] = Pairing.G1Point(uint256(0x1098e915e0a21515f3fa29ce9fa7c53f75568797197a817c3878a8def6d8d9e1), uint256(0x05e7cf68343a2f7d2aa498c820745dd222852505d63ab0b38f0adff115337795));
        vk.gamma_abc[32] = Pairing.G1Point(uint256(0x25a737160bd50cea2f4586795a8d74bb6b6c27bc3a42e733f79482de689dc72b), uint256(0x13e85dca321ebf67ad8192a77b6acb791b96e571542d19b732b85a10b26d00f9));
        vk.gamma_abc[33] = Pairing.G1Point(uint256(0x24fc2d7a8ea6f29cb4e7924584842d3936e4b1277bac62de1030bc4cc1801a81), uint256(0x20fcf4a61dac074a298c349fdef5517267d42b9ba9b0ec84801bf78538bf71f5));
        vk.gamma_abc[34] = Pairing.G1Point(uint256(0x07eaa7dde64e813724fbd3fb639a303b26bbd6cd74f51ca89ecc5221b14ce0d8), uint256(0x038700e1836f143832fbad3a6f8fbb4f99eb7069475f8ffa7e5e66a297325674));
        vk.gamma_abc[35] = Pairing.G1Point(uint256(0x21375ff16755d69c8b8553b3e8954943fbe19fce735dc6617067dd075f4bc4c2), uint256(0x1fdf8d4110253a0b7e0215a44a939e6fea66164fdf8fcd9570810441cdd97e6f));
        vk.gamma_abc[36] = Pairing.G1Point(uint256(0x10a40c9157b9d35522be0e5aa04eb8eb25aa0e46bc5512e823e31354ea18c01c), uint256(0x02a1a92728e4467b71d97da2a5d58b6c24ffc257ea7d8678cac632e270d1557f));
        vk.gamma_abc[37] = Pairing.G1Point(uint256(0x1ae83afc669f92b61637b6e56dab963e1d5a5d2e03948489d2bc51fe0ea9b87f), uint256(0x0daf2a170fe0feb21d7b244fd2cd90b1f6fd5d346af43b544eca13b096e47acd));
        vk.gamma_abc[38] = Pairing.G1Point(uint256(0x1bf36b39ece3dfd4f1b4576036742a9acb9c68c3aec20e39439b8bad15fbee75), uint256(0x1886916de8cdfb1bc0f2cfe8827dfa2a0f1394714dc7a3cbb1ac443462561fa7));
        vk.gamma_abc[39] = Pairing.G1Point(uint256(0x195e9093b49c6e3eff12ee7685a26b31927ea5df5f854590904841e40b0e2a84), uint256(0x00aebea21c9edb619f6a53b6823741163a0af5a769ea2a415522b5ee2dd0e4e9));
        vk.gamma_abc[40] = Pairing.G1Point(uint256(0x2c9b5a0690a252c6f7ec06a1046bd3cd3096eb9d1dc3bc34a1558e9366871075), uint256(0x28e3e49f0f1bbfc4d0d38fb00f35de7683868722980c4d5764c92c70834386c9));
        vk.gamma_abc[41] = Pairing.G1Point(uint256(0x0f31bb48b73f41f4ee998e8c305503d0dc1f4b67091a3b059fc861800520816c), uint256(0x07ff9849f3d863da0df4b0ea51bb59246b9663c4ad35a7cc48a3c014a4e620d2));
        vk.gamma_abc[42] = Pairing.G1Point(uint256(0x1a0538f44890be8d3149b1be9c6df6767253dc63b92dd20543b82853a3882b7b), uint256(0x1ac12eb91364fc14a8ced0857018a34d9c4e2e0d7860fb88ae14ea40eaa9dc4e));
        vk.gamma_abc[43] = Pairing.G1Point(uint256(0x1866091a1513a2096a06b8546240d50f2f019b12fbc8a8bd58f3d6ce71ddad3f), uint256(0x24c7324230cf8222021bd7b8e6179f4c7cc195a601db0346205a310ab4826258));
        vk.gamma_abc[44] = Pairing.G1Point(uint256(0x1d0b743cd15c8c06f464c1d36479e4e69668043e792617c6baa66dcc1d566f4f), uint256(0x054e02fc3073822fff8c0045bda8d24ffeffdf3cd79bf57fef736bb2356df4bf));
        vk.gamma_abc[45] = Pairing.G1Point(uint256(0x2112a24029b2a32a815ab0efd0635d5f40f6e092487590f48d0ae01a366348fc), uint256(0x1621e3141fb3622bc46f0aaef3e81c8144a7921becf387d201703ff0625b3fd5));
        vk.gamma_abc[46] = Pairing.G1Point(uint256(0x0f33571fabea4195e2a7ebb2a3d50bb4dfd0744abe04e2bece531c6596cd9e38), uint256(0x02681d8d642688dcaaa57df3a30215496d900b62a29abc794933138378cac742));
        vk.gamma_abc[47] = Pairing.G1Point(uint256(0x06a5172d923cda105af6e23d6663a7e47c825d43905603ce47cfbddceb1000d1), uint256(0x0f0e3de193c7fdb8ae8d23a21d23d0d47c51ec52d655cf03bd2d1f7adc053272));
        vk.gamma_abc[48] = Pairing.G1Point(uint256(0x0716e950aa10e589b82190aaa7b2f0ae46eff6faa83e5d8ee3fe40d9ba17e865), uint256(0x2bf5d13e542d5003d70be979f2e28021554cdcebc08a0c75ae77424ae9bf770d));
        vk.gamma_abc[49] = Pairing.G1Point(uint256(0x2b131d1aca389da5e5c387339f39272106e1f66f7436ca6273512f80f659460b), uint256(0x21889bf5919199becc7240a1b84bc8570094e0138e4bd3c4666bc0e0a6188e3f));
        vk.gamma_abc[50] = Pairing.G1Point(uint256(0x2e9558f204bc3804841a157af298038ba050dfc7373bef3431a4523cc58532dd), uint256(0x14239e8bb2535a7b1a80c9b7002c95d0e060015d95bb117eb7e3a9d0a57a7f07));
        vk.gamma_abc[51] = Pairing.G1Point(uint256(0x035d46b5fed7c55afdba3bf97ba5080b2dc17de56722ca54180d2f9e079775bc), uint256(0x2f9e4e346716bec53069d23ec03167c76c07a6b39556dbe88a4cb69d231e42b9));
        vk.gamma_abc[52] = Pairing.G1Point(uint256(0x0f7c868d219f207994e3eda260c0c15cdd3da400aafcaad98b0dc97aa551bf0f), uint256(0x05d7e6d6e78fd8b2fb5ec1042c2897fa310c306a3106909b27d891164b932bfc));
        vk.gamma_abc[53] = Pairing.G1Point(uint256(0x00ddb0bb79c22f9d288cdec5d5df8682a147b6c3ec3d0a7e501fa2d94ee59c4b), uint256(0x20a4db0ba2b917fb5ea2c42f9ee6cc82bc66a7fa601761e9ad1b2b00a9fdda72));
        vk.gamma_abc[54] = Pairing.G1Point(uint256(0x13b4130c4bbae083d0b52509f8444cd71f391f694f1289c6aa5c88a426f7a391), uint256(0x2e34bc13626dc68f4a98d4224fec50e98588fec84605b6e3624241e4083eff2e));
        vk.gamma_abc[55] = Pairing.G1Point(uint256(0x17e19e82921ad0475e8b0af7866a9407fd070e115a102f7448201c88532378f6), uint256(0x2fb3c4e2cfebe7314e65a6dc94d53deb061583618bdec1cd1e2410c7c8ce9e1e));
        vk.gamma_abc[56] = Pairing.G1Point(uint256(0x02dd9d8a88183ded79f3b1d167e6d40399a49e574543aeab97f479d3b8e2d546), uint256(0x0157f849fd7a45d755ee0b8a933cbe460bc951b9f0498f4c3eb41af647731857));
        vk.gamma_abc[57] = Pairing.G1Point(uint256(0x2e2cc52ed61d27ae81237ec7dce616312dd294e075cbcb42130407fe9855c371), uint256(0x01ba1fe6ac3d36582be60c1760849dd08e78c867f4dd289e1d950802b62b4492));
        vk.gamma_abc[58] = Pairing.G1Point(uint256(0x063177f0b3ae0ac488fd42229313d532454a210148c6311b0cdbad77a9e59d53), uint256(0x05996b1835ad5d28bf406cab605f915ba3aea44204af59cd2cc1bcd03268744b));
        vk.gamma_abc[59] = Pairing.G1Point(uint256(0x08585553552d728ea6fa5df8a919cb2bf00a014585c642aa88df9bb4d1d0837c), uint256(0x12ae6941c18cd8e7a3d4c9880bb708a396e1d44181ec01a0d94b1a6de8437ec0));
        vk.gamma_abc[60] = Pairing.G1Point(uint256(0x20dc072ec05053b6afb5a2e60cd7476272b3a7450789f6fdc396688d2115eda8), uint256(0x198e5e3f5f458488056f77714d8269bb3e5471ec7c8a37755b7d4b794b9c7055));
        vk.gamma_abc[61] = Pairing.G1Point(uint256(0x06eb41656b73a3f0dd957a4027777884622f9a8d1f798591dc13c57ff9b5a71d), uint256(0x16a770e3659847ab9dea25b82698602b9917ab50f08fea1427b6b8dbdb739fbe));
        vk.gamma_abc[62] = Pairing.G1Point(uint256(0x0ebcb57f60f4bb59689c1d749f9f2c32ff787f64a5834d549c435fea6118f932), uint256(0x15c6babd447b7538d29530e51411d0447c9f8faf6a8adf788106b87571794772));
        vk.gamma_abc[63] = Pairing.G1Point(uint256(0x1665c45bec6055ae60f92288ef8f761a35f16092f6439e295a71a0b657a7a7c7), uint256(0x08b0eae045cf6a55e902a421d1b5606bf802951baff69b7a5e559a2d1a01ea14));
        vk.gamma_abc[64] = Pairing.G1Point(uint256(0x03667489ec5498a08cb2140540707d323eb5169fda15662bec8edfd50c3a3a52), uint256(0x0ae0def7c49b68a7be0851b79d15c61df9a574f5b5d5c499e420dacc4db71a9b));
        vk.gamma_abc[65] = Pairing.G1Point(uint256(0x1a532aaf4b930b35684714a5d1e5d9a62fca2aee30ea208205ea4318b7b86bb8), uint256(0x2491644f5f8d9e70d2d4c9c51ece1ebef203f5fb016410dd17dd32e5ee4922ee));
        vk.gamma_abc[66] = Pairing.G1Point(uint256(0x2a6a3005c8dd8f59db5f076398f2ed0c9ce53233bc1d9eaa5ea97b5744f64bbf), uint256(0x2233048dbd448fd1b11787e7332d939e5832a3fa244e873208422a3da72faead));
        vk.gamma_abc[67] = Pairing.G1Point(uint256(0x0c20911d53460918f1706005fec29f057852efa9ca7738408617c2973f060b22), uint256(0x1a016a8fd85b0fada1bb93324e6f2bfcd9465c35a15642feee95285368433d21));
        vk.gamma_abc[68] = Pairing.G1Point(uint256(0x03eb617ed99c90f51e6dc2b697414c8e7a4fa71c0701e3398ea606ed1cf8edb4), uint256(0x2a847030783793f95d5f613384bdc74c3e7450a8a697fc124d5cad99c6b90443));
        vk.gamma_abc[69] = Pairing.G1Point(uint256(0x248ebbc6d6f092938b2e70f9314e4f9007587193034bada7f3c132ad7675a458), uint256(0x0e889b5bd5d17d941030c0027545e00aebb6d4e11cff084764e3cad5052df0fb));
        vk.gamma_abc[70] = Pairing.G1Point(uint256(0x2a67bda3ae5c9641f85f6c2daf1c43d8f602cacd9ab1d0fb130bd1de084556b8), uint256(0x1f938654605aefd7f159662b13a4a791abb0b67694cd15a378e91bdab7b03ca4));
        vk.gamma_abc[71] = Pairing.G1Point(uint256(0x16d6fd917eaa065a9bbb5b27f7d8dbfc8a20e90458bccc02d79728f21e62a788), uint256(0x0b086337188b961f87f9930d9e4eabf7275a752b2f6b3e9c71b255a55b676f58));
        vk.gamma_abc[72] = Pairing.G1Point(uint256(0x25c22fdccbf5aea16a00f6ea9b05eb3c57485892ae5407fbf95e331f4bb6b288), uint256(0x2c90c887ebc4ca0d5ffa3669e8277616bd57ff2287af9c42c4e7d462815d3f56));
        vk.gamma_abc[73] = Pairing.G1Point(uint256(0x1effaad81e1e43fb3a4ad6341a326396621209e1bee429a518ea4585a1fba9f1), uint256(0x0ca79be392efb6d39fda085a5ae6dd6a9073b12178eca6045b94d27bb407e9cf));
        vk.gamma_abc[74] = Pairing.G1Point(uint256(0x12b4af81704e33374f5a357b65c53f9cb93f1524adaac88fc712acbd837ad582), uint256(0x247d462b7dcb7a4c167f93f5fcb6ce44b77a4b6c7dd8f7c7cc71407a185e971a));
        vk.gamma_abc[75] = Pairing.G1Point(uint256(0x03d53ab919a6b200c16b80b4af23fb9997340107e422dad81413708918e5e895), uint256(0x1d16b9f224199ecef195b6bbbdefd526598cef39e67498abaebf4f6ef6813166));
        vk.gamma_abc[76] = Pairing.G1Point(uint256(0x2ce54d32a74b708cd0b2dd3c08c8524e62521302dff4a13484155524d08f7ff9), uint256(0x154a6f93bc7dc6fd6c46f12a99691fb628fb892de0f713445eaef355401aae0a));
        vk.gamma_abc[77] = Pairing.G1Point(uint256(0x09b7b927fe947227699657601e704e82a23b97b7944d440be36149e396056783), uint256(0x17200b42d2a620977b132b1f399a8b5258e638f0d0e13848457cdf6551422144));
        vk.gamma_abc[78] = Pairing.G1Point(uint256(0x261bb76ae956704a65ab9eb6374b40925c35ac2e0ed9702a44209ac0bec35215), uint256(0x093a2201f41ac45cc0aa609e16b74dcb16805818b2f129cbd1f2bdcbbd15dd08));
        vk.gamma_abc[79] = Pairing.G1Point(uint256(0x18328cab9c7ecb3c56723f806bbd944da7bb9d62fd2ef3da27432db4d902bb05), uint256(0x01fd03db83b976f71f33d139170df811577fe7a0408e3d5043c7153724e427e0));
        vk.gamma_abc[80] = Pairing.G1Point(uint256(0x07d326ed0477207c5c10252728a956d4c99d26cb17cd22f2926b2d7068bcee54), uint256(0x2a1fac4da86b68aa591b61fcb57980fd9c35c98e2897cf1caa709b83723b5996));
        vk.gamma_abc[81] = Pairing.G1Point(uint256(0x28576f769cd38afe64a6a225114f9435b2d47fdaa27672ed11794783460b0eae), uint256(0x235637caef37e9d4b747d437b878172b7bf807d55d7609df7a6752a75e91c4fa));
        vk.gamma_abc[82] = Pairing.G1Point(uint256(0x02ee4da8441f15ecca4260e97b7d5bfc534ac651ddcfc71754322e1707cc9fd7), uint256(0x1c0b9570b502e7782e28ea2fd14fb657dda1bff2f89972c7000a734ee979976f));
        vk.gamma_abc[83] = Pairing.G1Point(uint256(0x0a9d41ce0d45d84161784cd843eb5a9c99cb2bf110db3b1e09d80d0e2cc89009), uint256(0x1ddf8f7501eb6e041927acad8c50beb1aed9429fbac58173d26ee9f5672f3df6));
        vk.gamma_abc[84] = Pairing.G1Point(uint256(0x02b5fe5a38b26247d58fc445a8bf50ab31b80f524d88eff65e601545394ffdef), uint256(0x2125a86823b93ca8b762a741a81d816effd5a6a26de2e07a35d34e996ddb2cc5));
        vk.gamma_abc[85] = Pairing.G1Point(uint256(0x2ed9bbde54c23376c8d8d6f8ba75c015293b6e119fa8a8d2c658db8b4198fa38), uint256(0x0ec13a0decb5b67fcf99fb462f4af602de7977a3d7539df295feae9f93fd058e));
        vk.gamma_abc[86] = Pairing.G1Point(uint256(0x050c36375a95b8c55beefd9076edb4418958f86a888fa500432f180356338eeb), uint256(0x2e271a350fab77e7d4defc6ca02ec1db570654d90845217cf14025e13b94a878));
        vk.gamma_abc[87] = Pairing.G1Point(uint256(0x22a5acf3fa3648198b1c049434b368926e79b35f0ce80823cf6102bf1656fae0), uint256(0x0613f067c3e94f23e44fef5e24eef8d49732c66cc84dc266a142e8816c7dc197));
        vk.gamma_abc[88] = Pairing.G1Point(uint256(0x0a7da56819c4de1fb3c5a735f9ba45ac324778469c56676725cb9ffeb859b763), uint256(0x139591452b11747898ee0df94be170deb8a59cb9c3ab04e5338e2e588765b445));
        vk.gamma_abc[89] = Pairing.G1Point(uint256(0x0746d44884d024d6feb13c2ed14d8f3fe857ea9c20fc1c2b1428aaaaecbf362b), uint256(0x1b20e830f1f41d1993b0eb09e7440e3d02dc450e506c532d4de959d0007c4038));
        vk.gamma_abc[90] = Pairing.G1Point(uint256(0x2ce1a94ef3deb8e4deaafdee33e9b42e8d55aefa02f03f210d8ec634fb7931ec), uint256(0x17bca58a276ed9fc57501ae451cd5ff6db76da439c27204e0aae3b328e35a19c));
        vk.gamma_abc[91] = Pairing.G1Point(uint256(0x2fa752bd0a187bdbf1c613eee6d97579da6bd41a60f235d30b85b1ca4508a8d5), uint256(0x1fb51ff385593b48ae5d3a19b62558efc9883badb8fae452c51d8f1c78a4d250));
        vk.gamma_abc[92] = Pairing.G1Point(uint256(0x116f51c49fda57ce1e3a337e522785949c0b665e3ef2c4a64822ce71506b157b), uint256(0x030eab7af5cb757a18315f427f009619098fa5b310e0a176b3e864ac5821f28f));
        vk.gamma_abc[93] = Pairing.G1Point(uint256(0x1c185aa68e28f3e72eee4f6483e77d48dfb07841936c162b37b3e862ee024830), uint256(0x150e51e335bd67ab5d1a385610bde7b1d634c583334941a5d8ce01a457bd9b0a));
        vk.gamma_abc[94] = Pairing.G1Point(uint256(0x0bd1de457638d7432038be8b15cc89fe2ad4b86f77db7c88da331d9579a5711e), uint256(0x265727dbc7fd9494285ef10df98dbef37eb4af182184bce9f640188af1aaca91));
        vk.gamma_abc[95] = Pairing.G1Point(uint256(0x178e38ca072c2336ce59dc2097967f5b520c16cf2375ce7bd8a30f2e82436374), uint256(0x18f814c4d172d2be2e7f04606fe922127459b79ab25f7124f7ea6170085ef7c0));
        vk.gamma_abc[96] = Pairing.G1Point(uint256(0x206e76920f93d70d78274440a3c4c923e1ea9a918891828d61033ab6d1fa7fc2), uint256(0x0faea1fa13b3c5dbcd147dfc9dc1ac666dab13e70fec8a2cbf2050fe4dc9e309));
        vk.gamma_abc[97] = Pairing.G1Point(uint256(0x1a98d3b124937f5e47b3aafb73e71774cb72ae11c0f0035fc4fecaa3e668e39b), uint256(0x2b281432b79279aeea4a87fd9081f0ef9498145cef0d851d1407501dfb9b5afa));
        vk.gamma_abc[98] = Pairing.G1Point(uint256(0x13189272c7247965a10647bbb40bc21cad05b884e4d1bf8e045f6498fb7d7e51), uint256(0x165bc8339a20d64e6f5a9d599db6d16d43cf90c80421799c6163f7d24f16c6a8));
        vk.gamma_abc[99] = Pairing.G1Point(uint256(0x220658b0b293e394ba90f6c5122d3e26393ecde7f22171f81423cc625b7f04a5), uint256(0x105d9a0aed8146b2d59275d62b71ce243369617a0eddb352b8b3c5d7ea759421));
        vk.gamma_abc[100] = Pairing.G1Point(uint256(0x1b932df06e852bce72f8923748312597f42908ee43eb83d7c1c326106e09cab8), uint256(0x0961b8776e08b11880460dbec5b5afe9a29749dc73f85889b3c0863c1e07b9a0));
        vk.gamma_abc[101] = Pairing.G1Point(uint256(0x07584895e56ab383f6aa2c02183b0de3f3ad88f5d810b0f1769aafd92b094723), uint256(0x205b7a2504e70356dec3595fe5a0b6c271d726b6ff6b04eb827cc62125bebcd5));
        vk.gamma_abc[102] = Pairing.G1Point(uint256(0x0b9889e19dea51e5768b3ea3487749e06d45a9a9ff5e1f2ba90ebe0d94d27de4), uint256(0x2e9e7fed2dd7dbd13e497115d3a8ad87d18677f69cb8d81aff2a735c7a6e27c4));
        vk.gamma_abc[103] = Pairing.G1Point(uint256(0x2199a98a02fd13af2318c8ee1268bfe27d42343f874f42853485321374bde459), uint256(0x1ba182ec23221751c13932b576c827b063bc28941b28a31087b3cc6c54499408));
        vk.gamma_abc[104] = Pairing.G1Point(uint256(0x05c3ed0f7a365a2b6ef853ce7715c2bc919a24e8476966edb3a9523848ac1e37), uint256(0x27d93f1c3d9fe9eb92ac977e5e81a795abad4f3b2571085eda8b33761c6b2c5b));
        vk.gamma_abc[105] = Pairing.G1Point(uint256(0x077c73ab7df0abebc37513593152080949b50ac083ffea7743d7db9e6ab11dba), uint256(0x0e76fb5a21b821d694584c1568b7982284996e07741ff0b0d4582ac3a53914de));
        vk.gamma_abc[106] = Pairing.G1Point(uint256(0x2f3be972a2780a43ee158e1c69e959c2eec46e75cedf7b2d29406372c50efc75), uint256(0x0b38d6a0fedd4b63844f09de7d8f36d70783b1b5eddabb07c400632440c6b92e));
        vk.gamma_abc[107] = Pairing.G1Point(uint256(0x07223fa55ea232cf815e4e269c9033c6428dad68f9d4c280abc4cbe22f4092dd), uint256(0x16445822a3b643647a8e7b9e2775aa8780cd1f301587d3ed3dcfd37dc0d348d0));
        vk.gamma_abc[108] = Pairing.G1Point(uint256(0x12ffd92ddc5f8b79e061683c1af89a774c938656a67af8fd12f929a2a78592df), uint256(0x171456dbe258104d97a8f2ef90ce584573511cd39556f61d76800b98db073232));
        vk.gamma_abc[109] = Pairing.G1Point(uint256(0x2fe6f810b9b078093b44f4cfc28a465e54db2cc744758c1f6bd92b93fba74164), uint256(0x29db27af2652b797ba7b4c15be5acfd57b64570b155b0a2fa8fcff50714b0f5b));
        vk.gamma_abc[110] = Pairing.G1Point(uint256(0x28ae5254abd3c80cb27ac79b2f15af28f58f7c25d26ec5c34e792a5fc62c1b97), uint256(0x2c65667c9a64135ce18066ac2a138eb4c73f19955a763f18ec5375e8a04642ab));
        vk.gamma_abc[111] = Pairing.G1Point(uint256(0x0a0fb11cfd37c6db06f116f179ac3aa6bad05aab8d10e83ce20b860a0d2cf310), uint256(0x2c70d9005930bb20ca5628e29fdb879fe858d5daec791ecbd66c70b23d90ccf2));
        vk.gamma_abc[112] = Pairing.G1Point(uint256(0x210690ae1b629877b46448fe1130c28aed590614dfb38a740b9273324561c651), uint256(0x1f954b2717745c0ad4c4a18f35787ac5f18dfc9a6569c3e621f12b71cc94d0fb));
        vk.gamma_abc[113] = Pairing.G1Point(uint256(0x136af4a4c933a8206760e15be4538180e6713ae761e32805eb2306dcdba40e02), uint256(0x26091714869ced791042ab445abcbcf470485d0319ee709499ce8fe6135a5b2d));
        vk.gamma_abc[114] = Pairing.G1Point(uint256(0x075aa065b08e2094983c009de21bddf2ba303c3ff7b62a11da9a096d3f11dbe6), uint256(0x071753f90c8be218ac0931dbda9e6a6714a55ad191b533f335b4e60ab35d9b10));
        vk.gamma_abc[115] = Pairing.G1Point(uint256(0x2c52ee91d6596a3b1528a4e907de7b9301feefef4f70869c5a730a703510c83a), uint256(0x28c10ff0837a7aa169b9c471d14f024c99c4192118d48b43b925a2d686440b9e));
        vk.gamma_abc[116] = Pairing.G1Point(uint256(0x0576cdbd9ead188309f5850d2233a0141e115e94fd7123da703d6bb1eba5e57f), uint256(0x1bffeecedaa9c3c579b70db868330c884f59fc0b3b7b5145ace35605b9dd50bb));
        vk.gamma_abc[117] = Pairing.G1Point(uint256(0x22dc1bedf4882e5dc69b0cf41c7b021680d467e8207218735762d9f5aeacdcdc), uint256(0x00beee7eec388a05a76585477f34cb1da6aea993ed5fc23a8c3ba8019464ccc5));
        vk.gamma_abc[118] = Pairing.G1Point(uint256(0x010c5e03b4322e58fc4ff0b6e10a02611859ab47d11ff48237caf830ce362757), uint256(0x0bf13cece51c86485baf6fcab032c345db466966f21b586a4cfea90f6200eb32));
        vk.gamma_abc[119] = Pairing.G1Point(uint256(0x0db4c99c87612ad536cc3b2c05f3237335f93b4f95ce0b18ac9b09db270da0fb), uint256(0x202fa5eaef5b75a029419639fd9714c696dcb4bf769c8c3c5afaa7bd082a74d0));
        vk.gamma_abc[120] = Pairing.G1Point(uint256(0x233ee8b7874699545196bdfedab5be6f8ced965f1b0ef7b8c7e0e0071c7a65c4), uint256(0x22196869bf43f8c1edd0a592b6788d23a175f70a52e14b85d64e096488693692));
        vk.gamma_abc[121] = Pairing.G1Point(uint256(0x1f901710d8e962efc0417ca57bdbacf0b8764c1562c217914ac76fcdd7a48d3e), uint256(0x09a083cea47dc4ba52f6bed2d2793aa963824d0608ac752aea0052113bf4b183));
        vk.gamma_abc[122] = Pairing.G1Point(uint256(0x186faca790fe23635cdf61d5eea89cf06de2e8234da6e7c44c094ae9b6ddafb8), uint256(0x046dacae373d55977da7d6ad01f43e906f657a29c0e8387f9edf830b78135974));
        vk.gamma_abc[123] = Pairing.G1Point(uint256(0x05eb4f9a49d88c32cb6a217c22031c01d12a57f42aa7b346454c782eb7f0a125), uint256(0x2635ed189df727c0bec4630df0a75bfd2a6fa8a6b771271c8c8c33a6d9bd41f8));
        vk.gamma_abc[124] = Pairing.G1Point(uint256(0x2fdfc270241a5cb93c53a28fb5013d175bbccd24cfe6420ae02e4b6912810490), uint256(0x13b3acf615625f67f0fb9dfbcd03ada76956274ec5f6b49c5e0952c16832f99a));
        vk.gamma_abc[125] = Pairing.G1Point(uint256(0x245254c3d85c427d9988ce62a383000ec6a611d53ed7607843396f69ab2ede28), uint256(0x1e9e8654aa57aedd9d695e47c088fbffac3ffdf514fd8da7b815ed42051cb290));
        vk.gamma_abc[126] = Pairing.G1Point(uint256(0x235cc1268bbd0f76402e9d464a9103a5c3e933f0a7c0693b3ad6cccd52c83b03), uint256(0x0856c3db96fc78fcb80241a6affee15fbeb9812155259195d42a04095ce2f001));
        vk.gamma_abc[127] = Pairing.G1Point(uint256(0x02053ea60cc344593b657f67de5e53f5c17d1a36d46311031f0af9aff9e3dfcc), uint256(0x2638c02bfc85ce76f8a7b179ee3266d152d9be3ff987091fcdc4baf342a06ac5));
        vk.gamma_abc[128] = Pairing.G1Point(uint256(0x2e330d70150677e9ccf185bf9de769ba29575a6cb50fb32be290afbdb72e203e), uint256(0x2a698e4dbeae8896d7dbb4447b7b48dcbcfacdc829347b21ba704059617874fb));
        vk.gamma_abc[129] = Pairing.G1Point(uint256(0x0a40b08edcdf73b810d923e3af776e24b76ba3c84a66cd5523431f5114b2b2c2), uint256(0x00eace59ba63bcd626d1d9217aa522638d5448afdfd87bb5eb920dae8230d816));
        vk.gamma_abc[130] = Pairing.G1Point(uint256(0x03b0fcbe3d79d392c2b9318707deef7ba0f3a9191fdfec2561bf96c4afdf129e), uint256(0x141552884d81a71230d0575db202183ae67d1c3ed14ca81c6d688f96e2149854));
        vk.gamma_abc[131] = Pairing.G1Point(uint256(0x008b17e6f3cfec225dfcab4a3b7f4e30be634989dee404d60262007ceeea0709), uint256(0x228370a86fb432534c816e2d4486bd659a4e5317d01ff50731f4c519795c555a));
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
            Proof memory proof, uint[131] memory input
        ) public view returns (bool r) {
        uint[] memory inputValues = new uint[](131);
        
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
