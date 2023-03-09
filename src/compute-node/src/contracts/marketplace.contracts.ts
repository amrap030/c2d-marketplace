import { ethers } from "ethers";
import { SENDER_PRIVATE_KEY, MARKETPLACE_ADDRESS } from "@/config";
import { abi } from "@/contracts/abi/Marketplace.json";

const provider = new ethers.providers.JsonRpcProvider("http://127.0.0.1:8545");
const signer = new ethers.Wallet(SENDER_PRIVATE_KEY as string, provider);

export const marketplace = new ethers.Contract(
  MARKETPLACE_ADDRESS,
  abi,
  signer,
);

const n = 2;
const length = 32;
const depth = 2;

const keyCommit =
  "0x661ffbd00de5aea14a1cdfb143127566abdc469ffe1160b006acc5eacb0f0ead";

const cipherTextRoot =
  "0xa5215d05f9f454d2395e8604813ff4667435e1308d6781a9f437a51a6dd853f1";

export const proofComputation = async ({ sessionId, inputs, proof }) => {
  console.log(inputs);
  console.log(proof);

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
