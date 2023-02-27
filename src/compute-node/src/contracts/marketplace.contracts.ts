import { ethers } from "ethers";
import { SENDER_PRIVATE_KEY, MARKETPLACE_ADDRESS } from "@/config";
import { abi } from "@/contracts/abi/Marketplace.json";

const provider = new ethers.providers.JsonRpcProvider("http://127.0.0.1:8545");
const signer = new ethers.Wallet(SENDER_PRIVATE_KEY as string, provider);
const marketplace = new ethers.Contract(MARKETPLACE_ADDRESS, abi, signer);

const n = 2;
const length = 32;
const depth = 2;

const keyCommit =
  "0x4833fd0df81fe66248fa7a7a858ace1eb6cda67d46db68de29d210f9811fbac3";

const cipherTextRoot =
  "0xaabc52bbd65f0df6af50c828af1c299d0406898d34ad08b270e31eb4769cd4ec";
const plainDataRoot =
  "0xb1ea444fe88a2ab4f6add48eda24ce89497ced4dee1bf978f818853f35252939";

export const proofComputation = async ({ sessionId, inputs, proof }) => {
  try {
    const tx = await marketplace
      .connect(signer)
      .proofComputation(
        sessionId,
        depth,
        length,
        n,
        keyCommit,
        cipherTextRoot,
        plainDataRoot,
        inputs,
        proof,
        {
          gasLimit: 30000000,
        },
      );

    await tx.wait();
  } catch (e) {
    console.log(e);
  }
};
