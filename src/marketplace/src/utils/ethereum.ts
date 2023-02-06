import { ethers } from "ethers";

// return first 5 and last 5 characters of ethereum account address
export const getShortAddress = (address: string): string => {
  if (parseInt(address) === 0) return "Null address";
  return `${address.substring(0, 5)}...${address.substring(
    address.length - 5,
    address.length,
  )}`;
};

// convert wei to gwei
export const weiToGwei = (eth: string | number): number => {
  return Number(ethers.utils.formatUnits(eth, "gwei"));
};

// convert wei to eth
export const weiToEth = (wei: string | number): number => {
  return Number(ethers.utils.formatEther(wei));
};
