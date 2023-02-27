import { Queue } from "bullmq";
import { CONNECTION } from "@/db/redis.db";

export const setupQueue = new Queue("Setup", {
  connection: CONNECTION,
});
