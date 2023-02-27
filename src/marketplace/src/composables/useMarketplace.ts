import { useUserStore } from "@/store/modules/user";
import { ethers, ContractFactory, type ContractInterface } from "ethers";
import { env } from "@/constants";
import ERC721Factory from "@/constants/abi/ERC721Factory.json";
import Marketplace from "@/constants/abi/Marketplace.json";
import type { ERC721Factory as ERC721FactoryType } from "@/typechain";
import type { Marketplace as MarketplaceType } from "@/typechain";
import { watch } from "vue";
import { storeToRefs } from "pinia";
import { wordlist } from "@/utils";

interface OfferInput {
  nftAddress: string;
  algorithms: string[];
  prices: number[];
}

export function useMarketplace() {
  const { signer, provider, account } = storeToRefs(useUserStore());
  let factory: ERC721FactoryType;
  let marketplace: MarketplaceType;

  watch(provider, () => {
    if (provider) {
      factory = new ethers.Contract(
        env.FACTORY_ADDRESS,
        ERC721Factory.abi as any,
        provider.value,
      ) as ERC721FactoryType;

      marketplace = new ethers.Contract(
        env.MARKETPLACE_ADDRESS,
        Marketplace.abi as any,
        provider.value,
      ) as MarketplaceType;
    }
  });

  const createAlgorithm = async (cid: string) => {
    if (!account.value || !signer.value) {
      throw new Error("No account, signer or signature available");
    }

    try {
      const { name, symbol } = wordlist.getRandomSymbolAndName();
      const signedContract = factory.connect(signer.value);

      console.log(name);
      const tx = await signedContract.cloneContract(
        account.value.address,
        name,
        symbol,
        cid,
        1,
      );

      return await tx.wait();
    } catch (e) {
      console.log(e);
    }
  };

  const createDataset = async (cid: string) => {
    if (!account.value || !signer.value) {
      throw new Error("No account, signer or signature available");
    }

    try {
      const { name, symbol } = wordlist.getRandomSymbolAndName();
      const signedContract = factory.connect(signer.value);

      const tx = await signedContract.cloneContract(
        account.value.address,
        name,
        symbol,
        cid,
        0,
      );

      return await tx.wait();
    } catch (e) {
      console.log(e);
    }
  };

  const createOffer = async ({
    nftAddress,
    algorithms,
    prices,
  }: OfferInput) => {
    if (!account.value || !signer.value) {
      throw new Error("No account, signer or signature available");
    }

    try {
      const signedContract = marketplace.connect(signer.value);

      const tx = await signedContract.createOffer(
        nftAddress,
        algorithms,
        prices,
      );

      return await tx.wait();
    } catch (e) {
      console.log(e);
    }
  };

  const deployVerifier = async (program: string, abi: ContractInterface) => {
    if (!account.value || !signer.value) {
      throw new Error("No account, signer or signature available");
    }

    try {
      const factory = new ContractFactory(abi, program);
      // If your contract requires constructor args, you can specify them here
      const contract = await factory.connect(signer.value).deploy();

      return contract.address;
    } catch (e) {
      console.log(e);
    }
  };

  const createOrder = async ({
    nftAddress,
    verifierAddress,
    algorithmAddress,
    pkUrl,
  }) => {
    if (!account.value || !signer.value) {
      throw new Error("No account, signer or signature available");
    }

    try {
      const signedContract = marketplace.connect(signer.value);

      const tx = await signedContract.createOrder(
        nftAddress,
        verifierAddress,
        algorithmAddress,
        pkUrl,
      );

      return await tx.wait();
    } catch (e) {
      console.log(e);
    }
  };

  const acceptOrder = async (sessionId: string, price: number) => {
    if (!account.value || !signer.value) {
      throw new Error("No account, signer or signature available");
    }

    try {
      const signedContract = marketplace.connect(signer.value);

      const tx = await signedContract.buy(sessionId, { value: price });

      return await tx.wait();
    } catch (e) {
      console.log(e);
    }
  };

  return {
    account,
    createAlgorithm,
    createDataset,
    createOffer,
    createOrder,
    acceptOrder,
    deployVerifier,
  };
}
