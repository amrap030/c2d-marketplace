<template>
  <AppButton @click.prevent="start"> Mint Dataset </AppButton>
</template>

<script lang="ts" setup>
import AppButton from "@/components/app/AppButton";
import { useMarketplace } from "@/composables/useMarketplace";
import { useIpfs } from "@/composables/useIpfs";
import wordlist from "@/constants/adjectives.txt";

const { mint } = useMarketplace();
const { addToIpfs } = useIpfs();

const start = async () => {
  // await addToIpfs();
  const tx = await mint();
  // const receipt = await tx?.wait();
  // console.log(receipt);
};
</script>
