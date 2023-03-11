import { ethers } from "ethers";
import { SENDER_PRIVATE_KEY, MARKETPLACE_ADDRESS } from "@/config";
import { abi } from "@/contracts/abi/Marketplace.json";
import crypto from "crypto";

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

export const proofComputation = async ({
  sessionId,
  inputs,
  proof,
  key,
  root,
}) => {
  const keyCommit = crypto
    .createHash("sha256")
    .update(Buffer.from(key, "hex"))
    .digest("hex");
  try {
    const tx = await marketplace
      .connect(signer)
      .proofComputation(
        sessionId,
        depth,
        length,
        n,
        `0x${keyCommit}`,
        `0x${root}`,
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
