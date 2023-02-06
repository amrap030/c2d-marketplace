import { defineStore } from "pinia";
import { store } from "@/store";
import { ethers } from "ethers";
import { computed, ref, shallowRef, watch } from "vue";
import { useOnboard } from "@web3-onboard/vue";
import { getShortAddress } from "@/utils/ethereum";
import Jazzicon from "@raugfer/jazzicon";
import { hexlify, hexStripZeros } from "ethers/lib/utils";
import { env } from "@/constants";

export const useUserStore = defineStore("drip-user", () => {
  const { connectWallet, ...web3Onboard } = useOnboard();

  // state
  const balance = ref<string>("0");
  const image = ref<string>("");

  // useful instances
  const provider = shallowRef<ethers.providers.Web3Provider | undefined>();
  const signer = shallowRef<ethers.Signer | undefined>();
  const network = shallowRef<ethers.providers.Network | undefined>();
  const displayName = computed<string>(
    () =>
      account.value?.ens?.name || getShortAddress(account.value?.address || ""),
  );
  const isConnected = computed<boolean>(
    () => web3Onboard.alreadyConnectedWallets.value.length > 0,
  );
  const account = computed(
    () => web3Onboard.connectedWallet?.value?.accounts[0] || null,
  );
  const ens = computed(() => account.value?.ens);

  // methods
  const refreshState = async () => {
    provider.value = new ethers.providers.Web3Provider(
      web3Onboard.connectedWallet.value
        ?.provider as ethers.providers.ExternalProvider,
    );
    image.value =
      ens.value?.avatar?.url ||
      "data:image/svg+xml;base64," +
        window.btoa(Jazzicon(account.value?.address || ""));
    signer.value = provider.value.getSigner();
    balance.value = await getBalance(account.value?.address);
    network.value = await provider.value.getNetwork();
  };

  const resetState = () => {
    balance.value = "0";
    image.value = "";
    provider.value = undefined;
    signer.value = undefined;
    network.value = undefined;
  };

  const getBalance = async (
    addressOrName = account.value?.address,
  ): Promise<string> => {
    return provider.value
      ? ethers.utils
          .formatEther(await provider.value.getBalance(addressOrName || ""))
          .toString()
      : "0";
  };

  const connect = async (options?: any) => {
    await connectWallet(options);
    if (isConnected.value) {
      await web3Onboard.setChain({
        chainId: hexStripZeros(hexlify(env.chain.chainId)),
        wallet: web3Onboard.alreadyConnectedWallets.value[0],
      });
    }
  };

  if (web3Onboard.alreadyConnectedWallets.value[0]) {
    void connect({
      autoSelect: {
        label: web3Onboard.alreadyConnectedWallets.value[0],
        disableModals: true,
      },
    });
  }

  watch(web3Onboard.connectedWallet, async () => {
    if (isConnected.value) {
      await refreshState();
    } else {
      resetState();
    }
  });

  return {
    ...web3Onboard,
    image,
    isConnected,
    account,
    ens,
    displayName,
    provider,
    signer,
    network,
    balance,
    connect,
  };
});

// Need to be used outside the setup
export function useUserStoreWithOut() {
  return useUserStore(store);
}
