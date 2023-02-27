<template>
  <div class="flex items-center gap-4">
    <AppButton :fullWidth="false" @click.prevent="mintAlgorithm">
      Mint Algorithm
    </AppButton>
    <AppButton :fullWidth="false" @click.prevent="mintDataset">
      Mint Dataset
    </AppButton>
    <AppButton :fullWidth="false" @click.prevent="makeOffer">
      Make Offer
    </AppButton>
    <AppButton :fullWidth="false" @click.prevent="prepareOrder">
      Prepare Order
    </AppButton>
    <AppButton :fullWidth="false" @click.prevent="makeOrder">
      Make Order
    </AppButton>
    <AppButton :fullWidth="false" @click.prevent="buy">
      Accept Order
    </AppButton>
  </div>
</template>

<script lang="ts" setup>
import AppButton from "@/components/app/AppButton";
import { useMarketplace } from "@/composables/useMarketplace";
import { useIpfs } from "@/composables/useIpfs";
import { metadata } from "@/utils";
import { ethers } from "ethers";
import sum32 from "@/constants/abi/sum32/abi.json";
import {
  GetAlgorithmsDocument,
  GetDatasetsDocument,
  GetOrdersDocument,
} from "@/../.graphclient";
import { useApolloClient } from "@vue/apollo-composable";
import { ref } from "vue";

const { resolveClient } = useApolloClient();
const client = resolveClient();

const setupJob = ref();

const program = `import "hashes/sha256/1024bitPadded.code" as sha256_1024;
import "hashes/sha256/512bitPadded.code" as sha256_512;
import "hashes/sha256/256bitPadded.code" as sha256_256;
import "signatures/verifyEddsa.code" as verifyEddsa;
import "ecc/babyjubjubParams.code" as context;
import "utils/pack/u32/nonStrictUnpack256.code" as unpack;
import "utils/pack/u32/pack256.code" as pack256;
import "utils/casts/u32_to_field.code" as u32_to_field;
from "ecc/babyjubjubParams" import BabyJubJubParams;

def main(private u32[32] values, private field nonce, private field[2] R, private field S, field[2] A, u32[8] M0, u32[8] M1) -> (bool, bool, field) {
    // verify signature
    BabyJubJubParams context = context();
    bool isVerified = verifyEddsa(R, S, A, M0, M1, context);
    assert(isVerified);

    // calculate hash of input values from dataset
    u32[8] hash = sha256_1024(values[0..8],values[8..16],values[16..24],values[24..32]);

    // check integrity of input values
    bool isHashMatching = hash == M0 && hash == M1;
    assert(isHashMatching);

    // computation of sum
    field mut sum = 0;
    for u32 i in 0..32 {
        sum = sum + u32_to_field(values[i]);
    }

    // create merkle tree
    u32[8] h_computation = sha256_256(unpack(sum));
    u32[8] h_nonce = sha256_256(unpack(nonce));

    field result = pack256(sha256_512(h_computation, h_nonce));

    return (isVerified, isHashMatching, result);
}
`;

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

const mintAlgorithm = async () => {
  const createdAt = new Date().toISOString();
  const updatedAt = createdAt;
  try {
    const programCID = await addToIpfs(program);
    const abiCID = await addToIpfs(sum32);

    console.log(abiCID);
    const data = metadata.createAlgorithmMetadata({
      programUri: programCID.path,
      programSize: programCID.size,
      programCreatedAt: createdAt,
      programUpdatedAt: updatedAt,
      programChecksum: ethers.utils
        .sha256(ethers.utils.toUtf8Bytes(program))
        .slice(2),
      abiUri: abiCID.path,
      abiSize: abiCID.size,
      abiCreatedAt: createdAt,
      abiUpdatedAt: updatedAt,
      abiChecksum: ethers.utils
        .sha256(ethers.utils.toUtf8Bytes(JSON.stringify(sum32)))
        .slice(2),
    });

    const metadataCid = await addToIpfs(data);
    console.log(metadataCid);
    await createAlgorithm(metadataCid.path);
  } catch (e) {
    console.log(e);
  }
};

const mintDataset = async () => {
  try {
    const data = metadata.createDatasetMetadata({
      rows: 100,
    });

    const metadataCid = await addToIpfs(data);

    await createDataset(metadataCid.path);
  } catch (e) {
    console.log(e);
  }
};

const makeOffer = async () => {
  try {
    const [{ data: algorithms }, { data: datasets }] = await Promise.all([
      client.query({ query: GetAlgorithmsDocument }),
      client.query({ query: GetDatasetsDocument }),
    ]);

    console.log({
      ...algorithms.tokens[0],
      metadata: JSON.parse(datasets.tokens[0].metadata),
    });

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

const prepareOrder = async () => {
  console.log("test");
  try {
    const { data: datasets } = await client.query({
      query: GetDatasetsDocument,
      fetchPolicy: "no-cache",
    });
    console.log(datasets);
    const offers = datasets.tokens[0].offers;

    if (offers && offers.length) {
      const offer = offers[0];

      const metadata = JSON.parse(offer.algorithm.metadata as string);

      const res = await fetch("http://localhost:3000/v1/setup", {
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
      console.log(setupJob.value);
    }
  } catch (e) {
    console.log(e);
  }
};

const makeOrder = async () => {
  try {
    console.log();
    const res = await fetch(`http://localhost:3000/v1/setup/${1}`, {
      method: "GET",
    });

    const result = await res.json();

    console.log(result.returnvalue.abi.slice(7));
    const abiRes = await fetch(
      `http://localhost:8081/ipfs/${result.returnvalue.abi.slice(7)}`,
      {
        method: "GET",
      },
    );

    const byteCodeRes = await fetch(
      `http://localhost:8081/ipfs/${result.returnvalue.byteCode.slice(7)}`,
      {
        method: "GET",
      },
    );

    const abi = await abiRes.json();
    const program = await byteCodeRes.text();

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
    console.log(order);

    await acceptOrder(order.id, order.price);
  } catch (e) {
    console.log(e);
  }
};
</script>
