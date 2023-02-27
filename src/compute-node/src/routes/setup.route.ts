import { Router } from "express";
import { execSetup, getJob } from "@/controllers/setup.controller";

/**
 * All routes for algorithms
 *
 * @returns {Router} - Express router
 */
const setupRouter = () => {
  const router = Router();
  const PATH = "/setup";

  router.get(
    `${PATH}/:id`,
    async (req, res, next) => await getJob(req, res, next),
  );

  router.post(
    `${PATH}`,
    async (req, res, next) => await execSetup(req, res, next),
  );

  return router;
};

export default setupRouter;
