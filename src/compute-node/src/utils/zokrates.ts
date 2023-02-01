import { spawn } from "child_process";
import { logger } from "@utils/logger";
import fs from "fs";

const isProgramExisting = (dir: string) => fs.existsSync(`${dir}/main.zok`);

const isCompilationExisting = (dir: string) =>
  fs.existsSync(`${dir}/out`) &&
  fs.existsSync(`${dir}/out.r1cs`) &&
  fs.existsSync(`${dir}/abi.json`);

const isProofExisting = (dir: string) => fs.existsSync(`${dir}/proof.json`);

const areKeysExisting = (dir: string) =>
  fs.existsSync(`${dir}/proving.key`) &&
  fs.existsSync(`${dir}/verification.key`);

const isWitnessExisting = (dir: string) => fs.existsSync(`${dir}/witness`);

/**
 * Generic function to execute shell commands in a sub process.
 *
 * @example
 * execProcess(["compile", "-i", "main.zok"], "./zokrates");
 *
 * @param {String} command - Commands to be executed (automatically prefixed by "zokrates")
 * @param {String} cwd - Context (directory) in which shell commands should be executed
 */
const execProcess = async (command: string[], cwd: string) => {
  await new Promise((resolve, reject) => {
    const child = spawn(
      process.env.NODE_ENV === "development" ? "zokrates" : "/app/zokrates",
      command,
      {
        stdio: ["ignore", "pipe", "pipe"],
        cwd,
        shell: true,
        env: {
          PATH: "$PATH:~/.zokrates/bin",
          ZOKRATES_HOME: "/app/stdlib",
        },
      },
    );

    let output = "";

    child.stdout.on("data", data => {
      output = output + data;
    });

    child.stderr.on("data", err => {
      reject(new Error(err));
    });

    child.on("close", () => {
      if (output.includes("panicked")) {
        logger.error(`Process panicked.`);
        reject(new Error(output.slice(output.indexOf("panicked"))));
      }
      resolve(output);
    });
  });
};

/**
 * Compiles a zokrates program at specified directory and writes result to the same directory.
 *
 * @example
 * compile("./zokrates");
 *
 * @param {String} dir - Path of the zokrates program
 */
export const compile = async (dir: string) => {
  try {
    if (!isProgramExisting(dir))
      throw new Error("Program doesn't exist. Aborting compilation.");

    logger.info("Compilation started");
    const start = Date.now();

    await execProcess(["compile", "-i", "main.zok"], dir);

    const end = Date.now();
    logger.info("Compilation finished.");
    logger.info(`Compilation elapsed time: ${end - start} ms.`);
  } catch (e) {
    logger.error(e.toString());
    throw new Error(e.toString());
  }
};

/**
 * Executes the trusted setup in the specified directory and generates evidence key pair.
 *
 * @example
 * setup("./zokrates");
 *
 * @param {String} dir - Path of the zokrates artifacts
 */
export const setup = async (dir: string) => {
  try {
    if (!isCompilationExisting(dir))
      throw new Error("Compiled files don't exist. Aborting trusted setup.");

    logger.info("Trusted setup started");
    const start = Date.now();

    await execProcess(["setup"], dir);

    const end = Date.now();
    logger.info("Trusted setup finished.");
    logger.info(`Trusted setup elapsed time: ${end - start} ms.`);
  } catch (e) {
    logger.error(e.toString());
    throw new Error(e.toString());
  }
};

/**
 * Computes a witness in the specified directory.
 *
 * @example
 * computeWitness("./zokrates");
 *
 * @param {String} dir - Path of the zokrates artifacts
 */
export const computeWitness = async (input: string[], dir: string) => {
  try {
    if (!isCompilationExisting(dir))
      throw new Error(
        "Compiled files don't exist. Aborting witness computation.",
      );

    logger.info("Witness computation started");
    const start = Date.now();

    await execProcess(["compute-witness", "-a", ...input], dir);

    const end = Date.now();
    logger.info("Witness computation finished.");
    logger.info(`Witness computation elapsed time: ${end - start} ms.`);
  } catch (e) {
    logger.error(e.toString());
    throw new Error(e.toString());
  }
};

/**
 * Generates a proof in the specified directory.
 *
 * @example
 * generateProof("./zokrates");
 *
 * @param {String} dir - Path of the zokrates artifacts
 */
export const generateProof = async (dir: string) => {
  try {
    if (!isCompilationExisting(dir) || !isWitnessExisting(dir))
      throw new Error("Compiled files don't exist. Aborting proof generation.");

    logger.info("Proof generation started");
    const start = Date.now();

    await execProcess(["generate-proof"], dir);

    const end = Date.now();
    logger.info("Proof generation finished.");
    logger.info(`Proof generation elapsed time: ${end - start} ms.`);
  } catch (e) {
    logger.error(e.toString());
    throw new Error(e.toString());
  }
};

/**
 * Exports a verifier smart contract in the specified directory.
 *
 * @example
 * exportVerifier("./zokrates");
 *
 * @param {String} dir - Path of the zokrates artifacts
 */
export const exportVerifier = async (dir: string) => {
  try {
    if (
      !isCompilationExisting(dir) ||
      !isWitnessExisting(dir) ||
      !areKeysExisting(dir) ||
      !isProofExisting(dir)
    )
      throw new Error(
        "Compiled files don't exist. Aborting smart contract export generation.",
      );

    logger.info("Smart contract export started");
    const start = Date.now();

    await execProcess(["export-verifier"], dir);

    const end = Date.now();
    logger.info("Smart contract export finished.");
    logger.info(`Smart contract export elapsed time: ${end - start} ms.`);
  } catch (e) {
    logger.error(e.toString());
    throw new Error(e.toString());
  }
};
