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
        vk.alpha = Pairing.G1Point(uint256(0x24b9ce047620535d36fcd1713eea5a09e97dfafa6f79bc4f455540134c6ec451), uint256(0x075cff82993ac56dd385c8b7699763e4c2112fe0bc284f996f974d0b943b3854));
        vk.beta = Pairing.G2Point([uint256(0x228031b69a301be613a02e7778176f31c2529845cf5ffc0b954c75922542e866), uint256(0x12cdf09695afdea86602c327251afebc094c533456841fc8a53cdef341149d6b)], [uint256(0x2018db5d8afbd771a64572c9296b1774b3a2a761c8de017976b05e6418ff52d5), uint256(0x07fb4d145aa427e7cd8d83acd5743e0550f5ffc91b323e405741bece62b42a4d)]);
        vk.gamma = Pairing.G2Point([uint256(0x0f6f5f2da6d18550540ab28d86f3d3d71eff649e48cfd8d94b1a923aa4435357), uint256(0x3047718a4fa957a3de474322da3d03509899df861a8f0379e8d3e6c1a9e522c6)], [uint256(0x1662f19a5d1d5651b2463b7784cdca505bc2b926f3d93418b9f7d219fc9e2564), uint256(0x10cdf8e28d49d85fcb583097a1b2e01bea701ae01db97ac78fc8ee76c2451438)]);
        vk.delta = Pairing.G2Point([uint256(0x1414f545e329d5bd698f4aaac78637060e1e05fd859e1fd45118e84f66015713), uint256(0x12b719287426fa344f7d9a64108b517a85311ce99ecc9818422418bbbd93a1e0)], [uint256(0x1fbcbe5140713c26095605a7b0e5256d5f3cb60dfa3526a4cec72e59b9ac7b83), uint256(0x205c30c10ddd6a195d3d3c4b3b72c28d6e5d11b65d2516c23acd5f7cead15a50)]);
        vk.gamma_abc = new Pairing.G1Point[](36);
        vk.gamma_abc[0] = Pairing.G1Point(uint256(0x0a4d6fc949ad50dfa49ea502eb2f93db405c836597f758ca4f642607a0af45ab), uint256(0x2f1bab9e53162e96b5c6cc822e9926bd11844d5d376e73572f3a8b9a53ffc4a9));
        vk.gamma_abc[1] = Pairing.G1Point(uint256(0x1d7e7acbb79d3cceb36369f84c3a2049e3f27e7cacc099b6b795c06bcb52d12c), uint256(0x2f7b07a3f1335a45d8467f83524e9e56c2901084f5d4aa3d1597a01f3351b25a));
        vk.gamma_abc[2] = Pairing.G1Point(uint256(0x28bf9356eda9784dafdf380433d2aae33739579039bb163c2d9ec85cd59fdb01), uint256(0x2ffd55861770f2f61e5f97ee4603409e88032ac0b2d0fc99c6a5b1592f625151));
        vk.gamma_abc[3] = Pairing.G1Point(uint256(0x207a73fddbd64cca9661b915c6a313d2d67d1c210e8395c7dd0c0cad56c2f827), uint256(0x29fcf69352e82531ac8c92a88fc36c799005d2f988df6246582ae105a7e44e30));
        vk.gamma_abc[4] = Pairing.G1Point(uint256(0x2df33d30acbb072ad65cb6d273a757d57fa44b3f27907b2aeb1a19a3d1641279), uint256(0x1c4437561ff0644107a84c9dbdde623494bc58f364cdd46994094a991d39b9b9));
        vk.gamma_abc[5] = Pairing.G1Point(uint256(0x0a4e895da157b1c03139520ae3d42893ee30a369e49f370c406017a8ba6c2dba), uint256(0x07ddeb3f0142745a2db5545cc6c619fb2fde41ea7565042ba0464eda8315349d));
        vk.gamma_abc[6] = Pairing.G1Point(uint256(0x24f77ee7b7ae2527eafd31977b96205ad7171c700b0c6412c58e6463be0fee1b), uint256(0x1e0a5b9bb82da21799587ba0ee8ee8193d3943589c37ce67d880d41449096026));
        vk.gamma_abc[7] = Pairing.G1Point(uint256(0x22acacb60589752c7115c4d32c13788b4946f758886ec8bffc7647cd524bbea3), uint256(0x294dea28e9b742d28d1f26e00bb732de642ddf789f4472d77311ad3c04cb6f67));
        vk.gamma_abc[8] = Pairing.G1Point(uint256(0x2fef765bb8e74dfeb1f10bef6efa67173d9614423c25059d5c6c4ec752c95833), uint256(0x2f14b7fb04f142477aaf057ca31de47777e297889fb5295d27a76c1a9a11bf71));
        vk.gamma_abc[9] = Pairing.G1Point(uint256(0x233f23c13ed65287ee7a99cb0be4339663fbc959400dd2b6c1f59695ee8639c8), uint256(0x0157b0a334dc75edee87faaaada63e0cd851c2cd968532564cfb997d62e81df8));
        vk.gamma_abc[10] = Pairing.G1Point(uint256(0x0e8a9dfb0dfc71aad18aa2229ca00d763128f613a4d8c536e507ae2d2324a179), uint256(0x11072a0804e082df6c9588b33da215cdc3547e89367e56ede582d9b5a2f3deed));
        vk.gamma_abc[11] = Pairing.G1Point(uint256(0x2cae2799a78a81826864f8bd6f5f279e1fcdf52dc2b3db6db92566e0bed04eab), uint256(0x1f35be3bf3875adca56ac8bcb521c6d5a104f5c18937c2a909875cb9acc036dc));
        vk.gamma_abc[12] = Pairing.G1Point(uint256(0x19f05ce1b385138d2915ea442648a325511e8c48c8b05f9f32f2e1e3d1979389), uint256(0x229292ad94521d4fa1de702407c9fe08016e37fd17e552669af49f3878618b6a));
        vk.gamma_abc[13] = Pairing.G1Point(uint256(0x22c8368bfc08787f271388d5701d5f2b4c1791adfaa7c761cf63b0e6219cafbc), uint256(0x0be7e338b6025d2e4608c639b89cea5c33c5df3c6d3d2bb12ab869703ed25c0c));
        vk.gamma_abc[14] = Pairing.G1Point(uint256(0x12bc15c9bf99119670b56eaaedd3f9269c28863c04579a3faaed6c0686a9435e), uint256(0x252305468e6058e3fa48001c4d4ce1dba651d54c221aa625058fe750f19048e2));
        vk.gamma_abc[15] = Pairing.G1Point(uint256(0x126b1d00e301b5ffd1f532dd751acf5b3a4c91ad83b052d4d06d07ce097fd050), uint256(0x28e9155fe2f79339db1778ffe6da9184359076e614fc4c30cb42701d7a8de7ce));
        vk.gamma_abc[16] = Pairing.G1Point(uint256(0x07773c01590239450d533a8c35cb80a7223392526eea5532cf17f18e605fcdc7), uint256(0x0eae0ac758a8789c4d45283a365754350d1a155d29b219bfee145405a55e6e22));
        vk.gamma_abc[17] = Pairing.G1Point(uint256(0x1b362d318bc93bb86213d9fb4b5861955ea61b9f3ce5a818360eca8081929bc0), uint256(0x24db6f7ac3ffea9c36ee588b5ae014bd63f226917e393b7d51ed876244699c52));
        vk.gamma_abc[18] = Pairing.G1Point(uint256(0x22d415b542a234f846798871c52e05e3c9ea9453a7becd6e177abfb93eded811), uint256(0x1b52eba14a0dc35552fd15580e4947ee4d9f10bb572c264c9e216972d186c083));
        vk.gamma_abc[19] = Pairing.G1Point(uint256(0x13983c60a73b233d2c5924669c4b940c357f4faf73605981e313d20bf0ba71c4), uint256(0x15d18c2fc3b0070d12be5204d4d4f7fab17a9096511284301d2e6533b7d7a065));
        vk.gamma_abc[20] = Pairing.G1Point(uint256(0x13c58cc0f6ae5d2fb2e36d8c7006218d5b0856e66245624935fd2675b4a8cc20), uint256(0x0da8cb4042448780d3550bd8e19b636ebeee1c00c2783fd5c4c1f499e9d5895b));
        vk.gamma_abc[21] = Pairing.G1Point(uint256(0x28405088a2dadcc8928586f333ef158ee6b494d507c8e295cded57307f2c4025), uint256(0x0c26bc4662a96467a72493c9f8d14ca038c81b6f7ee6909e339faa74afe9490b));
        vk.gamma_abc[22] = Pairing.G1Point(uint256(0x06313640ad94d8414c54929a899347ab4ed64f07b8b48662cb07c66faa757f48), uint256(0x2f3684e2c8375fdf034e5da3d28106e4dd0ef39f23da7187350e18b8f0a8ec2b));
        vk.gamma_abc[23] = Pairing.G1Point(uint256(0x07a13df327d2b258293ff871a3a8bbb14021c1a1b267942f6c8ed7202d1cbfd8), uint256(0x256e9cd71485fe36d65bbcd4461e4d998a1e48ff30c76762795dbe7e5eefe9d8));
        vk.gamma_abc[24] = Pairing.G1Point(uint256(0x1cd6fff735d67503fb762320674e286a9b31b497553f75bd692d416193f74cfc), uint256(0x1a80f5b9ddb84c8bfce88cd4b9a8090f397768a693c9cde960da965d42f23776));
        vk.gamma_abc[25] = Pairing.G1Point(uint256(0x1541551912e7a5ec15320135c4d715aac977bad736fed611713c4514ebc217f7), uint256(0x2826a0185da6f837ec0d14ec367616213a26732a585bfea3e4115c7ed8ffc825));
        vk.gamma_abc[26] = Pairing.G1Point(uint256(0x05dfd0c6f7c08058905bb2febf108af0df060d198d91be956ea50d25397ac14c), uint256(0x0511562be0812e99faf37f973e172b3ad435d2f754c3f74c1aa732cfaeac048f));
        vk.gamma_abc[27] = Pairing.G1Point(uint256(0x08f54a4e947f4001a6c4ce12c9bc2ce271dab415ddb22bb85859c36395cddd1b), uint256(0x11641254f31cca201abfc60044ffd1b6ec7734da39a7d82ae8bf5f9f2f093cb1));
        vk.gamma_abc[28] = Pairing.G1Point(uint256(0x2d70a1a46899a965bea0017ceb472acd128ddeebe79450fa79bfb9a3b6b2ed81), uint256(0x2e7ea4bb8260b9d67ba4b62f54ad1c132c07c99a0fcbb035834214eba114e61a));
        vk.gamma_abc[29] = Pairing.G1Point(uint256(0x0f8117d78e90e36bf844fa04c39fc5fefd78f35ec1f34ed2a14a6425011cd347), uint256(0x10524cc29c1df31f299513a8e19298949465ab44fff35a647d825278e6a57ad9));
        vk.gamma_abc[30] = Pairing.G1Point(uint256(0x2ac4d42ddaf2ad2223af4024b138289e0079870e8073d5603dcfb3a530770294), uint256(0x1af36f5eee53d83f363084d6be7a172a937df47be1d7acc708cfe1683ea51b9b));
        vk.gamma_abc[31] = Pairing.G1Point(uint256(0x2092c4fd032b4a6c5434b93139499a0a2058948b211f17461aff77dea3efb204), uint256(0x211654101aa07526894c978b578fe361f762258b339a87a1cc43f5c2a641a524));
        vk.gamma_abc[32] = Pairing.G1Point(uint256(0x1e10440d89202d794a054904b533ed181c20bdc03e6c47590d5b068a7eba7156), uint256(0x189a920fecfcec5b74def5834c5e61845141d33e5f3917fda884a8bb27989cda));
        vk.gamma_abc[33] = Pairing.G1Point(uint256(0x1575b6242225746ddabeb51165141c58074a8349a20161444a19bd24498b2698), uint256(0x00d9f84b6ad2c3588da6163188bddd237351f90f3391dd6c71635ecd6b391e09));
        vk.gamma_abc[34] = Pairing.G1Point(uint256(0x103f4bcd8ae2e2aa90be1294ba0b7be8ec0b47650b460df001004d70ddba3d86), uint256(0x160ca7ae44add602c2b2a1ebda0b6cb954b932ddccbdcacfcd89ab3a52b9167a));
        vk.gamma_abc[35] = Pairing.G1Point(uint256(0x19ca87cf7625703ef2ed0bf922a9de0c99aada0f9bfda377879017c5326b5544), uint256(0x3058ea1d7204b5f2a98c5c2b38f3d7b4da7c871d952762073c95de3dab6a34f7));
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
            Proof memory proof, uint[35] memory input
        ) public view returns (bool r) {
        uint[] memory inputValues = new uint[](35);
        
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
