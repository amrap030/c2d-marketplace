import gql from "graphql-tag";

export const CONTRACT = gql`
  query contract($id: String) {
    contract(id: $id) {
      id
      name
      paused
      symbol
      maxSupply
      maxReserved
      totalSupply
    }
  }
`;

export const TOKENS_FROM_BLOCK = gql`
  query tokensFromBlock($address: String = "", $block: Int = 0) {
    tokens(where: { owner: $address, createdAtBlockNumber: $block }) {
      id
      owner {
        id
      }
      contract {
        id
      }
      metadataURI
      createdAtTimestamp
      createdAtBlockNumber
      transactionHash
    }
  }
`;

export const TOKEN_HOUR_DATAS = gql`
  query tokenHourDatas(
    $first: Int! = 1
    $skip: Int! = 0
    $address: String! = "0x0d500b1d8e8ef31e21c99d1db9a6444d3adf1270"
  ) {
    tokenHourDatas(
      first: $first
      where: { token: $address }
      skip: $skip
      orderBy: periodStartUnix
      orderDirection: desc
    ) {
      periodStartUnix
      high
      low
      open
      close
    }
  }
`;
