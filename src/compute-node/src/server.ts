import { startApp } from "@/app";
import AssetsRouter from "@routes/assets.route";
import SetupRouter from "@/routes/setup.route";

startApp([AssetsRouter(), SetupRouter()]);
