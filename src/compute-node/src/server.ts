import { startApp } from "@/app";
import AssetsRouter from "@routes/assets.route";
import ComputeRouter from "@routes/compute.route";

startApp([AssetsRouter(), ComputeRouter()]);
