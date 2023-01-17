import CollectionConfigInterface from "../utils/types/CollectionConfigInterface";
import { ethereumTestnet, ethereumMainnet } from "../utils/constants";

const CollectionConfig: CollectionConfigInterface = {
  testnet: ethereumTestnet,
  mainnet: ethereumMainnet,
  // The contract name can be updated using the following command:
  // yarn rename-contract NEW_CONTRACT_NAME NEW_SYMBOL
  // Please DO NOT change it manually!
  contractName: "C2D",
  tokenName: "C2D",
  tokenSymbol: "C2D",
  // from here it can be updated manually in this file, then run yarn configure-contract
  maxSupply: 1000,
  maxReserved: 100,
  whitelistSale: {
    price: 0.0001,
    maxMintAmountPerTx: 2,
  },
  publicSale: {
    price: 0.0005,
    maxMintAmountPerTx: 5,
  },
  contractMetadata: "ipfs://.../",
  tokenBaseUri: "ipfs://.../",
  adminAddress: "...",
  // necessary for splitter contract and nft contract
  payeesShares: [60, 40],
  payeesAdresses: ["...", "..."],
  paymentSplitterAddress: "...",
  // necessary after contract deployment
  signerAddress: "...",
  // rest
  contractAddress: "...",
};

export default CollectionConfig;
