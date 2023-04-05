import * as dotenv from "dotenv";
import { HardhatUserConfig, task } from "hardhat/config";
import "@nomiclabs/hardhat-etherscan";
import "@nomiclabs/hardhat-waffle";
import "@typechain/hardhat";
import "hardhat-gas-reporter";
import "solidity-coverage";
import "hardhat-contract-sizer";

dotenv.config();

task("accounts", "Prints the list of accounts", async (_, hre) => {
  const accounts = await hre.ethers.getSigners();
  for (const account of accounts) {
    console.log(account.address);
  }
});

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.17",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
      viaIR: true,
    },
  },
  defaultNetwork: "local",
  networks: {
    local: {
      url: "http://127.0.0.1:8545",
      blockGasLimit: 30_000_000,
    },
    goerli: {
      url:
        `https://eth-goerli.g.alchemy.com/v2/${process.env.ALCHEMY_GOERLI_KEY}` ||
        "",
      accounts:
        process.env.ETH_ACCOUNT_PRIVATE_KEY !== undefined
          ? [process.env.ETH_ACCOUNT_PRIVATE_KEY]
          : [],
      allowUnlimitedContractSize: true,
    },
  },
  gasReporter: {
    enabled: true,
    token: "MATIC",
    currency: "USD",
    gasPrice: 250,
    coinmarketcap: "3f8bf723-10ad-422d-b62f-7550e4af730c",
  },
  etherscan: {
    apiKey: {
      goerli: process.env.ALCHEMY_GOERLI_KEY || "",
    },
  },
  contractSizer: {
    alphaSort: true,
    disambiguatePaths: false,
    runOnCompile: true,
    strict: true,
  },
};

export default config;
