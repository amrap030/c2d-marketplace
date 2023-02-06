import { init } from "@web3-onboard/vue";
import injected from "./injected";
import { env } from "@/constants";
import { hexlify, hexStripZeros } from "ethers/lib/utils";

const wallets = [injected];

export const setupWeb3Onboard = function () {
  const rpcUrl = `https://goerli.infura.io/v3/063b375ba6ea4f2a956e15aae6c937fe`;

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
