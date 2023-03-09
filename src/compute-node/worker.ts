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
import { addAssets } from "@/services/assets.service";
import crypto from "crypto";

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
  job.queueName;
  await job.updateProgress(percent);
  logger.info(
    `${job.queueName} Queue: ${job.id} - Progress: ${percent}%  [${"#".repeat(
      percent / 5,
    )}${" ".repeat(20 - percent / 5)}]`,
  );
};

const ipfs = create({ protocol: "http", port: 5001, host: "localhost" });

const createDir = (path: string) => fs.mkdirSync(path, { recursive: true });
const writeProgram = (path: string, program: string) =>
  fs.writeFileSync(`${path}/main.zok`, program);

new Worker(
  "Setup",
  async (job: Job) => {
    try {
      const content = Buffer.concat(
        await all(ipfs.cat(job.data.algorithm.slice(7))),
      );
      const raw = content.toString();
      logger.info(`Setup Queue: ${job.id} - status changed: CREATED => ACTIVE`);
      const path = `./${job.data.receiver}`;
      createDir(path);
      writeProgram(path, raw);
      await updateJob(job, 20);
      await compile(path, job);
      await updateJob(job, 40);
      await setup(path, job);
      await updateJob(job, 60);
      await exportVerifier(path, job);
      await updateJob(job, 80);
      const pKey = fs.readFileSync(`${path}/proving.key`);
      const pKeyCid = await ipfs.add(pKey);
      const verifier = fs
        .readFileSync(`${path}/verifier.sol`)
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
  "123",
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

const createLog = ({ encoding, program, duration, constraints, createdAt }) => {
  return {
    program,
    result: {
      encoding,
      duration,
      constraints,
      createdAt,
      updatedAt: createdAt,
    },
  };
};

const nonce = crypto.randomBytes(32).toString("hex");

new Worker(
  "Order",
  async (job: Job) => {
    const { receiver, algorithm, pkAddress, sessionId } = job.data;

    try {
      const start = Date.now();
      const metadataUri = await getMetadataUri(algorithm);
      const metadata = JSON.parse(
        Buffer.concat(await all(ipfs.cat(metadataUri.slice(7)))).toString(),
      );
      const program = metadata.assets.find(asset => asset.type == "program");
      const content = Buffer.concat(await all(ipfs.cat(program.uri.slice(7))));
      const raw = content.toString();
      logger.info(`Order Queue: ${job.id} - status changed: CREATED => ACTIVE`);
      const path = `./${receiver}`;
      createDir(path);
      writeProgram(path, raw);
      await updateJob(job, 20);
      const { constraints } = await compile(path, job);
      const out = fs.readFileSync(`${path}/out`);
      const outR1CS = fs.readFileSync(`${path}/out.r1cs`);
      await Promise.all([
        addAssets("sales", `${receiver}/${algorithm}/out`, out),
        addAssets("sales", `${receiver}/${algorithm}/out.r1cs`, outR1CS),
      ]);
      await updateJob(job, 40);
      const data = Buffer.concat(await all(ipfs.cat(pkAddress.slice(7))));
      fs.writeFileSync(`${path}/proving.key`, data);
      await updateJob(job, 60);
      const { computationStdout } = await computeWitness(
        witnessInput,
        path,
        job,
      );
      const witness = fs.readFileSync(`${path}/witness`);
      const outWitness = fs.readFileSync(`${path}/out.wtns`);
      await Promise.all([
        addAssets("sales", `${receiver}/${algorithm}/witness`, witness),
        addAssets("sales", `${receiver}/${algorithm}/out.wtns`, outWitness),
      ]);
      await updateJob(job, 80);
      await generateProof(path, job);
      const generatedProof = fs.readFileSync(`${path}/proof.json`).toString();
      const { proof, inputs } = JSON.parse(generatedProof);
      await addAssets(
        "sales",
        `${receiver}/${algorithm}/proof.json`,
        generatedProof,
      );
      await proofComputation({ sessionId, inputs, proof });
      await updateJob(job, 100);
      logger.info(
        `Order Queue: ${job.id} - status changed: ACTIVE => COMPLETED`,
      );
      const end = Date.now();
      const createdAt = new Date().toISOString();
      const log = createLog({
        program,
        encoding: [
          "622aaa70db32069b6fb23b30bf78d3a020ce25f97c7544d18ae7ab49c84ee309",
          "08257cda3d290a4d1d1f0d40efe1583acc678cb3b16f3570408b269a14357a6d",
          "fe314db7be9736f0e56335def444b4d718abb5334ad8848ac9a6ab45f3b5d1d7",
          "0000000000000000000000000000000000000000000000000000000000000000",
        ],
        duration: end - start,
        constraints,
        createdAt,
      });
      await addAssets(
        "sales",
        `${receiver}/${algorithm}/receipt.json`,
        JSON.stringify(log),
      );
      return log;
    } catch (e) {
      console.log(e);
    }
  },
  { connection: CONNECTION, concurrency: CONCURRENCY },
);
