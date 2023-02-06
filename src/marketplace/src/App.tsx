import LayoutDefault from "@/layouts/default/LayoutDefault.vue";

// export default {
//   setup() {
//     return () => (
//       <router-view>
//         <LayoutDefault />
//       </router-view>
//     );
//   },
// };

export const App = () => (
  <router-view>
    <LayoutDefault />
  </router-view>
);
