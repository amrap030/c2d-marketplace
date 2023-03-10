import { ulid } from "ulid";

interface AlgorithmMetadata {
  programUri: string;
  programChecksum: string;
  programCreatedAt: string;
  programUpdatedAt: string;
  programSize: number;
  abiUri: string;
  abiChecksum: string;
  abiCreatedAt: string;
  abiUpdatedAt: string;
  abiSize: number;
}

export const createAlgorithmMetadata = ({
  programUri,
  programChecksum,
  programCreatedAt,
  programUpdatedAt,
  programSize,
  abiUri,
  abiChecksum,
  abiCreatedAt,
  abiUpdatedAt,
  abiSize,
}: AlgorithmMetadata) => {
  const id = ulid();
  return {
    id,
    name: "Computation of a sum",
    description: "This is a description of an algorithm.",
    tags: ["zokrates", "sum"],
    assets: [
      {
        type: "program",
        uri: programUri,
        checksum: `sha256:${programChecksum}`,
        additionalInformation: {
          createdAt: programCreatedAt,
          updatedAt: programUpdatedAt,
          file: "main.zok",
          fileSize: programSize,
          mimeType: "text/plain",
          scheme: "g16",
          curve: "bn128",
        },
      },
      {
        type: "abi",
        uri: abiUri,
        checksum: `sha256:${abiChecksum}`,
        additionalInformation: {
          createdAt: abiCreatedAt,
          updatedAt: abiUpdatedAt,
          file: "abi.json",
          fileSize: abiSize,
          mimeType: "application/json",
        },
      },
    ],
  };
};

interface DatasetMetadata {
  rows: number;
}

export const createDatasetMetadata = ({ rows }: DatasetMetadata) => {
  const id = ulid();
  return {
    id,
    name: "Steps & Heartrate",
    description: "This is a description of a dataset.",
    tags: ["health", "heartrate", "steps"],
    providerUri: `http://localhost:8060`,
    data: {
      rows,
      columns: [
        {
          name: "heart rate",
          schema: "integer",
          unit: "hertz",
          min: 0,
          max: 4294967295,
          additionalInformation: {
            checksum: [
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
          },
          signature:
            "14599544420984636321610449240244484646658932770421022906667676435055569344413",
        },
        {
          name: "steps",
          schema: "integer",
          unit: null,
          min: 0,
          max: 4294967295,
          additionalInformation: {
            checksum: [
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
          },
          signature:
            "14599544420984636321610449240244484646658932770421022906667676435055569344413",
        },
      ],
      sampleData: [
        ["80", "10000"],
        ["74", "15000"],
      ],
    },
    device: {
      id: "8860e142-d27e-4974-a696-f50bb7ce1eee",
      description: "This is a device description",
      publicKey: [
        "14585667688433000900526094642007891500577536322172190101886149081050508696387",
        "7474072388531090642842522123389324618269331295188349932287210707451279630008",
      ],
    },
  };
};
