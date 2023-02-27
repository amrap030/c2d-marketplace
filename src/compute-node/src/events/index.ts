import ethereum from "@/events/ethereum.events";
import { ordersQueue } from "@/queues/orders.queue";
import { logger } from "@/utils/logger";
import { ethers } from "ethers";
import { SENDER_PRIVATE_KEY, MARKETPLACE_ADDRESS } from "@/config";
import { abi } from "@/abi/Marketplace.json";

const provider = new ethers.providers.JsonRpcProvider("http://127.0.0.1:8545");
const signer = new ethers.Wallet(SENDER_PRIVATE_KEY as string, provider);
const marketplace = new ethers.Contract(MARKETPLACE_ADDRESS, abi, signer);

const key =
  "0x9eec88b55d9295bb2ac6d35562a2ca5cebfe4e64feb234c2a8dde95d1b6cd2a2";

export const listenToEvents = () => {
  ethereum.on("OrderCreated", async event => {
    const { receiver, algorithm, pkAddress, sessionId } = event.returnValues;
    const job = await ordersQueue.add("Order", {
      receiver,
      algorithm,
      pkAddress,
      sessionId,
    });
    logger.info(`Order Queue: ${job.id} - status changed: CREATED => WAITING`);
  });

  ethereum.on("OrderAccepted", async event => {
    const { sessionId } = event.returnValues;

    try {
      const tx = await marketplace.reveal(sessionId, key, {
        gasLimit: 30000000,
      });

      await tx.wait();
    } catch (e) {
      console.log(e);
    }
  });

  ethereum.listen();
};
