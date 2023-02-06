import type { RouterScrollBehavior } from "vue-router";

export default (function (to) {
  if (to.query.el) {
    return { el: to.query.el, behavior: "smooth" };
  } else if (to.hash) {
    return { el: to.hash, behavior: "smooth" };
  } else {
    return { top: 0 };
  }
} as RouterScrollBehavior);
