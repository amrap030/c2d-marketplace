import type { RouteRecordRaw } from "vue-router";
import type { App } from "vue";
import { createRouter, createWebHistory } from "vue-router";
import { createHead } from "@vueuse/head";
import HomeView from "@/views/home/HomeView.vue";
import scrollBehavior from "@/router/scrollBehavior";

const routes: Array<RouteRecordRaw> = [
  {
    path: "/",
    name: "home",
    component: HomeView,
  },
  {
    path: "/create",
    name: "create",
    component: () =>
      import(
        /* webpackChunkName: "create-token" */ "@/views/create/CreateView.vue"
      ),
  },
  {
    path: "/:pathMatch(.*)*",
    redirect: "/",
  },
];

export const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes,
  scrollBehavior,
});

export const head = createHead({
  titleTemplate: `C2D — %s`,
});

export function setupRouter(app: App<Element>) {
  app.use(router);
  app.use(head);
}
