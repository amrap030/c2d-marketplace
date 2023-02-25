import { ethers } from "hardhat";
import * as dotenv from "dotenv";

dotenv.config({ path: "../../.env" });

async function main() {
  const ERC721Factory = await ethers.getContractFactory("ERC721Factory");

  const erc721Factory = await ERC721Factory.deploy(
    "0x5FbDB2315678afecb367f032d93F642f64180aa3",
  );

  await erc721Factory.deployed();

  console.log("✨ Contract address:", erc721Factory.address);

  const provider = new ethers.providers.JsonRpcProvider(
    "http://127.0.0.1:8545",
  );
  const senderWallet = new ethers.Wallet(
    process.env.SENDER_PRIVATE_KEY as string,
  );
  const senderAccount = await senderWallet.connect(provider);

  const tx = await erc721Factory
    .connect(senderAccount)
    .cloneContract(
      senderAccount.address,
      "GODDOG-95",
      "Godly Dogma Token",
      "ipfs://bafkreihuk7qqpdskouyjax5wzpn4wwaktquzjd3flbluz6wbv46m7kt74u/",
      0,
      { gasLimit: 30000000 },
    );

  const txReceipt = await tx.wait();

  if (txReceipt.events) {
    const event = txReceipt.events.find(
      event => event.event === "ERC721Created",
    );
    const newTokenAddress = (event?.args as string[])[3] as string;
    console.log("Dataset: ", newTokenAddress);
  }

  const developerWallet = new ethers.Wallet(
    process.env.SENDER_PRIVATE_KEY as string,
  );
  const developerAccount = await developerWallet.connect(provider);

  const tx2 = await erc721Factory
    .connect(developerAccount)
    .cloneContract(
      developerAccount.address,
      "Spiky Nose Token",
      "SPINOS-67",
      "ipfs://bafkreihuk7qqpdskouyjax5wzpn4wwaktquzjd3flbluz6wbv46m7kt74u/",
      1,
      { gasLimit: 30000000 },
    );

  const txReceipt2 = await tx2.wait();

  if (txReceipt2.events) {
    const event = txReceipt2.events.find(
      event => event.event === "ERC721Created",
    );
    const newTokenAddress = (event?.args as string[])[3] as string;
    console.log("Algorithm: ", newTokenAddress);
  }
}

main().catch(error => {
  console.error(error);
  process.exitCode = 1;
});
