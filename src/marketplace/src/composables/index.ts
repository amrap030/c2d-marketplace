import type { App } from "vue";
import { createCurrency, CURRENCY_CONTEXT } from "@/composables/useCurrency";

export function setupGlobalComposables(app: App<Element>) {
  app.provide(CURRENCY_CONTEXT, createCurrency());
}
