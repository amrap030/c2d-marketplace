import { NextFunction, Request, Response } from "express";
import AssetsService from "@services/assets.service";
import { HttpException } from "@/exceptions/HttpException";

export const getAssets = async (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  const { tokenAddress } = req.params;
  try {
    if (!tokenAddress) throw new HttpException(400, "Invalid token address");

    const asset = await AssetsService.getAssets(tokenAddress);
    const arrayBuffer = await asset.arrayBuffer();
    const buffer = Buffer.from(arrayBuffer);

    res.setHeader("Content-Type", asset.type);
    res.setHeader(
      "Content-Disposition",
      `attachment; filename=${new Date().toJSON().slice(0, 10)}.json`,
    );
    res.setHeader("Content-Length", asset.size);

    return res.status(200).end(buffer);
  } catch (e) {
    next(e);
  }
};

/**
 * Get Servers
 */
export const addAssets = async (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  const { tokenAddress } = req.params;
  const file = req.file;
  try {
    if (!tokenAddress) throw new HttpException(400, "Invalid token address");
    if (!file) throw new HttpException(400, "Missing file");

    const asset = await AssetsService.addAssets(tokenAddress, file);

    return res.status(201).json(asset);
  } catch (e) {
    next(e);
  }
};
