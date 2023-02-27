import { minioClient } from "@/db/minio.db";
import { HttpException } from "@/exceptions/HttpException";
import { Blob } from "buffer";
import mime from "mime-types";

const PATH = "assets";

export const getAssets = async (folder: string): Promise<Blob> => {
  try {
    const assets = await new Promise((resolve, reject) => {
      const data = [];

      const stream = minioClient.listObjects(PATH, `${folder}/`, false);

      stream.on("data", obj => {
        data.push(obj);
      });
      stream.on("end", () => {
        return resolve(data);
      });
      stream.on("error", err => {
        return reject(err);
      });
    });

    const asset: Blob = await new Promise((resolve, reject) => {
      let size = 0;
      let file;
      minioClient.getObject(PATH, assets[0].name, (err, dataStream) => {
        if (err) {
          return reject(err);
        }
        const type = mime.lookup(assets[0].name);
        dataStream.on("data", function (chunk) {
          size = size + chunk.length;
          file = new Blob([chunk], { type });
        });
        dataStream.on("end", () => {
          return resolve(file);
        });
        dataStream.on("error", err => {
          return reject(err);
        });
      });
    });

    return asset;
  } catch (e) {
    throw new HttpException(400, e.toString());
  }
};

export const addAssets = async (folder: string, file: any) => {
  try {
    return await new Promise((resolve, reject) => {
      minioClient.putObject(
        PATH,
        `${folder}/${file.originalname}`,
        file.buffer,
        (err, objInfo) => {
          if (err) {
            reject(err);
          }
          resolve(objInfo);
        },
      );
    });
  } catch (e) {
    throw new HttpException(400, e.toString());
  }
};

export default { getAssets, addAssets };
