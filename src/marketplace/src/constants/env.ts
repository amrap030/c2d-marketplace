import { getChain } from "evm-chains";

const uniswapV3PolygonSubgraph = `https://api.thegraph.com/subgraphs/name/ianlapham/uniswap-v3-polygon`;

const chain = getChain(Number(import.meta.env["VUE_APP_CHAIN_ID"] || 5));

export const env = {
  uniswapV3PolygonSubgraph,
  chain,
};
