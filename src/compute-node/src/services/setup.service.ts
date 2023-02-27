import { HttpException } from "@/exceptions/HttpException";
import { setupQueue } from "@/queues/setup.queue";
import { logger } from "@/utils/logger";

export const getJobById = async (id: string) => {
  try {
    const job = await setupQueue.getJob(id);
    return job;
  } catch (e) {
    throw new HttpException(400, e.toString());
  }
};

export const execSetup = async ({ algorithm, price, receiver, dataset }) => {
  try {
    const job = await setupQueue.add("Setup", {
      algorithm,
      price,
      receiver,
      dataset,
    });
    logger.info(`Setup Queue: ${job.id} - status changed: CREATED => WAITING`);
    return job;
  } catch (e) {
    throw new HttpException(400, e.toString());
  }
};

export default { execSetup, getJobById };
