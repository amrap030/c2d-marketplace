import gql from "graphql-tag";

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
