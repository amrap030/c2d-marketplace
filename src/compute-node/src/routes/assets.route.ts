import { Router } from "express";
import { getAssets, addAssets } from "@/controllers/assets.controller";
import multer from "@middlewares/multer.middleware";

/**
 * All routes for NFT assets
 *
 * @returns {Router} - Express router
 */
const assetsRouter = () => {
  const router = Router();
  const PATH = "/assets";

  router.get(
    `${PATH}/:tokenAddress`,
    async (req, res, next) => await getAssets(req, res, next),
  );

  router.post(
    `${PATH}/:tokenAddress`,
    (req, res, next) => multer(req, res, next),
    async (req, res, next) => await addAssets(req, res, next),
  );

  return router;
};

export default assetsRouter;
