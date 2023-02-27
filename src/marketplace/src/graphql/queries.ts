import gql from "graphql-tag";

export const GET_ALGORITHMS = gql`
  query GetAlgorithms($kind: BigInt = "1") {
    tokens(where: { kind: $kind }) {
      id
      kind
      metadataURI
      metadata
      owner {
        id
      }
      offers {
        price
        id
        updatedAtBlockNumber
        updatedAtTimestamp
        createdAtTimestamp
        createdAtBlockNumber
      }
      name
      symbol
    }
  }
`;

export const GET_DATASETS = gql`
  query GetDatasets($kind: BigInt = "0") {
    tokens(where: { kind: $kind }) {
      id
      kind
      metadataURI
      metadata
      owner {
        id
      }
      offers {
        id
        price
        dataset {
          id
          metadata
        }
        algorithm {
          id
          metadata
        }
      }
      name
      symbol
    }
  }
`;

export const GET_ORDERS = gql`
  query GetOrders {
    fileSaleSessions {
      ciphertextRoot
      createdAtBlockNumber
      createdAtTimestamp
      depth
      fileRoot
      id
      key
      keyCommit
      length
      n
      phase
      pkUrl
      price
      timeout
      timeoutInterval
      updatedAtBlockNumber
      updatedAtTimestamp
      verifier
    }
  }
`;
