import { HttpException } from "@/exceptions/HttpException";
import { minioClient } from "@/db/minio.db";
import { Blob } from "buffer";

const PATH = "orders";

export const getReceipt = async (folder: string): Promise<Blob> => {
  try {
    const receipt: Blob = await new Promise((resolve, reject) => {
      let size = 0;
      let file;

      minioClient.getObject(
        PATH,
        `${folder}/receipt.json`,
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

    return JSON.parse(await receipt.text());
  } catch (e) {
    throw new HttpException(400, e.toString());
  }
};

export default { getReceipt };
