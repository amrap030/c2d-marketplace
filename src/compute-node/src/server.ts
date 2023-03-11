import { startApp } from "@/app";
import SetupRouter from "@/routes/setup.route";
import OrdersRouter from "@/routes/order.route";

startApp([SetupRouter(), OrdersRouter()]);
