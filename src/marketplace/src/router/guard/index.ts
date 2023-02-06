import type { Router } from "vue-router";
import { createGuard } from "@/router/guard/mobileMenuGuard";

export function setupRouterGuard(router: Router) {
  createGuard(router);
}
