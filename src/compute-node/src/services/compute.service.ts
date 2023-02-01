// import { minioClient } from "@/db/minio";
import { HttpException } from "@/exceptions/HttpException";
// import { Blob } from "buffer";
// import mime from "mime-types";
import {
  compile,
  setup,
  computeWitness,
  exportVerifier,
  generateProof,
} from "@/utils/zokrates";

// const PATH = "assets";

export const initComputation = async () => {
  try {
    await compile("./zokrates");
    await setup("./zokrates");
    await computeWitness(
      [
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
        "20529582127759150012468251093999993529646142270908953194350457080141537395951",
        "4370774027306841137530349508984781108679873748983348226587886369368307599222",
        "14599544420984636321610449240244484646658932770421022906667676435055569344413",
        "14585667688433000900526094642007891500577536322172190101886149081050508696387",
        "7474072388531090642842522123389324618269331295188349932287210707451279630008",
        "1615973535",
        "2282261419",
        "911569556",
        "3578753442",
        "4149480349",
        "2417982810",
        "1885183916",
        "2978347395",
        "1615973535",
        "2282261419",
        "911569556",
        "3578753442",
        "4149480349",
        "2417982810",
        "1885183916",
        "2978347395",
      ],
      "./zokrates",
    );
    await generateProof("./zokrates");
    await exportVerifier("./zokrates");
  } catch (e) {
    throw new HttpException(400, e.toString());
  }
};

export default { initComputation };
