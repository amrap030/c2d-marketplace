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
        vk.alpha = Pairing.G1Point(uint256(0x04a0a3c27075e53b0454d695b0a8f6089c0ea0356fa301248f7c73905a62bcc5), uint256(0x2ecc6aefa9c0dd244ee7d1cccd837cdcdaeb3d6bd3085f2bca1ce43b1bfbd096));
        vk.beta = Pairing.G2Point([uint256(0x12890b58a2ac5335a954b1deec5e4162e116d7f005e1695a85791a2ea8008d04), uint256(0x2a5882c84b44a2070bc3e8ba36d76f208cf7b1158ff06f25c15fc2f757f16fc8)], [uint256(0x1d8040e978ea457163518e771e67557ba71efd527508c792cce3e25305456c19), uint256(0x0e81e71425f8ba5ca0725abaccef58a54b451cb219d9339ed1c44da4ff1dfedb)]);
        vk.gamma = Pairing.G2Point([uint256(0x202191bc3ab288ab760cdf8fe568afa9c2655124ba3f678ad1455546de5ca5ad), uint256(0x274224864ee86f824388649de284f50e012dd09ccac7d3f46891be85bad222dd)], [uint256(0x25daa882ee02dc3f2c07079d54a81035f79eee4c5c8a380e9b596c62d4265211), uint256(0x02ba8edd5499b63da69355b50bc7d30c7d15f8d6eac56a0b2d560574757bd6f6)]);
        vk.delta = Pairing.G2Point([uint256(0x0c061fa3f0bc7ab6e9991df665ef54d1c72145d2d156323d4df2b963f698c01b), uint256(0x03ee4cebeb61d78ea07eab2419a74d996b8cfb12b71fd33757da56530bdf0ee0)], [uint256(0x0d502fab2b3361d93109a16fbe330085150fd9c417e17a466c7495b4fac1220e), uint256(0x098a5802748ee6b5e573e6bd4187a4e915d8f1a4cac0a5d9e06856006a3c7f27)]);
        vk.gamma_abc = new Pairing.G1Point[](20);
        vk.gamma_abc[0] = Pairing.G1Point(uint256(0x272b4052f0df9c6dd009dc0b7349ef353df6ad4472f79fb8783f88db27fb6363), uint256(0x10a2db42a262a27ddd20e30213bca00267a2e2a5b896f1e05ed6b309627bf866));
        vk.gamma_abc[1] = Pairing.G1Point(uint256(0x1c7438cbb9514de15225a92043c3746fa978b9bd0218487c541482e304f0d0be), uint256(0x2654a7e750b84ebbe8530976019b906baee6c621bdf296ecd2b7f5fac9db3979));
        vk.gamma_abc[2] = Pairing.G1Point(uint256(0x168db4cdcaa93ac2c1b84467955042eaf70bfb9603bcf878c1a19cd8f37cbf4a), uint256(0x0ffc26882a3bc64696cab99bd8bacb44572e0a1ffb3fc5975b05b4ebdf87ba18));
        vk.gamma_abc[3] = Pairing.G1Point(uint256(0x1f2d257c00c2ba6dcae483f70a94217fc0147b9d2b4bd73cef7e7278efc9917e), uint256(0x1bc77f12312d6563cfc3e67cd77ccbd1365acb2edb8b875dc61619fa4fbe48e2));
        vk.gamma_abc[4] = Pairing.G1Point(uint256(0x08164b8ae92fdc5e14744a536eb39aff73a7ad242f59acd2cb8dd78c898f4c88), uint256(0x1c0f3a8d7001130660f956029c1550d0739310af461d42ef589f8ceb74b18547));
        vk.gamma_abc[5] = Pairing.G1Point(uint256(0x2ec898a9bff3f71e4bbfa9833c3a1b60d44aa1d03b47d88f1fbe716122962036), uint256(0x268f7461fdca182637d8b6721896ca113434a25b49b49da2b9c0c9ba86729c9a));
        vk.gamma_abc[6] = Pairing.G1Point(uint256(0x040c28f13ef7d120da7142afce2217e4e17addda6041d6fa3dc122a45643d7ea), uint256(0x19b89e667deed48b6602467bc7bef8ffa5cbfdab9ac11f9cdec97589d0331ace));
        vk.gamma_abc[7] = Pairing.G1Point(uint256(0x1f9d973db87c6ed93ded5b3ffdf8df8c6049c804d693f0732f7772c0d4e1a65a), uint256(0x0a3a91cfbdf46837cab761fa117b670aac68449b10252a4eedfd2ec0f43b21ce));
        vk.gamma_abc[8] = Pairing.G1Point(uint256(0x00c95be8ce1f1486244486e85df73bea6ccb9b4fd081a0c088a1ba352e63ed67), uint256(0x13846e18266aeb5b04ffe12d20ef9d6c76a21476c4fdf4a179ad56310c308d97));
        vk.gamma_abc[9] = Pairing.G1Point(uint256(0x2ba6ac8d38194f4a08ef9fe1c44c19f999169a8094adb03d1dc82fdb276b971f), uint256(0x2fa8abcf4ea4c6de67c8106358be10977be5d67830f79bc21b67890d0a43f17e));
        vk.gamma_abc[10] = Pairing.G1Point(uint256(0x0047c8a6fdf72f1d8c9e9209653e46cfc5e4f26409d020fd8f404ad6f8cd6735), uint256(0x1f9883e08e7289fd50a511b76733ea6aa3e27fa5d1d6573e11b7202bf63bf92c));
        vk.gamma_abc[11] = Pairing.G1Point(uint256(0x26b95d2d6dea21147c9dd975686b26152817ed150c9c904bc5a24e31d1885067), uint256(0x228cedb388dfdb4f678f2139630bde987b25cbf6814515e134b804100ede0023));
        vk.gamma_abc[12] = Pairing.G1Point(uint256(0x0616e842ccd5c988cadf5af15f183eafbc65d4468099d9854ff562a7cb499490), uint256(0x1594a043226688a294b9bf122d46540ed2ab9ea25ca9b82b72b2a7383fd6c12c));
        vk.gamma_abc[13] = Pairing.G1Point(uint256(0x214f677ca0fc31b0a2a83f6ece90de9dc73474d47b6e2a5d44af5ffdb6b35a87), uint256(0x12add5c0432ec7cd8a5d9adedfb080bc68c47c35f02d931b4a16bbad2c9e1e6c));
        vk.gamma_abc[14] = Pairing.G1Point(uint256(0x2da3c5abe3c45b9f379f79817f0fa09657ad2176d9777b3d6e07d902897e4eae), uint256(0x19972d864d296486ee19744ab2d1e88d5ee443cc378005edc4ef8cb1bfed7e81));
        vk.gamma_abc[15] = Pairing.G1Point(uint256(0x26c6e611ff12918f6a057b1e1855d5d7b1fb0fcb705786567b2ce0e976089337), uint256(0x26ec734c7658d7050fdd59f506ef8b0268a8cf8ffd56c1b93fc255128a8db510));
        vk.gamma_abc[16] = Pairing.G1Point(uint256(0x0911ea510875b797289592498ad78b08bd0ebca4d6db02262deadd98852dcd75), uint256(0x092ebe3b8a7f087c1e309c91d18199e1e1df792fe7d213cd0c8b391573c27492));
        vk.gamma_abc[17] = Pairing.G1Point(uint256(0x12ee43b7a940bed5405c8064ad4a4ae48a6d07d19f0937c9ccc5aee7f070c876), uint256(0x12c27f9243d38a146749701cd6f3de204918d19fe2696298143b646c28c1db94));
        vk.gamma_abc[18] = Pairing.G1Point(uint256(0x0e4119c5b2a6c72dab8d813bbb8eb86ca9664d87f6db6b5be9459ab5fc3945c7), uint256(0x0181a8f32b6fa912f3496d0a7edb14d2edce580483d607df7b14353d071ae70b));
        vk.gamma_abc[19] = Pairing.G1Point(uint256(0x09087f523dc063e130e019973a6ac4bc1c9441ed35246043c22be088a6f6cdeb), uint256(0x16c6641cc824b129281c7c7cdedc958ca091f0c7531f1152cba51cfc88630751));
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
            Proof memory proof, uint[19] memory input
        ) public view returns (bool r) {
        uint[] memory inputValues = new uint[](19);
        
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
