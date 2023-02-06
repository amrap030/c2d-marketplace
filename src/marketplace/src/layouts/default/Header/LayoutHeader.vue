<template>
  <div class="sticky top-0 z-40 flex-none w-full lg:z-50">
    <header class="mx-auto max-w-7xl">
      <nav
        class="relative flex items-center justify-start flex-1 w-full px-8 mx-auto space-x-4 lg:px-12 md:space-x-8"
      >
        <router-link class="block pointer-events-auto !mr-auto" to="/">
          Icon
        </router-link>
        <AppButton
          class="pointer-events-auto !background-blur-sm"
          size="md"
          rounded="base"
          @click.prevent="connect()"
        >
          Connect Wallet
        </AppButton>
      </nav>
    </header>
  </div>
</template>

<script lang="ts" setup>
import AppButton from "@/components/app/AppButton";
import { useUserStore } from "@/store/modules/user";

const user = useUserStore();
const { connect, disconnectConnectedWallet, isConnected } = user;
</script>
