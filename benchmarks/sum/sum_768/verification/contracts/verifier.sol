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
        vk.alpha = Pairing.G1Point(uint256(0x124f540b4b4dc1a60974415e040d3d6878b88bafcf1514159129c27ae9df6fa3), uint256(0x2026adeba17ab16dcea6c23948cadd97750626461a671d50785bbddfc0c3828e));
        vk.beta = Pairing.G2Point([uint256(0x2b0d015314e95ac6fcc199d66109c746974d935dca2f21b021b3d4e4d6427764), uint256(0x07c69b02b70b22c1ebc88e15a255d681638b2507195268790c1c8944ea9f7f14)], [uint256(0x04faaa549d9b8d11aa52beecbe6ebd13d5665821ddc9ccc0a73807e694b88e0c), uint256(0x2465f38a5cfac88a49170342dbf3e9a3e5789f4caa5d6f7d6510139673b0f3d3)]);
        vk.gamma = Pairing.G2Point([uint256(0x1e787307d9b33f1cefa74337d9aa2ee28fc16a64307d418416c3a90ff5e72aa1), uint256(0x2991a9d4f545291d297f66e2b915a729751b1735e4b3d8ba417fcd0215236770)], [uint256(0x2f669eccbea286675d01caf50271a4348fafbd8d9e40067da9acd0c6a18b882a), uint256(0x2457d8a5c2622aa23cc7ff1d906121ecda685ecf948e155757eb338372d5b26f)]);
        vk.delta = Pairing.G2Point([uint256(0x0c4ec4a0a6a41608002820b33d13259438a46670c6bdf5633e88c7377ad91f26), uint256(0x0b2666f7b397194b84ddfdd06f6d6e1464e554c76dd0fd9a05578a6929c5f29a)], [uint256(0x0f51d94355b26145eb426d26c5cf955bf6d62ef0d0d20cfa611f6839e7a6d8bb), uint256(0x10629ee3d68bf027e9c041143dcce9860931f98d2c696732bc7a802e77d9dfbc)]);
        vk.gamma_abc = new Pairing.G1Point[](388);
        vk.gamma_abc[0] = Pairing.G1Point(uint256(0x0833b8a0c95b608bef7f2a4cf8fca332d6510d8fd2480fcf365deaa5f3bf59ec), uint256(0x16f8e601ee0dbff38cc455993c9e70c3a78a51f74ccca07e19b916580d65ce02));
        vk.gamma_abc[1] = Pairing.G1Point(uint256(0x0bf015169e2d1039193f5967b60fc222a8af650ecaf1ef857281d53a3b6c3b97), uint256(0x036da6b8ab7a428d115e184183d15a0635b55b556272133c2bd8ca9e525c7d11));
        vk.gamma_abc[2] = Pairing.G1Point(uint256(0x1fc70b228df1c545d607045fae7da6253dabbe336ba263ecee597623604eaaad), uint256(0x0109bc3209702539bc3987efa614c0c43c7e4172ce171a0829db9b753deb9991));
        vk.gamma_abc[3] = Pairing.G1Point(uint256(0x0ba89b22f4d95ae3f9984d7316b1d026269e9fdecec9e7e3c4100620bbe5dae7), uint256(0x0f654552074f4141bc3578d741ca051dc2a3733cfc291afdd413ff2a75f4d3b2));
        vk.gamma_abc[4] = Pairing.G1Point(uint256(0x07139192ce479f7f11fcd9f38ac5ac5f9ca69eb95f8b67c018d97f88d9ff54e6), uint256(0x0a042011357f1ef2ff16245ff54865bdf73c0f35cd7547c0c93a37f13315ab08));
        vk.gamma_abc[5] = Pairing.G1Point(uint256(0x25d8ab3c8aa2c71080eb8e5b3337af4066da5d1466e0708f2521f5a815b8c962), uint256(0x1e5471f8ce26195eb57988c5263a3018c4b6822cebda6ebb8d6d24512fd1b9ab));
        vk.gamma_abc[6] = Pairing.G1Point(uint256(0x264a1a8e4989fa74af0292b4155498e12aba52e6358fef9eda375a6f4b2ac3bd), uint256(0x1dd6402d952262e965c067948b78df3ca5cd6ac1335c4c3230b6d125a12c4182));
        vk.gamma_abc[7] = Pairing.G1Point(uint256(0x2f0d07eb9e287c352509947c7244a6f7f2c2a299407ea77ca70255cd3144a729), uint256(0x134636986f264e978b0886489ced70eb9fc9722cc591c494f28a7d0f20cdbf5c));
        vk.gamma_abc[8] = Pairing.G1Point(uint256(0x0f89e78dafca3f18e162ae0bb38217923ef47e664c24f01dc27756536135cff5), uint256(0x235932e8f25ee08cf996d602ec17c96be52d6778618f735819aa43c6997706aa));
        vk.gamma_abc[9] = Pairing.G1Point(uint256(0x260c7471eb94f1cc73e06612f587b76111de9d4a8aa5986a8b1cf784d80105c7), uint256(0x083b770c2bca514e40ea1ce08cf7db516854c2d79039e3a53aa51d2f9e0b44e9));
        vk.gamma_abc[10] = Pairing.G1Point(uint256(0x212761430e4d18f6fbe251975cb15b8b0079f2968be8dd43bc3cf30d6efeaaac), uint256(0x169ca0e6c9e36b3b2f1dec9dc9b9e304debef2e24b0aaa795d12e9ffefd675e5));
        vk.gamma_abc[11] = Pairing.G1Point(uint256(0x234534c94f1f20619dfce48980620640ba6d8ca7a607c58a818bf98f886344a4), uint256(0x014557a5b4d1490680b1cb3e818f6eb061c4a22fd9830b5f4b2dee847fb26c8b));
        vk.gamma_abc[12] = Pairing.G1Point(uint256(0x1168d35a8ec3fa51c60e22b302f04fe1fa78e7dcdf716971a4063ba8d2e1535a), uint256(0x2e9d844b6101180f18cbac90e52c4f48fb1603884cb54b6c86e5fbe0f41c6fab));
        vk.gamma_abc[13] = Pairing.G1Point(uint256(0x1898a17b6093300cebea75dc366c54d2d5584c1ce99700a84e8323f2dfd80084), uint256(0x2c9786a0a952febbfd3e945d00a6e768cfe8842516408536b86a3513afdd475f));
        vk.gamma_abc[14] = Pairing.G1Point(uint256(0x2cef358cf2b9eecc80391e9ad05eafb42d208abb7924ff5d4eb1613a567e188c), uint256(0x0d539657bf6ccc973e8ef176d72419dbef59d3c5e276ac42f5164310b4bba5d2));
        vk.gamma_abc[15] = Pairing.G1Point(uint256(0x03253572e6787af7ddebd03d678458edcc095d99192d4bca83802006a8c4b831), uint256(0x17eed70c73c2369c2cc144b6c109ef33f16f5d57639b079cc343915e2973b0be));
        vk.gamma_abc[16] = Pairing.G1Point(uint256(0x12467986037c7c1c5a9cabab4ad060d3017868af1f0a1a8aa7ae12cd5075d5a6), uint256(0x07c59f1ed800e0adf105a7b5689c46bacd7d79aaf435b1934b0916b5e6df14d2));
        vk.gamma_abc[17] = Pairing.G1Point(uint256(0x21d55f3fb57285edcb0a92548279ce0a5047c08f20d3a4b39bb55043bb8c46da), uint256(0x22c4ef57192cde1bfc4518452c67b034421be55c7d875ef6033844dde6c24904));
        vk.gamma_abc[18] = Pairing.G1Point(uint256(0x1f951b572c1fc193398a3abf93511ce38481c33e03ce211a892fa2fe7e29877d), uint256(0x270e753774ed7b73d9c037c9cae9faec1b44a8834efffcdb2f7efcc942bdc97b));
        vk.gamma_abc[19] = Pairing.G1Point(uint256(0x141fb278f53acc6adf52d877498ad804724ca0667cbd514f64413ab2ce988f01), uint256(0x2de5187e214730661a21e702d4151233bfdc7cb46f5cbaa9d28b70b1b6bc857e));
        vk.gamma_abc[20] = Pairing.G1Point(uint256(0x04ba0fe4cc6ac030d27319034810de80880667923b91f63a8e77d99fff765b2d), uint256(0x1a3cdb1197e6cd612e37170ccee873d6bf997226bbbe78cecea8205061dcf85c));
        vk.gamma_abc[21] = Pairing.G1Point(uint256(0x29caf3add121747ffdbdf0c05185e127cc853c64cf3dd5c34f009ca4b5c70095), uint256(0x20702324fb76cb393c026e7a82213fb4007c6258c61e1349219c4a1340ad98e9));
        vk.gamma_abc[22] = Pairing.G1Point(uint256(0x1b1c83d2c7003150c8a9546e8e8437d3441fe649774db1a7632955b240f12985), uint256(0x07e86230af25d7c00805f9b651c0779cb7d5190b7cf5006f416810b96300851b));
        vk.gamma_abc[23] = Pairing.G1Point(uint256(0x1aa7176f4b546f74dd7c53e8b221e72677ff75b068fc0d86ea0a9dcb0cabdfac), uint256(0x02f3b07b98b526aa0232b48889fe76937c340b596f6e9394e17dc535c38420e1));
        vk.gamma_abc[24] = Pairing.G1Point(uint256(0x1d139bf991c70d3f5a6c2b8cc993e49e6a4dca331614ee2c6e89be27229c5564), uint256(0x28464f81fbfc7288c820f6bc40b2207f6ab21d850826a5996134e44a00f86a20));
        vk.gamma_abc[25] = Pairing.G1Point(uint256(0x18f9505f86583ab606eed06d38ccd55017081d0957bcf268e99e507feca9bd8a), uint256(0x24d53d613cb1ad465921595898a5e6d2c55327919b7e3e5d0176c0a2c13bfd34));
        vk.gamma_abc[26] = Pairing.G1Point(uint256(0x29714765a1ac3c5233a9b58151ec47c29e7cf02d4f473133d2045847f402f34d), uint256(0x12c17bcd364ce0c91458fd79cdc15f06b030493b79ec9d584993d4619d277e30));
        vk.gamma_abc[27] = Pairing.G1Point(uint256(0x08f0a9e921efe49d16e15ad3b72a697470cdec3dcd149346f7e516e436fadbb5), uint256(0x0d8e9583a97eb1849f275bab325e12c220f96821a632fd594e66478bc0d6ac56));
        vk.gamma_abc[28] = Pairing.G1Point(uint256(0x26b640c40fea8b1152f31a4ba0f5b5e848ca610491c77c2f800628953dee1a83), uint256(0x1e27fb8078f5bff376d6e1f27e1d820ec461baeee609e72fb4db82433a2a0f29));
        vk.gamma_abc[29] = Pairing.G1Point(uint256(0x1894f514ca1b3f7d88227cbf83707f8550387cffd60f032dc94c68659ad41a5a), uint256(0x2ff7dedaa9f24f5df5d53f540e06afe5591320e3ffb37969ba4233ddcaf842f3));
        vk.gamma_abc[30] = Pairing.G1Point(uint256(0x0e49d4071be39e88cac3280928edb940f2133455aa46c6830ea2ac4544193007), uint256(0x2b908867ac48b5fe3ff6c0a55ec690dab640cbfbf3d97681af9c8885a9bd90d4));
        vk.gamma_abc[31] = Pairing.G1Point(uint256(0x11a01f08f4a2150e058376d4f9bd84e6e157a8c7895a34b2e3e164a1ab908586), uint256(0x13bcbcf86974bcf9b65c72bf34b9dfcef94a1d8bebb4790adfced205add9fa26));
        vk.gamma_abc[32] = Pairing.G1Point(uint256(0x0348384db3dd27e1d494b8b89c05ca96bf7ad988e801752f39a91fe2058ea683), uint256(0x089da3fdb780aef5c19d9ba4272bee0851496350dac258a2012daa1ced579e89));
        vk.gamma_abc[33] = Pairing.G1Point(uint256(0x1255c06c4b323a5ca226e1988dce90c114e101314e653e22b577e6e54c249187), uint256(0x02da8e464ac0b310992d2b60bd8ed4dd7478cdd3b9101a24441aac15b7b80bbe));
        vk.gamma_abc[34] = Pairing.G1Point(uint256(0x12a8ceb38601b192b9c752b84f06c4038e08f351c9f40cc72aa7e9a384b2db20), uint256(0x0c296655136a7c3186e9ecbf0857a3a0480bf75103acd3624892c54825274054));
        vk.gamma_abc[35] = Pairing.G1Point(uint256(0x1dcaade5a27a359b565c8e76111fa48bd13f55099866730752dbcc18fc72f63d), uint256(0x1dbb4988a21fcde1dabc3d2daf540faa7f8fd548a4e7ca3a8dd79cda66dca211));
        vk.gamma_abc[36] = Pairing.G1Point(uint256(0x2add4860b04f907581f67f223a190fd88631d0b974ae92f2991822f67390b615), uint256(0x0fea76dc9ef9831c8ee9fca7c709f22d63193120e4ff5c0f6214860f3d9b74ce));
        vk.gamma_abc[37] = Pairing.G1Point(uint256(0x29beca47f7b0c51dfb83dcd0702010c77062f548fe57e1645ff0751e171970ed), uint256(0x239b72573d82b8d79873a8dc0a66ed3767b32ad23bacdeeef9bd9397d13dfc6d));
        vk.gamma_abc[38] = Pairing.G1Point(uint256(0x2b534518e0b0c0d06e6e1128d2c0f35f2d8f5aff72a42752faec09c0fd74ccd1), uint256(0x29ede2ae1275515b3d0e6eac6a21b78a344895c9bc20bebe0d80f6f1890c1f03));
        vk.gamma_abc[39] = Pairing.G1Point(uint256(0x0d61cb88bbf96279219186f3d7ed714c49c6e8a72bd4101bdf35b8c97beada15), uint256(0x1b03d1f9b82ce97c7ddc2075049455d55523916099eda7ac37c0c64b265b69b5));
        vk.gamma_abc[40] = Pairing.G1Point(uint256(0x0aaf6973b40034dd6173e655082f826a47903dc8dc3599852f7cfc7040f3c46c), uint256(0x1673474f3654e665eece4120184f9c5a3cdd2f4d1104a81f283ccaa6a379b95b));
        vk.gamma_abc[41] = Pairing.G1Point(uint256(0x26229b238cad1a5f0cfbf7eda19f9bdb3995cae47338f48fe44ac5037eb1a2fa), uint256(0x21f8ff6850f71924e7d30606a1c5f3d4a1e7f88dc4e5a17cadb8343a100452fd));
        vk.gamma_abc[42] = Pairing.G1Point(uint256(0x2898930b4f6872bc4f54c71f98d1b564bb63aab487907d3c56193b548c996dff), uint256(0x282819865f59ec7f4da426c82fa8a1f37fd20ec39fe035e728a599cef57c9cba));
        vk.gamma_abc[43] = Pairing.G1Point(uint256(0x121fb38c4f4d29f8d78817bbc427809fcd4efe04c0fb8db7bc74366237c8c213), uint256(0x03452bec0953768f13f42522045110624a68cd5a6f3347b7f3eb70cac9ed6541));
        vk.gamma_abc[44] = Pairing.G1Point(uint256(0x04df5fe6bf4802ab4ed7f9584b9572f185ab649bd3972954febef109b3c86b49), uint256(0x28ba1a7cf41eab6a83567fe67870ee2883e39efba290b2b306ee31d845fa12b1));
        vk.gamma_abc[45] = Pairing.G1Point(uint256(0x049914ee0d439be47f03c25a8be5aedc8bd65f5179db0aaca2922f8f4fac5c3f), uint256(0x17acb017824c95db40f0f521ac193509c8b0b8d5c7ce17cceeef057f59ee4c53));
        vk.gamma_abc[46] = Pairing.G1Point(uint256(0x0152ceeafea38f6a8c2dfa3baefcaf96bc52c98f98eaf22702d60e958fa59926), uint256(0x05cc2066c2215cc31904aba395d99aac6b04f3df8a2b8f307b5bb943a299061f));
        vk.gamma_abc[47] = Pairing.G1Point(uint256(0x0f30884f3b30b4b48427a66848f4253bc574aa0577d7fc18f3349b2dc6e72f94), uint256(0x1597ebe004294bc4be39405e7648ce6f1afca0e85acd92e01de3149408dfc441));
        vk.gamma_abc[48] = Pairing.G1Point(uint256(0x1350f8fc44c0d676d4475ebe15b5b5e1bc8d0695023889284f3b2cf734549568), uint256(0x06ac3ed258fc4a844bb3a47f3aee76df9a255636b892e8695b20e165b3471830));
        vk.gamma_abc[49] = Pairing.G1Point(uint256(0x13c44a765e79c3d0409485090ed9a0ade570d96168be29d97fd6f5d9108f6626), uint256(0x1af64c2134f108d916a8bbaaa350efa04fb664c864e264e17387655a4981b89d));
        vk.gamma_abc[50] = Pairing.G1Point(uint256(0x02e474e29f013948fcf86cf68eabaeb9f8cd2499b44bbddfc7332e063a26903d), uint256(0x30250b35764fe3162150abd770c31c94db13eea0348ff7ee24a6ac3eb14c65e0));
        vk.gamma_abc[51] = Pairing.G1Point(uint256(0x1822d5e2af785d07d6df8808d577293bf968434a266b8813d0b0e4072f63f3f4), uint256(0x00d24bc7ebb3a86d30b15e86cc22cd163f8632abc492e012666f9f87c83ce77d));
        vk.gamma_abc[52] = Pairing.G1Point(uint256(0x2d89bfbe462143bed54c773f8b095966db0977b33dde18f4cd6c840abaeeb684), uint256(0x1cb41670670e6bc278e5062d54b18106f27540a3dd67d0e5672898c8e43faca4));
        vk.gamma_abc[53] = Pairing.G1Point(uint256(0x22884ec4309f23e5cb2544bb5d9298e989100c2b0559e0870ff7e045dcdd3e69), uint256(0x1538e5b2827e1ca3a71dfda64e17518daba94562a8fe7a0b2ec236a91fa64f1e));
        vk.gamma_abc[54] = Pairing.G1Point(uint256(0x2e39d556aff24ca68c5c61d71dbc8ae934f908c286678193e5297b1b6129a9de), uint256(0x13554db7e5409e16995361caff89dc23897e664dc109f205d045c26aab487646));
        vk.gamma_abc[55] = Pairing.G1Point(uint256(0x12d928918d891b3f8f6f3db349051e7daa110e1e1b6d40e4964d6d815e1bdf0c), uint256(0x01ebee1d50647c5d0e764e725a049824a8b9b3d8bf2e3f9492085bc24d8012d7));
        vk.gamma_abc[56] = Pairing.G1Point(uint256(0x1739d9f390db91591a9a1d661f96fd6412156ec3a14c293ab098fd63f3083dc2), uint256(0x18843c4df1f42ea833f906f5e0c229e7b726d5158f77a18300b89fec17201ca7));
        vk.gamma_abc[57] = Pairing.G1Point(uint256(0x060bb358840beae18be6b2ca75b748f393c9ad55330d48eb0f244f59922a0601), uint256(0x2e49da97ef7306dfd3a9f9b16a8066d6a56021afa9d4d49a997a23248f886dfd));
        vk.gamma_abc[58] = Pairing.G1Point(uint256(0x00d028d303ee517516e9741af5cd8ac5ff445b727c6b17b0df929108faedf856), uint256(0x2688c5ca713587843efa40384b0872aafb5376ea9a2e293034c2ea6e52de7912));
        vk.gamma_abc[59] = Pairing.G1Point(uint256(0x1d97dd7634189724d886a3d3909cba5ad25d10b46d3ea2da96eb9f8d5b9528c1), uint256(0x1d61c7959fc5ae0d44eb25f59bce13b264f55eed325feeb11fd59e8db571ab82));
        vk.gamma_abc[60] = Pairing.G1Point(uint256(0x067c23823ab6b6ea5d1d2d6c643377e486ffe525eae9e713f187e42c68766ea8), uint256(0x1be0b401a4f5058f6f6d8b19eae1e9f1b3ffd49b0a2e28ab818cdad0439f9c9d));
        vk.gamma_abc[61] = Pairing.G1Point(uint256(0x08b40ebb8d34f0388e13e9f7f45686c8ab1ebf00e963c2e415724e84e34865a4), uint256(0x242fe046ff26335f2b2f23feaa93503faadd62ce7e28b4110783bacb6e6a5c1a));
        vk.gamma_abc[62] = Pairing.G1Point(uint256(0x2d8cb5ee6697169b980836ba3983ee9718fce8f308f96249502846b88b685888), uint256(0x2eb0dad46c402e8d4206a8a7fa900a95dbb431cd2c1ee8a71bab0189cfd086e0));
        vk.gamma_abc[63] = Pairing.G1Point(uint256(0x12c6c1c5ef4fdb69d403f1275ab4769cd4fc0c5dfcc4b07494b33fed344da44c), uint256(0x149490945eb436e3c7067dba2f9d4a6305911d52ce4e1d86995d7ab78c012709));
        vk.gamma_abc[64] = Pairing.G1Point(uint256(0x29ef5e6d695ebed2a32a5fd11188a8ebe419ebe73feb045a6316063ad816f7b4), uint256(0x103fdfe4c4385535c3d116bbdd3785bfa9285a5cf096bfcae43d1d7414672228));
        vk.gamma_abc[65] = Pairing.G1Point(uint256(0x28be2d5fc8fe968824080a5bfaa37dd02ced8c8c055f61ea91902b1958b6ca2a), uint256(0x15348d11d17ea4c72c664a1f3b6908fcd0c2e926dea91c35782d5e0fa657e586));
        vk.gamma_abc[66] = Pairing.G1Point(uint256(0x230381cb445ae0839def11f0c081a4a9a5ac11d07bcad903ef03d458a65a7eca), uint256(0x28c0448a069241d490738c1ba3df0e3195ca9408b5d82308e122ddc72e6f47f9));
        vk.gamma_abc[67] = Pairing.G1Point(uint256(0x02b522e6728464faa9558b1f3f6293cf3f9ffe4ee2f86168e4d343b219bf9d07), uint256(0x19d9af7c3b80f79ee2315af0ee1edacc0c933ae29aff08db851bb5308527f0bb));
        vk.gamma_abc[68] = Pairing.G1Point(uint256(0x1187aafc513fcb7b1d21591a0e21cbfa8bc2df25314fb990d1b8e836a00bd16c), uint256(0x2255d51d6b594a097085aee4a11a7b63811d5defe91a9e67d08163f8cb1dcddc));
        vk.gamma_abc[69] = Pairing.G1Point(uint256(0x0e41b82a4840314f945d16b8210fbaee4fd8ee11f4a5ac4f26da649ab1080b00), uint256(0x2290afd04fa25c3e583c0dd7ec9a73fb3ea145f6d1b51f38cc268178a581429e));
        vk.gamma_abc[70] = Pairing.G1Point(uint256(0x2527c1094cbb7efce6b549d8d5c7e1f52519826913f08b3f9b50cd864bd867c2), uint256(0x1065ce542b905b128a90a97c47d7f58578db822f2a202727422ca4b98c840fb8));
        vk.gamma_abc[71] = Pairing.G1Point(uint256(0x1383d655682d7ea461ae2ee782e61c025eb0353eebcfecd76ec0689d86cf49db), uint256(0x10219c22b0bc5cb58e8583fdd698c777cca43cc28afa12b8ba62ebb6a302739d));
        vk.gamma_abc[72] = Pairing.G1Point(uint256(0x0ad3a722cc14749089a3b7af192909c3e625ea9a7cf630e6093bea3d7a241c19), uint256(0x008f48edcb405ba68fefcabc84000e9c2d2c6c5c8afd23db9fbd1f915678f9b8));
        vk.gamma_abc[73] = Pairing.G1Point(uint256(0x15c6bd5970f2720bcc7ab8d8a5f5d569cdc7f371915b42184d6dc4ad2d0a7942), uint256(0x24b4ba3e29b36546d74803eed242de4f42050816529cfdc63b698123f88534b7));
        vk.gamma_abc[74] = Pairing.G1Point(uint256(0x133ad69852b8607a7ca2526426048fbdda8631cff93a1a70348686af468f9d0c), uint256(0x00f1aa9d9f98b72b2cd0d6645a49808eca2d8f1c5e9ea521469b567fa3402611));
        vk.gamma_abc[75] = Pairing.G1Point(uint256(0x0c998397ac6817b7b135475c92db37aab9dca62b697db8b934fe38975dbabd80), uint256(0x2407105f4533a27a0ac2c52e7e1e8ff38cc5cfc6132e9437c544772314238469));
        vk.gamma_abc[76] = Pairing.G1Point(uint256(0x2ab1c89822cf820e3d6f7d6b962eed69ae4dea91262eb326de54eb8498ff079d), uint256(0x2c12273f7ac179223f0ce368d1b107b45d77eecc86a1a0c282abbd39591830d0));
        vk.gamma_abc[77] = Pairing.G1Point(uint256(0x02551d20adfda1ba32173fa9c1764f649e1f4138a0fb46be460a08b7afb7e57d), uint256(0x1ae8bfba1df94a8d2ccd5daffc43b75768546eddc266db636e7b2f10a71cdee7));
        vk.gamma_abc[78] = Pairing.G1Point(uint256(0x01a42c39d0e48ed7aff1b4eb3a9e0b865ff63f7a368986246db42ed9f12ab887), uint256(0x2578758e17753a618ae38935ebab2f376d83cd084feb1796908751d66c210b0c));
        vk.gamma_abc[79] = Pairing.G1Point(uint256(0x1e38a903e4e2b5940650773d5347651716f22782b00274a64acc963037d7e7aa), uint256(0x12c9881650fd3d24bb78d60b55a7896db76ec5a18a1d01086f9b43f9e9a5fa9e));
        vk.gamma_abc[80] = Pairing.G1Point(uint256(0x2bfdf059e37fbd719f42634605f8003c81393b36a9f613813c5dba7a107c2b40), uint256(0x1ff066d7fdc4292e63be146368d51ce66cdb43c09b7a017af8f7b5d4c64348cd));
        vk.gamma_abc[81] = Pairing.G1Point(uint256(0x2062805dbc3d3fe35778404ca2c31f97d7108b31e222f52af974e0db6fdc4b40), uint256(0x12ab457b27a41b061d97705c645ab272bffe9c350a9c0b1cc775167723f2b8ca));
        vk.gamma_abc[82] = Pairing.G1Point(uint256(0x2c0a871adbabfd236883e66883a127901ed0245121b9e93ae394cc985ae98406), uint256(0x14d47c4f7da699ef3f7c7c53336c3c78a250cd8a6cff8a7521043ded0cb8d9aa));
        vk.gamma_abc[83] = Pairing.G1Point(uint256(0x2495b38211b990102f537cb99007a07089e487e2714453472eb96c276b9e3e53), uint256(0x253413a3360d5e0f9ee0125d02465f839fc2ecdbd23c8e5be43bb062d0a448c9));
        vk.gamma_abc[84] = Pairing.G1Point(uint256(0x0f815cada8444c16b35d309af514694504df23efcfa2be4541000845d56602da), uint256(0x101c040f5ab3e0b913bc12d50774fb5b75dabb106d00d154daacb53916fa583b));
        vk.gamma_abc[85] = Pairing.G1Point(uint256(0x047db12e7ca7fbc14778252d97afc8e748bae30eac4d1bc1ff8842190ae28dff), uint256(0x22a3911f66d64aac4495fdd70abe00e41930394a3b7e1b0b617f27c12b609549));
        vk.gamma_abc[86] = Pairing.G1Point(uint256(0x27de592fb3e446b49d0aa1faaca1c7115a91d15e554e166ed2472f2cc0e9fa84), uint256(0x0ba0d1d1e121f6463005124b28f448870ecc0f02ee841a05a04d026655f8110d));
        vk.gamma_abc[87] = Pairing.G1Point(uint256(0x0a77f356e0556ee3650e29c7caabdbc5c6af382f8efe4f9f5dbc79903dfbadc6), uint256(0x0ab878701f7ee6e95a1cd414c5a001943c088c618ded86745b402d63c0e6cb70));
        vk.gamma_abc[88] = Pairing.G1Point(uint256(0x16f7cc98b63ea6d067275c9544c51e2ec759f01b55bed66b4a59466f6dd65263), uint256(0x0e2d60c108f183aa449754bdb525d82aab84e53c148c61cebfbe75e0d63186bf));
        vk.gamma_abc[89] = Pairing.G1Point(uint256(0x048e8aa9acc03295853bb0523b4c4763fc9e74368f327fb981c9025901681975), uint256(0x1491607e6c23ea90ccbcee8edc761aa2f5e08fad51e39d9f279c620447727201));
        vk.gamma_abc[90] = Pairing.G1Point(uint256(0x1cbd9edc8b9f55586c74939a36fa3665b730f05cd1ddf01c1cd25ec4564c2464), uint256(0x1073e4544d99578e886414af234e2cbc61776548fd506f9c3e8790ec71dbaa4c));
        vk.gamma_abc[91] = Pairing.G1Point(uint256(0x29521cae5ede6b68b8c2368ae2677fe6a53a14a5b0c7ba5c4cdee5ec48fe6e95), uint256(0x2c00e17422e83727338fe567d5b4e3810e55a95019f1f314fb7b2a112366f24b));
        vk.gamma_abc[92] = Pairing.G1Point(uint256(0x1e172ac2a530076b951a144c28fe66b81ebd2f20df0cbe6690aa5a8b393c0445), uint256(0x1902cba054b6efa986afc77fd9b648fab395fcd3ad0713657dd91a9c0a01831d));
        vk.gamma_abc[93] = Pairing.G1Point(uint256(0x24b3124d0f3b9c8fbbeaf223c79f7dfbc56c5dc8a761153cd1907d151b84c04e), uint256(0x1bbfea1aed037e0077f283b362418228c00ee85a1eecb80eb99668a529f54775));
        vk.gamma_abc[94] = Pairing.G1Point(uint256(0x29e8454e55d594800d52e99b9346af916a5ce1192a9789c2d686346587ad9d55), uint256(0x26de96dfc2b085d69706d93ef2fa83af2ff993678b459010348ae3e3c64903e2));
        vk.gamma_abc[95] = Pairing.G1Point(uint256(0x16f4bd3c12d3a862acd8a76aa40b5e43a424463bdcbb76634a0dce6cb67a6067), uint256(0x0480ec9189de289c3ed9264225768fbfa78d2748b5bc7486d79f39548735c0da));
        vk.gamma_abc[96] = Pairing.G1Point(uint256(0x0ebfe6d238ac0ce4d1e8f7a3e2de9c38bf8ccfc1d814044eca85128cf3540c11), uint256(0x0bbe65efa03243e25da1e41091142594d1c4a4f4e9e72c161aaa5305b1dddb6c));
        vk.gamma_abc[97] = Pairing.G1Point(uint256(0x249f3ee2619dacbd11b020aaf2b7fb271dd92754250a886d4ca148ff55f48f87), uint256(0x185cd08e87b90e1b922a076f49e3fa0ba815d91d9b40d49b1a62dfbd62decad6));
        vk.gamma_abc[98] = Pairing.G1Point(uint256(0x1b71ea817c3d36ba162988dfb0b3bfbd34f5bb40465be0e68af0503c5ddbb5f0), uint256(0x183c05c4568053f82d98b297c130f6fd0ce6471f120201b4cfa8e8ead8a08b9c));
        vk.gamma_abc[99] = Pairing.G1Point(uint256(0x0eb0594b2e5eaaeba331897163cee438b45111beb712c2377fe325cb1e8fd398), uint256(0x060ba87b8242b11a55d4e07451dfde970d737da354e10745f615f5db7a6ec2c3));
        vk.gamma_abc[100] = Pairing.G1Point(uint256(0x0f98dd03020ded326a8b6a1a60ab24fa2166b3dd07f40a95f6343e6cf7bb1fa2), uint256(0x2dea0f312f6fef5853913c14fd31211b9af993ca6a0991984fe8b65e5b167b9b));
        vk.gamma_abc[101] = Pairing.G1Point(uint256(0x12c42674c3f9b2f354524b8c098caabeabb8984deb8514837e510605ed69e801), uint256(0x2491705967313ad1bf793d6fbd770c3a2396d226d4aeb7379f6c101ad413cff5));
        vk.gamma_abc[102] = Pairing.G1Point(uint256(0x09943c2dd8644b3e8e52b2c047b502d169513186c3d2e5d19424e984fe790b2b), uint256(0x0e53b52d741dfa4a6f2815ee185cb8f6bdb383546e9f731f26694d342cf5926b));
        vk.gamma_abc[103] = Pairing.G1Point(uint256(0x03c9037c1fc86f807510190cf9317c15db3617866da1dfed3a9759ea2e76cff8), uint256(0x286066e3bcc0ce877f38887750a75fcdb409ffb78aad1c597405a8e0fba576bb));
        vk.gamma_abc[104] = Pairing.G1Point(uint256(0x11cebab8faa7d48c0fa0f75e5b1766d9de883f99d1facd99f3f3c1dde7e6b8d9), uint256(0x1186deb43be7319aa55ef7324879ab7f777158f17677e0bceae9d5a8ba9e56f9));
        vk.gamma_abc[105] = Pairing.G1Point(uint256(0x1ae9887f80d0b16c43805443e6bef78d3421cbc2fee633ce067cc2cc0873901d), uint256(0x153c26f39efc0f2b9ab1acb84d29e37eced95b6f9e694cb6b1480899b7db4e02));
        vk.gamma_abc[106] = Pairing.G1Point(uint256(0x17a26bd83351191d6a81a0b9aa21c516cf9cae6a567158e88debf86fa45035e6), uint256(0x191e48a3ac3321178233cd8abdc005d1797640b8a82d701d1724f95eb55e2c5a));
        vk.gamma_abc[107] = Pairing.G1Point(uint256(0x0aba093111eb452a62f95ab0fb3398b2e13b1acfe37afff877c0e1f6f4bef7ec), uint256(0x2a98b6e75fc80b31236bfedcc2230df6e1447e1513c3b0c95baa432571079f19));
        vk.gamma_abc[108] = Pairing.G1Point(uint256(0x10f6444110ccc32616c96e9750604a8d092f543f6ee71ad42f3d3cf6c62647fb), uint256(0x02c539364a29a76041f5af1997432f3bf8cefea7462cf3b4d0b8eeca3ddd3730));
        vk.gamma_abc[109] = Pairing.G1Point(uint256(0x212b26cccf152fb5d753ebe5903a8fa6723c295abd496f2cc428620381983a10), uint256(0x19d01263da8baf4737cc9d6f92d25ad6e47176e08713a4618a2e4cf8e9ad2679));
        vk.gamma_abc[110] = Pairing.G1Point(uint256(0x2cd5e7fed923a1daedd3be987060b18e8f6fb07f0407a755ec6936837b995b45), uint256(0x296c2d27127e1f829186aa6007dca629b1f78c42d1910147f2dd00c9d499a4f4));
        vk.gamma_abc[111] = Pairing.G1Point(uint256(0x0c21e358e20e37b73d72d4f965b7c71182c8c94feee9b64ad258c5bb83503153), uint256(0x008c32892663c20afc3890d46b844b2e3ef17133d378ecb8b52b83ca9bd1fdd9));
        vk.gamma_abc[112] = Pairing.G1Point(uint256(0x2c65a51ca014b31c934ecd1fdf1182ac80b17923e5f6c46218b57f56f3cac229), uint256(0x27f5d3a4e804c66f6828bce51b4e6cd7526d01d5c9661e1659119f58ab979dbe));
        vk.gamma_abc[113] = Pairing.G1Point(uint256(0x2306e4fac9b6962825f7524cfa1ac66113be9284a65c1412354ac566c0c846ab), uint256(0x0bcbbbb9157a67457efc2445ec224f0fc1ad593b4aa43a74111f222af4efdeab));
        vk.gamma_abc[114] = Pairing.G1Point(uint256(0x157e6c8eef0ad5ac1556fad122ae8ed2f6920700e280235d6f86d2fafbf468f2), uint256(0x16f30f2cc4f896fbf223273cf3202073368c22d524d901cca04ad3468e168e38));
        vk.gamma_abc[115] = Pairing.G1Point(uint256(0x1742dd556ede7312d2b758b2c06c9148d64b659b18657e1ddcbe8b2bbd62eaf6), uint256(0x178657e6af41a010f5d775901fd8ed73e64352b99b6f9f2e92a07d641ec403cc));
        vk.gamma_abc[116] = Pairing.G1Point(uint256(0x1d78377da6b72b58decdc46b260a68e6c44ed30ad99d1847bbe46542b4733682), uint256(0x1e418d5e4d0eac5b95482b5b1409e88ca66d6a53ace13dc07735dfa262ccc226));
        vk.gamma_abc[117] = Pairing.G1Point(uint256(0x17b07e91b96e3058f1f638318508baf4235d8e6f300a5dabd73491dc662b4536), uint256(0x1663c47143fe8355f9d00e3b4758cb84303f29e60e1f06ee6c1d751c31b01a15));
        vk.gamma_abc[118] = Pairing.G1Point(uint256(0x13bf475bc9fa4e249160df00cbce7388a53c075f5c565fd50d411b9a3972f32f), uint256(0x119e5060cf41fa2458f986a7546227a75b1a7e64fee52d8b81baa0509b4d4f08));
        vk.gamma_abc[119] = Pairing.G1Point(uint256(0x228e64aaea99c4996d09142949a3dde8fef9b6aad190160de6c6765d196a6bf2), uint256(0x09aecb6de224a4f36e982766bcdd35e2306bb1e54d0e10e93b7961981a2f8c5b));
        vk.gamma_abc[120] = Pairing.G1Point(uint256(0x1a8fd7d93ff0a8d218f647039b87c453a57db108fbf1a127dfa79f9af9ad82a0), uint256(0x2d7a676e82bf778f8c07222a068d3923190ebb15effdc7adcfd173834833ee7c));
        vk.gamma_abc[121] = Pairing.G1Point(uint256(0x10d3b5e75ad6399386102a906382550cefb1956f99e9f4567cccddd921765d73), uint256(0x2e802332821f4c91f2a689a98d9c624fa16904a09a52cc90a7ae9a8de19ee579));
        vk.gamma_abc[122] = Pairing.G1Point(uint256(0x24a8d69e71fb013d56f85126d6f11bb8b846cd16033bf29b8bf8e7c2b18c02f0), uint256(0x199ac62b41aa45e41a9d4d423d7572adcabe4e7154bca448570974fe6861a332));
        vk.gamma_abc[123] = Pairing.G1Point(uint256(0x0dd7a6f9cc71a3479016b46ed406317a60c030ca21d34d4119613338c567a333), uint256(0x20eb27827ceca9a7d5691c8b81d5692fcaedc1a33e99a11559db8145750b5f44));
        vk.gamma_abc[124] = Pairing.G1Point(uint256(0x16b49cb786783b4e2fbdc1df5db4931ce5155a644d6c0bbbde57b1ba84cc9038), uint256(0x1a1995442b9755d199b2a7279d70f14c9ef1b93cf9f6a9f2e5e2d9ea6ba6c245));
        vk.gamma_abc[125] = Pairing.G1Point(uint256(0x27a60ced95c8415d7146f231d7486d97ab315febba761dd2d0a1a45c4fbf88be), uint256(0x0082c2e4d5bb663cc1801d9c3342f8439438e69f8acfa5d93de19f160023cd82));
        vk.gamma_abc[126] = Pairing.G1Point(uint256(0x1ebd258478e3504cda7ee0c3c742ce5244311d7da4aa67b944b75a4aa944eed7), uint256(0x2705f2dbb64f26e05ba8a9c74487892129df7abb83da29d89c7368248fefbedd));
        vk.gamma_abc[127] = Pairing.G1Point(uint256(0x0a5cf12695871b9796b1e3a4e7f88b5b3d95f24be2efa1893fbe1a5ce1836e9f), uint256(0x066cb8ceb9e0457a065ada98a9b623cf31f6e77cece220cc21cd03d71d486dc3));
        vk.gamma_abc[128] = Pairing.G1Point(uint256(0x194432f4d8ae734e253ea51ec3dcdfe0dd5bdf17a6840e99dc8512d409fe9c96), uint256(0x013b4b0cf8ab4d6e34b1b66e3b944e61075af5d2d8eff626dd65e95c2d333787));
        vk.gamma_abc[129] = Pairing.G1Point(uint256(0x2d416e950dd5a274d4dc836aeac4ba57e0ddb73dc8d025d85eb2744468357521), uint256(0x1198070bd6d8fb6f1f89b7252c402dc13ccacf97f0221b43080ec9c3624e5b33));
        vk.gamma_abc[130] = Pairing.G1Point(uint256(0x29117057ce146d8925e168f5626f35e8a32efd8ca19c2304fe1357f41e7a9c2c), uint256(0x25b754c595cffcc35f3fdac9e2d94811a95898b143c86639f58fbf07138a16d9));
        vk.gamma_abc[131] = Pairing.G1Point(uint256(0x1334a9d44ac6684bac5c3eb549a93d28112676feaa85dc5838d1bf6bf1224821), uint256(0x0d82171f8bb5fe04641e854e2fedf251c0a4b142ee910d362dff20a4a07954e6));
        vk.gamma_abc[132] = Pairing.G1Point(uint256(0x2864cb8e703cda898837b202de8ffb2b1e39aae9566411dbd52cedd9bfcc7388), uint256(0x0dd7f911867e2a539b1e3c26bafcb7ca917312675246d2199f37bf1a4adaf7b0));
        vk.gamma_abc[133] = Pairing.G1Point(uint256(0x2bb090b2b262b55e3c1bc6ab8de23cb79517a633f46cdbad9307160f3fc13cca), uint256(0x295cdef4d75266ae60f1f911cf809518c54b81020991dd4e0b8ea5900e68593d));
        vk.gamma_abc[134] = Pairing.G1Point(uint256(0x157c55aae7ddd3087e4d9d8cbe04ab82d8cdbd72817f25fbfb27b125b921f6d7), uint256(0x1999b87c88c8b08f70b54e153608a11aafb0d926d3ed5ca8114e5eab1b6d4ddd));
        vk.gamma_abc[135] = Pairing.G1Point(uint256(0x135efdadb174e0830fbc98763707b872957bcd6e643ea95c8018ab3f9ffe865f), uint256(0x2867b5eb343b04b5136355d0f481d5427f4ba18c94beb1472d935493e9809cef));
        vk.gamma_abc[136] = Pairing.G1Point(uint256(0x28b93b157058bf61d7c5adc80659d80cfec0fec46784c897970296e93fe291a8), uint256(0x2a31b592deab233b439ea747ae350b7cd0d3e358e0977e283244908e1da993f4));
        vk.gamma_abc[137] = Pairing.G1Point(uint256(0x0619521ce10c12d055044f906729d08c5eb486ba10fb1ec9a9df7745819d11a7), uint256(0x054e06aa74ba76d443dce24acff583f9437954e83c5f1fe31f1529d4d4934bd9));
        vk.gamma_abc[138] = Pairing.G1Point(uint256(0x14d8a64a819200b62741b77ffd5baf33332e675ff1ded625cb6039e82917a21f), uint256(0x2276ff76de5a4c6b59659e115d7dab479539364cf47c631a93b38a1f2531110a));
        vk.gamma_abc[139] = Pairing.G1Point(uint256(0x0ea1569689bd89e1d6fff20dd409671d8903b7c5549b5a1cc09dd6b3600e72d1), uint256(0x16719a5f08e77493e112bc0b5168f88664f20b8557f92a2e213cb3fe747bb6f1));
        vk.gamma_abc[140] = Pairing.G1Point(uint256(0x1bbca627dc630c1692fd098a41bc7ac2bc9bfc3a3cef221a855ec728bd6713ef), uint256(0x105376f26f307ed095f0b5cae2074151da995e2c410782b6e74833006955d9f0));
        vk.gamma_abc[141] = Pairing.G1Point(uint256(0x26b29dd94ca707c816ff7e2f999b779630a9b554de546eeefe4561f48b72c4b0), uint256(0x050a197dabad57b6467c451bd0d1d00ddd64d5ee85ca9253ce45cf3d4041919c));
        vk.gamma_abc[142] = Pairing.G1Point(uint256(0x2c11de13ec2d9e75800a668dbd8885d2a5f4b6068998b7617e2567d2a44d018a), uint256(0x18a11b99b81ea34c48c67cb5f186b1f9ed2bd219d92a17d41d73748e695eb05e));
        vk.gamma_abc[143] = Pairing.G1Point(uint256(0x07c012d18f0797cbd4f2c8b8212c7f5a53bec708028486a77eff420ad1b1ca46), uint256(0x1337d11c7783280da5ab6f93023904a31746135a14a186adb675c06929f5fa1b));
        vk.gamma_abc[144] = Pairing.G1Point(uint256(0x16a72c93c991c06c3d5d2badbfe7db46fbcaa011cf4c02723513d35e1940e4c4), uint256(0x1f2eb4ffdad7633bf0125f08162e53c5829fbeda4d9fa7a707eb58048aa07ef3));
        vk.gamma_abc[145] = Pairing.G1Point(uint256(0x0c9e745519a311840cd4261596dcc689b8b1cfadc8f219a917751763e82ebd7a), uint256(0x07bb64e25a1222d6616e060ca5bf8da76e2e65fe0cc97c9706c6f6e80848d063));
        vk.gamma_abc[146] = Pairing.G1Point(uint256(0x2ebb1fba5d2dcb34e7d3a31ff6253e01eed8c74f86d5110d7663ede93294f081), uint256(0x27dfe6a7dad390d984b6f699bb4ff822f54fa173219a67510bd2d0fbb128e5b0));
        vk.gamma_abc[147] = Pairing.G1Point(uint256(0x2853de3738037a1e5756b005d6d2836ba0808e44f8571fa091836da44677360f), uint256(0x2ab7d75fb889e62d13e0d74c2c52096a2255aa239d8ecf3be3b0f3efbc9b644f));
        vk.gamma_abc[148] = Pairing.G1Point(uint256(0x1e1a0b66e8ea545c6cb405e7b09f5dcb57b355c606cf38c3c2ea3f5e8d502586), uint256(0x2dc67ac3a4bf46afab129f4ebafba62b6176ed3ec8a662e3ab7f7f5433cd2292));
        vk.gamma_abc[149] = Pairing.G1Point(uint256(0x1118cc39337c514f18b4e4fce0998c0892425137aea0f8ee3bd0981c34b21173), uint256(0x0ce4ce2edc5ad43c4ec59b5b67ed947f110ebcafb3440fc6906702f8e9878eea));
        vk.gamma_abc[150] = Pairing.G1Point(uint256(0x0627040bd1dcd7c7ef232047c4aa895b0a2fd260c7a7048f62bfae6d6d7512fd), uint256(0x074a558632b09f5b472631fb4deff6f59b5beb19030565a0d8f02d8dd806912a));
        vk.gamma_abc[151] = Pairing.G1Point(uint256(0x2af5e16ae914949b9df56460d975cdcea2c9477db99057f3aea807c9580e75f6), uint256(0x1b2605915ea6a0660ff809559f358b684a9dd4be49ed3676691edb6958c74138));
        vk.gamma_abc[152] = Pairing.G1Point(uint256(0x1c06328496434600ad4c6aa558b7100b471426260d28757abb958c4f22cc75ca), uint256(0x257e169a66e05f6d1f6ffe3d603939821a5d1c5eae530f368ce714c5915b34cb));
        vk.gamma_abc[153] = Pairing.G1Point(uint256(0x14f7285a04b364130e27b2dee41134e16352cdc9608fe9770acea1275d343087), uint256(0x1ce5833fc634eaf1ab987c9d5a96e824ab650f849647fd17ad8204796c9208a6));
        vk.gamma_abc[154] = Pairing.G1Point(uint256(0x06e9977ea5ba053ad2f64c437d7a41c06af05a6eb276755f6cf026fa67301be9), uint256(0x0bac295370cd81fc682d8474b30794564b3bb0754d0a1fb4531576469fe2734a));
        vk.gamma_abc[155] = Pairing.G1Point(uint256(0x0cbcaf538e5df4289aa29d739ce10bd233a78bdab7fafbf714edc784ae0d0476), uint256(0x23570dee2da0032b74d6a7453b32f4ed4076fdcc8aebf1fce2e04f52446b64ff));
        vk.gamma_abc[156] = Pairing.G1Point(uint256(0x0753cced53444ca31a53e2798d5b5df3c411b8df4ba0ab1504255d5c269c8f5a), uint256(0x132ed32cdfc108a8c2d22844af1206ffcda7a0e2b116dc57a51d0e8f69e0426a));
        vk.gamma_abc[157] = Pairing.G1Point(uint256(0x20c99ae07d54e272f300b36fb0d6f21df3722f8ebf08b0d64fa852c899bc62ef), uint256(0x2fe6341d2e2c3a4bc3f91486b4a5ca3562030564c9a559845951fd83c6ce3ebf));
        vk.gamma_abc[158] = Pairing.G1Point(uint256(0x008e76e13fe002a5491795aaa8a70e6eacdc18fea02ca3f36ea5d39f28700acf), uint256(0x24055a798d6a6273fd6a154367d2bb886d00b50eccaadac2e80a479b381836d2));
        vk.gamma_abc[159] = Pairing.G1Point(uint256(0x2ab39d787c78232a6b1d337d783f0169b89a79ea225641b4f71b988fd947a787), uint256(0x241fb3724b1afc58fc18a1bae11950a536c82be28e2b75887580e1c2fe466df2));
        vk.gamma_abc[160] = Pairing.G1Point(uint256(0x04d1edba27cafd228dcea1eadf18708da85f40b3aa787cac976ff9c9befed940), uint256(0x13a6d8bbf51a403008c99d0d634cb1bedfc2c6747ea21255f3d1636409ea927c));
        vk.gamma_abc[161] = Pairing.G1Point(uint256(0x19ee57575d5dde25a01bae4bd82d09b0eec77a2130078bd13e9a9bbe2501117f), uint256(0x014fe3cc2fe0a0734d906b2d7c72020cdf698d035dc2d452d17d493cc4f5564a));
        vk.gamma_abc[162] = Pairing.G1Point(uint256(0x052f5ada70331a7703c6477390b5a8f804b99e66deb52c95c8c105741214832f), uint256(0x27feedf41d7727017c64216393e3600c1f29db7f594cb9383753d18859e299cc));
        vk.gamma_abc[163] = Pairing.G1Point(uint256(0x182ee9d28b9849c467c63e5b20942bed98a69aa58136f8a2455103a525b95c0d), uint256(0x02753cda5bcce793e4be3baed6e46571ca0168ca7aa8f997594b63ada581e517));
        vk.gamma_abc[164] = Pairing.G1Point(uint256(0x1775e14a4946f51eb087dd128570df28abc22227b631d8651a22bbbaec5ed4b9), uint256(0x038fdedb2fb5916a6f3ff0da98ce635f2bf54934d307a237cb77939e31511f06));
        vk.gamma_abc[165] = Pairing.G1Point(uint256(0x094b14166132fb0b639f846e2df9a9712bfa2642ebc3d5a53fe218eca33a1bde), uint256(0x03e61ae7aeaa9475662e3ba1165a1b0cdbb017e982aaa4081af0cb3afb1655ca));
        vk.gamma_abc[166] = Pairing.G1Point(uint256(0x2aec5870d09c4c50fee33beac5ad49ae2e980b8c8e2246d3e0386aa483644388), uint256(0x06e89ffc6b8701087bd489271ad7c6eda5007d6413202f5d28ad8ce1be84fb8d));
        vk.gamma_abc[167] = Pairing.G1Point(uint256(0x2e3874a8fd6c6739d8ca89a0e8c3bd6fb3bc829f9bf619d9256f03f2f2fc3e5f), uint256(0x1cbd42f1fa8093b4e747eb8a1b7cb83f27d653cfa3730ff0a75904a643fac2f5));
        vk.gamma_abc[168] = Pairing.G1Point(uint256(0x07caf7c3674e2daafb1d855943127f7e395b3b353b9d57b12dd2194d1e2a373d), uint256(0x1a4caeeb9e45d172189b62d277bdf75c32b10526a79820bdab3f09064787472c));
        vk.gamma_abc[169] = Pairing.G1Point(uint256(0x27dcccd24bb5ff5a0fcfd8fb05060e6f87fb408815b1d63fda13b0f809a4632e), uint256(0x02c4008fdf2d20d83a78e9ee4c7a7597490e988a360ff8dcb9dbec7b3c673c2f));
        vk.gamma_abc[170] = Pairing.G1Point(uint256(0x22a984848dccfe8bd0895f76ae91eb9f280b2b005ef012a94660c7bf31c3288e), uint256(0x2bbb705602959f4974e4a00c8ff6ca936f8b048b1484fe31bece4979e6857503));
        vk.gamma_abc[171] = Pairing.G1Point(uint256(0x006c525568e48c27512b2268029829177d03b1a768f5fc78b82f9a66ea5351b0), uint256(0x15f0c797d0d64a2f7bf670d129ddfe7e7db065cf8e007e0d55393a6395937769));
        vk.gamma_abc[172] = Pairing.G1Point(uint256(0x22224c9adab233f5b366080a70267e84f839438afcb383fcd7935887ffb8e48a), uint256(0x1d3abbd15a0cdca0dca418938844d7bd197dbac750ce3302ccf37ca17e851fd5));
        vk.gamma_abc[173] = Pairing.G1Point(uint256(0x189493e3737617b477ca2bad6cf8a1943aff7af339549f200ad524247cfa98c3), uint256(0x122f75a44b2645ba3ba3213f3abc66a558e2539cf0abd7626008a39dff21f5a2));
        vk.gamma_abc[174] = Pairing.G1Point(uint256(0x03f8a4929582d94119e4a605ee577b298fac9f3f8f090fa8eb8e72c9a7c2aac1), uint256(0x0dc518a598083302108256b6c0ff1771d9514dde8393ce0749bb8edd127da9ff));
        vk.gamma_abc[175] = Pairing.G1Point(uint256(0x088426390c041a67e3627af5f84709c66c025fbeda701edfd34ecafb3d964c45), uint256(0x1fff26f5dacefdba1df7174e29a8c164758a1f762cfc0187e17d794dfba9554b));
        vk.gamma_abc[176] = Pairing.G1Point(uint256(0x2efa98186f9b972bb3a488bb79c8d6802cc77c78427cc57e6aa5ee00afb6e401), uint256(0x0f1cb4dd608377847d8ed45f284d03540749c71dd61600d801e6381638c075a2));
        vk.gamma_abc[177] = Pairing.G1Point(uint256(0x26abed0eabb184aafe4d72eec6e7a6a31d0afd72389cbaa46dd346d79b1dcab7), uint256(0x1e61dbae91181e9c3dc3839b8aad51821bcf4b4c95c28a7d773c0eb8c6f4ee8b));
        vk.gamma_abc[178] = Pairing.G1Point(uint256(0x1ced6dfde9dac7cf75fa3a3fbd36c4a3e142c3810330a59bc2bbf2a002455622), uint256(0x1bd64d02b086d7ba75a2ffb5da9fd076a7cef4663088b3ae46e3d2068fad40a6));
        vk.gamma_abc[179] = Pairing.G1Point(uint256(0x1e67c807897ef92ef5a1285ad3d230224a2828788dff7c1ec97d93d02397b774), uint256(0x0af05b44c48de265982d03c843a81c508a2ae217a49edbdf32e11536a70c4e7c));
        vk.gamma_abc[180] = Pairing.G1Point(uint256(0x1237881706618f79de9a97d4d69c5cd643e71a19c5715e5a8033663c61e16cfc), uint256(0x26f97a5e343efa54be4ced20dcc5b3cb7d3e4efca09d9a63134fe4db77872200));
        vk.gamma_abc[181] = Pairing.G1Point(uint256(0x16007a28a28c1cd738c0144c46845483613393f26b63428811b6fa1967bedde2), uint256(0x21394b98757de4b55e65b3ca894d956cc71ec4fafddbd0629544737fae8211eb));
        vk.gamma_abc[182] = Pairing.G1Point(uint256(0x02cbdde827fb7df31544efe4c8f597f81389c5273e03d55818bf7da9550c7fce), uint256(0x18a6492c713a14c05c817b3336ba337b199111f7a1bf64cb8c5e91e459eca73b));
        vk.gamma_abc[183] = Pairing.G1Point(uint256(0x24f5c0ee90daad6edd201f2cdabc53f278b5914df9da62a8824e7d9b080647a6), uint256(0x0e5a422936ff5d97adf084437199b7d8d5a6ab38435279a5f6bcdb5424b3f6fd));
        vk.gamma_abc[184] = Pairing.G1Point(uint256(0x0c815fbad4eb0b5c05254f33ec20532f5fc44f661d63f8712ac061249cbd0b97), uint256(0x01bd99bb8455dc223ea3bfdd6b951e65f1e25cb52b3474d3a406a558ca2e65ac));
        vk.gamma_abc[185] = Pairing.G1Point(uint256(0x0024603af0d0f2b31b978fb5d852072737714aebd1a1b540e756723bbd72c3ba), uint256(0x196d79dbc58c8df529a6f17d3b37baad3f001a9324a7d0c5654312ff36b253e8));
        vk.gamma_abc[186] = Pairing.G1Point(uint256(0x2e489055962dfc341919ef3803565ca81c662ef35c29b976545be7494cb6a42d), uint256(0x2ca43f44e1fbfff976627cc2e7485e6c39f4bb6cff61a3dcfa8c014f57a6e7ae));
        vk.gamma_abc[187] = Pairing.G1Point(uint256(0x162975ba5e98adba1654be9eb7af09a1c809938b3a26472d057eadd834b1ccb6), uint256(0x2b2ab30c371a6a280f865590ea078f53353d89ab95e6bba01c820cf5abc5331b));
        vk.gamma_abc[188] = Pairing.G1Point(uint256(0x1124a63907da136a52fc64ba972312fec94999cea3c09af0db71f023e077494d), uint256(0x0db3547eed5d5b09ce3570b2dd069188814bcdca5662e68c7fd081b5ddda417e));
        vk.gamma_abc[189] = Pairing.G1Point(uint256(0x1382dcd64365b3ebd48af5b7eaffabb2c3333d67f35c196033428bdf3dedf35a), uint256(0x1786f7817bdd0018dcc5f49826ed841dd805e541d7ca680c09804734bd2c92e8));
        vk.gamma_abc[190] = Pairing.G1Point(uint256(0x18bf42688ef58be79fffe9424e37df5a7bc4852482e0735740a8df666a3e0976), uint256(0x20c833062d3228619948f05054c94cb2a2c164358ea621e659d697373004c3c4));
        vk.gamma_abc[191] = Pairing.G1Point(uint256(0x0667df98abb07bdd5bb301c7a56e7b45e04269885859977d3bbff03f4242c694), uint256(0x0e231b0e01aea61c3ac2243c58e908e1f0121fce0b507ce1b391bb55fd668cc5));
        vk.gamma_abc[192] = Pairing.G1Point(uint256(0x2527cb940860b7e0aeea46c190104ba7e37ac5bed461d4aa6efec56d5bcb3d6b), uint256(0x0eedacf28e5f29c8dc15446d9036d54b87271e99bce28eec6784585eadbcdfb9));
        vk.gamma_abc[193] = Pairing.G1Point(uint256(0x1c005530812559e2702e07662e23fb622cd8085bc2c2d1289a7ac38360d3dcb6), uint256(0x1bf9cf34a68fad2f2f79bbfa35a5f22d9bfff6826f346958352a9bf0113dfefe));
        vk.gamma_abc[194] = Pairing.G1Point(uint256(0x04dd8664cd6ecd2f9f74cc3f8e9010250e416e76ffc077e2ad0554a5dbf67dc9), uint256(0x0c202176ec8cbf5e665665c93a155c365442c61334ae9ccba8f98f8dd4e9975c));
        vk.gamma_abc[195] = Pairing.G1Point(uint256(0x2bbe230fdf5629cd7be2c704a2d267685be1822b5d4bb84a5c574f8491f41ea2), uint256(0x10f627a6613619c89a1a38971b784447daca2e99869c793434ba977e07da0aba));
        vk.gamma_abc[196] = Pairing.G1Point(uint256(0x19a968cac5b609b697e1d4ad15cf511327ed2d5609bf82ec84d157ba926164cf), uint256(0x086fa5c2cc346c4a6f7546f661ee29dc1d674d2a4fb953c744b49a2590a3c855));
        vk.gamma_abc[197] = Pairing.G1Point(uint256(0x27d2db699f8a49947131c63771316b4aa299d55c0b48e3b85747a436be090b2c), uint256(0x285bdbb50e3e19460119a9e35ae1c60d6ba082688a7c50bda33ce368691c0378));
        vk.gamma_abc[198] = Pairing.G1Point(uint256(0x029f1ae73cb6bcb879f5d3a2017235081e3a7e2f5e26779ee5c95509ee645887), uint256(0x0e58d961ae348739b50c6eb5e7607163478b0949fac35805db9a12024790d2cd));
        vk.gamma_abc[199] = Pairing.G1Point(uint256(0x294e41d2957f35ab14f84147500d2477071a826b21087c61865d45f7a3feeb18), uint256(0x226ea9a3b8e50a57cd2655b91b5820cfc1cdacd9cd96e25e25da9ef17d3ef502));
        vk.gamma_abc[200] = Pairing.G1Point(uint256(0x275654989b67a900702b15d1e3d42e6afbf02004c1f1f5a8b96ebc83b62fb2a8), uint256(0x2fb86f6f854c67b105f14b0e3448ba5696cd84ee2de555ce9bde707544c9a788));
        vk.gamma_abc[201] = Pairing.G1Point(uint256(0x10604a9887622c14ffdffe90b60e490e840da809760772d1b82fd186aef330e0), uint256(0x2a44c3b1ce2e79ff2b85c6a92d5a2b0b32a82cc660c52bb20b0c65de3db1bde0));
        vk.gamma_abc[202] = Pairing.G1Point(uint256(0x0867f1a9f691e5af355ef6274883eb3be6b65acd6e4c9c6b1e1b89d938bfbb9f), uint256(0x1a423320a76f7129b1520938801ab1ed4afffdebb53a23bc434f5b35430edc3b));
        vk.gamma_abc[203] = Pairing.G1Point(uint256(0x29d7165660ab1b725df8dc80b06610ebde7fa99850c4cc20921d3377ff9b6210), uint256(0x0673e811b2b3f6d68a3b0dcb324f9d0b624ba6d1c9b5499ba7265afee5394cb8));
        vk.gamma_abc[204] = Pairing.G1Point(uint256(0x241dd33242aa84dc0adfdedec2bebc41b5dc49bd263c751fa99b29486d831df3), uint256(0x28ac530ca522608f18f17a5ce6b2ec756b697196aeb217b78ba714dba43a09c2));
        vk.gamma_abc[205] = Pairing.G1Point(uint256(0x0e6ce5a7d203ab4f2002a149f00e6dcaf0b97a2064043acd19c2ea049f3b67ad), uint256(0x11e4a6780eee736bb7bc406f66575e1f91f12befbc76ea66c0dedd26c435c568));
        vk.gamma_abc[206] = Pairing.G1Point(uint256(0x2ce4b2c1ceaf4a2a8d87afc1b215459e13adaa5e905bbcbe6bb811760b230b67), uint256(0x1565c49c80527a9541190b0655f8089b37894369fa55d5e4c5d9aa49a787597b));
        vk.gamma_abc[207] = Pairing.G1Point(uint256(0x1a7636dce3af2e15bc96b6b47305deef175629205e30e381b4f29e95dcd646b3), uint256(0x21130d85f3a0626199c71bcaf6e043cf40bce2fcaf30b3279e3dc503763f6f5c));
        vk.gamma_abc[208] = Pairing.G1Point(uint256(0x2ad38164864937c2e0baa31074df25c3e7621f90ef7cc67fdfdd7bc8d652eefc), uint256(0x2e848179af8a1181d148fc18bcbe6198f85d2c65e79f2f1771bcf018121d1d59));
        vk.gamma_abc[209] = Pairing.G1Point(uint256(0x2806c4fbb8cce4c2711ae2310e9367efeac14d71cf617c7101662d30ecf5c43b), uint256(0x26f31a0e166fd0a9f941cce0910f870e145633cdc6764a7bbf50a580bb5334e2));
        vk.gamma_abc[210] = Pairing.G1Point(uint256(0x2615c2a58d9d3f0dfaa7eebf108a8696a0a4f2a1a0fbd497643b0db5f92b3c16), uint256(0x2b181feae18de7b6ffc8a58d101a6d76fc6a56dda9b88bf5ed2c52e8d3284be2));
        vk.gamma_abc[211] = Pairing.G1Point(uint256(0x269b2eb7b2facc5a56f8c4e8bdb98e2cfde83cfda034740709078eb91b610979), uint256(0x1df80faed334217da76979b294fa43625d7c42853fd1ad63512a1e7751cc8931));
        vk.gamma_abc[212] = Pairing.G1Point(uint256(0x190f7e65f52743ee1fdef7ad5ef47f21ed1589717a5c414924c507240cef0707), uint256(0x210a946bdf46fa089e9912e9a5d4cf0113de6bca8284b4cb81236d6e917d0305));
        vk.gamma_abc[213] = Pairing.G1Point(uint256(0x27fd792a7ab4c3b9354df62e7452cd92d468e224630b2ac39cdf2e23d30bd095), uint256(0x197d2bf45da172331b6b519a89f16c23dcdd3607d52b91ae373b321602f32c69));
        vk.gamma_abc[214] = Pairing.G1Point(uint256(0x065e45cfba7700b29e9850535e2a658816735628cee1eef426c74c9b548b774e), uint256(0x02140cdf151f5a5260c8d6231515d41fb9857f62f89c6158f429362534301331));
        vk.gamma_abc[215] = Pairing.G1Point(uint256(0x2467d487cea76da6ddfa6f496c11f9e8bfdc0943d5c9def2f47de2817e7aa7d3), uint256(0x19973a091783d20f4d96f1448550584177008881befe012099214f963c791083));
        vk.gamma_abc[216] = Pairing.G1Point(uint256(0x01f46639130c62dce46e0a5656b650bf30eb20b62f5a2f0c3ade6d0ac26bf1f5), uint256(0x11bd7335da21bbc0d2cadf907a9b49aecdfc7a4904973dcd09fd0d4c8d1b49b6));
        vk.gamma_abc[217] = Pairing.G1Point(uint256(0x136ac2804f2d61069a030fcfd28fbcdea2d116f96b40f9edf4ef3e3b957ba875), uint256(0x0eb24db4403b53bc51c18cd0657d9d1dfd6399be6b7458674011accdf24036ba));
        vk.gamma_abc[218] = Pairing.G1Point(uint256(0x0d119510553b8974e6709cdcef227a8db6f88342437d030d6075cbee5a4722e4), uint256(0x1ce4f5e93eddfec82e257002d87727bd2cf2cca7d32f1b9a0441bc53aca80411));
        vk.gamma_abc[219] = Pairing.G1Point(uint256(0x213f8129db7e4fd4d9a4a3d5b215c87fba3190188961246e985c4a61ad8f9886), uint256(0x1a74bb9b1274bdbc7b429ba6eb5b8f9f844684df0ad353e6886007855404dd1d));
        vk.gamma_abc[220] = Pairing.G1Point(uint256(0x01104e2845ea7972722a4e390d4f054ff6872099b14bbb9bbf747745816160be), uint256(0x26b33b96f0846f84452fb2ac36cd4031a1de250bd9d822e38f061d44fc63035a));
        vk.gamma_abc[221] = Pairing.G1Point(uint256(0x04a05acce018e76cd725848b0794c2ca40b7171431b8cb318e8d5f4a444a52bf), uint256(0x18acdcdfb23ef39f83d385a45c03e2099225bdfb30bb6c986738639cc2da80d6));
        vk.gamma_abc[222] = Pairing.G1Point(uint256(0x1eb7fd8520e77866541a637baf1ad35f69602ee2b40e2c9fe34c51cfd21e3c39), uint256(0x24bc348cf4794ab13525fa322222831145e46b13377e551a1249b186146c367b));
        vk.gamma_abc[223] = Pairing.G1Point(uint256(0x030a5e530a4d74c04fffdee68a5fc2b04acd880e8adec2b9e94a2f7683e825b5), uint256(0x03d5b3ff3af967e277a54a1fa20f4e6277c21796d1b80cc6aebdfffb207e8f2a));
        vk.gamma_abc[224] = Pairing.G1Point(uint256(0x108ca827e981e2d8216a913134176f821f1e52ca044e61752f260441ead38606), uint256(0x269486bd73a037058b5ed1dab352698cc805eb94774c8a3704ddfbe40d0fdd86));
        vk.gamma_abc[225] = Pairing.G1Point(uint256(0x289e54f1120271230f9b25b4dfa2c8086e5257a225de913e4608683f6b679574), uint256(0x204c87d05cdf20358130051d2f939b4d2a3913add72f28d8487f1e8378e8dc27));
        vk.gamma_abc[226] = Pairing.G1Point(uint256(0x15106142dc2e63cfbe7088479304777a5d282c8a343169a8c807e3901a029d8c), uint256(0x163c7dbbd39df8df983f22bd0d3105e5c497447e24634babaa2240c7041b31c7));
        vk.gamma_abc[227] = Pairing.G1Point(uint256(0x148bdbef1103c1c3cc165f53091a0d0dbf53b950a3db8e1e53839d0b76618e7f), uint256(0x142f20cde79af3f84765201b225371df9e1f2d424975e374dfb37de00d9acb28));
        vk.gamma_abc[228] = Pairing.G1Point(uint256(0x12df8519a54775ae140eba696a4f480b38ab1977fe8827ef6f5c2789cb032a86), uint256(0x0778d9dd292d8066836c07524371f35cffaa27b5f5ee70b016a0b7ab2cee4004));
        vk.gamma_abc[229] = Pairing.G1Point(uint256(0x281a3857608572d11fc746c2c3e6bc6398bea496d8a18fe8d5243050930780d9), uint256(0x034a41aba45bf10c1ee27f9a8bdda7c71490751595f4902ea3bbb244354afac8));
        vk.gamma_abc[230] = Pairing.G1Point(uint256(0x0e31acd23ba464a95ce553049c40e79a7e30414a9f99690984d5e5a92a3a07a6), uint256(0x1a5e1641be963653ad6205e54717a98ec3ed6491c76febb3a63e1cd89a778cea));
        vk.gamma_abc[231] = Pairing.G1Point(uint256(0x21c6009d3972f08ed6071f155a17c4cbf99191b3e00a77b7e7e1956e7616d4f5), uint256(0x01b85edf9f6308363c0bf9007f7292294814cd06d4239a556c53d57de7f9fb64));
        vk.gamma_abc[232] = Pairing.G1Point(uint256(0x0948afc17ceae782421049bb4638d3dd041e8f0dc28e5d39463f6672cd42728f), uint256(0x01d75d6189ccfd431753ae7d6a7429a8b2ee51598052de621b04e8baadb0dd69));
        vk.gamma_abc[233] = Pairing.G1Point(uint256(0x22d4e615da78de727f7afbb3748e2bd90907867319af1a18e10b813e37703f1c), uint256(0x11df89239eea4869ce63e6ac66e34fc1ddf89937b84b67913aa617c198e844e9));
        vk.gamma_abc[234] = Pairing.G1Point(uint256(0x1963146f2f728460c57dcf8440a0ffda316d2c5e1092509e0e611dc7c6af4d65), uint256(0x062d3b7290ffe961f3f3294a810339edf3784c53c1e7388addcf7c1fad50ac2e));
        vk.gamma_abc[235] = Pairing.G1Point(uint256(0x1b1fa0db08e38690f9f62c5d01f46031c831b34e2a9ed734edb2b112e413a003), uint256(0x062a7bfd47282bbe43674049dc2a531878fd6a47b5fc63e723d052b8c6f144dc));
        vk.gamma_abc[236] = Pairing.G1Point(uint256(0x169fa9a082558db9a01bc910208c937fdb18cc63851d581ccbe7a8786ca7b0c9), uint256(0x1fb9e1c78328d858c96d2356dd58f754175ade7f0b00b7583312bd9ff8bdcd42));
        vk.gamma_abc[237] = Pairing.G1Point(uint256(0x2efe89e9c3ff67bc29bc2bbb4cc5ce5588aee435d9e3f86aa20b77760d7e84ae), uint256(0x00d234f7fc9ea34e2383964e21441b21478a86d3e36bbd7078038e465ddaac99));
        vk.gamma_abc[238] = Pairing.G1Point(uint256(0x0f027573e627a9baf421e67a7f8c779691d320c7f5752ab1e1ea7053262ff496), uint256(0x1563f641cee83bbe8632de3de6708cebd5de2a6993ac00db0c2182cc081b85f0));
        vk.gamma_abc[239] = Pairing.G1Point(uint256(0x235d232fc73f0a19cf431be8cd58f1ea897e704557d5e4b1f25fc192889d9827), uint256(0x15c7e83e8ff52dd329c169441e697a62b80e1165472ef56965a8ba3a607fe1bf));
        vk.gamma_abc[240] = Pairing.G1Point(uint256(0x2ba5bf1a680b5423df0c75a087f8ba184505932f8a4f42af3c255df5b53ead96), uint256(0x14d0c28f2b25d49692aeb5ae8a98c1d2c3227ef99c24c21c3c0b5498b45b343c));
        vk.gamma_abc[241] = Pairing.G1Point(uint256(0x2022e62346fdd7de23880ac3196542ba6f57b2bbd91c1c08f9631eab40885d41), uint256(0x02f9b872b8c967dbc437158e70559388a6a56cba2abd5c418748f1d0d8a45c6a));
        vk.gamma_abc[242] = Pairing.G1Point(uint256(0x17d734064e2143a276e4091534b7fd65be28faf78ab3c475ff5a072392cbe70f), uint256(0x29443963babf71cff2cc5ffa44bbc75bd7ddeb218512c721a8ea95d9af31f14e));
        vk.gamma_abc[243] = Pairing.G1Point(uint256(0x21e7d15d7b3f37cf42e6394b15ea6bf2cf47aadf2a63eeefbf167c4872ec7d0d), uint256(0x1938b73192783b8abaceca5434adfbea4de96f301f721ad3546300dd8214dd60));
        vk.gamma_abc[244] = Pairing.G1Point(uint256(0x00e97e333559d2463212a2801ecffefe5431b6df0a9315952cba90e74075c2cf), uint256(0x23c0da2bf8d501eb7c97f9e40427b609bde29f64bbe60714deb053b2e20c0838));
        vk.gamma_abc[245] = Pairing.G1Point(uint256(0x00f82c3bb52e6f0087e57bc6fbf2030afe0e310c70111a893de8e0e040bc77dc), uint256(0x12d5a420e27f2f45a2e1997c3cb27432fa5d8286ec164337428d8dcf629f1b02));
        vk.gamma_abc[246] = Pairing.G1Point(uint256(0x13861a914a965c870791d01185e8b094cff97c1d7f6a60b7c0899651f77b88e5), uint256(0x2400599152bb40acfafa9fa89fb8085f1f6ee3318576f85acd59f2aded5dd3ac));
        vk.gamma_abc[247] = Pairing.G1Point(uint256(0x2b05c12228c35f41f68e1b3fb643a26a2931ddf5552027efcb7936113c7d0a4d), uint256(0x22485742e38f0849dcdbb65d4123648f6e2b5887fe6603282d8da1939bfd2c9a));
        vk.gamma_abc[248] = Pairing.G1Point(uint256(0x291f2747144ea92e0c8ea1c7f1d81ae941a2b92a586df59c102c08708bdf16e7), uint256(0x1a4dfc4d5918c9992c5121d420428365c3a16dc64add16b11c8a9c969886f767));
        vk.gamma_abc[249] = Pairing.G1Point(uint256(0x15931e004253613d4a64f91902daf13e416467276232e3e20159746c774cee39), uint256(0x104c59c3c89e0ae428bd012b6856939f112721eff8b25b10bc88c1a4f56b8d4d));
        vk.gamma_abc[250] = Pairing.G1Point(uint256(0x26f955f0e49de1b87fcda8b8c6c4fb9d7546716170f7ea87ff23b3e1002bd577), uint256(0x0947b9230174f3ed7e2763b8ba59160ac9cce61d9b56403f5bf73fec0be1cbaa));
        vk.gamma_abc[251] = Pairing.G1Point(uint256(0x14c16ae5dcf3f7518eebd54700bd742c6b71ea79166f370dc51f89636c7131f0), uint256(0x2f9c7991ef8783d543f55e62f0fee246869e3e18d3b73a4e6eed0bf67f0e1d4b));
        vk.gamma_abc[252] = Pairing.G1Point(uint256(0x0266cee5f3be155fb4b92f4c8897ff49a85ce728247e305e1d71ae3b8d9260ee), uint256(0x2f657bba1e06502acd679629ce326f52de1d2a9f97322174f9bf640600d0abec));
        vk.gamma_abc[253] = Pairing.G1Point(uint256(0x0d0c15dc1d98279d99ccb25e92fc41f0a1a86d75a9bff7fc454316bca9bbbca5), uint256(0x1bd7dba94b65898cb76a5e0486ad3f430d89dae88c9363a02613d8a901a1724c));
        vk.gamma_abc[254] = Pairing.G1Point(uint256(0x0f733ebf3a91ddc40c279672b176d7681d9492d3dad30969989a2c75410a6f34), uint256(0x052375f2b97277c7c8b7bb87890720d765c2beccfc450f95e2b05b6756918fde));
        vk.gamma_abc[255] = Pairing.G1Point(uint256(0x1e106b07823c531e3db545580976667e317a566c2a0df58d891b59dfab0f7564), uint256(0x0b4c54219dd33c7f0a070b5b1d8cfd5bc28ba7b3cb9da722037ba98900d3102c));
        vk.gamma_abc[256] = Pairing.G1Point(uint256(0x2d822e83e5229d92fa314def8382cb32863d8a05cecb3c1648496bb4c902568b), uint256(0x1440a57bf3b620ca1dcd06781e4682b70d4e0cdb1b139bccc304fe255814c980));
        vk.gamma_abc[257] = Pairing.G1Point(uint256(0x1e15978af0edee8e004ad11414d9e6000cd142b9290ee6ec621151dd06d47688), uint256(0x221affd80d662ee073dfa88eb731862b6de22fe226bf08f808f4036c35d82c59));
        vk.gamma_abc[258] = Pairing.G1Point(uint256(0x2c3afb7e9ea489abc52ef7339d138af870290e90ca2bd663dff7edf12af848a3), uint256(0x16ecb1adcbf186805c22f970a6e23fe85171fd82ad1be5a830237766a5b31f5e));
        vk.gamma_abc[259] = Pairing.G1Point(uint256(0x06cc128b9b1ed5f8d08068606efc9a9eccb799e2141de922c86d2500ad876f5a), uint256(0x0c41cc2404196b2f40dcae04c1cbfeba65c24254b0d1ec7f7ae259af7499f9b8));
        vk.gamma_abc[260] = Pairing.G1Point(uint256(0x1aff5b4f71206c2bcb9541bfb7611fee383dbecc595c0740f537c665f8f8e288), uint256(0x0888d0b93402cfcd2f7d64d0eca10b6fa85e6cf5a4f687333a54d7520f5c92ad));
        vk.gamma_abc[261] = Pairing.G1Point(uint256(0x2d2084dd3b703050ac567d923fc0c8dfb7924ce5c7daa4d3fd8f9560891fa358), uint256(0x2718399ea2b6ff954a1df48be6d517e33618a3d94d1482c6c62c263caa6000e5));
        vk.gamma_abc[262] = Pairing.G1Point(uint256(0x261219d24604f23254f691b5bb48f035ca18f9b2fd98ecd616a7e795ed6653b1), uint256(0x2c34b62061a912222b0ecd99bc5e75fb3457e5f39f0124cf6ca03be7ea456572));
        vk.gamma_abc[263] = Pairing.G1Point(uint256(0x20a42124c59091ddc7eecc7b757e363e0d4f20ff33a3681b6397e30ee8a55b40), uint256(0x25033666d1501d59eb57d46014173646d55b5418b22f97545d543e5312d8752c));
        vk.gamma_abc[264] = Pairing.G1Point(uint256(0x055f40b04f53c0c6f54f740dea5d86006fdabad311d5645d707b69d5e9f48c0d), uint256(0x2597baf2b203860627d0867d0974a14ed42c34bc89b7a6b1215f494ec53d6090));
        vk.gamma_abc[265] = Pairing.G1Point(uint256(0x21af74813a49765d7a9a5ccda36cfbe3749f35126ef4f932bbd6fd29de977c00), uint256(0x287dcac66051843fd7725fdc26258c55ab0b13e673e4b99849139f5d5dcb172d));
        vk.gamma_abc[266] = Pairing.G1Point(uint256(0x2cbbb6e370ee61675d6966a6ea6b7e928fe565868b6926d5b40cb428bc3534ad), uint256(0x0b2a814b9161d5f1cb92311ba91e6f736448fca0f5eb78383559baaba98c841e));
        vk.gamma_abc[267] = Pairing.G1Point(uint256(0x009d91f8676839433c6814639e142d60ef2d86da1a89b76f3d3373fdb679b55a), uint256(0x15dca2de7f4df028b608e0ded811eb7a1dfbf15453d3bca62b8c2ce1bf6e15e3));
        vk.gamma_abc[268] = Pairing.G1Point(uint256(0x2cda40a9343e4e3278361905b4845a70f2f42b4c0065fbdc8ae74ab347c8acc3), uint256(0x11f82840af5cedc0fac3b04b2741a5d84bb645a5a6e55ba8314c93aea38af76a));
        vk.gamma_abc[269] = Pairing.G1Point(uint256(0x1df7d4af3659cb4251708bd5e176b2331f26362307785b0588b5e469d2e8e7f1), uint256(0x18f012388d18e806be80377b61bc40ad060a2b7b36875a0cd3c4c5f2cf67dc59));
        vk.gamma_abc[270] = Pairing.G1Point(uint256(0x11c7752befc6c546864308db2f8e8cac5c4ba1e3a072a323328f258da1b3e2b9), uint256(0x1cad4520d30a55f5bed5e4ee61a23a0a0510c46c8f21ae56cd5e9f87a3b4ea78));
        vk.gamma_abc[271] = Pairing.G1Point(uint256(0x0c238e18f0db1dabfa643cde8818d603270bb2e6d06a11d348dac5b9715bd067), uint256(0x22b7eee9455da29c41c0fbd4f39a48670d08d72c81aa05002144cac28b77cc5c));
        vk.gamma_abc[272] = Pairing.G1Point(uint256(0x2132276914269b1e93d8bfe829b532c1a471ea84b7d955e9727d5ada9645f5e8), uint256(0x273e87e57637781a125190627b8911fa6e7348d89cebcc25539b5a67455f7722));
        vk.gamma_abc[273] = Pairing.G1Point(uint256(0x16fec56fccda6bcaceaa05b0d229bb72e8881e883513b26f6119e4aaaaac4e4b), uint256(0x0b591d8b82558748b07d1205bdbfe752c4a4fa9f2bec15f4fa8f9e8a3edeab7e));
        vk.gamma_abc[274] = Pairing.G1Point(uint256(0x15a026aeaecb02ea39a8914e43e9837806806d75e34f8b6514b60fbc1bc3c736), uint256(0x0e1b8b37ea1ba7904fe0b60caf98816a6f480a2b84efba28c05ecdb93fb38c41));
        vk.gamma_abc[275] = Pairing.G1Point(uint256(0x0cd001633cf9fca2811b7fa46079ac4f443ec02ec59f6a04b050b2ca7bbcac41), uint256(0x03679994bbcb020237f949bdcd22282ccd99579a8b07e78670b4000767d657fd));
        vk.gamma_abc[276] = Pairing.G1Point(uint256(0x22df9f1a253ba125b669d4c9fda1ae863c19c6de8db26b53262cf17a6774577e), uint256(0x0872595764433d35746c02d827de8ebe6cfdd0b4719e858f797eec77d81bb5ed));
        vk.gamma_abc[277] = Pairing.G1Point(uint256(0x2dd5a032e1e53b2cfa3e93999f897dd896ad189de116877f1f5d6c802c31ca6e), uint256(0x1e0f8d5e5a6296910afcfae525a742c6114e5e9c0395c44d4be1abe07daa1baf));
        vk.gamma_abc[278] = Pairing.G1Point(uint256(0x26e21f0b3ce774ecb060de95bc353c6ae0a9197a2c045197890a2853c1cc04f1), uint256(0x02cf235dbbb274642f0f1d2936a9431d13bb78e9720cd5554651407f601fea32));
        vk.gamma_abc[279] = Pairing.G1Point(uint256(0x23b096d6b09aba0865c7a90b769df7875d015f5d3ed1f012e4fac3ebd4145595), uint256(0x0e8de97d89ec9893eb1e246feea6bd129ab98c69ca940a7b8ef575f95f8492cd));
        vk.gamma_abc[280] = Pairing.G1Point(uint256(0x1df39c2039a4994023becac49465e69fddfb7364dff7151c09c47eb4da568f01), uint256(0x2217c7f769df639cf3509bc565cbb005dab8ec26cdc3463f11472680981b7da9));
        vk.gamma_abc[281] = Pairing.G1Point(uint256(0x1fee41a43dc1e0a7071798a5a28e11c07b486c2ecf429b8517b5197b4ddcc89e), uint256(0x1600d2b109ccbe52e70445814d6fc4cf1f4e7a5ad5b146fadd17f8d24cc08181));
        vk.gamma_abc[282] = Pairing.G1Point(uint256(0x14586bf6dddea7afad684075bfae5fa7d40ac069f0110df2523d45a83e9ec537), uint256(0x0adcfb86d68c8ea17a71402413a22c5b747f7a97840a5e8782a0fd2b19d89f4c));
        vk.gamma_abc[283] = Pairing.G1Point(uint256(0x09cde28b625e6b3d8d74a685b426168ee598d6758a2593e5ce268bb27b8d17cf), uint256(0x1b0accb0e2399aed8f8cdd21c4d12a929c5088e3873ee47b60710ac140182775));
        vk.gamma_abc[284] = Pairing.G1Point(uint256(0x0e624db5ba9e82f06bb9f6847a80346223d70057edf380b2059b04d479936e9b), uint256(0x1837f0cb7e30db42a98ec986d64425934cfd6f8e70b43cdee6de1acdf3b7199c));
        vk.gamma_abc[285] = Pairing.G1Point(uint256(0x257871d4ae537ca070455b74e4543acdd9bb922d55af137a4b8e69d2aae4ec61), uint256(0x1ddde962511194d67284baaddc12565a1150a7f33ee89b9642953f9dba805288));
        vk.gamma_abc[286] = Pairing.G1Point(uint256(0x06571866f92a4a0acc9b89ee8997b6c814aa8a127ca64a21fd58d4ca7b5d5805), uint256(0x10264e99da0b4b0e11ed75175d428f72ab04f6d08faa742b89b83b3955f050f2));
        vk.gamma_abc[287] = Pairing.G1Point(uint256(0x13f1dabc84ff712b46016f0db389352bd4ca64590fd0ac967766370bb51df308), uint256(0x1310bf850a476eccedd657135227fb33a3f0080966be1ae38fd4d70f747cb9f5));
        vk.gamma_abc[288] = Pairing.G1Point(uint256(0x27f0bfe55837949fd6be989b11beddce4e219bcb8c44af2848a4573da52b5910), uint256(0x1bf48098a0823def2018bd79f227b23aa8c79afcf9a5da920c46631b76e81281));
        vk.gamma_abc[289] = Pairing.G1Point(uint256(0x2b77f3bf7046ca083d9c8fedbf4a365086b13a3ff95e5ad27d3a112c0e427c8b), uint256(0x1ded090ec6d378754b7c316d304677d6d32bf61badfe058b9afa00e8b937dfb3));
        vk.gamma_abc[290] = Pairing.G1Point(uint256(0x2b859e6d43b4a837ffc1d0f1b96c022c2b70d6d8c6cb27322f5c9c7bbaeec794), uint256(0x19b5893afd45831c40fa29e8991c000b8bd6c8692148952b17f7bd62ee33af6a));
        vk.gamma_abc[291] = Pairing.G1Point(uint256(0x04e204ef81f845a6471e2c0c3e3b0c404400e35c3de03b559c61a4220e1d1756), uint256(0x03963134158efde1f6e19135565cf957df143113001060f175b7ff0b5b38dbe8));
        vk.gamma_abc[292] = Pairing.G1Point(uint256(0x0044f33c84953f634f8de27fb71f6850ede9b926f0371cd397ee2375733e8ff6), uint256(0x211bc8c3b1f0fdf72ca91804e1c849a17a4c18224fbd395c278028bdfbaded31));
        vk.gamma_abc[293] = Pairing.G1Point(uint256(0x06a0a72aafcc3e03e81f87d99439412efb97a1f6122b618185b623fe579fbb90), uint256(0x26734674060708e687994a0c7c337067d19e3e69c6b02edc800e3d7b50f29449));
        vk.gamma_abc[294] = Pairing.G1Point(uint256(0x26dbeae8fa194f84fd41f8a1ecf1e69d1dcd37695640d29e24fb0c666359b516), uint256(0x0433dfb3b6510f89445534673ab3d5b4c2f4e7e60350b2f5e7f24fc9ab9eeea0));
        vk.gamma_abc[295] = Pairing.G1Point(uint256(0x2d934734a5325a0bd80351b30e2e2553e1c38d0d32c844d4bf029b4c6fbcd06f), uint256(0x1f5735111f594832cdf840a350102043e3d601d82e4da62f6f2138a745ea2a3c));
        vk.gamma_abc[296] = Pairing.G1Point(uint256(0x302f0f6a17d747702c2e996563c477a449783affff6d04fca2a9adb166d0f2f4), uint256(0x1be675c6b06e1745995f3fa130dbfe7c445f95333f457f355855e575d213be8f));
        vk.gamma_abc[297] = Pairing.G1Point(uint256(0x1a81c780a516641f461e71a4f5d74ce4d947f2590e22c7b6c7794196dae37bc9), uint256(0x1294edefa56e46bafa00f474da77f1bb77ffc1e19123450d002272747f595b3a));
        vk.gamma_abc[298] = Pairing.G1Point(uint256(0x0644fab58c4b92a0fdc4b640bcc5ee26ee2eb0c117b56456f3abced4d6d7a96b), uint256(0x02d9e5124ce7e177622d9a513e64c44fcf6ddcca66ff460b47c3f0eeb689f00b));
        vk.gamma_abc[299] = Pairing.G1Point(uint256(0x2e157d5e00af6bf8da9f43477ee5de8394adf68d0883d9e2352c4f198b4b4e0a), uint256(0x28447c6309b687c4cafc68b2cf71fe1201041671a77621589f55281f3ffe4ac8));
        vk.gamma_abc[300] = Pairing.G1Point(uint256(0x2340ebaeffe33655c2e46c844970c64615bcb8db0689fe1cec1eea50dedf20e5), uint256(0x270d4588c646940336fbea03aa0bebd726da555f8e30e2eeb63e2ff6462a3ed4));
        vk.gamma_abc[301] = Pairing.G1Point(uint256(0x24275c8ba63dfdb460b9a9c0e68f9c8bc59db08e9de98889c714b6017e170d17), uint256(0x1ceff48162f21f1099e607c2d810d532e1482013b80dfa83490cf4310bc4de29));
        vk.gamma_abc[302] = Pairing.G1Point(uint256(0x1ce25a514a31a487237fee779ea5617df11d273fbf598f15d42464418cf60e51), uint256(0x26e465fb12394a89139c306750a0a2d6a7c9bbc1ff0dc540ff7c3dce99cdaa7b));
        vk.gamma_abc[303] = Pairing.G1Point(uint256(0x14556e00d1b106112ea06d60c64b6a27ff1b45acdfb6f657ef77865aa2d56ef0), uint256(0x01def3d35363ac80074f289bce50e813b631e2a464d07245b0c28479277917c7));
        vk.gamma_abc[304] = Pairing.G1Point(uint256(0x141aea213b65d1519b799bd16bd5eaeea9a1bd54124df8e88b5aa6bb3a90380e), uint256(0x3041e6415ac9cdf9114292fe7d65a023fe89a8591f76de9b6b9e4eb82028bb58));
        vk.gamma_abc[305] = Pairing.G1Point(uint256(0x10b6d5af83ccaeb57bf16e498c23682daedc32806a5d3ae116d4f6e9958821ce), uint256(0x04ecf82bf640e0ab6fdde738c680c7e9bf4266264ca59521c6b11144fb19fef8));
        vk.gamma_abc[306] = Pairing.G1Point(uint256(0x094e265d8a36181e49030696a74fbcd3ae571429a0552cb6ff0dfc560eb44e8e), uint256(0x1f0196e1c0cc2f291dcc4e7653c2fd29bb53e82868c89031afbd1f75cb212c30));
        vk.gamma_abc[307] = Pairing.G1Point(uint256(0x0939fd3ea23eff5ec38dc0b953462a2c6dac199f5007322ae6c563922d8f7cb8), uint256(0x0799d93d0cdf3352ba1e26e7aa63c4b043e3be0ef0edd401927ed9d51347e4b8));
        vk.gamma_abc[308] = Pairing.G1Point(uint256(0x2176546cb954652c6d356fcabe4cfcee589c7a9c67c7af6cd8b5eb95f1486055), uint256(0x063b7f57bb25bc8da538b1e77360de02c9f4093ad3212578d5f198464b21a2ed));
        vk.gamma_abc[309] = Pairing.G1Point(uint256(0x0d8aaba879927772f3d359e468697c485f514cb9237c5a0a9ec58420b6472dff), uint256(0x01c63d027f8c557e103322c3750230a3f33bff86abcb5a6e86eb290389c7fb5a));
        vk.gamma_abc[310] = Pairing.G1Point(uint256(0x1ee80bddf4708f9986e26dd50c3957b3004bb6ad15f945d3609514ab7c18a28b), uint256(0x022f8f8de8d392689870d1448cdacf181e19bba394d55c552da14ee749a9921c));
        vk.gamma_abc[311] = Pairing.G1Point(uint256(0x140aaf4caca795267dcebe41a2b257525defc85979ab086ac98cb093e3a96a6b), uint256(0x177b4038b708c3ea02e5ba7f9fc8e6aaaac053391547413ca2cb7e22ab21d063));
        vk.gamma_abc[312] = Pairing.G1Point(uint256(0x06003b5c7c568ae1e347394fd48206d6fbdb3acd6cc84a6d0bc2a3d3dea55328), uint256(0x18f86e1d8d2f7d0d0cf09facadc8c2a06349832755f5e4ca032e58b01de1e72b));
        vk.gamma_abc[313] = Pairing.G1Point(uint256(0x1ee1dbab414b6d495b57f1254d8b8f6e98a465138d99d865d93254f908ab39f7), uint256(0x00a6c49e0b2df31773598da7e6d0c88cd64bc755d5938dfad34f9edb5add7ca9));
        vk.gamma_abc[314] = Pairing.G1Point(uint256(0x2635c33a0433a2b4b8b9e6649ade45068b78a1e61459a47014b8fcf7f05df858), uint256(0x085e0a95de2d49c02a5d556b5e273c5d0264ba41979a50a0c30d2cedb1eb43ba));
        vk.gamma_abc[315] = Pairing.G1Point(uint256(0x297428bcec30ee9c5f3df3c5be1201e30df83c489e01cb66bfcb25119bd00867), uint256(0x27c2d790e09ad4055a6be63e005288d051bca164c953088d3e0798d7208748f8));
        vk.gamma_abc[316] = Pairing.G1Point(uint256(0x1fd7fc3ddeeba8e6ef2664b6e51059221fe46cfb663947faca752f6b75aadefc), uint256(0x24d055c13028f6c6f5c590f94956186f69d0cd0436f1d92c09ea294b15d313a6));
        vk.gamma_abc[317] = Pairing.G1Point(uint256(0x21f2da6e9246c7a84142de2a9414cc450c66735c310b098584a9832dee327632), uint256(0x10bc4b4b8a7d7739d18ed06d0fb86d9eec2ce381e41c0864b8cee07c275fb556));
        vk.gamma_abc[318] = Pairing.G1Point(uint256(0x13c4304f376de1e556319373888832091796fcd00567f2329a4ca3d88ea09af6), uint256(0x23d7288d8981b2200a83d16eafd7158b5dac263bc0071d536596e1fe9ba44a88));
        vk.gamma_abc[319] = Pairing.G1Point(uint256(0x0d1a1f78a0d171657364ac02149e70c26315c6d23f706b69c327db7f4aacfaca), uint256(0x051ab1eb33d5ab7acabcb3748f30bb165c8e9d2b2f468074f1aabf8f5cad7228));
        vk.gamma_abc[320] = Pairing.G1Point(uint256(0x2b9206940cd37585957dba7bf31cf21dbe5e40a6cd127f697b8708b7401f8da8), uint256(0x00e8e73fe93a9ab33e4bcf112d5cc17174899bfae83e0f96cda13753ba9749a2));
        vk.gamma_abc[321] = Pairing.G1Point(uint256(0x10ce320fef8cb00a9dee42adabe5743e17e006b635a2c038b73f3965311cd0ac), uint256(0x15fef94cb3c6e2b868b8d0c947e21a8937a309211f5f3d725ad103554970c331));
        vk.gamma_abc[322] = Pairing.G1Point(uint256(0x0f041a0988aa53664f1548bbd80623691178b22ab2a5b4642841efaede3e79f9), uint256(0x2997336028d3dfb3c612e38ae77b020ebac8854b0ceed91b46fd3616775f0b5c));
        vk.gamma_abc[323] = Pairing.G1Point(uint256(0x2dd5723251dfb95bee3b0c1f620e3d42f73319545fd3c8a715f973668da44dbb), uint256(0x09d325ddcb804d98b9a9bc29ea206060ec0cb9ae300a5b8868b70177b195c206));
        vk.gamma_abc[324] = Pairing.G1Point(uint256(0x0705e66200e54c9c370d96603a33ff83be54b28615521e82c7a32ad5cdeda60f), uint256(0x254d43d74dca65cd3a56bac6952992c34706e20dfd95b7d85a15a9b80f29667b));
        vk.gamma_abc[325] = Pairing.G1Point(uint256(0x0d6cd5036ade0ccda27864c17a4d756d4b49d45b355c7ce7594f3e5d6e45088d), uint256(0x14c7735a83ecc08345138ced8c82bac3b16f32c6ca73e84122272671bb468cba));
        vk.gamma_abc[326] = Pairing.G1Point(uint256(0x04fbe5035a90eae8adbef06fe9e2db985d1f6a8a882f40bb10f717ab20b8974d), uint256(0x2d69abffe5a60b0e417596ea16caf038e00bd51e5eb8f4fcadfd3b66d90116e2));
        vk.gamma_abc[327] = Pairing.G1Point(uint256(0x0bd5e81b188e8d6f31cfecc7c737b1a6ca348593a7518f74707748d1b199e98e), uint256(0x25cd1a3b12968434bc0afc1d32d917720be9f4b3c70f99336fbc7631a34084e4));
        vk.gamma_abc[328] = Pairing.G1Point(uint256(0x12531160a0dac9a988988c36a7f5d0806281c2d02b86d5b0a1ec16fef7cf0cc8), uint256(0x0ec90ac6e2bc5497f0e47ec3a6b939ffda3a056c2a073c9ae3b93b43f3e31bf6));
        vk.gamma_abc[329] = Pairing.G1Point(uint256(0x24d2a40fa581c5fc420700eb93be9824e3982cc0054cde87b8dfe99e7c4b2a92), uint256(0x23626f44d80e8f832bb2d7d151650ef1aa94562d45fb755ed0b4d87b8001920d));
        vk.gamma_abc[330] = Pairing.G1Point(uint256(0x0a912b5a66ddde7078247e33e8f5ee34074f7e9e4695893e8c1abb0f963c7229), uint256(0x215205df1af93f52cc464c43ae879610e1e1c7b683b38ccc1b59b212f08b9a03));
        vk.gamma_abc[331] = Pairing.G1Point(uint256(0x1d579aa7cd8b46e598201c0ccb1e3009113e68e0477aa10906a2e7143ca73a69), uint256(0x0453a8ef6f0d5e85e485987cd95a8264eae04b5d8af8a0641d9a2b5c2b511812));
        vk.gamma_abc[332] = Pairing.G1Point(uint256(0x14ad70e413b0a45ab0a370f6530d0b47cdee11e4a1e2b947a03e3f6203ea69e9), uint256(0x13287d2cc8a64f2b13e0f49e86fc9071f6874b2b8603a68a00bc21079f3b4a80));
        vk.gamma_abc[333] = Pairing.G1Point(uint256(0x0afc7dd18c443679246b504b22ee07f054558c24bcb1e7db628cf406f55efdb3), uint256(0x26e0df3982122391e2c42a0394cf61b4d515c403e6ba58e980c8d11e2f74cc79));
        vk.gamma_abc[334] = Pairing.G1Point(uint256(0x092be663fd01a6bea5390e70f6f1a07aba16a17280c009cba999b22b85a37657), uint256(0x0309dfe076aa4e44961e2abbae02c5209f9c33dcc0e63ec5a8e1bf5202411584));
        vk.gamma_abc[335] = Pairing.G1Point(uint256(0x27e9caa4bdc4b84c4b5a82bf0423c8229d137fba47779d01d043a8aa9e630a1e), uint256(0x0bec95961aebf074d9b6eb9e170d725d09cffa46d6e8894d35e5b9bdf376f9fe));
        vk.gamma_abc[336] = Pairing.G1Point(uint256(0x0f296033429312cb0a2e417f0357795bf6b06a374acfcc1d0d01b9f6b3c077cc), uint256(0x2f9e4b1eb14f6f9449b945d75e7a16f0268e75c1abebed092b6c3d26bbe6f19e));
        vk.gamma_abc[337] = Pairing.G1Point(uint256(0x2b0b3a778e425798323ae546ebbcbea47381da486dbc71bc4888ffa5ba6002a7), uint256(0x0ab88c92f7bebb32421325a1e356696863bd0af6c0ab3dc85b7565388f2c0e17));
        vk.gamma_abc[338] = Pairing.G1Point(uint256(0x0815ebaff2249454845e4ad8b1ae86e01d5aeef892c65d19daf20172950c4bfb), uint256(0x29767d1b58f904cd6e4121629f83eef306c6556619b64d157dc21b6dce86e196));
        vk.gamma_abc[339] = Pairing.G1Point(uint256(0x08b17c05137309a15dd19e13c1e4d644c652352fb90f7ff2e47ce1153a0d36aa), uint256(0x1b608389cc5f01545769f1d86699093cc4d201231c61430f56bf069b12fe1359));
        vk.gamma_abc[340] = Pairing.G1Point(uint256(0x07611c01585155f3e03b434953bba5b79f4e9780dd77cb660e399f355438d2a3), uint256(0x194f3eeffb50469bb58f9232d5329ccafe6c03a7860fa50cf6915a83bbebbe01));
        vk.gamma_abc[341] = Pairing.G1Point(uint256(0x28b70e55c4770b9f13ca8f0c76f3d1b54f0dca93ae38f41c3f59b1dbd5d0904c), uint256(0x03f7205aebd3f2fdb3cd7e207e7b879146e500ab94a2e583c1238ccc85f6b30b));
        vk.gamma_abc[342] = Pairing.G1Point(uint256(0x0ebb15ca816f7a8470b301a33d4afb33b18ef1b834588e1e2b8c0f9dbcb286ac), uint256(0x124e9ec7bbf37939d0a33de1829c0fdd89ad9985d6bb1152ca97a5c54fa94e77));
        vk.gamma_abc[343] = Pairing.G1Point(uint256(0x2391ac24884a909215e6f46d289e6323867ebe3b179e45d194f9de7d717bbfef), uint256(0x220d80bc059979f729e9801ef451f64e0c95c8b2dc0ebf7f627b1209d87d2731));
        vk.gamma_abc[344] = Pairing.G1Point(uint256(0x2fac3fced492244d0e90d57bb7f17551cdea6ecee390d629eb9c2bbb3460f237), uint256(0x00e8d42b3c6edd1fff02b3ec18499ef96a7e5203226d25a45ef6d829cc9881ef));
        vk.gamma_abc[345] = Pairing.G1Point(uint256(0x03a5fa636b3d32f539351ec8d5319cfe98b0debcaf847f3fdcba93ef87cf6ac0), uint256(0x01c58ca83bd60d06ad1d407bd49107e61f7123380080f1a12d693bd7e6c7c001));
        vk.gamma_abc[346] = Pairing.G1Point(uint256(0x097c492dec17f7fc333cb26461dd7fe8519c897cf12f24b4b4a5a1180ea126a0), uint256(0x12e9502273d265c73440bd12df62334e07af9f41265ae59da77456def93d635e));
        vk.gamma_abc[347] = Pairing.G1Point(uint256(0x0ee98f8379a80b5a3545646fe5893b4f22f3d1a45030c8a019133c80ff45a590), uint256(0x24bc282b1bbf6a721f730ddc7839d50a0287ef3b8e8fc0ae66b9a879f193f4ff));
        vk.gamma_abc[348] = Pairing.G1Point(uint256(0x0bd284cb7c44acf31bd49409556fc8aa1893a866d95b25cff0d15aad96d841db), uint256(0x02de43634b2dcf7bad261b8cac37342a24e8bc246586129058048fb6ba5f9eeb));
        vk.gamma_abc[349] = Pairing.G1Point(uint256(0x1d217870de56781cbb8afb66214e4a1a0bc0f9037292cd01b300c727d5d3922a), uint256(0x1a26c69c2a45481abfa771070180154abeef57223972bdbdaa005cfbb9c64d5f));
        vk.gamma_abc[350] = Pairing.G1Point(uint256(0x0ed00b81d1464b89f3dd0c1ac4d86af3924d9b864994da332681340aed1fafda), uint256(0x1db5283d7dc5138a7d7043d5d733794102383b776bd3188f35e047163d45e17c));
        vk.gamma_abc[351] = Pairing.G1Point(uint256(0x01c7a76d722cdaf5ac5075fb53e354a230982548adeed7cc8d6e71e9db16ec0b), uint256(0x1df08a85432c5db030de74f3c731e052bdc0a8e89bce6b26186953f7fef72b65));
        vk.gamma_abc[352] = Pairing.G1Point(uint256(0x29916cd96b8fc90a4509ee05c6129970cc8440b6d7147034663a4c6e75d124df), uint256(0x21d8132807cd52f9e0941f6c33b205225a228efd2ad8b08748b86c9c97b98b81));
        vk.gamma_abc[353] = Pairing.G1Point(uint256(0x277c5398f59032c74c78adcc5d5ef2b53e4146f6d6b09f2046a32f172d1f10de), uint256(0x207dcf7740f08f4eb0ce58f8400acacfba32b67efd3eadcde1a830180f38f84b));
        vk.gamma_abc[354] = Pairing.G1Point(uint256(0x1863efafe9646e90bab163cf2a0c75bfc01e04709137a87a489664aaa4b7edb4), uint256(0x15d90896b0d21f9dbd3c9a969a8818d4d96ce1b8137f0f7acd4af1f71eb73670));
        vk.gamma_abc[355] = Pairing.G1Point(uint256(0x27a7e4a837fb33a2e5e5d9d90c4b3fd823597e3a9d576310dd9de995e7b45b3c), uint256(0x2bf40921d74a24a9b86780a3188fe4b50c28ccea1e5d80b4f4ef1b724c4a112e));
        vk.gamma_abc[356] = Pairing.G1Point(uint256(0x0bd280ed2eae6c48ee3a313b8136970531079d42d0427fa22ce7be7ce2ce42e1), uint256(0x05319ad0257380b931d9069412a41109f230e45bcf9019c706368abdb324929b));
        vk.gamma_abc[357] = Pairing.G1Point(uint256(0x25b5cc6988a2d3888279ccf55642ec0598489cae9a54cc471828b5074aafce9b), uint256(0x12b7ba9ebbc6d6e05c1eba9dce010d60380d438e20edcecc277a516b729756ae));
        vk.gamma_abc[358] = Pairing.G1Point(uint256(0x0a13e3d73e16b434c1dc9d49860cf9eeebd0b19a6604a0e8b13c93e55d11e43f), uint256(0x207e3e2f7f34059340044a08f14df9c412aaab489d9838fee65e4ef8d16624d3));
        vk.gamma_abc[359] = Pairing.G1Point(uint256(0x119e39a846ea5a89075ae98d82ee8b7df92a17e79ca2c69452bf4d8d7decae58), uint256(0x060bc53f74190782376c76197c5e8aba2d264f9f790052975b60d1c0a7e8607e));
        vk.gamma_abc[360] = Pairing.G1Point(uint256(0x268bd4e24d86f11b236949ff475036383af9a956cc96e9f5ca9b76866279ff95), uint256(0x0eab44088865f03e731cbc49c8e1e7c852d919c65c7f136fca12b214f65adbb9));
        vk.gamma_abc[361] = Pairing.G1Point(uint256(0x03accca866d3c7df455dbf60186d0b41fb1720abc7ba36a04c4dd81114483147), uint256(0x3021af3b8495ef6936b08585a3932fc9cdbf823408ac464d294c93aa6c897fbe));
        vk.gamma_abc[362] = Pairing.G1Point(uint256(0x1d749c45a403133471e7d6c272e26130d11bcabd1a89a7e8e82045e816dafe14), uint256(0x297c0721da8470a499b474040345d62ae3c2c81922be22f10211c62cd4b1777a));
        vk.gamma_abc[363] = Pairing.G1Point(uint256(0x0f100726fb89a04afdcf04686b546f0bb7c0aa4e5330a882d29f082ba4d15e9a), uint256(0x12be27ed6bb110d9892e5767e003b8d07a43371a04cea54b0e213e7baea5a258));
        vk.gamma_abc[364] = Pairing.G1Point(uint256(0x006563cfad0eaa24a3915dc9ee428670929157f1541fcda33bb26712f17db642), uint256(0x253a2f4c65ba9a6dd103f210ccb9579af8485c7cdf19aa0dca0987932cc09e3d));
        vk.gamma_abc[365] = Pairing.G1Point(uint256(0x119e502a299f8ebfb29fd7a09eccdb78e530ae342e2198223142ac2d913ea189), uint256(0x17bb540c207c7858c7089d0c2a395de73b9290bfeeb249e9ce8441942421703d));
        vk.gamma_abc[366] = Pairing.G1Point(uint256(0x08b8a1a5df800cdffa9aa6f379a518b0bcbef6386465f5e0b2a024b0dba07d3a), uint256(0x14d701a0dad478f5f588795893c352079cb44de8a3ce5b6b0eb26468cec63bbe));
        vk.gamma_abc[367] = Pairing.G1Point(uint256(0x24f2989be7517fb6d68aa2165747f636bc2d56c539333864e8ffcf3d168b8385), uint256(0x00e92ba838b98f5cb6681ee890bca96125d92a04a5d135e660da4dd49eabf5b7));
        vk.gamma_abc[368] = Pairing.G1Point(uint256(0x3037e6e69a0626a38ba9bc92b590b02c52f31ca24d28eead7425fa387daf1eb5), uint256(0x2d951454c71d10f06cd33ee0bf844129cbca16aa97aeb9bbfe87c18a91fd0116));
        vk.gamma_abc[369] = Pairing.G1Point(uint256(0x07886c9cbcd44623914566fba6580f82ae56240cdce5f39c7e045617dffd28a9), uint256(0x2bb131c8ec0689d8ec730aab5d419add5f6e53f6b542495d4bb41bcbd2c03bf0));
        vk.gamma_abc[370] = Pairing.G1Point(uint256(0x04ce4b1727fd59a43074a5e95bbd8bcc12caf0f162fa18bbab03a8f0cf60e338), uint256(0x051727856eb119277090d1a03f76aeae68aa22184ffc8dca3a76f90b27446dd9));
        vk.gamma_abc[371] = Pairing.G1Point(uint256(0x2fc349be7649edaa5f10d1277156da8ebece1263b89c7b6f1d375afc155abaa0), uint256(0x1c8457350d42a3b1212b21a6136fd3cfc7b97bab6a9795545f4db67626e691f2));
        vk.gamma_abc[372] = Pairing.G1Point(uint256(0x0eb3e3fdcfcb459773b2e12ba3e25b802f8c75944e32c085a43bd7a16356a456), uint256(0x0b233783b654f6d38a3941006f6c7f0d8a011c3ec8a8454243f15f17b69efa69));
        vk.gamma_abc[373] = Pairing.G1Point(uint256(0x0e6b9d4f0d9d9de5209b52c49b06698437e7117f201665e668c663999c7d1582), uint256(0x0951b1a70945640ce4eb775620e9a0d3fcffa1578d60604f406158235abab170));
        vk.gamma_abc[374] = Pairing.G1Point(uint256(0x04a1abff56659b71bf55e88d301188be9904e346686c884f2674ae21c1e66163), uint256(0x1bd05bdaacd441c4a4183f8bc93dccdc01d97bfcbaa51516ee1448faaee11f33));
        vk.gamma_abc[375] = Pairing.G1Point(uint256(0x079f8c8413186c5dae580f27b7101585ad5e4b23d00c3cbb1da4a30db0e8d3e3), uint256(0x26606bdc859897676f6c04c79497ffec2e3ece28a80d662fab097cb35ab6662e));
        vk.gamma_abc[376] = Pairing.G1Point(uint256(0x2ca015740051b78f56d15536bf998ad51f2e521dbd41d701e6be8b391eeec74b), uint256(0x04e862e5cca62e64915d531e59e3bfdec4db4e8315b2562ba9cfff006b8735dd));
        vk.gamma_abc[377] = Pairing.G1Point(uint256(0x06df2e06e7cb191cf558577198bc86b595b900604cc288d0cd7ad3f5031a5153), uint256(0x06d736f400c1f06bca8a9e91eb5e7395b415fcd68230ba330fdbc1cdd949f643));
        vk.gamma_abc[378] = Pairing.G1Point(uint256(0x0dcd9055351b11dbe81ee86ba48200163511ddd823ee38363a6e14bb8bda6d60), uint256(0x2615d555ee9d31ab7006324d49a9b3c98c78dae2b9cf40328ee8250519406257));
        vk.gamma_abc[379] = Pairing.G1Point(uint256(0x23ddde6dbc100cd1475e25407aa5ce90b1caedd3cb404d38762a8c5292982a46), uint256(0x2c76b8af2d10d2c7c4c1ca4e896ed0246fd52f688a135c116b40ed78564f29a4));
        vk.gamma_abc[380] = Pairing.G1Point(uint256(0x1608bec625766a0e8c77d14657bf23c12ab9ab751613420746bef4c98c5ec508), uint256(0x254779fa552f593b18d3ca4b141a83f3d9479d17ea21f4d77692714b12db6a94));
        vk.gamma_abc[381] = Pairing.G1Point(uint256(0x1c183098e12fc8908091ea870782dc6a8c66a06bb1af9a1b7cfb1daee0fecb43), uint256(0x19c202ba752db29f139053f65dc5307c8021d1d63e648aeb9dba07a68bdc5b1c));
        vk.gamma_abc[382] = Pairing.G1Point(uint256(0x115e654666980d853e766059574ba068d8654e58dd2e45945da5f386e6f29825), uint256(0x0aaf447f4ea2415e0518997e0f6c2c7322786e67d3c563d30d04e0745d71ce6b));
        vk.gamma_abc[383] = Pairing.G1Point(uint256(0x0929639b113251bdb46c08ef43803a5df15c755664df65daa7442d38c3bb2354), uint256(0x11222231d1ef1f14c8b45da83f6e4945362debe604b8322f07ce064727871ec9));
        vk.gamma_abc[384] = Pairing.G1Point(uint256(0x0a6313e1337a1adc52e54d17d9a690dea9ace532fcd286dbf311ec3e45e48a15), uint256(0x2470afce29a994a4a3eca9647afdaa77b04d88a5aeedff98cdba1c26f9afd470));
        vk.gamma_abc[385] = Pairing.G1Point(uint256(0x06e9d86f9fed0c9bef95960e38a0cf2817c7b87af1f41f1a9046b1ed5430ff47), uint256(0x1e5104a0c0969a7c7ab85d8b81e1da654bf8b31fe6501e3daab3d2458296877a));
        vk.gamma_abc[386] = Pairing.G1Point(uint256(0x1ab2f620146ffb063cd2fcb17096c3684079c382cca4f05b0ddfc4d662690523), uint256(0x17b5a43c05f940d58ade7f35916054a3e97ac43a8e98ac7cb4fcaed2d706670b));
        vk.gamma_abc[387] = Pairing.G1Point(uint256(0x23050e2c44a6899d982ed68ba0ae8e05575ca2229fe44c99c0873df988894c49), uint256(0x28576063f2b34db9b32e9e4fcbce78652bcbb23b7b6318964a908dbee1132351));
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
            Proof memory proof, uint[387] memory input
        ) public view returns (bool r) {
        uint[] memory inputValues = new uint[](387);
        
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
