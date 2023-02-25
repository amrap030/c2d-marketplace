import { ethers } from "hardhat";
import * as dotenv from "dotenv";

dotenv.config({ path: "../../.env" });

async function main() {
  const Marketplace = await ethers.getContractFactory("Marketplace");

  const marketplace = await Marketplace.deploy();

  await marketplace.deployed();

  console.log("✨ Contract address:", marketplace.address);
}

main().catch(error => {
  console.error(error);
  process.exitCode = 1;
});
