import { getChain } from "evm-chains";

const uniswapV3PolygonSubgraph = `https://api.thegraph.com/subgraphs/name/ianlapham/uniswap-v3-polygon`;

const localChain = {
  name: "Hardhat Local Chain",
  chainId: 1337,
  shortName: "hh",
  chain: "ETH",
  network: "hardhat",
  networkId: 5,
  nativeCurrency: {
    name: "Hardhat Ether",
    symbol: "ETH",
    decimals: 18,
  },
  rpc: ["http://localhost:8545/"],
  faucets: [],
  infoURL: "",
};

const chain =
  import.meta.env.MODE === "development"
    ? localChain
    : getChain(Number(import.meta.env["VUE_APP_CHAIN_ID"]));

export const env = {
  uniswapV3PolygonSubgraph,
  chain,
};
