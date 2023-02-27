import { ethers } from "hardhat";
import * as dotenv from "dotenv";

dotenv.config({ path: "../../.env" });

async function main() {
  const ERC721Template = await ethers.getContractFactory("ERC721Template");

  const erc721Template = await ERC721Template.deploy();

  await erc721Template.deployed();

  console.log("✨ Contract address:", erc721Template.address);

  const ERC721Factory = await ethers.getContractFactory("ERC721Factory");

  const erc721Factory = await ERC721Factory.deploy(erc721Template.address);

  await erc721Factory.deployed();

  console.log("✨ Contract address:", erc721Factory.address);

  const Marketplace = await ethers.getContractFactory("Marketplace");

  const marketplace = await Marketplace.deploy();

  await marketplace.deployed();

  console.log("✨ Contract address:", marketplace.address);
}

main().catch(error => {
  console.error(error);
  process.exitCode = 1;
});
