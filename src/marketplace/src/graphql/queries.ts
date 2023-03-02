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

export const GET_FILE_SESSIONS = gql`
  query GetFileSessions {
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
      events(orderBy: createdAtBlockNumber) {
        createdAtBlockNumber
        createdAtTimestamp
        gasPrice
        id
        to
        transactionHash
        type
        value
      }
    }
  }
`;

export const GET_TOKENS_WITH_OFFERS = gql`
  query GetTokensWithOffers {
    tokens {
      id
      kind
      managers
      metadataURI
      name
      paused
      supportsMetadata
      symbol
      template
      transactionHash
      updatedAtBlockNumber
      updatedAtTimestamp
      createdAtTimestamp
      createdAtBlockNumber
      offers {
        createdAtBlockNumber
        createdAtTimestamp
        id
        price
        updatedAtBlockNumber
        updatedAtTimestamp
        algorithm {
          id
          owner {
            id
          }
        }
      }
      owner {
        id
      }
    }
  }
`;
