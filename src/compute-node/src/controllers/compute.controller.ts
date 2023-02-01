import { NextFunction, Request, Response } from "express";
import ComputeService from "@services/compute.service";
// import { HttpException } from "@/exceptions/HttpException";

export const initComputation = async (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  try {
    await ComputeService.initComputation();
    return res.status(200).end();
  } catch (e) {
    next(e);
  }
};
