<template>
  <div
    class="sticky top-0 z-20 flex-none w-full supports-backdrop-blur:bg-white/60 backdrop-blur shadow-[0_1px_3px_rgba(15,23,42,0.08)]"
  >
    <header
      class="flex flex-col items-center justify-center w-full py-4 mx-auto max-w-7xl"
    >
      <nav
        class="relative flex items-center justify-start w-full mx-auto space-x-8"
      >
        <router-link
          class="mr-auto text-lg font-bold pointer-events-auto"
          to="/"
        >
          C2D <span class="font-normal">Marketplace</span>
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
const { connect } = user;
</script>
