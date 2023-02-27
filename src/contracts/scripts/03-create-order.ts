import { ethers } from "hardhat";
import * as dotenv from "dotenv";

dotenv.config({ path: "../../.env" });

async function main() {
  const Verifier = await ethers.getContractFactory("Verifier");

  const verifier = await Verifier.deploy();

  await verifier.deployed();

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
    .createOrder(
      "0xCafac3dD18aC6c6e92c921884f9E4176737C052c",
      verifier.address,
      "0x9f1ac54BEF0DD2f6f3462EA0fa94fC62300d3a8e",
      "ipfs://bafkreihuk7qqpdskouyjax5wzpn4wwaktquzjd3flbluz6wbv46m7kt74u/",
    );

  await tx.wait();
}

main().catch(error => {
  console.error(error);
  process.exitCode = 1;
});
