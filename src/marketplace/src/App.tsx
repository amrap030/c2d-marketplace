import LayoutDefault from "@/layouts/default/LayoutDefault.vue"; // export

export const App = () => (
  <router-view>
    {({ Component }) => <LayoutDefault is={Component} />}
  </router-view>
);
