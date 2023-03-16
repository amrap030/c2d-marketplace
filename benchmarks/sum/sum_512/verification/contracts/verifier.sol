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
        vk.alpha = Pairing.G1Point(uint256(0x142ed94cf2042f634505a06b1f9f9003f3e1deb6433cfddb892f6883a5236835), uint256(0x300ceb5b78d914d0b844cb80f926db635c20eadc904910ce604201e9fe50e9df));
        vk.beta = Pairing.G2Point([uint256(0x19c62168e865df5e2d7dec592f9efd110a73275e9d855258769f6dad40950761), uint256(0x03a2e5d5e8358d25926e37bb4323f162945009ef2aa583e8fd144d538eca6c5a)], [uint256(0x026cc28c8612bbe07c24f0b1a0dfdf47533511558ac70a009dc8d286a2d95ea9), uint256(0x1e50c6650c5d43324c1cc4c80be57056e10444a6d6ba0600edf559b408cce3ec)]);
        vk.gamma = Pairing.G2Point([uint256(0x00f685b01d38e516c3d0de8673e64517e9673322b3762beccc93f839570e0d80), uint256(0x15491bd28bcfa5a20e5504466c652b3ad3471be34f36ba8a4d26c900ce775d4a)], [uint256(0x0db37bef34f8c72e684e674d7feaaad740046a62f2d5c50370e266fa13008e2a), uint256(0x2a059e8d68732f796721d38668d820061b9d5c6a2563bd855aeaf3eac59191ae)]);
        vk.delta = Pairing.G2Point([uint256(0x221c641368f9fdb3bf0ba3cca73781dddfd09e841db310169e4965a24933c9ae), uint256(0x078b45b4fcb9fe1e0506e2e30952592c31fe354192b68d7e7071f6d30fb01759)], [uint256(0x2fef21b5e7a0ae38066f846ccbcee6d4e53b9dd6669e6710a460b2e2f531bd22), uint256(0x1edc6bf4d2a9176e60d6dc9336a2beb24af78e12e51c96e92ba244b4763b43c2)]);
        vk.gamma_abc = new Pairing.G1Point[](260);
        vk.gamma_abc[0] = Pairing.G1Point(uint256(0x1b2e77acc7599bf269f42f77b565018a5fc82d794099f09ce5a3e83b58551870), uint256(0x2aaee2325e41fc6ca45b00dfcb07bc28c88f9affa9a1e52ecfc7cc8618e3bd45));
        vk.gamma_abc[1] = Pairing.G1Point(uint256(0x2d8b2c637a21387b7651c3d8cb4aebcd0f14e69acdf64a0cc0bc4832ebc46f30), uint256(0x1bae113cf15887dd35fa6b4d7dd88f5918b48d81aed9c3aeddcf08269f55d5eb));
        vk.gamma_abc[2] = Pairing.G1Point(uint256(0x28fe605255bd797ecc3975ccb23137c8f45bf16bd0a6e21d5f8102d37e312d81), uint256(0x16f1d46aa7b6c8a03d897eb91371d0df5d519bac032a7361e74c085c80c1b7fc));
        vk.gamma_abc[3] = Pairing.G1Point(uint256(0x05bcb1fb3007d7435a406c721a151849ba71a75cea559801c28be76119cf5e3e), uint256(0x214fc2716a4d76bcc1dcef5d3988b6c28f086f7ba9c90cc6b5dec5112d4e6e7e));
        vk.gamma_abc[4] = Pairing.G1Point(uint256(0x07735452532d7b7644f570e32ff5745b688f70890bbd2ab197661afa77783b37), uint256(0x138ac5a401ecee8251f45912ecae74f8c1067d4789c3755cb31eff317cdc9425));
        vk.gamma_abc[5] = Pairing.G1Point(uint256(0x1c4f678e03fe5d26642bfe42bcd3cd325a8a459cdf72febe1d53bdbfdd51669a), uint256(0x2a534429947e2ea020d4834cf76abe38238315f6475c541236d4c7e370331c79));
        vk.gamma_abc[6] = Pairing.G1Point(uint256(0x129ecd5fc04a0762eeedd8cb301ae68db059890127ccd976b2dd1f454cfe3534), uint256(0x275d08110d0d7c7d181af8b1e3926d83bf36421a7ebf9158427377c08c8fc56f));
        vk.gamma_abc[7] = Pairing.G1Point(uint256(0x08901b923505635cc2f6a12f066c9c495035c4dc53a757e88307c20b3f2c8af0), uint256(0x1844a1f42b68d9c1ca62aee7b55a46b4b4f0eacb8860fa14f46ec0e67c4cddb3));
        vk.gamma_abc[8] = Pairing.G1Point(uint256(0x1f6604cfbea31e38380b0f6d0614c835d19da7dc29392255721dfa6d7deffbb1), uint256(0x1d19e014a7cea0a7ac0ddd2974ad4d679ad317345ddd42de2e7b010da7116e25));
        vk.gamma_abc[9] = Pairing.G1Point(uint256(0x088bb5539130669b2e9f28a9b328d78e9cab6b3bcd7883f78bf5df64e94a5339), uint256(0x25661d3b10899dc13b018280a7537764ede15218ed8de85de496b77f6a1e390a));
        vk.gamma_abc[10] = Pairing.G1Point(uint256(0x23996f6f02a3602ddbe088cd9624bf9499edf4b0afd544a46c5b64601076a928), uint256(0x1341e0622894eae146fc87da7d4e2b556919b89568505aca2481b0c78c3cfb58));
        vk.gamma_abc[11] = Pairing.G1Point(uint256(0x277a7ad797cbe9e4b68a291ffc47485b3037b96bcca250a687e3a154a480e794), uint256(0x1c21bc3fbc1e8e194c2b495b483c0c942c947d2ebeda3e8785fede391fa94840));
        vk.gamma_abc[12] = Pairing.G1Point(uint256(0x04b2454ea7f5daa84f8a1ef71a8773afb6d2ee0e7bc11c11484de1c9cfce2ad9), uint256(0x24e0ff1552eb36c20c335367539c907a0e479812580f50bf84c2e7ffb488a05b));
        vk.gamma_abc[13] = Pairing.G1Point(uint256(0x0930a0b6edbd1106c9c7d7e9e6de0c1d256ab486568cd99598671ea35ad4ca02), uint256(0x2963e231bfebd6f38464c44491199dda89462a2afb9076130efdc5a8cf08596b));
        vk.gamma_abc[14] = Pairing.G1Point(uint256(0x22917282002a3b06a89f52a7c029d22bc57efdd44b323a168ca3b403555835a0), uint256(0x226a34981b1ce5447769d5911237550db173251329382d36a956ae826ed12f07));
        vk.gamma_abc[15] = Pairing.G1Point(uint256(0x1a4e24f23ead265d9f748bf92bdb01ea6af745e4157452c8d8ef550413a47073), uint256(0x1b306e9ea3cac057793aa4bdf9e344a05867f2398b8f32fd82472c7fa9e16544));
        vk.gamma_abc[16] = Pairing.G1Point(uint256(0x07cc6edf27ea2b209ff592af0664f6fcd9d562f0bc8dcbcfb3c5f8eea2b3628d), uint256(0x2b9b768673148700fd29842791b8d7776e6b40363f44d734de6f02b497703224));
        vk.gamma_abc[17] = Pairing.G1Point(uint256(0x08e4f96fa76d0efe5d5d0785816434fa52401132095a396fbe5a254dc6c5d4a5), uint256(0x0437b8364f6a95842299b06d29d06560db80fad8a1b2e9369a1281ccf646fd9e));
        vk.gamma_abc[18] = Pairing.G1Point(uint256(0x09264f6a7a933e6cafacd57cd09b7673c0d8bc5a8aaa82e84950758e8c16026b), uint256(0x0795eae352f6ed31f1700a5a8fae13748ae3a17373c5a466c43e2cac1b535c1c));
        vk.gamma_abc[19] = Pairing.G1Point(uint256(0x051d503eb50e3c7122cb928ed535d224a8b680e96b7f9edd29acd89da950410e), uint256(0x2c65991785bd497c68612bcdbda226d1f6a2345332e82ff513c71693ad0285e0));
        vk.gamma_abc[20] = Pairing.G1Point(uint256(0x1731770ebbc89b3d6f841167fdefa2495852c5c84e8b7205ab062dc7aced65af), uint256(0x24812b966e5e691eb864073379a701427f2e765de593ddbb8bafe272bdce9213));
        vk.gamma_abc[21] = Pairing.G1Point(uint256(0x05a2771e91853b870a99694f1adcca974cfd5035429f1502f1c1cec13e172c68), uint256(0x11bb7c22bb98112935cfe59bff448cbfe839d5218b0d7cc5184e41168db162f0));
        vk.gamma_abc[22] = Pairing.G1Point(uint256(0x064596dd97c6417e33a1dcfa3f1e3e99917be6c12b3dbf75091eca29d9f73fdd), uint256(0x0deb933b39b4fa3511de9d61810d50eae036d737c0a4dcea9f6ea54724c53514));
        vk.gamma_abc[23] = Pairing.G1Point(uint256(0x2a4d84b48c4b5cd622a4abd549287f86f3e088ba3cece13d870b27d3824cef7e), uint256(0x2299345529c149bf72e513ec6289ebd7c6830d5aac6a5527501b258f4f254b3e));
        vk.gamma_abc[24] = Pairing.G1Point(uint256(0x00e9151187866f0f94a1cd4df5ab08f26ed2ba357324c20db6330ee4c57938c6), uint256(0x02dd862915adf06ed000d1a67cef5986b43370f64b1d4ec67285b3cdcf11cba7));
        vk.gamma_abc[25] = Pairing.G1Point(uint256(0x04d5c2ede0b5237f08f64c4cff5098688d25ebefb348395f89739a8841b75ee9), uint256(0x2a875e37dd22cfb8f556cc458113c097c2961e42ef9b82db41a72270ccba3bed));
        vk.gamma_abc[26] = Pairing.G1Point(uint256(0x12e2df35bf58a2484e72c9f4b88aaa64dee1a2610e43bad7b83bbf0ce5ba26f6), uint256(0x0fcc9d0da3f6b9b88d5e2f8621b67a4233f4164e318440ceb2eb97582ec69a84));
        vk.gamma_abc[27] = Pairing.G1Point(uint256(0x04e2ea218b7d4d646992f3e8f9516c6c7ba49efd3dff006424f2783ec3522d39), uint256(0x12aace1b7c229825202dcfa53cc5b83ea99acab61bad9f55a9a29652fd3ea3b1));
        vk.gamma_abc[28] = Pairing.G1Point(uint256(0x1a35b0ca4b9867287a9f8c05cc028951296f2133b2d9ccf40178c18430b891ed), uint256(0x18def84bab9661b3586c791d841b8299c8f381cec02ca0887c5f37c75b838ef0));
        vk.gamma_abc[29] = Pairing.G1Point(uint256(0x08b69614eb18bc2c4c7c0891b1125fed3fb67737cae2bbe2fce83f774019428c), uint256(0x022625a9ae7d60e4cb29e20542a36fd96ec426e48dd34ea626c0aecee6b75dc1));
        vk.gamma_abc[30] = Pairing.G1Point(uint256(0x2b1ce2806402d4f6777de117be18cf572a0f3660311fea2530b7d2241eec9c35), uint256(0x20fb5eb9159b25c6925ffc295a7a822521aacc42b3b11ff3d7b9b93286a63033));
        vk.gamma_abc[31] = Pairing.G1Point(uint256(0x16b58a90937e0641cc62fc20fc5188eddec8a24a5a008972d4c744c00103e449), uint256(0x17e92299dbe38e3bd76faadd09c2704c75dae2ba7f5030b323e05c8232efe84e));
        vk.gamma_abc[32] = Pairing.G1Point(uint256(0x0c4fc9a2c8d7719d62d9e9b2cb34d0c294e610349cb6fca4efebda46646198c5), uint256(0x1dfd320257c9ae4510139913fef614b804308273a569a0f1c4498bb888242d6c));
        vk.gamma_abc[33] = Pairing.G1Point(uint256(0x08f7c076d823aa0bb908f3f10ef4f733d84bdad04d810d441644d19f1675350d), uint256(0x02617eaf6f79ad8726e8c898477d1ae2c58a082b977460627f9a056636e274bf));
        vk.gamma_abc[34] = Pairing.G1Point(uint256(0x2e9e3097de042e639841ec23519bf836761882cd33c15cf11c5de12bd1106e2d), uint256(0x2f372f513b8692a33612480a3d7fca23d55f1e03910acf8bf40e8e563f82a434));
        vk.gamma_abc[35] = Pairing.G1Point(uint256(0x1d5794921d6e06755341fa4c45303b7696a00932d580e22f5c80b70aa793a872), uint256(0x282439b837d19996b600f5376572f1b47687dbd6c9af47579758f44bd73733f2));
        vk.gamma_abc[36] = Pairing.G1Point(uint256(0x1eef029969784e9836d21f36c1e9b8dc046a509d9647035515830fb5de34d3a2), uint256(0x1fe0068e1609a366a6e986e2e0591e819241ff26ef16e16841966db610f34b38));
        vk.gamma_abc[37] = Pairing.G1Point(uint256(0x1d11c71d72cf01a7986b5c8ae4bc4809ac5ab218902ac7d22f6007709f0b1dde), uint256(0x07c46225a239818849ffeca0b8f05f39304c91acb4651b72cd3a10cfa7138b54));
        vk.gamma_abc[38] = Pairing.G1Point(uint256(0x1a144feaa500ff587939c23b892f80aacae2a843412365128a731c10a5a3fcbf), uint256(0x05a55a5de218df8d554991eca2bf98d1f36faab93d7e25f78a19f132fe75111e));
        vk.gamma_abc[39] = Pairing.G1Point(uint256(0x0d86a465087c73e1d0126b423620a9468ca165ee34372edff90810c7ce8c5daf), uint256(0x054e42d69df1ebee5e00f7b14c34c28d73502dbe47b09e0635fde4b20344789c));
        vk.gamma_abc[40] = Pairing.G1Point(uint256(0x2882f8debf9dc3582377a80dc834ccd65e213bd5af7584808defd1e02151d351), uint256(0x162b5c6e1a6346c411754fb026d5f77a0d14d1368e2467e33d3371e4aeee957a));
        vk.gamma_abc[41] = Pairing.G1Point(uint256(0x2cc21f4f494b093048a6343c4a400070dac6f4206cfa5d6f13d5ebe4727140cf), uint256(0x180db958a3c7e6d7741659fda993f7699ba7ccfb12f72b30aaf8cb7f1ac5464a));
        vk.gamma_abc[42] = Pairing.G1Point(uint256(0x0960bb68082abc53e43514c7bc138c2ecf14f9913e7fab2dfd6ba9345f1841d9), uint256(0x2a71c4ac5d69e15dcc0b46cb46ca8a42e5c0d15b61e530040244fcebe0143382));
        vk.gamma_abc[43] = Pairing.G1Point(uint256(0x075f45d4998fb89e2ce847c11412e1c276821388271dc2c878b16d5331237c0f), uint256(0x176fc80a305a80770ac221c51710732b91d7dc7b037b60aa517543ee93299c4e));
        vk.gamma_abc[44] = Pairing.G1Point(uint256(0x277beade0b78854f5f2e9e02709fc7d6b30a9a8b45b66e06bda984d10625204a), uint256(0x1e59d2aee1078f2db1cb91de8e14a7918193d2b804d3cca52d523fd754430beb));
        vk.gamma_abc[45] = Pairing.G1Point(uint256(0x10d8839a422d748b59ce2028ada16359b54f40cd28b8a52e776935f1ed1b0250), uint256(0x20da75c6a43b8a22e5d7cb976d1af227f55a4caaedbbc04970d40caa3644b1cd));
        vk.gamma_abc[46] = Pairing.G1Point(uint256(0x0cb2ba9c1b0232885acafdd723f236e22616fdb54f2bc93c200364e79305869c), uint256(0x192c7cf30a1be260494ff9f4442f53e9ba40a728d075584bec62bb2c3be1cf6d));
        vk.gamma_abc[47] = Pairing.G1Point(uint256(0x234644382b30096713da92ca45126f82570195e51af9f1be8fbaaeca7ae395cb), uint256(0x0ce974e42537a1621073bcc75e5c3b5bb4422f925c6963ff722916d0f1d951f9));
        vk.gamma_abc[48] = Pairing.G1Point(uint256(0x24e592cf620ecc8fa24e87efa76878d7e8c18f83c3d3c8a120cc086c102fc4b3), uint256(0x2b16d01a310a41a6e085d99cfb6d1a5ab05d115734e8897903a7dbbaf236db56));
        vk.gamma_abc[49] = Pairing.G1Point(uint256(0x294ea04459db6dd55ee0b8bee4cb9234ce98f2d709d936b69f22fecd8f89b507), uint256(0x1ce59c81bae34be0818aa667767040e2990a99a8fd7a66e6198b4ec8688eeac3));
        vk.gamma_abc[50] = Pairing.G1Point(uint256(0x15a7d0bda56091cf2b15be424a148ed7bd89fec7c7bda01d6b41c3315c276fb2), uint256(0x17a83d53721d1bd0364e0dcd0d72a386e819850d9d8a3ce51457f0efef6ec312));
        vk.gamma_abc[51] = Pairing.G1Point(uint256(0x1c607a7dc0be5decdb36f860fa9acd179437427d6c62bbeefcf4b7e205dd88a6), uint256(0x1e6c173ae046ca73ee54d80f0b5521898cda446c166bab8673f522773e2d7688));
        vk.gamma_abc[52] = Pairing.G1Point(uint256(0x224c6027c0db09dcb499bcb16852651912da37bc66a9dd132bc2d7d484c088d7), uint256(0x05807a2c65d93ed0c1a2287f06f7deea903e34b1438c23970c244c4fe2ec5fa2));
        vk.gamma_abc[53] = Pairing.G1Point(uint256(0x14e356d8bc3015be58cbc0d9911c31c0548c3a9efdf3f0d6772f964de0f80d6a), uint256(0x0a73fb333abcf3914fa7969cc20b0b3cf3b7edb7d2a783aada431e94a525fc0d));
        vk.gamma_abc[54] = Pairing.G1Point(uint256(0x14cf668ec72145e74813116ea4556981c2d0a3ec0fddda94deae81658447b832), uint256(0x2a9a0f38aff7e11e8403b2a92972ddb62ac885f53a59020a2199b9efe5c450f4));
        vk.gamma_abc[55] = Pairing.G1Point(uint256(0x08678a910572a351a1284d64274003eab6b6cf5448aa0ff15249fe0dc6e7e510), uint256(0x09edd498dec2e2db833e5651c12a79a29ade8300db242c3adf77e65399ffb856));
        vk.gamma_abc[56] = Pairing.G1Point(uint256(0x2b6ab074194467190919d4153259b4754acb89e1ce4b5e28ad91feaae671d9fb), uint256(0x0cecefc3b6c08fdd41d864ccaf459a84e2e0dc7592ebbdc34b82c8b322f2a85d));
        vk.gamma_abc[57] = Pairing.G1Point(uint256(0x0dea988e23c504954c1a009626df9dcfce3e144bae9f9d60c8c46984022d31bd), uint256(0x2abdc67e40cf21e0f9347b1f6e542b6c747b9eaaf739d2cf2f18eb3ba7fadb6d));
        vk.gamma_abc[58] = Pairing.G1Point(uint256(0x13df191fb4b6e1a4c69c32afb09cf6efdffd73ef0711b6ad30449aab093f377d), uint256(0x031cde7eedf3fa0745cef81e89363aa269ace1dc969abdf9d43ccc5c322f426d));
        vk.gamma_abc[59] = Pairing.G1Point(uint256(0x264816ac6bdde0480dd4259b9ad92cb5bba11734c2c9ffb38ae8fcf711397ec4), uint256(0x010f5188a25ed03b69013d6c8a94a70c2b6d087a5e010d1c7c5197a7a085c61e));
        vk.gamma_abc[60] = Pairing.G1Point(uint256(0x0efecb882a10a42ba3424be26ea4ef46b32027556b3fd2660921360683c5f420), uint256(0x246fdec1f2be86ff31d3fdf9a6409bedb91c540b2d914d7bd9c43214ae4c4fa8));
        vk.gamma_abc[61] = Pairing.G1Point(uint256(0x048134d4f94f1605a4e2947d93870e1aa84f104fecac7d650ea9c3ab04b10c8c), uint256(0x25a41915175632a0ea6c33608d57da6850bbb5b564bd61ff6583278371f55d10));
        vk.gamma_abc[62] = Pairing.G1Point(uint256(0x2bd8af0b3b338faae403e2eda235009da7b05e96f94002f7fa16ef71c6e31bbc), uint256(0x001af651b560bb8bf8c1ad0bb7517ceb08c3a19f18804158f53149e7cff4cf6d));
        vk.gamma_abc[63] = Pairing.G1Point(uint256(0x2ec1d8b1ae504f3a74949fcac92085a793c213628c1b2e7de5d92432daa1ee41), uint256(0x281533351b8aad9e7eddb03790a92a9d74d4dd639935f45fb20894b820d417a7));
        vk.gamma_abc[64] = Pairing.G1Point(uint256(0x30373e00ff948dcedaef768f40016b543a29f94002a9889e69eb7a1ddb2a56ba), uint256(0x13b8f6bcad1141f3511cda66f4b25d5c69466c0abfe435ba7e3a763ad448c730));
        vk.gamma_abc[65] = Pairing.G1Point(uint256(0x298ca9ff7c3e98ea920b622217545e98739dfc45b5ba3fb0d1dd83a1dbcba7b2), uint256(0x264e55998c098ba306f962bc6e0031a1250cab587cd9e989d50a583a63bc644d));
        vk.gamma_abc[66] = Pairing.G1Point(uint256(0x140da5b519878fa291ca19f0b55922867ab4c5cfb7eb22fccd590037d3520d0f), uint256(0x0071778c3d7379f198f0991cfe571d6ef76ab225836a645022ae28cb33056921));
        vk.gamma_abc[67] = Pairing.G1Point(uint256(0x024df3390d7c9d1ce6fe3aef1101c74267f08935568db4f2287b2b62a2b0677f), uint256(0x2a97132cd49500e4ab66611e552d01dbd518e647af4623b0cacfd1c20b3d4634));
        vk.gamma_abc[68] = Pairing.G1Point(uint256(0x03b04bbb0271bf8680fac0000a162c6b26ee2d72147d6a8b37bd66e2ab7d40c9), uint256(0x1073a76add24dd1e332eba89085b6cf80d10c776279d1f25dd62971600d80422));
        vk.gamma_abc[69] = Pairing.G1Point(uint256(0x0d4c237109a1a0456cb189fc9c4786ee9f3b0f77de96ef8ed9534aaa0121a4e6), uint256(0x106b60a658a4df586755fc0d6d18333bff44da076c9cc77e7568055834e8c95e));
        vk.gamma_abc[70] = Pairing.G1Point(uint256(0x108fc5438341eff54f43a4b7c2842102cdb65bfbe39defa3119d2b8e3f46baca), uint256(0x182b04d2ce0f589708002b46bc246bb8251cd4a6116337f320799aa10c86d2bc));
        vk.gamma_abc[71] = Pairing.G1Point(uint256(0x04389179e968a8042ec742505612eac1e18627f6b8b288fa22a817249c9a1014), uint256(0x0b67bb84d2298cb705449ac2b2f9f48193b6166aebf484b5bfa183027cc8ae59));
        vk.gamma_abc[72] = Pairing.G1Point(uint256(0x0401cfe0058516667f3697fea4716bff890ad4b3a3c2d5719ad82c79971e3eaf), uint256(0x057ecbe19a83601981613b4d63ec882123cc63f51698813f127f430c13c7a2e0));
        vk.gamma_abc[73] = Pairing.G1Point(uint256(0x2ffa01ee0408bc48f0ebb01a74ab164ebbfa0f3dc3d96a13e4ceb0a9f17b7eca), uint256(0x05624a62d2b9a5bac72561549468e7ed00216b34b8ca7d90dab80df3caffb3d9));
        vk.gamma_abc[74] = Pairing.G1Point(uint256(0x0ccf5a5f866d2e3bee386c42fc9dc7202fef7490748b4275ac628e8087e8a7ca), uint256(0x1d0b5e1ea48ea9205fe492921b6a139ef65ad4cd0b4632e2abebbda91c498591));
        vk.gamma_abc[75] = Pairing.G1Point(uint256(0x1abfc8335d5f2c9433a0f3e6522e05e1cca1334b276e7af62e4daff1f6051b8a), uint256(0x0f94515766ddc0a53a5149ee4da9d7620eb4d3d07e0879321cba50bfdd2cffc2));
        vk.gamma_abc[76] = Pairing.G1Point(uint256(0x12f8c4c81063f526e6d38afaea05411feae2a03cef0d28401d20bce26cee705f), uint256(0x22b5d8d18797f85a2969f5869f4ae7334fe9fa51ff34c8271cd28e913cbabbd1));
        vk.gamma_abc[77] = Pairing.G1Point(uint256(0x1badd2c394e823a7ca429d4edeb982d185ba55b6187181fdae94733fae4c4c6e), uint256(0x0222b849943e1dcc2b018029ae4677bb87494a8582294b2e9c5bdc5fc36e9475));
        vk.gamma_abc[78] = Pairing.G1Point(uint256(0x146eeb371a8f7aaf36aa8bb5b1a34a161ca2956166e9c343b02a6861f14914dc), uint256(0x0bdf3aae90b24c70a83bea4404b890826a15c62ffafecc0c08473287d5402e43));
        vk.gamma_abc[79] = Pairing.G1Point(uint256(0x147c5726f22916db72c643a30e40518069f22b49321bd0571ed6853a2efd2369), uint256(0x1b3818db44e463f6573944449b01a4a4f287d5d419ad7d2345429a7134c7a332));
        vk.gamma_abc[80] = Pairing.G1Point(uint256(0x293f32f05823a12c356fdbeaaeef0dc1e27be5db3727d15b8bf80dcbb7f8c551), uint256(0x28a760d6851aa5ea367b4df0b217153d43cb66f55e319786adf3a44641b877cf));
        vk.gamma_abc[81] = Pairing.G1Point(uint256(0x03d91a2d80621d0bf9aad4d62e99e417dbeaed9aaacf9de9b6fab5da302128f3), uint256(0x272543a2d7fd1654017114eb7aea3ba83f490e404c5209803e5ca6d9d8753146));
        vk.gamma_abc[82] = Pairing.G1Point(uint256(0x09aaf3e0a2c2366a014052f4f882bad4f8192112d7e800007ff03e997c97df8e), uint256(0x01279092cbc60dede482fff8d7ce4577d83057f91ff566687ee7705481838e2c));
        vk.gamma_abc[83] = Pairing.G1Point(uint256(0x19b17c28ac13b5722cf8907e95dc9a9d8fe17a6e273631a529a2b8b037152f3c), uint256(0x1f54344fb3ded277bd5f6c94f656b552de1d8c47682ea24d03b45eab7e025654));
        vk.gamma_abc[84] = Pairing.G1Point(uint256(0x26103941790a7f7ef28e755f7f9c19ad5feba4f4287ceee3c7247176fa362824), uint256(0x021c54e3dcafee6a8f25cde615406aeb4a1d840d9e726d424d04add2c9435dce));
        vk.gamma_abc[85] = Pairing.G1Point(uint256(0x0cd54808424c2d1e3666add1a434b7797f5e70edda01a57dc91a9e4a15f2febb), uint256(0x2c3811ac4bcafe75f160b96d4be0b044ad312e747579c4634c26e67fc9f92e03));
        vk.gamma_abc[86] = Pairing.G1Point(uint256(0x152cc25038adfd96887a22ce26bbdbdcadbfff43110c4cd8d0155547f8b61d65), uint256(0x02a75de1291db917c9f4c242204415b1de6cdc84fef7bca39e877a2d7555b47d));
        vk.gamma_abc[87] = Pairing.G1Point(uint256(0x0450b4651c79948e2edc053fb73575078c2ae3e5a527bbc3869ac0e417196cb0), uint256(0x2b56de2b624a3e529d49a26f820c73469184d65696c3b50101dbe130527fd687));
        vk.gamma_abc[88] = Pairing.G1Point(uint256(0x0167d749def20a251e66d8a433454d32ceaeff93bcbe2e743a7dcbd7fec554c4), uint256(0x284d27b946ad2715e46e57001c848133b7eb2070cc44048383f44d89f349df61));
        vk.gamma_abc[89] = Pairing.G1Point(uint256(0x09ff14a5c4a10fb563c6eb23d1f8aac12ad93d615888178dd5d7ae997d9116bd), uint256(0x1e53edd9dc0c3ab912aaaa274bfa9bd5ba8f5a99a6008fe683982783caea67ea));
        vk.gamma_abc[90] = Pairing.G1Point(uint256(0x2f65e5109abf1b8bf7f3d8715e67d4fdfbf34035d3151eff5d3161f3863110af), uint256(0x00d5c1d5b5b5f6e16a5c3e4ca065b4c62ce9d537d6ec9b2b4ef5be3cd064323f));
        vk.gamma_abc[91] = Pairing.G1Point(uint256(0x09cd570f3c46f11f329bbcc34084e831f0c70458aef660b04e23c8cd0d0d0310), uint256(0x07eabcd25b5ce86001046c575b32595d07c4078748c329bc0a79b22e405b7dd5));
        vk.gamma_abc[92] = Pairing.G1Point(uint256(0x00b3ea0ad9977ea562c8f97d3bf4605436dce3a8410182876ec9216269cf266f), uint256(0x131ea8e64a6f3c6198b762f0b8024bbee2e60686e752bb610da1530cfef9545b));
        vk.gamma_abc[93] = Pairing.G1Point(uint256(0x152f3a7a976c961dad6648ce610340fab3bf1c0079e53577f1f4bbc9d944e7fa), uint256(0x090f77157d1b26be5066d99bbf4f711d8d9af3e4d4cb66cf4bfe67505e6e0bc7));
        vk.gamma_abc[94] = Pairing.G1Point(uint256(0x149328c8d84bcfb59bc96efa066bc79b033d856b4e0d1752e1009d9636ed2ea5), uint256(0x066f1cfb5836890e261e6f00fa7ba2679c5a6a6fdb71415de1d5865f173e4044));
        vk.gamma_abc[95] = Pairing.G1Point(uint256(0x02d0593bc946e9fc0f3bab17cb00f9e9b629dc55360551c4b99c531b8b23ff1d), uint256(0x2fa8a86abd99bf7c8a1175c48e476f55626b8591753f4041f74f5057e7e91bd9));
        vk.gamma_abc[96] = Pairing.G1Point(uint256(0x07bad998fe1c093be0a92c28141b7e68f394c98573286e0f6c3cb87808a5c2e2), uint256(0x1d4b918d708d126b0303a7bee120a9b9e91350a22d20aa9ab28355a79e611fd4));
        vk.gamma_abc[97] = Pairing.G1Point(uint256(0x1fcfdb5d13240a5302c0b787a072c6d35fff10792d202e7a33b7724b23d620f7), uint256(0x19a4143bdb967443c7a7fb4457c6a0e94cee7c55b83bbdac921df2e5f3637f99));
        vk.gamma_abc[98] = Pairing.G1Point(uint256(0x0d847cd864e496cbb41f969d8454dfc2be3811e13db5454f58411a184928ce6e), uint256(0x0321465ddf0108e4f85b71402e6fbf3a66c34fd3e61b02c29a139068c272dc71));
        vk.gamma_abc[99] = Pairing.G1Point(uint256(0x2a7825c305b4e690e2d92745cfbb43ee21e2be07e178c934a6caa56656984ce9), uint256(0x1920711919e11fc5564276ee5d4cc99d2c1fdb41beba9c0e1d32880f8731fe3d));
        vk.gamma_abc[100] = Pairing.G1Point(uint256(0x2c384e530f854d3236a7498cea12aee84465241bfb7afd4dc2dcc03fe7835c29), uint256(0x10914d0304d76ac550d862398e91595e80be81144b3da28b2b024451cc0a965e));
        vk.gamma_abc[101] = Pairing.G1Point(uint256(0x1d148b821ac7d8868c10fc090f50dedc1f07c8f99ca0176354bacb52a0d062fa), uint256(0x13e49987ec9e73f469e1d4e5b6387e8906699f6d40a9f3662d71737a2e54bc8c));
        vk.gamma_abc[102] = Pairing.G1Point(uint256(0x17b087494a2a782c0f93ec81df6e8d52962725f3d098e45d24809200b04077b5), uint256(0x15f78343db6b7f330f500f31ea9cc5572af622140119b0e5710b4a770f337a2a));
        vk.gamma_abc[103] = Pairing.G1Point(uint256(0x0279b2251b759cb4d3daeab814b0606565de1981442bf15d095981856168b395), uint256(0x01351876d11bb260e6c0c65b0877bc89c81a7cb76e59e8072ce79e2a5e47206e));
        vk.gamma_abc[104] = Pairing.G1Point(uint256(0x13854e2fc84496c156beecbf8f5be13f264b5f23c8e3cfc9f59999a4d2380399), uint256(0x29106c36a9c2d3c9308155d9c7f15c2670b67a38e2480aa54223bc62d4a32ffc));
        vk.gamma_abc[105] = Pairing.G1Point(uint256(0x01070431330d87abdf649c7574535ff35750804ade5dc6ac34744446757bcb16), uint256(0x21f5882499c75fd73f7b80a47cdc51124a76e25b74c9105d3259b845138e499a));
        vk.gamma_abc[106] = Pairing.G1Point(uint256(0x29293fedd977ee1f6aab2af7161c483ae13b935e17b72f9a42dbfc9b1449e1ec), uint256(0x1ca823e99e868c3102aa858c450b3413ff2f129d7e37314c6f4fa636541ae6ee));
        vk.gamma_abc[107] = Pairing.G1Point(uint256(0x0043f6b536ba49600ad112b7c84e1873bbf22afda1e0685937d5079e48571917), uint256(0x1a7313a8bb1d78d9fd8038eea1b54b757cc1034afd33dc4b7321659e772ffaeb));
        vk.gamma_abc[108] = Pairing.G1Point(uint256(0x25bb7346e8d878d7a431d68f8695f306b4ba6cd2699997574f466160abb14a33), uint256(0x0b84dc34b6ab22d84cae40179670e88bece62835e82bf33c9d65db0b02f6d7ba));
        vk.gamma_abc[109] = Pairing.G1Point(uint256(0x179ca51baf52e9bb1e12f6d82adb95d2ec87aac48efcdb7927a85976cc8fb0db), uint256(0x1c023491a12dabba7af9ebac93d5e14aaf374619d90671c51e5dfda945079465));
        vk.gamma_abc[110] = Pairing.G1Point(uint256(0x1ec51a849ef523b7edfc01614380d7216a5d9529d0f5a4d4ca1b523c7160a845), uint256(0x279eef4d2f77109ed2b4fe547de2754a3d09d318ccdf561bb617848575b77dbf));
        vk.gamma_abc[111] = Pairing.G1Point(uint256(0x1f7b8399565f62d4abe5b588aeaea9dfd396a2ce47c4d7e3e5785920db4034c2), uint256(0x13b22070f296b7c525e932293af48bd8b42a192ff3b06a82497ab5ee6a060312));
        vk.gamma_abc[112] = Pairing.G1Point(uint256(0x2257e307fe095e5ebd7ff5e349a2c8353b6faa6c30e111f7a15212db1f8c010d), uint256(0x2d16b20eb8d46ec0c3d3cb2c44633e01a08513b4e2d8d2dfccb1e5ea39dc8925));
        vk.gamma_abc[113] = Pairing.G1Point(uint256(0x2bc4d1f8f355096e20d06a72228299626376958e53e008fbe33256cd243547a3), uint256(0x179984648eb187ebc2dbdfddbe37543f288be49861590a05cf199d2dc5789ba9));
        vk.gamma_abc[114] = Pairing.G1Point(uint256(0x236e5af76189a5b60f676b3c4cfee9fddc159c75d2dffb2ff1994a7d310ebce8), uint256(0x304e3e71e276a05a1575196702c3647e1c939e41211502bf29087b6639b0e7de));
        vk.gamma_abc[115] = Pairing.G1Point(uint256(0x292d3124d84754aba3f024ff9454127a4a62f051eac2d5e1f4817ba25e71ec58), uint256(0x28afe4a1059abbe7e45dbb0b125f5aa686b445ecdaadf6e7b218a5f4316e4782));
        vk.gamma_abc[116] = Pairing.G1Point(uint256(0x284704aca33c44c6171ce0b38882830fbd0251ac07bf1e7419bc78490f7e7bed), uint256(0x29351d3ec73ac581696beb57449a18b502422c42065f084b13af67230f3e33b2));
        vk.gamma_abc[117] = Pairing.G1Point(uint256(0x1ee5e763259574adaf08e04504f7fdb8154538a401d930e62480576f47986d53), uint256(0x0dba7f0be000c09597ffcd25641a87346559b349be39c31743b6192a70157b43));
        vk.gamma_abc[118] = Pairing.G1Point(uint256(0x1fee6b628d7419e61f73940b4f0728b3a0d91b4ba2d6418ce7f8ea31d3e6e52d), uint256(0x028e571dc232a44ee3c19f4711358aaaa27b49c3c777dfacb0b91c22467dfc0f));
        vk.gamma_abc[119] = Pairing.G1Point(uint256(0x25ed60e6b85e0297f82ac8571eb0a45e47a17d511e710234286cc7c79ba9263c), uint256(0x0d9afa4aa259e7defd8b381932f50c4564ede81962b60c6dbca22115eb736bc7));
        vk.gamma_abc[120] = Pairing.G1Point(uint256(0x0c3ee062e4926f31e1bbc2aecf004b6e2bf34a5ec114077b22681bf3fcaeb1bb), uint256(0x12f73f6a850274bc5c87b425970ed50d4fe681042243617b17ae2234415077ac));
        vk.gamma_abc[121] = Pairing.G1Point(uint256(0x10680d6d6414732e6f57170a6890677ff706e73ad7ecf55f6fa3aaddb1927bab), uint256(0x2188eb7f921dce96ba288580e9efda89252350e4e53b279c44b0148c172a2efe));
        vk.gamma_abc[122] = Pairing.G1Point(uint256(0x17b806be402292e84ebf14d3055e439928efbd175114865d1f3253928f957541), uint256(0x06162116bec36812964519b98f2b9dfa1126b0fb48deefe6f0d7930017f43610));
        vk.gamma_abc[123] = Pairing.G1Point(uint256(0x2ef1bf8c3b6a73b980159158f61e845ff396b5fe4b6e005f0722cf8d0cfc20b9), uint256(0x28b882b9d4ff5f2d89a54e10a1b7da749e960be18fea1a14bdcce365e22784b9));
        vk.gamma_abc[124] = Pairing.G1Point(uint256(0x0733a087c2f61930c60fcbacb2c185dfd4bde78574c689fd025e1e921c55f54d), uint256(0x2d1c7368ceccd1b5935c6dea319b4738b619d727d71fb47d31bc4cf21b39841f));
        vk.gamma_abc[125] = Pairing.G1Point(uint256(0x01fe36602199ccec2895196a472099972b47b7c912cf21edceceb3a7b5471802), uint256(0x28656e60e3fd6a34384fd0dff0f7075fb0354863a0f1cf3b74c96bfc86c03dae));
        vk.gamma_abc[126] = Pairing.G1Point(uint256(0x0580ad603db8ba88679166f5920787c18dbf00f3780bb6da9e4d60f1d56952cd), uint256(0x13553a8f2ffa28dc88f7484da9a975405859130a65fe69636c846cdc6c49311f));
        vk.gamma_abc[127] = Pairing.G1Point(uint256(0x070a043011007d651564026a7794a908b2cb8c8153423649ff312cb9646c82ce), uint256(0x04c041ce93dfffee1ad1fc6f6fb794904e2ab947dc07f2701d722e2014b08f49));
        vk.gamma_abc[128] = Pairing.G1Point(uint256(0x104c18226a5a5f439d29a7f3ffa113d60f24bb6b6aae8b2e4dbe316bbd104dd5), uint256(0x1e2d0fcb117a80cab54ec3579b4bcd1b626b6cda7a5f927e001636749509154a));
        vk.gamma_abc[129] = Pairing.G1Point(uint256(0x027f5b05ae26e623bf65c26850408e30818296d5a7364ceb77aca5f4dbd16dca), uint256(0x0f52785e6544fdcc0c22694b2d71799e9ff08bdd61647f0823a7c7db41b3f7c8));
        vk.gamma_abc[130] = Pairing.G1Point(uint256(0x1fe0b738b944ab6a799f45e977051b8dbb32724591eb7e78061dd4071431b0e8), uint256(0x21a8f7f5ffb30b318d180a14e37ccaa5b9390d6d8c9c2ed90ed124778422cc7a));
        vk.gamma_abc[131] = Pairing.G1Point(uint256(0x1c183a1a25d4042f245d445245e20a27ad4294438970812a2cdca731f5074586), uint256(0x2335d70d05fb8a9226bf3e2da18340e55cdee84fb6e79cc10c13812710c6cf24));
        vk.gamma_abc[132] = Pairing.G1Point(uint256(0x2fb2a52f8c70a16533b4b910c7cb82128a0e4ad96d3e58e6aa6d2dfdd97c2656), uint256(0x194c9a6cc0e2fd71227c2c0a97dd0f1e2f01db486607f8610decc7c5b6efc914));
        vk.gamma_abc[133] = Pairing.G1Point(uint256(0x05148cbb422cfb1256d6a63e47db6a9e6d85c9367fac8e5f5cdc83de5b0281fd), uint256(0x10ad4b74b221f58a73731b1628df52e11cdf224b24e6948195b1a6ac8183fbb8));
        vk.gamma_abc[134] = Pairing.G1Point(uint256(0x0b39e42477cb474003196fff27deb7c71e24776c1c87b4e9b71ba70de8708480), uint256(0x13c9fc332ddf0b807a2fa0e451ad4210d4702b0d1f20e7d553a843ad9505ac3f));
        vk.gamma_abc[135] = Pairing.G1Point(uint256(0x0300cdd92945284c23ca516eac539faaf3c640a20294362591ea5aa3fbd11113), uint256(0x19e37c36dee213181bbf457b8193ccff3d2bd6d5cf6b0a0c95dd31385eb4ec75));
        vk.gamma_abc[136] = Pairing.G1Point(uint256(0x28ca75c5d307a88ca5d9592276c4994acd8317858181e5921288eef8021ea5eb), uint256(0x0352776dc804d1f70c270a8bf8fb8ca1e29b4d4fb1021f7f64d9c944847df533));
        vk.gamma_abc[137] = Pairing.G1Point(uint256(0x1e414d342d14741b4517a7c9d950c84956511eb3565938b053ba6e0274c489ec), uint256(0x04553cbd89df30506217690bbe59d8450e48c87261e11388a83a6cd836a3ca32));
        vk.gamma_abc[138] = Pairing.G1Point(uint256(0x1aee5053d4b144d24c58cd2b07628fa3462a355df570972ebeb430149e955d38), uint256(0x24cbe159e71bc725da799231e3a7a605249d55b6dda543dc3aa01de8533a9cc4));
        vk.gamma_abc[139] = Pairing.G1Point(uint256(0x291e9667ecfbe21f94a0344e9cdb5355ffb926d5a6912eb1662464ffb66d5e7d), uint256(0x2999f4cf33d99878fb1e39f9bfe8c0f299bf35d28d6f1e5231e1cea2546aa123));
        vk.gamma_abc[140] = Pairing.G1Point(uint256(0x26f428b2a4f233e25d27528c5a3254c042a2746f241d4bdad06c0c9e48d9cb4f), uint256(0x2800a43dbcea11159ba0817dbbbb69dfc64037677192f9c1c930490292551b62));
        vk.gamma_abc[141] = Pairing.G1Point(uint256(0x002d9fccffdf1040aae52f6f600edf27b432f0fb5d668cd32b79b27bd85cfa9c), uint256(0x2097e1895efbdb123d3d20804200f434477a1bfe66fe03b268c1c4aa46174e98));
        vk.gamma_abc[142] = Pairing.G1Point(uint256(0x01bdcd09e23c115c55fe60a454ab29d8d6a57a58bd9902ac9f01dade81ac6efb), uint256(0x11b72fe5919677d3760c2f49f6812ed2550791028de4151d8e457d7ab7a1995c));
        vk.gamma_abc[143] = Pairing.G1Point(uint256(0x12c4d187d062f9777610ede374d2e096beec1400ec12ea95286ad781219db7d3), uint256(0x173b710b6d1cde146c4b9447ab51b786b282d2b3abb25e1076381959adf1345f));
        vk.gamma_abc[144] = Pairing.G1Point(uint256(0x0da9d3d6fc5f07bce5285a9e796fe83d05c0cc93c38718281b9ad463d8345566), uint256(0x233bb068e7f8965b1c157c5d0d3ac68a3c1f7a6e7aca733cf0cdc60cf941ca69));
        vk.gamma_abc[145] = Pairing.G1Point(uint256(0x2d0fabfc6525b647da61266f5d6fbddc77cb9dd08319c7073468dbba1da4d3f1), uint256(0x2a8578f9d97f752148699ebc7579784476c5cf93a1893af005f4f61d63ef2745));
        vk.gamma_abc[146] = Pairing.G1Point(uint256(0x07972453e18d1b7c5e658ff69bc82caba9dcb9dc5436514461af7cae58e9510a), uint256(0x0e7a59fc11b522898f402916ae0f75c19968bf481fa5cb06cc9e42748eaeacdb));
        vk.gamma_abc[147] = Pairing.G1Point(uint256(0x1db5fba4b09df25d749daabc9978493bcf0e71eeffb7df0862cf83d24accfa91), uint256(0x02aa31fecde0423067f0100d1632922b468dbf30b439fd43d04e476b5b781f24));
        vk.gamma_abc[148] = Pairing.G1Point(uint256(0x07c67cc00df18101296f64cc5c54d547a911702fbf8b8e6fe61c1e56b81e6b59), uint256(0x21b8d0ac239ae3c5e2a7bb4c9cbfc3b6f66461bdd1a96217085eec1ced2586ce));
        vk.gamma_abc[149] = Pairing.G1Point(uint256(0x2f55ab46d0b070f69983943a908f3698c5d362b250a131259bb20d5d453fc4b0), uint256(0x27468883f8839b2a748149f8f88b76109b790ee176dbb2504ac3badeeb9a7b4c));
        vk.gamma_abc[150] = Pairing.G1Point(uint256(0x282b75c4b03b89a5deae4f016749d98cf41e17c976c0206d981b170e33626903), uint256(0x0aec5380d6c9f9ad91fb1539c5ad64dc10be72ff542fe2aa4f5e9fbcb0c99bdb));
        vk.gamma_abc[151] = Pairing.G1Point(uint256(0x0444cdff8dbae1b7ef2d132a36b64f52e85512c8001d6f8ce75f0ab8f79fb846), uint256(0x110db8504b4fecc22b275c6927509aaa8a9344bb301e524239bdbeab93fb1dad));
        vk.gamma_abc[152] = Pairing.G1Point(uint256(0x0626bcbd7a4e2283bbfa7fed2de87adb9a250d4a5e66c53a012244e874abe862), uint256(0x13666a15348b9818be925be9164c77b1344e34b451eeddc6a35729a4e732fac3));
        vk.gamma_abc[153] = Pairing.G1Point(uint256(0x22963cac94b9c9e9b8edb9345aee7368c5c87a6ea8960749d84860ca6e48534e), uint256(0x1b5dd5a479c8ea70729de015f9813676450be9e495e164b8df5e096e770247bc));
        vk.gamma_abc[154] = Pairing.G1Point(uint256(0x298ecbaa387b75bb108ff3020bb742c3f7f8d59524584b6bcdf95e016de6601f), uint256(0x1c24ed6eb6c641e42b960b312be9bb1719b682f676d80279969ba0387b02914b));
        vk.gamma_abc[155] = Pairing.G1Point(uint256(0x2a076453d4016bdd03e57eeef4c4d48893d61a677dcd12978a4ada5ce59be002), uint256(0x1fbee4f10d8d9bb18633265b615b7add93d82e47654011ae0e5ec568eda702d6));
        vk.gamma_abc[156] = Pairing.G1Point(uint256(0x05603dde68b1000526b00f827cf042ef4f3595e666be14e942f8271d982a2314), uint256(0x16962794046abdc55ef08123b3dab968fc53e08e6f611344d3db684c54269c1c));
        vk.gamma_abc[157] = Pairing.G1Point(uint256(0x1074077a849119250603def4a62d891f9cbaa8a18232050314e852ab5f57810f), uint256(0x1de80ca856c3cfb32da2254a6698ac54daab3bb6e8720bdce2a5e81379e20bcf));
        vk.gamma_abc[158] = Pairing.G1Point(uint256(0x0ffed16d4072236241bf9898ec8dc9555b298d0ddf7a8c3075d03bfeef4b74a6), uint256(0x14683d327a9968fd5972a6b9a8920d0016854881f99face5421d880cefee854b));
        vk.gamma_abc[159] = Pairing.G1Point(uint256(0x0cd48eb94ae6c2bf53f055f38aedfd4b03690af81b484b520a712c348826bd9a), uint256(0x1b464fd0a235fbe2ded958502d5f0dd2ffd016e3e660e3173410c56a79629ac2));
        vk.gamma_abc[160] = Pairing.G1Point(uint256(0x2c4b73c7d051c363c98a79eef0309ed6cfbc6ea336d7594ec00977f9d6e652d3), uint256(0x26452a29cd74de71c42288b36b5677baa1da547ef2c6ed18c8c08b4877fa19ad));
        vk.gamma_abc[161] = Pairing.G1Point(uint256(0x0c0c1648ed40337902a0c67463427640e74c3fc8f67cc884b62255cd1291f4a1), uint256(0x2479bf2b17038611a1341df98f8360c3e3f137b272df7d42c766048616ccd2e5));
        vk.gamma_abc[162] = Pairing.G1Point(uint256(0x0d0f34955ab328b02814e17a46728f0f163c2eda46bed88fe483993274664863), uint256(0x1efcde41dd6b19a73bda2c0ac1c605d4b758eca34012aaec4a54791d6a4742b2));
        vk.gamma_abc[163] = Pairing.G1Point(uint256(0x0605df7f2ae214fca62846cd3da0f33bb5756fb7360a2d5fcf2056b248c4d686), uint256(0x21ef9b947f7c77064718ba1c9e6062481063c8d80539aa5182a0db01689dbfe7));
        vk.gamma_abc[164] = Pairing.G1Point(uint256(0x0c85d6edebc3fda70ec751ed677e334b1cfc9f7f6d29cb994775d82101157b38), uint256(0x2a2841f084406bced4ef1f0f85c5aa5edfb58d1b93420d89c12b5ae3eb61be65));
        vk.gamma_abc[165] = Pairing.G1Point(uint256(0x0debd389992be3a17e4f93f4ed21af3aa7d9698f0ef874a06d4bb1fbec171246), uint256(0x0ce1ce69ec41e7d056630a4aaa8510f0e9a971e1e1622290bd3ff790868d9711));
        vk.gamma_abc[166] = Pairing.G1Point(uint256(0x1f8aa117cd9a6fb82148636139443281aa2bed9feeb1d9e24b946fed365d22be), uint256(0x1e3e8c94d10812a9b0caac755522f2723f8709d43922a482386d838f73c4c329));
        vk.gamma_abc[167] = Pairing.G1Point(uint256(0x04390c5ee84cb46046587d200977a11dfef1c65e4a1f425aa8bc61a9865ca969), uint256(0x204273eb5105b09a4b42c454dc8cd3345ab60821fcd5dc5059cb33ce4b2e0eee));
        vk.gamma_abc[168] = Pairing.G1Point(uint256(0x03ab147843619e646d623572b935d5301afd493203a28bc85fc9e75def930f7a), uint256(0x29b60c3ae0bff9ee855d2c8485b24ba3c62c0a550d053caf643c7c525d572a3a));
        vk.gamma_abc[169] = Pairing.G1Point(uint256(0x07f25284b4dac33e96702cfa6ee7b779c6538a16c6e60fa2b7958dd11515b44a), uint256(0x130703529fd024e72f90340a433ca35e5e1927d14997411f7fd3dc8fbb82f1c6));
        vk.gamma_abc[170] = Pairing.G1Point(uint256(0x052ae81c30fd08ba13d8ac81c9bef50903b174c9fcd128b2f6d98789e2ab4556), uint256(0x196b11de770f5f54ce059a89be84b1f4b44f386e3af74961f987cf0b391560fa));
        vk.gamma_abc[171] = Pairing.G1Point(uint256(0x1f3f722123291335b48b594e35c9bff317fd5e9beeb6eb27b6b71c36ebc4329d), uint256(0x3021d70043640e46700ddf492095aa30c98a09f42564ce1aef872b6daa58169d));
        vk.gamma_abc[172] = Pairing.G1Point(uint256(0x02d23c0b67aec6a833f074d8bc96823c339b76df6342a2f1e67cf26ab6d0394f), uint256(0x003ea48c613089ac558051e22df09881809a47a2975ebdbbba392f4ba13a86f5));
        vk.gamma_abc[173] = Pairing.G1Point(uint256(0x18b8dc986fe8c288531d20072abf566984fb2222b5cbf0b8ba5c4e85b7e13fba), uint256(0x178ed6091a8813599b7f66a75f2e7c4be83b5c2e102e3a33877615f8df022656));
        vk.gamma_abc[174] = Pairing.G1Point(uint256(0x1e83157cd3475cb33ef94d0d6d9b5cfb97c5d9bd4fc1018f6b4461a7ffc1a4e0), uint256(0x1f6bcc9c986bae757933b5455ce04fc0d5b981c33a7d741770907c57fd2f9634));
        vk.gamma_abc[175] = Pairing.G1Point(uint256(0x27b0b7aa56935bc3dd83e3d9d00a3fe86ee992bcf9121bc272792a343d34e9ac), uint256(0x1afd17bce67a99dbd171b7ffc13bc978b828673c3be23e88b84fba535e8cbb0e));
        vk.gamma_abc[176] = Pairing.G1Point(uint256(0x105cc5d7c15b7637a74d24b69444cada26ee4cc26653e2d2572c9bf2283530f1), uint256(0x0f7282c797a4be41f3aa643cf28ddb2f2da5e646541ca134513618b9a662ced2));
        vk.gamma_abc[177] = Pairing.G1Point(uint256(0x2ec83cbe806c5340f73481e8f85a37ed92f1f80b93190ea7fdea165b9830693e), uint256(0x1b1a3df34ebabd6a242c44d73290fb6a3f923f1cfbdc021e40654042ef05a4d2));
        vk.gamma_abc[178] = Pairing.G1Point(uint256(0x2bef6a47973ea62e98dec79c92fb5a435d5dc7496cde3dfd2fbfbe0338a81452), uint256(0x1dbac2efa530ab3a17b8259076d665e88fcce62b949a5818ed7fcec34af50f8e));
        vk.gamma_abc[179] = Pairing.G1Point(uint256(0x282a59bbd0c9d5cf98b725aaff60a22c6c69989432fb7363a4ea334338de6781), uint256(0x195462acf2e516cd0181f3815da8ef09a704e8def5d6dcb9faa6a05f4ef29168));
        vk.gamma_abc[180] = Pairing.G1Point(uint256(0x0350af91c169e2e05184f6726488d04d7203db8b82fdceea0a578104e1ee06d3), uint256(0x1e53783ab3ace0fa48ad95a6aa0738ba4478c14692a60e402c7b437b3e40c4ad));
        vk.gamma_abc[181] = Pairing.G1Point(uint256(0x034ea438eea32c4c459eb83e9733cb2341b98adcdfd4afc58b349533c6a94790), uint256(0x1b8451ec1cffb10c2e4c478b8050e752550837d9a3f28e4996fa50eefc62dcf8));
        vk.gamma_abc[182] = Pairing.G1Point(uint256(0x19ee2608dbfbd867932b9e4d2d641967be234e1a061b4fa9832041b9de945271), uint256(0x1c2e4f2a214c70a6c5b438cda6edc69a6cd5c6bada136f301bfeec457c1e26c2));
        vk.gamma_abc[183] = Pairing.G1Point(uint256(0x28f544c85302f5aedd9ebfa4e420ae1eed841c9865245487f9236ad996998ae8), uint256(0x2736107f391e58f3947f5ecfd47e755e8a2c811e3e1fba474c6cde2537a9d16a));
        vk.gamma_abc[184] = Pairing.G1Point(uint256(0x2afd59ec50ab27567d1d26760fc051d3a3d8eb1fd716b13594d478be96d3b3cc), uint256(0x0bfeb23b2218d3eedb614b6d02c1baa0bdcb1711b294abc48171db427ddb9cf4));
        vk.gamma_abc[185] = Pairing.G1Point(uint256(0x16614e355c2897961e3ce4c10dbfdce12acaba6513aa03fb72ae74e6ee3b698d), uint256(0x2c66a300084883741f101b7f0ae22303856df793ed41dc8d697d921e3dd4b21d));
        vk.gamma_abc[186] = Pairing.G1Point(uint256(0x25336535afa7f5a04de445e22aa66a76f09c323b85121346a601640c9fdda580), uint256(0x141665425f3d5576448e9ce02fd4c339b865dc2576d9046fb41904f81b4eedd1));
        vk.gamma_abc[187] = Pairing.G1Point(uint256(0x155efe061744e91166dcb2fe4082e505bf33cad5076d754406dde0d149a04b57), uint256(0x19723b039ad3677b051109c65e2df02abf14270d3d3ebc08fb051a6896fc5eb3));
        vk.gamma_abc[188] = Pairing.G1Point(uint256(0x14d9bf96fa6e0b0ed452b0a793a9d4c3e8689e6e715bab7a3b98b98b0237a968), uint256(0x1ac533c5af12dee800dd851a1c7e2e7b63beaaa1d4c3117d2849d78cbc557685));
        vk.gamma_abc[189] = Pairing.G1Point(uint256(0x084c5887b52427fe829da157645339549360b0749a44abf98e8afdb957dc3796), uint256(0x1603e4a1f864cb3fa671b1cebb3e96a93cfd77c391614913d6c9734c244fdf4e));
        vk.gamma_abc[190] = Pairing.G1Point(uint256(0x0f601e245ab587ad7df4caf7137df2f1eeb38ad9e760b3eafdc139470d89bd4e), uint256(0x22005b291fd27db4c0f6570277c61e17d8f3d20fdecd2db3ab78f0b21193194e));
        vk.gamma_abc[191] = Pairing.G1Point(uint256(0x1e5b4110e1753965185fb8cf4b1e56f9428d11436aa80849d81f6a0390714e0d), uint256(0x240c68a7b99832ff5dcca5cbabcea5d1ffdf9b6205fcfe5f7d6ac4cba3b718b9));
        vk.gamma_abc[192] = Pairing.G1Point(uint256(0x2300fb69bed303b0e0f8e554a86588a11f1125d35a1e24526d5a28cb39e89fdf), uint256(0x01c84fe14cbf823654007c8949e3db3ccd7ac9521f143a7bc64f84549931b97c));
        vk.gamma_abc[193] = Pairing.G1Point(uint256(0x0e3cb971d4c9dd8d12a1aee0c12964d17544e7d0a829471fced586c76d9a91af), uint256(0x2da374e785eaa974c97fd5677a2855c94c00b5f254cc94bf3b8a7db56a66787d));
        vk.gamma_abc[194] = Pairing.G1Point(uint256(0x10641ae89ae76515b09f01f898f55270ba40a7150043337e3a0b1f7c92a0de55), uint256(0x0238a6b8c89daaa82173722c74f685d58e04c0e48af857b37ea6c16c7e56635c));
        vk.gamma_abc[195] = Pairing.G1Point(uint256(0x0267da238122a1cfd13ad4ecf639adc4bcbb5b5a87803412dd570dca9d0f5683), uint256(0x1bd3115a740f553bdcb646829461f458a06b399aaf0ed8c97847250d28ae0906));
        vk.gamma_abc[196] = Pairing.G1Point(uint256(0x295897f584d61e4695738ce4a0f54e3dc55d1185c9cd89260493642e915a91cc), uint256(0x05c1adc3fa90a621dd53f2b14bffe048973c72206ac9f20c58637cf1499b26f6));
        vk.gamma_abc[197] = Pairing.G1Point(uint256(0x0c5b079da51faf1706b28be6dc78a67b0c7c3ab37a50126b1d5aaba8a02ea31a), uint256(0x1709916057012841f59dd44286b95b5e843f0fa00c6daafa74ddafe10d68544e));
        vk.gamma_abc[198] = Pairing.G1Point(uint256(0x0705f378e4a2aee2865c772588b18c309359ed00505d5daa30a298c4a81bbaf2), uint256(0x2be722337817b85ff049e2b927d3d531df5729a782cd99e3168ec2929a8a5dbf));
        vk.gamma_abc[199] = Pairing.G1Point(uint256(0x0e27a72e98c90cba5887394654ab64305358727d5aeb6dded7405485b4f8c02f), uint256(0x16e174f00cd34ca46a2fe32c1aa0f8dc3ba0e957975a940a7d16c1cefe2f9f3d));
        vk.gamma_abc[200] = Pairing.G1Point(uint256(0x1fdad7252a2bef6ccc50548f4ad694e78afdaf1d8cc60ac59977487a3fbf1f55), uint256(0x273ceb76c71f1281cf664bfa192e84e0ae03f363b89dc54bc4dadb80a14ac116));
        vk.gamma_abc[201] = Pairing.G1Point(uint256(0x2ea8ed3eaf809fcf56490fc0190bd864d278bc18f751fe3422d935900ff90393), uint256(0x238199fd0635e6388f0dffa96b1d448937063365b5fbfa73ff76437ba5e309aa));
        vk.gamma_abc[202] = Pairing.G1Point(uint256(0x2b7af405725f6924fd0b5e0ab1905109b27f12246bcc694a8f5ecfdd1d61abfc), uint256(0x2e8e6129c1d63b9ff1b261fa858b3d96f42533db5e6502d73c91196c9f6454a0));
        vk.gamma_abc[203] = Pairing.G1Point(uint256(0x2c7382bde2e90607d601f439e0f0cabc817dee99f612e839d4bab3ef7d4b9a84), uint256(0x1eb9b0ed978739f4168296c6a80248d74c7adba0edabb41da1e84c3d73a0ffb4));
        vk.gamma_abc[204] = Pairing.G1Point(uint256(0x212ae23795be2a6d13d322d5fbe5659c90057e6b8f8884624f42acfb20e5be9c), uint256(0x2295ac2d47ab94497285a14fe1c077b58e555e1456b820c9c5fab13df75629f3));
        vk.gamma_abc[205] = Pairing.G1Point(uint256(0x1b388579817444d04c971680060c0ce15b397fc85193b0b6519821164b083543), uint256(0x0e36a7297e7fef73bd3b723d9cb907e947bd915a636fceff28814f59b4eb1d10));
        vk.gamma_abc[206] = Pairing.G1Point(uint256(0x0892344a4b21c8ec242d4ce59db7b786ff413c77f4a4b85765cc3ed3be146b23), uint256(0x281383dec24d1996789482f71973f2e5a4dd7162ad239dde8e629af5b2adf6f1));
        vk.gamma_abc[207] = Pairing.G1Point(uint256(0x1444a4dea68cbc882cf4c822a91761423f7c4326e40b36284251bf05f8be39db), uint256(0x275fd056385be820ccc347e5e61790730dc4b301430e43d3a965167abe618dbf));
        vk.gamma_abc[208] = Pairing.G1Point(uint256(0x205c9923f6cc32bb17dcc66abc2d8cad882439c7c6761f4ef5b3cb8738257f49), uint256(0x2ef509f3e9bc61f2e6aa7896c6a12c69b0927d51f2b8927e793d8f8f20ba3081));
        vk.gamma_abc[209] = Pairing.G1Point(uint256(0x24fb266a2cb0739910184ac88210f35ea1ce60b44b320d4cc9b3a31756414806), uint256(0x2f7ca22352cabe92b23f09dd4a43507a61dda962461b0b29f380ee4ded5fadf2));
        vk.gamma_abc[210] = Pairing.G1Point(uint256(0x0c76a5aff295441fd942e35aa34ac3755889087394b52106f57353ad7153ba2f), uint256(0x0fa6063e282e2f2baca383f09f40ac2691d499a57000fb47db00943696d97fc1));
        vk.gamma_abc[211] = Pairing.G1Point(uint256(0x136a9444cce068e3c52ae71c3de0087aeb1a1000a3b30eb79b1446b9eaf4ee4b), uint256(0x28fdb9ce5dac59c04a179994e5547847cb076ff7b27caae94ce96c00560ed867));
        vk.gamma_abc[212] = Pairing.G1Point(uint256(0x0f3c59c4b544313d8717570d2b7cef64f78e722054343ede7d0b93dce32151cc), uint256(0x00a12730a24f452371ed561a4d076564c4bc68b1dc04890a8101745a87211103));
        vk.gamma_abc[213] = Pairing.G1Point(uint256(0x0084d429bf1223d54faef9b2bdc8d42da2a1ca4c59403d6c0dbfadcc5fa9a1f9), uint256(0x1c0ade9845e87e20ce61b19013b2035d87c99a86be542c7dfcb6d7f9eda8e88f));
        vk.gamma_abc[214] = Pairing.G1Point(uint256(0x2a8aad9ae45fc387f2ad46189b08040474edc6e30f6f649db56635659f18dac1), uint256(0x27eba67b2ece00d4578475f403e2e001213d9aea3da537e7a2547f35a668553e));
        vk.gamma_abc[215] = Pairing.G1Point(uint256(0x006f59acf748043bf9c649ca1868f85321d9eb70e19eacb953140080165adade), uint256(0x230fd5deb97bcdb950e126506e47910ad71e8231e26df5bc5ac3f208eb22e58d));
        vk.gamma_abc[216] = Pairing.G1Point(uint256(0x0822defff0b0e98bb62e39eeacbc545c9efcd824b49856bf53a9df0b65ad762b), uint256(0x2d6fb4ab3d544335cc7675eeadce85fa163c4857882d2a07752f9fd1448e0994));
        vk.gamma_abc[217] = Pairing.G1Point(uint256(0x026a304947b1047912058ef4a2b838f62909b54d62dea906d14eb7e2ff7a6828), uint256(0x083fa3e35ee1acae7f5dc3a3b2f856c7a07f02c41823c23bae5ec05c226aa15b));
        vk.gamma_abc[218] = Pairing.G1Point(uint256(0x2cbbe7fafc4f8717e0a55166d958b000b527149df9fe13cbfa9e249310f8ca67), uint256(0x1be291bbf82d63628f6e5e471b601fa4f89ed4511c96ff1f2b9460c70714c9e1));
        vk.gamma_abc[219] = Pairing.G1Point(uint256(0x29393dc345a13ae378d3fbfeceea159269f32cdc0540462c6459ae27baf61f32), uint256(0x2c734c5f01cb219303ea844112653d990ab68da5e0cf8180f1d28763539c3dfd));
        vk.gamma_abc[220] = Pairing.G1Point(uint256(0x12db9ba78e5c5b48bd08e8a11141d0464c8b81306b96bf3ad235437f7581e3b1), uint256(0x2adbc98eaecc8359f9a9045fa5ed98fed113d222d0ae3f0f849e1b8130e9d15e));
        vk.gamma_abc[221] = Pairing.G1Point(uint256(0x1c535a1de3e6c4fb1171a52f4bd98c9a7f8720a84428e4dd1409b09540fe0bdd), uint256(0x0b6fe7d0655323a273b24c883796b4a4b36c2fcdeb9060c819cdd0ce3fcd530c));
        vk.gamma_abc[222] = Pairing.G1Point(uint256(0x14ea5b4b883df2a7150c8cefa303b91726332eb37bf616ae8c5e8f03d53abce6), uint256(0x1741384b1374668ed99a5e8a54da51cf26c0b4ae2c8561d0f1d9e290ea41c9cb));
        vk.gamma_abc[223] = Pairing.G1Point(uint256(0x2169a6c629cf7013f185dcfc2ed4cda1f578f9857d783c863b0f564c42646b9b), uint256(0x11d976ac1db51e27e4b4a408d4015fe836f4ec37f27aed6b6bb54f17f9ec9a3d));
        vk.gamma_abc[224] = Pairing.G1Point(uint256(0x158008fb8137f048c46819163373a8342308028683f167a91f0575c28c7f96ba), uint256(0x202916fc7b737e6a095ea36e948462f2c42dde76c8c0e72f865db08be867f5ed));
        vk.gamma_abc[225] = Pairing.G1Point(uint256(0x0a6106d32fa50641b301b4020d3d9617eda6c7b48ecc280fd8c679622ddd6441), uint256(0x21d03b31eeac363d98d64b38c39d77d2992ae5fd644be1f47c72f925d88a7061));
        vk.gamma_abc[226] = Pairing.G1Point(uint256(0x15a95d7f6fa0b9f4196a5a2e5a593d722ccbcffb653065c72273f386f83724bd), uint256(0x287035c50ddc21f93f261a7fb876c1d0da76c20c6c2622c45a242cd5cabb2538));
        vk.gamma_abc[227] = Pairing.G1Point(uint256(0x04477036f759a3ac2ee69f0e5c9ea27e714a3f616886be64cc27218fff3dee68), uint256(0x063e74135b8a0a7e08244d7b72da62712e185bbc3327038f88b2b6bc3e6bd45f));
        vk.gamma_abc[228] = Pairing.G1Point(uint256(0x3005179297f2125191b92415e1242afa18da0a5a33c95ae8034947d16e92d802), uint256(0x1f19a7791db23306efc647c10c092541b7dde756b1d7b74b013ad529510649b8));
        vk.gamma_abc[229] = Pairing.G1Point(uint256(0x1259984eae1f76649389afefa76878641fce1ac102657d15c54dd9f3a7a1cb6d), uint256(0x0ae64ee6cc7972ef141a3bff8fc95d1c3bbb7a2f6ab0365ff6782f10e55ef2e2));
        vk.gamma_abc[230] = Pairing.G1Point(uint256(0x0ed020e2f9e6233a07f0f83c46c26f188655744ea5aa93eea716b8da7204dbfd), uint256(0x0ac0f100ddfbb6db2a1c40701bb17d2d6a0207de6abfbd604b55a8202e7088cd));
        vk.gamma_abc[231] = Pairing.G1Point(uint256(0x1874c039d52e05d466432ca59b802ea9432115b4a2ed4ebcd961186855a3030d), uint256(0x240a6415421ad8b87642175c1f70ca894589b71c9c242dc1773e416aa169bcae));
        vk.gamma_abc[232] = Pairing.G1Point(uint256(0x1f3cbbe9d5b1a0253cb4761c13c40710a6a90a60c346818bd73ca0b997d42223), uint256(0x08bc6474a68eb8264925f1dab032447f144673fb551c2d2168d33e49933f9d6f));
        vk.gamma_abc[233] = Pairing.G1Point(uint256(0x03f968aac7168ef5325c7ee8e7234f79cdf38c363a4045de028804b99aa030a7), uint256(0x0bb938f87254379f26aca6f17efb68a64e4b6701ecf8685513a87ec9dc2fdf9c));
        vk.gamma_abc[234] = Pairing.G1Point(uint256(0x210d9b47e7d1f3e50f0ebfae624fa8c5f8b57f57c6942e8d8204e90276c01b23), uint256(0x2a728cb7073e68c26759fad98ca55ec798f9812800861a303e834ba663ac9981));
        vk.gamma_abc[235] = Pairing.G1Point(uint256(0x062334ffc73749c9ee910490c773f0bbfc283136a75b5b30ff029bdd0e5d8fbc), uint256(0x104084c0b441a0ac498287037308274b17e05494ebdef992c4116c454dff1a5d));
        vk.gamma_abc[236] = Pairing.G1Point(uint256(0x02d514a2492db57e0444d033c8b69e4f6f2828ad2966d9aab9e974aa1a9c62fb), uint256(0x27c6e4f462fe10137df733883f7130d78f85cf6ef3c2abc3d040034f1c7e2194));
        vk.gamma_abc[237] = Pairing.G1Point(uint256(0x1e35e2aef354fa4d9e182c183c6b9a4bb39d856053e3ec6795e60acfd4b22d34), uint256(0x0a2284359cd6e13e00c00a8ae6b4b1bd66a472680eec3aa7d2a5ade265298b53));
        vk.gamma_abc[238] = Pairing.G1Point(uint256(0x1b249db25e240d5a23f6043ef967095fb7d7ca5c54b59b6374ff9d261cf6db15), uint256(0x15b4b3d9e744411203b4b0495b8a92a34e20e7b06d4e466f028de56723b1b928));
        vk.gamma_abc[239] = Pairing.G1Point(uint256(0x1e1e8dc761315bec0b1705b7ce2234088b435f64fd4f16d6f36dfff57b88f27e), uint256(0x2df76c680494677eb3c89a053cc6ab9c01dad461f979b2a2d1f1ee4052587a21));
        vk.gamma_abc[240] = Pairing.G1Point(uint256(0x275b33806583494e27b90fa0aae24593790316fd9cca5b5275372b6cf70a2550), uint256(0x05051cd1bd75a9873f51a48920851609cb30ba0cceef98d6721c12b69ebfcaf2));
        vk.gamma_abc[241] = Pairing.G1Point(uint256(0x08f14d79b51bea79350fd4c10138fcfcfa2c0b02247269c515f4b7ef0293f728), uint256(0x220a8fbe521a913d1a398c7e39801f25519f05fa9bfd9d5daac0a9a83a9a2ec4));
        vk.gamma_abc[242] = Pairing.G1Point(uint256(0x21018349416c192b6949091a3889e073e33b019580a8d33f1185d076e038b3b4), uint256(0x1d3c44db31e88c32c7eee79b198362100a5761f8668eebbfc582680eac4fcdb8));
        vk.gamma_abc[243] = Pairing.G1Point(uint256(0x09cd4bdb319e2415895211076995a9906d221addf9870203bf0a972fc660fe10), uint256(0x0d227c33fbd8a3e3abae6a5798a9ef226311dccdb1688bfd27e880a65d56d00f));
        vk.gamma_abc[244] = Pairing.G1Point(uint256(0x0c54f40dd338f3f22f0f1a99f94e788582761ae6f2d07100b6842800d7b8f918), uint256(0x2a9185a49b9c75709cb4101caf4f8ce12528caeb1be7a9a91fb33a7c5d41d0a1));
        vk.gamma_abc[245] = Pairing.G1Point(uint256(0x13d65fcda73fce1a537c51aac7b32e1741a15917e62b88519541855a82b99227), uint256(0x2007dd7947162101fb62a98b0190d165f908b3ab833ca69b88c54b9216ee49d7));
        vk.gamma_abc[246] = Pairing.G1Point(uint256(0x110aa0aeaee69c3ece49b31e92264e1bcd3671cb78000dca8b123e98d9c21c47), uint256(0x2391fc323392646c94657ed796f949662a1b2759834fba4520846dc90d88ba1e));
        vk.gamma_abc[247] = Pairing.G1Point(uint256(0x0922723b224f5755873e385f2707d001f9d30693c8524a3e6a956d853e90a128), uint256(0x2ede790accb5c052a47ca1f7046330d4c6f6200f9d2d90fd5a7377a5ae41ef9e));
        vk.gamma_abc[248] = Pairing.G1Point(uint256(0x158ff9929eb92bfa4934a26b9d4187adedaca81a86d2a3faac68a2f676a47386), uint256(0x13e4eeb67903ad36ac29e274c4027c4a763cb92a51761cb709e1fbeaa12b9f1d));
        vk.gamma_abc[249] = Pairing.G1Point(uint256(0x138940cf1b9f1b9f5a797850878324b73f9064a1991b71ac5ad2841e106db594), uint256(0x2664cb91f6cd500e902f6c67fa88cf5c9795f1d53adbcfbe6e4b183e1e5246d6));
        vk.gamma_abc[250] = Pairing.G1Point(uint256(0x204139dc1b728d19473f9957964cbf69b92c8d8bc7cf2ec26fe9d6c8c0dfe6d9), uint256(0x0efaf623212504f297e427772644c391ce42b77df5bbfe69aceb95f0124a4903));
        vk.gamma_abc[251] = Pairing.G1Point(uint256(0x20247034da3b0e8ff5aa3299a48baf4eccb2b517f93b4621a4ee4522535e47f1), uint256(0x21b3efa27cff581e9c0e007b0b305fab3f65c67ce6a05cfa492412fd9c1f5cb9));
        vk.gamma_abc[252] = Pairing.G1Point(uint256(0x1efae051e6b96ca217fb7c57a2e61895287f6c9e28a31ff2f451291880f21ea0), uint256(0x2fe38fdcf2e742abcf89a1982628ad20114e0e94c6d31cf55f49e9055798fb77));
        vk.gamma_abc[253] = Pairing.G1Point(uint256(0x1e64619b0b03ced8c38f38a0930c38bb13be37bd43191929e0cb2b18d9564538), uint256(0x12393513425fa17c97220c0821afea95b714c40c5b8c19230caeeead4639730d));
        vk.gamma_abc[254] = Pairing.G1Point(uint256(0x0bdb8590137728c9202a3bd240dcaa7a9f8baca2ee2cb40fd9997617074080e2), uint256(0x03aaa9c90f6535d2a788c842fe62a6f621026c0e9aee86251a6c140c93140de5));
        vk.gamma_abc[255] = Pairing.G1Point(uint256(0x139c49e580bf0e9218a99fceea4f0998908f6f96210f2c6851caf2ebbc06019f), uint256(0x078c10f1b95749960c3f7fc7af421774b8cdd22970270ea987f403a9b214ecc7));
        vk.gamma_abc[256] = Pairing.G1Point(uint256(0x28c59831127766134dd600fb66d69506d67b9adde16c42e96641dd8487a7afce), uint256(0x17d51c24217c1ab8de05d9167a0eafb78ea64def31c5de696bab6f9f0724f0b1));
        vk.gamma_abc[257] = Pairing.G1Point(uint256(0x0e77135ab5bf686f08b6d44823e36ab268460613e24ee7e9bb6af5eed5c0c2a5), uint256(0x04357ffe1559085253884d6952e7ce26d4c5dabdfd1f4eb9e1ffe05f0625c818));
        vk.gamma_abc[258] = Pairing.G1Point(uint256(0x20e014124d92082279e56c05ad7e69cb2c444b7fed9cba476c46f799646b7c7d), uint256(0x26fc60350149f537322b11c8ddf4a220db85c97cd71f5a203b73c3fc6b325fd7));
        vk.gamma_abc[259] = Pairing.G1Point(uint256(0x1d503ebb2d3c54070f6e2377bf9c522edda32491c0d2caa6de1c4079e8babf5d), uint256(0x2b241b6991b9df7aa78e964e111cd2ca0ab4c9424a01ccc9eb854d6c4482cd5e));
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
            Proof memory proof, uint[259] memory input
        ) public view returns (bool r) {
        uint[] memory inputValues = new uint[](259);
        
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
