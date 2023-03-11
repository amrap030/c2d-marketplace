import ethereum from "@/events/ethereum.events";
import { ordersQueue } from "@/queues/orders.queue";
import { marketplace } from "@/contracts";
import { minioClient } from "@/db/minio.s3";
import { Blob } from "buffer";

const PATH = "orders";

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
      const receipt: Blob = await new Promise((resolve, reject) => {
        let size = 0;
        let file;

        minioClient.getObject(
          PATH,
          `${sessionId}/receipt.json`,
          (err, dataStream) => {
            if (err) {
              return reject(err);
            }
            dataStream.on("data", function (chunk) {
              size = size + chunk.length;
              file = new Blob([chunk], { type: "application/json" });
            });
            dataStream.on("end", () => {
              return resolve(file);
            });
            dataStream.on("error", err => {
              return reject(err);
            });
          },
        );
      });

      const parsedReceipt = JSON.parse(await receipt.text());

      const tx = await marketplace.reveal(sessionId, `0x${parsedReceipt.key}`, {
        gasLimit: 30000000,
      });

      await tx.wait();
    } catch (e) {
      console.log(e);
    }
  });

  ethereum.listen();
};
