import { config } from "dotenv";
config({ path: `../../.env` });

export const {
  NODE_ENV,
  PORT,
  LOG_FORMAT,
  LOG_DIR,
  MARKETPLACE_ADDRESS,
  SENDER_PRIVATE_KEY,
} = process.env;
