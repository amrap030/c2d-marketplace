import { defineStore } from "pinia";
import { store } from "@/store";

export const useAppStore = defineStore({
  id: "app",
  state: () => ({}),
  getters: {},
  actions: {},
});

export function createAppStore() {
  return useAppStore(store);
}
