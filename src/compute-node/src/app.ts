import compression from "compression";
import cookieParser from "cookie-parser";
import cors from "cors";
import express, { Router } from "express";
import helmet from "helmet";
import hpp from "hpp";
import morgan from "morgan";
import swaggerJSDoc from "swagger-jsdoc";
import swaggerUi from "swagger-ui-express";
import { PORT, LOG_FORMAT } from "@config";
import errorMiddleware from "@middlewares/error.middleware";
import { logger, stream } from "@utils/logger";

const app = express();

const listen = () => {
  app.listen(PORT, () => {
    logger.info(`=================================`);
    logger.info(`🚀 App listening on the port ${PORT}`);
    logger.info(`=================================`);
  });
};

const initializeMiddlewares = () => {
  app.use(morgan(LOG_FORMAT, { stream }));
  app.use(cors({ origin: "*", credentials: true }));
  app.use(hpp());
  app.use(helmet());
  app.use(compression());
  app.use(express.json());
  app.use(express.urlencoded({ extended: true }));
  app.use(cookieParser());
};

const initializeRoutes = (routes: any) => {
  routes.forEach(route => {
    app.use("/v1", route);
  });
};

const initializeSwagger = () => {
  const options = {
    swaggerDefinition: {
      info: {
        title: "REST API",
        version: "1.0.0",
        description: "Example docs",
      },
    },
    apis: ["swagger.yaml"],
  };

  const specs = swaggerJSDoc(options);
  app.use("/api-docs", swaggerUi.serve, swaggerUi.setup(specs));
};

const initializeErrorHandling = () => {
  app.use(errorMiddleware);
};

export const startApp = (routes: Router[]) => {
  initializeMiddlewares();
  initializeRoutes(routes);
  initializeSwagger();
  initializeErrorHandling();
  listen();
};
