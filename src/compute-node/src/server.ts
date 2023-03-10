import { startApp } from "@/app";
import AssetsRouter from "@routes/assets.route";
import SetupRouter from "@/routes/setup.route";
import OrdersRouter from "@/routes/order.route";

startApp([AssetsRouter(), SetupRouter(), OrdersRouter()]);
