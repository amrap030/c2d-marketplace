import { NextFunction, Request, Response } from "express";
import OrderService from "@/services/orders.service";
import { HttpException } from "@/exceptions/HttpException";

export const getReceiptByOrderId = async (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  const { id } = req.params;
  try {
    if (!id) throw new HttpException(400, "Missing id");
    const receipt = await OrderService.getReceipt(id);
    return res.status(200).json(receipt);
  } catch (e) {
    next(e);
  }
};
