import { ethers } from "hardhat";
import * as dotenv from "dotenv";

dotenv.config({ path: "../../.env" });

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

  const tx = await marketplace
    .connect(senderAccount)
    .createOffer(
      "0xCafac3dD18aC6c6e92c921884f9E4176737C052c",
      ["0x9f1ac54BEF0DD2f6f3462EA0fa94fC62300d3a8e"],
      [10],
    );

  await tx.wait();
}

main().catch(error => {
  console.error(error);
  process.exitCode = 1;
});
