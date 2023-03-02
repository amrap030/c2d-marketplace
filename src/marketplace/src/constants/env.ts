import { getChain } from "evm-chains";

const TEMPLATE_ADDRESS = "0x5FbDB2315678afecb367f032d93F642f64180aa3";
const FACTORY_ADDRESS = "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512";
const MARKETPLACE_ADDRESS = "0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0";
const API_GATEWAY = "http://localhost:8060";

const uniswapV3PolygonSubgraph = `https://api.thegraph.com/subgraphs/name/ianlapham/uniswap-v3-polygon`;
const c2dSubgraph = `${API_GATEWAY}/subgraph`;

const localChain = {
  name: "Hardhat Local Chain",
  chainId: 31337,
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
  c2dSubgraph,
  chain,
  TEMPLATE_ADDRESS,
  FACTORY_ADDRESS,
  MARKETPLACE_ADDRESS,
  API_GATEWAY,
};
