import { NextFunction, Request, Response } from "express";
import SetupService from "@/services/setup.service";
// import { HttpException } from "@/exceptions/HttpException";

export const getJob = async (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  const { id } = req.params;
  try {
    const job = await SetupService.getJobById(id);
    return res.status(201).json(job);
  } catch (e) {
    next(e);
  }
};

export const execSetup = async (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  const { algorithm, price, receiver, dataset } = req.body;
  try {
    const job = await SetupService.execSetup({
      algorithm,
      price,
      receiver,
      dataset,
    });
    return res.status(201).json(job);
  } catch (e) {
    next(e);
  }
};
