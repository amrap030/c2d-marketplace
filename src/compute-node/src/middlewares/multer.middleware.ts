import { NextFunction, Request, Response } from "express";
import { logger } from "@utils/logger";
import multer from "multer";

const upload = multer({
  limits: { fileSize: 10000000, files: 1 },
}).single("file");

const multerMiddleware = (req: Request, res: Response, next: NextFunction) => {
  upload(req, res, err => {
    if (err instanceof multer.MulterError) {
      let message = "";
      if (err.code === "LIMIT_FILE_SIZE")
        message = "Maximum file size exceeded";
      if (err.code === "LIMIT_FIELD_COUNT")
        message = "Amount of fields in multipart/form-data exceeded";
      if (err.code === "LIMIT_FILE_COUNT")
        message = "Amount of files in multipart/form-data exceeded";
      if (err.code === "LIMIT_PART_COUNT")
        message = "Amount of parts in multipart/form-data exceeded";
      logger.error(
        `[${req.method}] ${req.path} >> StatusCode:: 400, Message:: ${message}`,
      );
      return res
        .status(400)
        .send("Amount of parts in multipart/form-data exceeded");
    } else if (err) {
      logger.error(
        `[${req.method}] ${
          req.path
        } >> StatusCode:: 400, Message:: ${err.toString()}`,
      );
      return res.status(400).send(err.toString());
    }
    next();
  });
};

export default multerMiddleware;
