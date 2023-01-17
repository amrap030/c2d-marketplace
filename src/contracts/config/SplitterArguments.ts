import CollectionConfig from "./CollectionConfig";

// Update the following array if you change the constructor arguments...
const ContractArguments = [
  CollectionConfig.payeesAdresses,
  CollectionConfig.payeesShares,
] as const;

export default ContractArguments;
