import { ethers } from "ethers";
import { SENDER_PRIVATE_KEY } from "@/config";
import { abi } from "@/contracts/abi/ERC721Template.json";

const provider = new ethers.providers.JsonRpcProvider("http://127.0.0.1:8545");
const signer = new ethers.Wallet(SENDER_PRIVATE_KEY as string, provider);

export const getMetadataUri = async (address: string) => {
  try {
    const erc721Contract = new ethers.Contract(address, abi, signer);
    const metadataUri = await erc721Contract.tokenURI(1);
    return metadataUri;
  } catch (e) {
    console.log(e);
  }
};
