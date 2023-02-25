import { ethers } from "hardhat";
import * as dotenv from "dotenv";
import proof from "../contracts/mock/proof.json";

dotenv.config({ path: "../../.env" });

const n = 2;
const length = 32;
const depth = 2;

const keyCommit =
  "0x4833fd0df81fe66248fa7a7a858ace1eb6cda67d46db68de29d210f9811fbac3";

const cipherTextRoot =
  "0xaabc52bbd65f0df6af50c828af1c299d0406898d34ad08b270e31eb4769cd4ec";
const plainDataRoot =
  "0xb1ea444fe88a2ab4f6add48eda24ce89497ced4dee1bf978f818853f35252939";

async function main() {
  const marketplace = await ethers.getContractAt(
    "Marketplace",
    "0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0",
  );

  const provider = new ethers.providers.JsonRpcProvider(
    "http://127.0.0.1:8545",
  );
  const senderWallet = new ethers.Wallet(
    process.env.SENDER_PRIVATE_KEY as string,
  );
  const senderAccount = await senderWallet.connect(provider);

  const sessionId = ethers.utils.soliditySha256(
    ["address", "address", "address"],
    [
      senderAccount.address,
      "0x70997970C51812dc3A010C7d01b50e0d17dc79C8",
      "0x9f1ac54BEF0DD2f6f3462EA0fa94fC62300d3a8e",
    ],
  );

  console.log("Session ID: ", sessionId);

  const tx = await marketplace.connect(senderAccount).proofComputation(
    sessionId,
    depth,
    length,
    n,
    keyCommit,
    cipherTextRoot,
    plainDataRoot,
    proof.inputs,
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    proof.proof as any,
  );

  await tx.wait();
}

main().catch(error => {
  console.error(error);
  process.exitCode = 1;
});
