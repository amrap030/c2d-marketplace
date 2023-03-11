import { Worker, Job } from "bullmq";
import { CONNECTION, CONCURRENCY } from "@/db/redis.db";
import {
  compile,
  setup,
  exportVerifier,
  generateProof,
  computeWitness,
} from "@/utils/zokrates";
import { logger } from "@/utils/logger";
import { create } from "ipfs-http-client";
import { proofComputation, getMetadataUri } from "@/contracts";
import solc from "solc";
import all from "it-all";
import fs from "fs";
import crypto from "crypto";
import axios from "axios";
import { h2d } from "@/utils/util";
import { HttpException } from "@/exceptions/HttpException";
import { minioClient } from "@/db/minio.s3";

const ipfs = create({ protocol: "http", port: 5001, host: "localhost" });

const getFromIpfs = async (
  cid: string,
  type = "string",
): Promise<string | any> => {
  const content = Buffer.concat(
    await all(ipfs.cat(cid.startsWith("ipfs://") ? cid.slice(7) : cid)),
  );
  if (type === "buffer") return content;
  if (type === "object") return JSON.parse(content.toString());
  return content.toString();
};

const createInput = (program: string) => {
  return {
    language: "Solidity",
    sources: {
      "verifier.sol": {
        content: program,
      },
    },
    settings: {
      outputSelection: {
        "*": {
          "*": ["*"],
        },
      },
    },
  };
};

const updateJob = async (job: Job, percent: number) => {
  await job.updateProgress(percent);
  logger.info(
    `${job.queueName} Queue: ${job.id} - Progress: ${percent}%  [${"#".repeat(
      percent / 5,
    )}${" ".repeat(20 - percent / 5)}]`,
  );
};

const createDir = (path: string) => fs.mkdirSync(path, { recursive: true });
const writeProgram = (path: string, program: string) =>
  fs.writeFileSync(`${path}/main.zok`, program);
const readFile = (path: string) => fs.readFileSync(path);

new Worker(
  "Setup",
  async (job: Job) => {
    const path = `./${job.data.receiver}`;
    try {
      logger.info(`Setup Queue: ${job.id} - status changed: CREATED => ACTIVE`);

      const algorithm = await getFromIpfs(job.data.algorithm);
      createDir(path);
      writeProgram(path, algorithm);
      await updateJob(job, 20);
      await compile(path, job);
      await updateJob(job, 40);
      await setup(path, job);
      await updateJob(job, 60);
      await exportVerifier(path, job);
      await updateJob(job, 80);
      const pKey = readFile(`${path}/proving.key`);
      const pKeyCid = await ipfs.add(pKey);
      const verifier = readFile(`${path}/verifier.sol`)
        .toString()
        .replace(
          /Proof memory proof, uint[[0-9]*] memory input/g,
          "Proof memory proof, uint[] memory input",
        );
      const verifierCid = await ipfs.add(verifier);
      await updateJob(job, 100);
      logger.info(
        `Setup Queue: ${job.id} - status changed: ACTIVE => COMPLETED`,
      );
      const output = JSON.parse(
        solc.compile(JSON.stringify(createInput(verifier))),
      );
      const [abiCid, byteCodeCid] = await Promise.all([
        ipfs.add(JSON.stringify(output.contracts["verifier.sol"].Verifier.abi)),
        ipfs.add(output.contracts["verifier.sol"].Verifier.evm.bytecode.object),
      ]);
      return {
        pkUrl: `ipfs://${pKeyCid.path}`,
        verifier: `ipfs://${verifierCid.path}`,
        byteCode: `ipfs://${byteCodeCid.path}`,
        abi: `ipfs://${abiCid.path}`,
      };
    } catch (e) {
      console.log(e);
    }
  },
  { connection: CONNECTION, concurrency: CONCURRENCY },
);

const addAssets = async (bucket: string, dir: string, file: any) => {
  try {
    return await new Promise((resolve, reject) => {
      minioClient.putObject(bucket, `${dir}`, file, (err, objInfo) => {
        if (err) {
          reject(err);
        }
        resolve(objInfo);
      });
    });
  } catch (e) {
    throw new HttpException(400, e.toString());
  }
};

const nonce = crypto.randomBytes(32).toString("hex");
const encKey = crypto.randomBytes(32).toString("hex");

const witnessInput = [
  "0",
  "0",
  "0",
  "0",
  "0",
  "0",
  "0",
  "0",
  "0",
  "0",
  "0",
  "0",
  "0",
  "0",
  "0",
  "0",
  "0",
  "0",
  "0",
  "0",
  "0",
  "0",
  "0",
  "0",
  "0",
  "0",
  "0",
  "0",
  "0",
  "0",
  "0",
  "5",
  h2d(nonce),
  "211284057869832099014035831622581185257648010655577101702555687051243543409",
  "86879352787595152790056029059697888577935271275983373879547195205771125316",
  "5978134405341758551626751406772071994675738548173425210367593014524857184155",
  "14585667688433000900526094642007891500577536322172190101886149081050508696387",
  "7474072388531090642842522123389324618269331295188349932287210707451279630008",
  "4020509860",
  "2781309769",
  "1565908955",
  "4179055392",
  "1078672512",
  "1219727025",
  "2268767843",
  "976631939",
  "4020509860",
  "2781309769",
  "1565908955",
  "4179055392",
  "1078672512",
  "1219727025",
  "2268767843",
  "976631939",
];

const createLog = ({
  encoding,
  program,
  duration,
  constraints,
  createdAt,
  root,
}) => {
  return {
    program,
    result: {
      encoding,
      root,
      duration,
      constraints,
      createdAt,
      updatedAt: createdAt,
    },
  };
};

new Worker(
  "Order",
  async (job: Job) => {
    const { receiver, algorithm, pkAddress, sessionId } = job.data;
    const start = Date.now();
    const path = `./${receiver}`;

    try {
      logger.info(`Order Queue: ${job.id} - status changed: CREATED => ACTIVE`);

      const metadataUri = await getMetadataUri(algorithm);
      const metadata = await getFromIpfs(metadataUri, "object");
      const program = metadata?.assets?.find(asset => asset.type == "program");
      const rawProgram = await getFromIpfs(program.uri);
      createDir(path);
      writeProgram(path, rawProgram);
      await updateJob(job, 20);
      const { constraints } = await compile(path, job);
      const out = fs.readFileSync(`${path}/out`);
      const outR1CS = fs.readFileSync(`${path}/out.r1cs`);
      await Promise.all([
        addAssets("orders", `${sessionId}/out`, out),
        addAssets("orders", `${sessionId}/out.r1cs`, outR1CS),
      ]);
      await updateJob(job, 40);
      const pKey = await getFromIpfs(pkAddress, "buffer");
      fs.writeFileSync(`${path}/proving.key`, pKey);
      await updateJob(job, 60);
      const { computationStdout } = await computeWitness(
        witnessInput,
        path,
        job,
      );
      const witness = readFile(`${path}/witness`);
      const outWitness = readFile(`${path}/out.wtns`);
      await Promise.all([
        addAssets("orders", `${sessionId}/witness`, witness),
        addAssets("orders", `${sessionId}/out.wtns`, outWitness),
      ]);
      await updateJob(job, 80);
      await generateProof(path, job);
      const generatedProof = readFile(`${path}/proof.json`).toString();
      const { proof, inputs } = JSON.parse(generatedProof);

      const { data } = await axios.post("http://localhost:7777/api/encoding", {
        result: Number(computationStdout),
        nonce: nonce,
        key: encKey,
      });

      await Promise.all([
        addAssets("orders", `${sessionId}/proof.json`, generatedProof),
        proofComputation({
          sessionId,
          inputs,
          proof,
          key: encKey,
          root: data.root,
        }),
      ]);
      await updateJob(job, 100);

      logger.info(
        `Order Queue: ${job.id} - status changed: ACTIVE => COMPLETED`,
      );

      const end = Date.now();
      const createdAt = new Date().toISOString();

      const log = createLog({
        program,
        encoding: data.encoding,
        root: data.root,
        duration: end - start,
        constraints,
        createdAt,
      });

      await addAssets(
        "orders",
        `${sessionId}/receipt.json`,
        JSON.stringify({ ...log, key: encKey }, null, 2),
      );
      return log;
    } catch (e) {
      console.log(e);
    }
  },
  { connection: CONNECTION, concurrency: CONCURRENCY },
);
