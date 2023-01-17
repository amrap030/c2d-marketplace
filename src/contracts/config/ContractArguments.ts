import CollectionConfig from "./CollectionConfig";

// Update the following array if you change the constructor arguments...
const ContractArguments = [
  CollectionConfig.paymentSplitterAddress,
  CollectionConfig.signerAddress,
  CollectionConfig.tokenBaseUri,
] as const;

export default ContractArguments;
