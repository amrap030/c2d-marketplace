import { Queue } from "bullmq";
import { CONNECTION } from "@/db/redis.db";

export const ordersQueue = new Queue("Order", {
  connection: CONNECTION,
});
