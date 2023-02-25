import { ethers } from "hardhat";
import * as dotenv from "dotenv";

dotenv.config({ path: "../../.env" });

async function main() {
  const ERC721Template = await ethers.getContractFactory("ERC721Template");

  const erc721Template = await ERC721Template.deploy();

  await erc721Template.deployed();

  console.log("✨ Contract address:", erc721Template.address);
}

main().catch(error => {
  console.error(error);
  process.exitCode = 1;
});
