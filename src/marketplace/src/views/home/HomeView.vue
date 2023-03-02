<template>
  <div class="flex flex-col gap-4">
    <Terminal :loading="false" :code="zokratesSum32" filename="main.zok" />
    <Terminal
      :loading="false"
      :code="JSON.stringify(sum32, null, 2)"
      filename="abi.json"
    />
    <AppButton
      class="ml-auto"
      :fullWidth="false"
      @click.prevent="mintAlgorithm"
    >
      Mint Algorithm
    </AppButton>
    <Terminal
      :loading="algorithmLoading"
      :code="algorithmMetadata"
      filename="algorithm-metadata.json"
    />
    <AppButton class="ml-auto" :fullWidth="false" @click.prevent="mintDataset">
      Mint Dataset
    </AppButton>
    <Terminal
      :loading="datasetLoading"
      :code="datasetMetadata"
      filename="dataset-metadata.json"
    />
    <AppButton class="ml-auto" :fullWidth="false" @click.prevent="makeOffer">
      Make Offer
    </AppButton>
    <AppButton class="ml-auto" :fullWidth="false" @click.prevent="fetchOffers">
      Get Offer
    </AppButton>
    <Terminal
      :loading="offersLoading"
      :code="offers || ''"
      filename="offer.json"
    />
    <AppButton class="ml-auto" :fullWidth="false" @click.prevent="prepareOrder">
      Prepare Order
    </AppButton>
    <AppButton class="ml-auto" :fullWidth="false" @click.prevent="makeOrder">
      Make Order
    </AppButton>
    <Terminal
      :loading="bytecodeLoading"
      :code="bytecode || ''"
      filename="bytecode.json"
    />
    <AppButton
      class="ml-auto"
      :fullWidth="false"
      @click.prevent="fetchFileSessions"
    >
      Get File Session
    </AppButton>
    <Terminal
      :loading="fileSessionLoading"
      :code="fileSession || ''"
      filename="file-session.json"
    />
    <AppButton class="ml-auto" :fullWidth="false" @click.prevent="buy">
      Accept Order
    </AppButton>
  </div>
</template>

<script lang="ts" setup>
import { useMarketplace } from "@/composables/useMarketplace";
import { useIpfs } from "@/composables/useIpfs";
import { metadata } from "@/utils";
import { ethers } from "ethers";
import {
  GetAlgorithmsDocument,
  GetDatasetsDocument,
  GetOrdersDocument,
  GetFileSessionsDocument,
  GetTokensWithOffersDocument,
} from "@/../.graphclient";
import { useApolloClient } from "@vue/apollo-composable";
import { ref } from "vue";
import { env } from "@/constants";
import sum32 from "@/constants/abi/sum32/abi.json";
import Terminal from "@/components/app/AppTerminal.vue";
import AppButton from "@/components/app/AppButton";
import { zokratesSum32 } from "@/constants/programs";
import { utils } from "@/utils";

const { resolveClient } = useApolloClient();
const client = resolveClient();

const setupJob = ref();

const { addToIpfs } = useIpfs();
const {
  createAlgorithm,
  createDataset,
  createOffer,
  createOrder,
  acceptOrder,
  deployVerifier,
  account,
} = useMarketplace();

const algorithmMetadata = ref("");
const algorithmLoading = ref(false);

const mintAlgorithm = async () => {
  const createdAt = new Date().toISOString();
  const updatedAt = createdAt;

  try {
    algorithmLoading.value = true;
    await utils.delay(2000);

    const programCID = await addToIpfs(zokratesSum32);
    const abiCID = await addToIpfs(sum32);

    const data = metadata.createAlgorithmMetadata({
      programUri: programCID.path,
      programSize: programCID.size,
      programCreatedAt: createdAt,
      programUpdatedAt: updatedAt,
      programChecksum: ethers.utils
        .sha256(ethers.utils.toUtf8Bytes(zokratesSum32))
        .slice(2),
      abiUri: abiCID.path,
      abiSize: abiCID.size,
      abiCreatedAt: createdAt,
      abiUpdatedAt: updatedAt,
      abiChecksum: ethers.utils
        .sha256(ethers.utils.toUtf8Bytes(JSON.stringify(sum32)))
        .slice(2),
    });

    algorithmMetadata.value = JSON.stringify(data, null, 2);
    algorithmLoading.value = false;

    const metadataCid = await addToIpfs(data);
    await createAlgorithm(metadataCid.path);
  } catch (e) {
    console.log(e);
  }
};

const datasetMetadata = ref("");
const datasetLoading = ref(false);

const mintDataset = async () => {
  try {
    datasetLoading.value = true;
    await utils.delay(2000);
    const data = metadata.createDatasetMetadata({
      rows: 100,
    });

    const metadataCid = await addToIpfs(data);

    datasetMetadata.value = JSON.stringify(data, null, 2);
    datasetLoading.value = false;
    await createDataset(metadataCid.path);
  } catch (e) {
    console.log(e);
  }
};

const makeOffer = async () => {
  try {
    const [{ data: algorithms }, { data: datasets }] = await Promise.all([
      client.query({ query: GetAlgorithmsDocument, fetchPolicy: "no-cache" }),
      client.query({ query: GetDatasetsDocument, fetchPolicy: "no-cache" }),
    ]);

    if (datasets && algorithms) {
      const dataset = datasets.tokens[0];
      const algorithm = algorithms.tokens[0];

      await createOffer({
        nftAddress: dataset.id,
        algorithms: [algorithm.id],
        prices: [10],
      });
    }
  } catch (e) {
    console.log(e);
  }
};

const offers = ref();
const offersLoading = ref(false);

const fetchOffers = async () => {
  try {
    offersLoading.value = true;

    const { data } = await client.query({
      query: GetTokensWithOffersDocument,
      fetchPolicy: "no-cache",
    });

    offersLoading.value = false;

    if (data) {
      const token = data.tokens.find(token => {
        if (token.offers) return token.offers.length > 0;
      });
      offers.value = JSON.stringify(token, null, 2);
    }
  } catch (e) {
    console.log(e);
  }
};

const prepareOrder = async () => {
  try {
    const { data: datasets } = await client.query({
      query: GetDatasetsDocument,
      fetchPolicy: "no-cache",
    });
    const offers = datasets.tokens[0].offers;

    if (offers && offers.length) {
      const offer = offers[0];
      const metadata = JSON.parse(offer.algorithm.metadata as string);

      const res = await fetch(`${env.API_GATEWAY}/api/setup`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          dataset: offer.dataset.id,
          algorithm: metadata.assets[0].uri,
          receiver: account.value?.address,
          price: offer.price,
        }),
      });

      setupJob.value = await res.json();
    }
  } catch (e) {
    console.log(e);
  }
};

const fileSession = ref();
const fileSessionLoading = ref(false);

const fetchFileSessions = async () => {
  try {
    fileSessionLoading.value = true;
    const { data } = await client.query({
      query: GetFileSessionsDocument,
      fetchPolicy: "no-cache",
    });

    fileSessionLoading.value = false;
    if (data)
      fileSession.value = JSON.stringify(data.fileSaleSessions[0], null, 2);
  } catch (e) {
    console.log(e);
  }
};

const bytecode = ref();
const bytecodeLoading = ref(false);

const makeOrder = async () => {
  try {
    const res = await fetch(
      `${env.API_GATEWAY}/api/setup/${setupJob.value.id}`,
      {
        method: "GET",
      },
    );

    const result = await res.json();

    bytecodeLoading.value = true;

    const [abiRes, byteCodeRes] = await Promise.all([
      fetch(`http://localhost:8081/ipfs/${result.returnvalue.abi.slice(7)}`, {
        method: "GET",
      }),
      fetch(
        `http://localhost:8081/ipfs/${result.returnvalue.byteCode.slice(7)}`,
        {
          method: "GET",
        },
      ),
    ]);

    const abi = await abiRes.json();
    const program = await byteCodeRes.text();
    bytecode.value = JSON.stringify({ abi, bytecode: program }, null, 2);

    bytecodeLoading.value = false;

    const verifierAddress = await deployVerifier(program, abi);

    const { data: datasets } = await client.query({
      query: GetDatasetsDocument,
      fetchPolicy: "no-cache",
    });

    const offers = datasets.tokens[0].offers;

    if (offers && offers.length) {
      const offer = offers[0];

      await createOrder({
        nftAddress: offer.dataset.id,
        algorithmAddress: offer.algorithm.id,
        pkUrl: result.returnvalue.pkUrl,
        verifierAddress,
      });
    }
  } catch (e) {
    console.log(e);
  }
};

const buy = async () => {
  try {
    const { data: orders } = await client.query({
      query: GetOrdersDocument,
      fetchPolicy: "no-cache",
    });

    const order = orders.fileSaleSessions[0];

    await acceptOrder(order.id, order.price);
  } catch (e) {
    console.log(e);
  }
};
</script>
