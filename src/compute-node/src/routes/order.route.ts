import { Router } from "express";
import { getReceiptByOrderId } from "@/controllers/orders.controller";

/**
 * All routes for orders
 *
 * @returns {Router} - Express router
 */
const ordersRouter = () => {
  const router = Router();
  const PATH = "/orders";

  router.get(
    `${PATH}/:id/receipt`,
    async (req, res, next) => await getReceiptByOrderId(req, res, next),
  );

  return router;
};

export default ordersRouter;
