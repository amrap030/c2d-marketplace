import { ethers } from "hardhat";
import * as dotenv from "dotenv";

dotenv.config({ path: "../../.env" });

const sessionId =
  "0xcdcc901d0d433e382ba17a142d566d311f1d0a41ff6c9ee0c18192393c77b4e9";

async function main() {
  const marketplace = await ethers.getContractAt(
    "Marketplace",
    "0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0",
  );

  const provider = new ethers.providers.JsonRpcProvider(
    "http://127.0.0.1:8545",
  );
  const receiverWallet = new ethers.Wallet(
    process.env.RECEIVER_PRIVATE_KEY as string,
  );
  const receiverAccount = await receiverWallet.connect(provider);

  const tx = await marketplace
    .connect(receiverAccount)
    .buy(sessionId, { value: 10 });

  await tx.wait();
}

main().catch(error => {
  console.error(error);
  process.exitCode = 1;
});
