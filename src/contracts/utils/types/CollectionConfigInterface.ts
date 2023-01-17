import NetworkConfigInterface from "./NetworkConfigInterface";

interface SaleConfig {
  price: number;
  maxMintAmountPerTx: number;
}

export default interface CollectionConfigInterface {
  testnet: NetworkConfigInterface;
  mainnet: NetworkConfigInterface;
  contractName: string;
  tokenName: string;
  tokenSymbol: string;
  maxSupply: number;
  maxReserved: number;
  whitelistSale: SaleConfig;
  publicSale: SaleConfig;
  payeesAdresses: string[];
  payeesShares: number[];
  contractMetadata: string;
  tokenBaseUri: string;
  paymentSplitterAddress: string;
  contractAddress: string | null;
  signerAddress: string;
  adminAddress: string;
}
