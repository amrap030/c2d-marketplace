import gql from "graphql-tag";

export const tokenHourDataFragment = gql`
  fragment TokenHourDataFragment on TokenHourData {
    periodStartUnix
    open
    high
    low
    close
  }
`;
