import { startApp } from "@/app";
import AssetsRouter from "@routes/assets.route";
import ComputeRouter from "@/routes/computations.route";

startApp([AssetsRouter(), ComputeRouter()]);
