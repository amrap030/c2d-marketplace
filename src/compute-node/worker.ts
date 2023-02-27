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
import fs from "fs";
import solc from "solc";
import { ethers } from "ethers";
import { SENDER_PRIVATE_KEY, MARKETPLACE_ADDRESS } from "@/config";
import { abi } from "@/abi/Marketplace.json";
import { abi as erc721Abi } from "@/abi/ERC721Template.json";
import all from "it-all";

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

const ipfs = create({ protocol: "http", port: 5001, host: "localhost" });

const createDir = (path: string) => fs.mkdirSync(path, { recursive: true });
const writeProgram = (path: string, program: string) =>
  fs.writeFileSync(`${path}/main.zok`, program);

const setupWorker = new Worker(
  "Setup",
  async (job: Job) => {
    try {
      const content = Buffer.concat(
        await all(ipfs.cat(job.data.algorithm.slice(7))),
      );
      const raw = content.toString();

      logger.info(`Setup Queue: ${job.id} - status changed: CREATED => ACTIVE`);
      await job.updateProgress(0);
      logger.info(
        `Setup Queue: ${job.id} - Progress:  0%  [##                  ]`,
      );

      const path = `./${job.data.receiver}`;

      createDir(path);
      writeProgram(path, raw);

      await job.updateProgress(20);
      logger.info(
        `Setup Queue: ${job.id} - Progress: 20%  [###                 ]`,
      );

      await compile(path, job);

      await job.updateProgress(40);
      logger.info(
        `Setup Queue: ${job.id} - Progress: 40%  [######              ]`,
      );

      await setup(path, job);

      await job.updateProgress(60);
      logger.info(
        `Setup Queue: ${job.id} - Progress: 60%  [##########          ]`,
      );

      await exportVerifier(path, job);

      await job.updateProgress(80);
      logger.info(
        `Setup Queue: ${job.id} - Progress: 80%  [################    ]`,
      );

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

      await job.updateProgress(100);
      logger.info(
        `Setup Queue: ${job.id} - Progress: 100% [####################]`,
      );
      logger.info(
        `Setup Queue: ${job.id} - status changed: ACTIVE => COMPLETED`,
      );

      const output = JSON.parse(
        solc.compile(JSON.stringify(createInput(verifier))),
      );

      const abiCid = await ipfs.add(
        JSON.stringify(output.contracts["verifier.sol"].Verifier.abi),
      );
      const byteCodeCid = await ipfs.add(
        output.contracts["verifier.sol"].Verifier.evm.bytecode.object,
      );

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

const n = 2;
const length = 32;
const depth = 2;

const keyCommit =
  "0x4833fd0df81fe66248fa7a7a858ace1eb6cda67d46db68de29d210f9811fbac3";

const cipherTextRoot =
  "0xaabc52bbd65f0df6af50c828af1c299d0406898d34ad08b270e31eb4769cd4ec";
const plainDataRoot =
  "0xb1ea444fe88a2ab4f6add48eda24ce89497ced4dee1bf978f818853f35252939";

const provider = new ethers.providers.JsonRpcProvider("http://127.0.0.1:8545");
const signer = new ethers.Wallet(SENDER_PRIVATE_KEY as string, provider);
const marketplace = new ethers.Contract(MARKETPLACE_ADDRESS, abi, signer);

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

const orderWorker = new Worker(
  "Order",
  async (job: Job) => {
    const { receiver, algorithm, pkAddress, sessionId } = job.data;

    try {
      const algorithmContract = new ethers.Contract(
        algorithm,
        erc721Abi,
        signer,
      );

      const metadataUri = await algorithmContract.tokenURI(1);

      const content = Buffer.concat(await all(ipfs.cat(metadataUri.slice(7))));
      const raw = content.toString();

      logger.info(`Order Queue: ${job.id} - status changed: CREATED => ACTIVE`);
      await job.updateProgress(0);
      logger.info(
        `Order Queue: ${job.id} - Progress:  0%  [##                  ]`,
      );

      const path = `./${receiver}`;

      createDir(path);
      writeProgram(path, raw);

      await job.updateProgress(20);
      logger.info(
        `Order Queue: ${job.id} - Progress: 20%  [###                 ]`,
      );

      await compile(path, job);

      await job.updateProgress(40);
      logger.info(
        `Order Queue: ${job.id} - Progress: 40%  [######              ]`,
      );

      const data = Buffer.concat(await all(ipfs.cat(pkAddress.slice(7))));

      fs.writeFileSync(`${path}/proving.key`, data);

      await job.updateProgress(60);
      logger.info(
        `Order Queue: ${job.id} - Progress: 60%  [##########          ]`,
      );

      await computeWitness(witnessInput, path, job);

      await job.updateProgress(80);
      logger.info(
        `Order Queue: ${job.id} - Progress: 80%  [################    ]`,
      );

      await generateProof(path, job);

      const { proof, inputs } = JSON.parse(
        fs.readFileSync(`${path}/proof.json`).toString(),
      );

      // transaction
      const tx = await marketplace
        .connect(signer)
        .proofComputation(
          sessionId,
          depth,
          length,
          n,
          keyCommit,
          cipherTextRoot,
          plainDataRoot,
          inputs,
          proof,
          {
            gasLimit: 30000000,
          },
        );

      await tx.wait();

      await job.updateProgress(100);
      logger.info(
        `Order Queue: ${job.id} - Progress: 100% [####################]`,
      );
      logger.info(
        `Order Queue: ${job.id} - status changed: ACTIVE => COMPLETED`,
      );

      return {
        status: 200,
        message: "OK",
      };
    } catch (e) {
      console.log(e);
    }
  },
  { connection: CONNECTION, concurrency: CONCURRENCY },
);
