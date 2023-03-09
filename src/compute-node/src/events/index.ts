import ethereum from "@/events/ethereum.events";
import { ordersQueue } from "@/queues/orders.queue";
import { marketplace } from "@/contracts";

const key =
  "0x000000000000000000000000000000000000000000000000000000000000007b";

export const listenToEvents = () => {
  ethereum.on("OrderCreated", async event => {
    const { receiver, algorithm, pkAddress, sessionId } = event.returnValues;
    await ordersQueue.add("Order", {
      receiver,
      algorithm,
      pkAddress,
      sessionId,
    });
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
