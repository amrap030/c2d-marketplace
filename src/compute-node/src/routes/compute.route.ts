import { Router } from "express";
import { initComputation } from "@/controllers/compute.controller";

/**
 * All routes for NFT assets
 *
 * @returns {Router} - Express router
 */
const computeRouter = () => {
  const router = Router();
  const PATH = "/computations";

  router.post(
    `${PATH}/output`,
    async (req, res, next) => await initComputation(req, res, next),
  );

  return router;
};

export default computeRouter;
