import { ethers } from "hardhat";
import * as dotenv from "dotenv";

dotenv.config({ path: "../../.env" });

const sessionId =
  "0xcdcc901d0d433e382ba17a142d566d311f1d0a41ff6c9ee0c18192393c77b4e9";

const key =
  "0x9eec88b55d9295bb2ac6d35562a2ca5cebfe4e64feb234c2a8dde95d1b6cd2a2";

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

  const tx = await marketplace.connect(senderAccount).reveal(sessionId, key);

  await tx.wait();
}

main().catch(error => {
  console.error(error);
  process.exitCode = 1;
});
