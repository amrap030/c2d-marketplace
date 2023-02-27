import * as Minio from "minio";

export const minioClient = new Minio.Client({
  endPoint: "127.0.0.1",
  port: 9000,
  useSSL: false,
  accessKey: "root",
  secretKey: "changeme",
});
