import { init } from "@web3-onboard/vue";
import injected from "./injected";
import { env } from "@/constants";
import { hexlify, hexStripZeros } from "ethers/lib/utils";

const wallets = [injected];

export const setupWeb3Onboard = function () {
  const rpcUrl = `http://localhost:8545`;

  return init({
    wallets,
    theme: "light",
    chains: [
      {
        id: hexStripZeros(hexlify(env.chain.chainId)),
        token: env.chain.nativeCurrency.symbol,
        label: env.chain.network,
        rpcUrl,
      },
    ],
    accountCenter: {
      desktop: { enabled: false },
      mobile: { enabled: false },
    },
  });
};
