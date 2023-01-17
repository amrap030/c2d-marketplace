import { ethers } from "hardhat";
import ContractArguments from "../config/ContractArguments";
import CollectionConfig from "../config/CollectionConfig";
import * as dotenv from "dotenv";

dotenv.config();

async function main() {
  const C2D = await ethers.getContractFactory(CollectionConfig.contractName);

  const wallet = new ethers.Wallet(process.env.SIGNER_PKEY as string);

  console.log("✨ Signer public key:", wallet.address);
  console.log(
    "🚨 Please save this private key carefully to create vouchers:",
    wallet.privateKey
  );

  const c2d = await C2D.deploy(
    CollectionConfig.paymentSplitterAddress,
    wallet.address,
    ContractArguments[2]
  );

  await c2d.deployed();

  console.log("✨ Contract address:", c2d.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
