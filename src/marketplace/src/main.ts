import { createApp } from "vue";
import { App } from "./App";
import "@/assets/styles/app.css";
import "@/assets/styles/web3-onboard.css";

import { gsap } from "gsap";
import ScrollTrigger from "gsap/ScrollTrigger";
import { router, setupRouter } from "./router";
import { setupRouterGuard } from "@/router/guard";
import { setupStore } from "@/store";
import { setupWeb3Onboard } from "@/wallets";
import { setupApolloClients } from "@/graphql";
import { setupGlobalComposables } from "@/composables";

gsap.registerPlugin(ScrollTrigger);

const app = createApp(App);

// Configure store
setupStore(app);

// Configure apollo graphql clients
setupApolloClients();

// Configure routing and head setup
setupRouter(app);
setupRouterGuard(router);

// Configure web3 onboard modal
setupWeb3Onboard();

// Configure global composables
setupGlobalComposables(app);

app.mount("#app");
