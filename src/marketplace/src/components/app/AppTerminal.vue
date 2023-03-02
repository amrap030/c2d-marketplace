<template>
  <div class="mt-4 -mx-4 sm:mx-0 lg:mt-0 lg:col-span-7 xl:col-span-6">
    <div
      class="relative flex overflow-hidden shadow-xl bg-slate-800 sm:rounded-xl dark:bg-slate-900/70 dark:backdrop-blur dark:ring-1 dark:ring-inset dark:ring-white/10"
    >
      <div class="relative flex flex-col w-full">
        <div class="flex items-center border-b border-slate-500/30">
          <div class="flex items-center h-8 space-x-1.5 px-3">
            <div class="w-2.5 h-2.5 bg-slate-600 rounded-full"></div>
            <div class="w-2.5 h-2.5 bg-slate-600 rounded-full"></div>
            <div class="w-2.5 h-2.5 bg-slate-600 rounded-full"></div>
          </div>
          <code
            class="absolute flex justify-center w-full text-sm text-slate-200"
            >{{ filename }}</code
          >
        </div>
        <div class="relative flex flex-col flex-auto min-h-0">
          <div class="flex flex-auto w-full min-h-0">
            <div class="relative flex-auto w-full">
              <Code :code="code" :loading="loading" />
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import Code from "@/components/app/AppCode";

defineProps({
  code: {
    type: String,
    required: true,
  },
  filename: {
    type: String,
    required: true,
  },
  loading: {
    type: Boolean,
    required: true,
  },
});
</script>
