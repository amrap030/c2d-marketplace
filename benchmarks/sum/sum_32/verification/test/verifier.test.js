const fs = require("fs");

const Verifier = artifacts.require("Verifier");

contract("Verifier", _ => {
  let verifier;

  let proof;

  before(async () => {
    verifier = await Verifier.new();
  });

  it("loads proof", async () => {
    let txt = await fs.readFileSync("../zokrates/proof.json", "utf8");
    assert.ok(txt.length > 0);
    proof = JSON.parse(txt);
    assert.ok(proof);
  });

  it("verifies proof", async () => {
    const isTrue = await verifier.verifyTx(proof.proof, proof.inputs);
    assert.ok(isTrue);
    // const receipt = await verifier.contract.methods.verifyTx(
    //   proof.proof,
    //   proof.inputs,
    // );
    // console.log(await receipt.call());
    // console.log(await receipt.estimateGas());
    //      assert.ok(_verified);
  });
});
