import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "hardhat-gas-reporter";
import "hardhat-contract-sizer";

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.19",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  defaultNetwork: "local",
  networks: {
    local: {
      url: "http://127.0.0.1:8545",
      blockGasLimit: 30_000_000,
    },
  },
  gasReporter: {
    enabled: true,
    token: "ETH",
    currency: "USD",
    gasPrice: 20,
    coinmarketcap: "3f8bf723-10ad-422d-b62f-7550e4af730c",
  },
  contractSizer: {
    alphaSort: true,
    disambiguatePaths: false,
    runOnCompile: true,
    strict: true,
  },
};

export default config;
