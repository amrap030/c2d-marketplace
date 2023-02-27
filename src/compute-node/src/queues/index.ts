import {
  ExpressAdapter,
  createBullBoard,
  BullMQAdapter,
} from "@bull-board/express";
import { setupQueue } from "@/queues/setup.queue";
import { ordersQueue } from "@/queues/orders.queue";

export const setupBullBoard = app => {
  const serverAdapter = new ExpressAdapter();
  serverAdapter.setBasePath("/admin/queues");

  createBullBoard({
    queues: [new BullMQAdapter(setupQueue), new BullMQAdapter(ordersQueue)],
    serverAdapter: serverAdapter,
  });

  app.use("/admin/queues", serverAdapter.getRouter());
};
