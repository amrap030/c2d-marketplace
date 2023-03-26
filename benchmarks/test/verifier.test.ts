import { ethers } from "hardhat";
import { expect } from "chai";
import { Verifier } from "../typechain";
import proof from "../contracts/proof.json";

describe("Verifier", async () => {
  let verifier: Verifier;

  before(async function () {
    const Verifier = await ethers.getContractFactory("Verifier");

    verifier = await Verifier.deploy();
    await verifier.deployed();
  });

  it("verify proof", async () => {
    expect(await verifier.verifyTx(proof.proof, proof.inputs)).to.be.ok;
  });
});
