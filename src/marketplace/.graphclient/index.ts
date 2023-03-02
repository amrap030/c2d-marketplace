// @ts-nocheck
import {
  GraphQLResolveInfo,
  SelectionSetNode,
  FieldNode,
  GraphQLScalarType,
  GraphQLScalarTypeConfig,
} from "graphql";
import { TypedDocumentNode as DocumentNode } from "@graphql-typed-document-node/core";
import { gql } from "@graphql-mesh/utils";

import type { GetMeshOptions } from "@graphql-mesh/runtime";
import type { YamlConfig } from "@graphql-mesh/types";
import { PubSub } from "@graphql-mesh/utils";
import { DefaultLogger } from "@graphql-mesh/utils";
import MeshCache from "@graphql-mesh/cache-localforage";
import { fetch as fetchFn } from "@whatwg-node/fetch";

import { MeshResolvedSource } from "@graphql-mesh/runtime";
import { MeshTransform, MeshPlugin } from "@graphql-mesh/types";
import GraphqlHandler from "@graphql-mesh/graphql";
import BareMerger from "@graphql-mesh/merger-bare";
import { printWithCache } from "@graphql-mesh/utils";
import { createMeshHTTPHandler, MeshHTTPHandler } from "@graphql-mesh/http";
import {
  getMesh,
  ExecuteMeshFn,
  SubscribeMeshFn,
  MeshContext as BaseMeshContext,
  MeshInstance,
} from "@graphql-mesh/runtime";
import { MeshStore, FsStoreStorageAdapter } from "@graphql-mesh/store";
import { path as pathModule } from "@graphql-mesh/cross-helpers";
import { ImportFn } from "@graphql-mesh/types";
import type { C2DTypes } from "./sources/C2D/types";
export type Maybe<T> = T | null;
export type InputMaybe<T> = Maybe<T>;
export type Exact<T extends { [key: string]: unknown }> = {
  [K in keyof T]: T[K];
};
export type MakeOptional<T, K extends keyof T> = Omit<T, K> & {
  [SubKey in K]?: Maybe<T[SubKey]>;
};
export type MakeMaybe<T, K extends keyof T> = Omit<T, K> & {
  [SubKey in K]: Maybe<T[SubKey]>;
};
export type RequireFields<T, K extends keyof T> = Omit<T, K> & {
  [P in K]-?: NonNullable<T[P]>;
};

/** All built-in and custom scalars, mapped to their actual values */
export type Scalars = {
  ID: string;
  String: string;
  Boolean: boolean;
  Int: number;
  Float: number;
  BigDecimal: any;
  BigInt: any;
  Bytes: any;
};

export type Account = {
  /** The account address */
  id: Scalars["ID"];
  /** The Media the User owns */
  possessions: Array<Token>;
  /** The Media the User created */
  creations: Array<Token>;
  /** The purchases of a user */
  purchases: Array<FileSaleSession>;
  /** The sales of a user */
  sales: Array<FileSaleSession>;
  /** The activities of a user */
  activities: Array<Event>;
};

export type AccountpossessionsArgs = {
  skip?: InputMaybe<Scalars["Int"]>;
  first?: InputMaybe<Scalars["Int"]>;
  orderBy?: InputMaybe<Token_orderBy>;
  orderDirection?: InputMaybe<OrderDirection>;
  where?: InputMaybe<Token_filter>;
};

export type AccountcreationsArgs = {
  skip?: InputMaybe<Scalars["Int"]>;
  first?: InputMaybe<Scalars["Int"]>;
  orderBy?: InputMaybe<Token_orderBy>;
  orderDirection?: InputMaybe<OrderDirection>;
  where?: InputMaybe<Token_filter>;
};

export type AccountpurchasesArgs = {
  skip?: InputMaybe<Scalars["Int"]>;
  first?: InputMaybe<Scalars["Int"]>;
  orderBy?: InputMaybe<FileSaleSession_orderBy>;
  orderDirection?: InputMaybe<OrderDirection>;
  where?: InputMaybe<FileSaleSession_filter>;
};

export type AccountsalesArgs = {
  skip?: InputMaybe<Scalars["Int"]>;
  first?: InputMaybe<Scalars["Int"]>;
  orderBy?: InputMaybe<FileSaleSession_orderBy>;
  orderDirection?: InputMaybe<OrderDirection>;
  where?: InputMaybe<FileSaleSession_filter>;
};

export type AccountactivitiesArgs = {
  skip?: InputMaybe<Scalars["Int"]>;
  first?: InputMaybe<Scalars["Int"]>;
  orderBy?: InputMaybe<Event_orderBy>;
  orderDirection?: InputMaybe<OrderDirection>;
  where?: InputMaybe<Event_filter>;
};

export type Account_filter = {
  id?: InputMaybe<Scalars["ID"]>;
  id_not?: InputMaybe<Scalars["ID"]>;
  id_gt?: InputMaybe<Scalars["ID"]>;
  id_lt?: InputMaybe<Scalars["ID"]>;
  id_gte?: InputMaybe<Scalars["ID"]>;
  id_lte?: InputMaybe<Scalars["ID"]>;
  id_in?: InputMaybe<Array<Scalars["ID"]>>;
  id_not_in?: InputMaybe<Array<Scalars["ID"]>>;
  possessions_?: InputMaybe<Token_filter>;
  creations_?: InputMaybe<Token_filter>;
  purchases_?: InputMaybe<FileSaleSession_filter>;
  sales_?: InputMaybe<FileSaleSession_filter>;
  activities_?: InputMaybe<Event_filter>;
  /** Filter for the block changed event. */
  _change_block?: InputMaybe<BlockChangedFilter>;
};

export type Account_orderBy =
  | "id"
  | "possessions"
  | "creations"
  | "purchases"
  | "sales"
  | "activities";

export type BlockChangedFilter = {
  number_gte: Scalars["Int"];
};

export type Block_height = {
  hash?: InputMaybe<Scalars["Bytes"]>;
  number?: InputMaybe<Scalars["Int"]>;
  number_gte?: InputMaybe<Scalars["Int"]>;
};

export type Event = {
  /** <transactionHash>-<logIndex */
  id: Scalars["ID"];
  /** The User or Contract who initiated the transaction */
  from: Account;
  /** The Contract who receives the transaction */
  to: Scalars["String"];
  /** The timestamp of the block the transaction was created in */
  createdAtTimestamp: Scalars["BigInt"];
  /** The number of the block the transaction was created in */
  createdAtBlockNumber: Scalars["BigInt"];
  /** The gas price for the transaction */
  gasPrice: Scalars["BigInt"];
  /** The price of the transaction */
  value: Scalars["BigInt"];
  /** The type of the event */
  type: EventType;
  /** Transaction hash for the event */
  transactionHash: Scalars["String"];
};

export type EventType =
  | "Approval"
  | "ApprovalForAll"
  | "Transfer"
  | "Paused"
  | "Unpaused"
  | "MetadataUpdated"
  | "ERC721Created"
  | "OfferCreated"
  | "OrderCreated"
  | "OrderInitialized"
  | "OrderAccepted"
  | "OrderRevealed"
  | "OrderFulfilled"
  | "OrderCancelled";

export type Event_filter = {
  id?: InputMaybe<Scalars["ID"]>;
  id_not?: InputMaybe<Scalars["ID"]>;
  id_gt?: InputMaybe<Scalars["ID"]>;
  id_lt?: InputMaybe<Scalars["ID"]>;
  id_gte?: InputMaybe<Scalars["ID"]>;
  id_lte?: InputMaybe<Scalars["ID"]>;
  id_in?: InputMaybe<Array<Scalars["ID"]>>;
  id_not_in?: InputMaybe<Array<Scalars["ID"]>>;
  from?: InputMaybe<Scalars["String"]>;
  from_not?: InputMaybe<Scalars["String"]>;
  from_gt?: InputMaybe<Scalars["String"]>;
  from_lt?: InputMaybe<Scalars["String"]>;
  from_gte?: InputMaybe<Scalars["String"]>;
  from_lte?: InputMaybe<Scalars["String"]>;
  from_in?: InputMaybe<Array<Scalars["String"]>>;
  from_not_in?: InputMaybe<Array<Scalars["String"]>>;
  from_contains?: InputMaybe<Scalars["String"]>;
  from_contains_nocase?: InputMaybe<Scalars["String"]>;
  from_not_contains?: InputMaybe<Scalars["String"]>;
  from_not_contains_nocase?: InputMaybe<Scalars["String"]>;
  from_starts_with?: InputMaybe<Scalars["String"]>;
  from_starts_with_nocase?: InputMaybe<Scalars["String"]>;
  from_not_starts_with?: InputMaybe<Scalars["String"]>;
  from_not_starts_with_nocase?: InputMaybe<Scalars["String"]>;
  from_ends_with?: InputMaybe<Scalars["String"]>;
  from_ends_with_nocase?: InputMaybe<Scalars["String"]>;
  from_not_ends_with?: InputMaybe<Scalars["String"]>;
  from_not_ends_with_nocase?: InputMaybe<Scalars["String"]>;
  from_?: InputMaybe<Account_filter>;
  to?: InputMaybe<Scalars["String"]>;
  to_not?: InputMaybe<Scalars["String"]>;
  to_gt?: InputMaybe<Scalars["String"]>;
  to_lt?: InputMaybe<Scalars["String"]>;
  to_gte?: InputMaybe<Scalars["String"]>;
  to_lte?: InputMaybe<Scalars["String"]>;
  to_in?: InputMaybe<Array<Scalars["String"]>>;
  to_not_in?: InputMaybe<Array<Scalars["String"]>>;
  to_contains?: InputMaybe<Scalars["String"]>;
  to_contains_nocase?: InputMaybe<Scalars["String"]>;
  to_not_contains?: InputMaybe<Scalars["String"]>;
  to_not_contains_nocase?: InputMaybe<Scalars["String"]>;
  to_starts_with?: InputMaybe<Scalars["String"]>;
  to_starts_with_nocase?: InputMaybe<Scalars["String"]>;
  to_not_starts_with?: InputMaybe<Scalars["String"]>;
  to_not_starts_with_nocase?: InputMaybe<Scalars["String"]>;
  to_ends_with?: InputMaybe<Scalars["String"]>;
  to_ends_with_nocase?: InputMaybe<Scalars["String"]>;
  to_not_ends_with?: InputMaybe<Scalars["String"]>;
  to_not_ends_with_nocase?: InputMaybe<Scalars["String"]>;
  createdAtTimestamp?: InputMaybe<Scalars["BigInt"]>;
  createdAtTimestamp_not?: InputMaybe<Scalars["BigInt"]>;
  createdAtTimestamp_gt?: InputMaybe<Scalars["BigInt"]>;
  createdAtTimestamp_lt?: InputMaybe<Scalars["BigInt"]>;
  createdAtTimestamp_gte?: InputMaybe<Scalars["BigInt"]>;
  createdAtTimestamp_lte?: InputMaybe<Scalars["BigInt"]>;
  createdAtTimestamp_in?: InputMaybe<Array<Scalars["BigInt"]>>;
  createdAtTimestamp_not_in?: InputMaybe<Array<Scalars["BigInt"]>>;
  createdAtBlockNumber?: InputMaybe<Scalars["BigInt"]>;
  createdAtBlockNumber_not?: InputMaybe<Scalars["BigInt"]>;
  createdAtBlockNumber_gt?: InputMaybe<Scalars["BigInt"]>;
  createdAtBlockNumber_lt?: InputMaybe<Scalars["BigInt"]>;
  createdAtBlockNumber_gte?: InputMaybe<Scalars["BigInt"]>;
  createdAtBlockNumber_lte?: InputMaybe<Scalars["BigInt"]>;
  createdAtBlockNumber_in?: InputMaybe<Array<Scalars["BigInt"]>>;
  createdAtBlockNumber_not_in?: InputMaybe<Array<Scalars["BigInt"]>>;
  gasPrice?: InputMaybe<Scalars["BigInt"]>;
  gasPrice_not?: InputMaybe<Scalars["BigInt"]>;
  gasPrice_gt?: InputMaybe<Scalars["BigInt"]>;
  gasPrice_lt?: InputMaybe<Scalars["BigInt"]>;
  gasPrice_gte?: InputMaybe<Scalars["BigInt"]>;
  gasPrice_lte?: InputMaybe<Scalars["BigInt"]>;
  gasPrice_in?: InputMaybe<Array<Scalars["BigInt"]>>;
  gasPrice_not_in?: InputMaybe<Array<Scalars["BigInt"]>>;
  value?: InputMaybe<Scalars["BigInt"]>;
  value_not?: InputMaybe<Scalars["BigInt"]>;
  value_gt?: InputMaybe<Scalars["BigInt"]>;
  value_lt?: InputMaybe<Scalars["BigInt"]>;
  value_gte?: InputMaybe<Scalars["BigInt"]>;
  value_lte?: InputMaybe<Scalars["BigInt"]>;
  value_in?: InputMaybe<Array<Scalars["BigInt"]>>;
  value_not_in?: InputMaybe<Array<Scalars["BigInt"]>>;
  type?: InputMaybe<EventType>;
  type_not?: InputMaybe<EventType>;
  type_in?: InputMaybe<Array<EventType>>;
  type_not_in?: InputMaybe<Array<EventType>>;
  transactionHash?: InputMaybe<Scalars["String"]>;
  transactionHash_not?: InputMaybe<Scalars["String"]>;
  transactionHash_gt?: InputMaybe<Scalars["String"]>;
  transactionHash_lt?: InputMaybe<Scalars["String"]>;
  transactionHash_gte?: InputMaybe<Scalars["String"]>;
  transactionHash_lte?: InputMaybe<Scalars["String"]>;
  transactionHash_in?: InputMaybe<Array<Scalars["String"]>>;
  transactionHash_not_in?: InputMaybe<Array<Scalars["String"]>>;
  transactionHash_contains?: InputMaybe<Scalars["String"]>;
  transactionHash_contains_nocase?: InputMaybe<Scalars["String"]>;
  transactionHash_not_contains?: InputMaybe<Scalars["String"]>;
  transactionHash_not_contains_nocase?: InputMaybe<Scalars["String"]>;
  transactionHash_starts_with?: InputMaybe<Scalars["String"]>;
  transactionHash_starts_with_nocase?: InputMaybe<Scalars["String"]>;
  transactionHash_not_starts_with?: InputMaybe<Scalars["String"]>;
  transactionHash_not_starts_with_nocase?: InputMaybe<Scalars["String"]>;
  transactionHash_ends_with?: InputMaybe<Scalars["String"]>;
  transactionHash_ends_with_nocase?: InputMaybe<Scalars["String"]>;
  transactionHash_not_ends_with?: InputMaybe<Scalars["String"]>;
  transactionHash_not_ends_with_nocase?: InputMaybe<Scalars["String"]>;
  /** Filter for the block changed event. */
  _change_block?: InputMaybe<BlockChangedFilter>;
};

export type Event_orderBy =
  | "id"
  | "from"
  | "to"
  | "createdAtTimestamp"
  | "createdAtBlockNumber"
  | "gasPrice"
  | "value"
  | "type"
  | "transactionHash";

export type FileSaleSession = {
  /** The item id */
  id: Scalars["ID"];
  /** The phase of a file sale session (one of created, initialized, accepted, keyRevealed, finished) */
  phase: Scalars["BigInt"];
  /** The sender of a computation */
  sender: Account;
  /** The receiver of a computation */
  receiver: Account;
  /** The token entity of a dataset */
  dataset: Token;
  /** The token entity of an algorithm */
  algorithm: Token;
  /** The address of the proof verification smart contract */
  verifier: Scalars["String"];
  /** The url of the proving key */
  pkUrl: Scalars["String"];
  /** The depth of the merkle tree */
  depth: Scalars["BigInt"];
  /** The length of the plain data */
  length: Scalars["BigInt"];
  /** The number of slices of the plain data */
  n: Scalars["BigInt"];
  /** The time until funds are locked in the marketplace */
  timeout: Scalars["BigInt"];
  /** The timeout interval for locked funds */
  timeoutInterval: Scalars["BigInt"];
  /** The price of a computation */
  price: Scalars["BigInt"];
  /** The hashed symmetric encryption key */
  keyCommit: Scalars["String"];
  /** The plain symmetric encryption key */
  key: Scalars["String"];
  /** The root hash of the plain data */
  fileRoot: Scalars["String"];
  /** The root hash of the encoding */
  ciphertextRoot: Scalars["String"];
  /** The timestamp of the block the session was created */
  createdAtTimestamp: Scalars["BigInt"];
  /** The number of the block the session was created */
  createdAtBlockNumber: Scalars["BigInt"];
  /** The timestamp of the block the session was updated */
  updatedAtTimestamp: Scalars["BigInt"];
  /** The number of the block the session was updated */
  updatedAtBlockNumber: Scalars["BigInt"];
  /** All events of the session */
  events?: Maybe<Array<Event>>;
};

export type FileSaleSessioneventsArgs = {
  skip?: InputMaybe<Scalars["Int"]>;
  first?: InputMaybe<Scalars["Int"]>;
  orderBy?: InputMaybe<Event_orderBy>;
  orderDirection?: InputMaybe<OrderDirection>;
  where?: InputMaybe<Event_filter>;
};

export type FileSaleSession_filter = {
  id?: InputMaybe<Scalars["ID"]>;
  id_not?: InputMaybe<Scalars["ID"]>;
  id_gt?: InputMaybe<Scalars["ID"]>;
  id_lt?: InputMaybe<Scalars["ID"]>;
  id_gte?: InputMaybe<Scalars["ID"]>;
  id_lte?: InputMaybe<Scalars["ID"]>;
  id_in?: InputMaybe<Array<Scalars["ID"]>>;
  id_not_in?: InputMaybe<Array<Scalars["ID"]>>;
  phase?: InputMaybe<Scalars["BigInt"]>;
  phase_not?: InputMaybe<Scalars["BigInt"]>;
  phase_gt?: InputMaybe<Scalars["BigInt"]>;
  phase_lt?: InputMaybe<Scalars["BigInt"]>;
  phase_gte?: InputMaybe<Scalars["BigInt"]>;
  phase_lte?: InputMaybe<Scalars["BigInt"]>;
  phase_in?: InputMaybe<Array<Scalars["BigInt"]>>;
  phase_not_in?: InputMaybe<Array<Scalars["BigInt"]>>;
  sender?: InputMaybe<Scalars["String"]>;
  sender_not?: InputMaybe<Scalars["String"]>;
  sender_gt?: InputMaybe<Scalars["String"]>;
  sender_lt?: InputMaybe<Scalars["String"]>;
  sender_gte?: InputMaybe<Scalars["String"]>;
  sender_lte?: InputMaybe<Scalars["String"]>;
  sender_in?: InputMaybe<Array<Scalars["String"]>>;
  sender_not_in?: InputMaybe<Array<Scalars["String"]>>;
  sender_contains?: InputMaybe<Scalars["String"]>;
  sender_contains_nocase?: InputMaybe<Scalars["String"]>;
  sender_not_contains?: InputMaybe<Scalars["String"]>;
  sender_not_contains_nocase?: InputMaybe<Scalars["String"]>;
  sender_starts_with?: InputMaybe<Scalars["String"]>;
  sender_starts_with_nocase?: InputMaybe<Scalars["String"]>;
  sender_not_starts_with?: InputMaybe<Scalars["String"]>;
  sender_not_starts_with_nocase?: InputMaybe<Scalars["String"]>;
  sender_ends_with?: InputMaybe<Scalars["String"]>;
  sender_ends_with_nocase?: InputMaybe<Scalars["String"]>;
  sender_not_ends_with?: InputMaybe<Scalars["String"]>;
  sender_not_ends_with_nocase?: InputMaybe<Scalars["String"]>;
  sender_?: InputMaybe<Account_filter>;
  receiver?: InputMaybe<Scalars["String"]>;
  receiver_not?: InputMaybe<Scalars["String"]>;
  receiver_gt?: InputMaybe<Scalars["String"]>;
  receiver_lt?: InputMaybe<Scalars["String"]>;
  receiver_gte?: InputMaybe<Scalars["String"]>;
  receiver_lte?: InputMaybe<Scalars["String"]>;
  receiver_in?: InputMaybe<Array<Scalars["String"]>>;
  receiver_not_in?: InputMaybe<Array<Scalars["String"]>>;
  receiver_contains?: InputMaybe<Scalars["String"]>;
  receiver_contains_nocase?: InputMaybe<Scalars["String"]>;
  receiver_not_contains?: InputMaybe<Scalars["String"]>;
  receiver_not_contains_nocase?: InputMaybe<Scalars["String"]>;
  receiver_starts_with?: InputMaybe<Scalars["String"]>;
  receiver_starts_with_nocase?: InputMaybe<Scalars["String"]>;
  receiver_not_starts_with?: InputMaybe<Scalars["String"]>;
  receiver_not_starts_with_nocase?: InputMaybe<Scalars["String"]>;
  receiver_ends_with?: InputMaybe<Scalars["String"]>;
  receiver_ends_with_nocase?: InputMaybe<Scalars["String"]>;
  receiver_not_ends_with?: InputMaybe<Scalars["String"]>;
  receiver_not_ends_with_nocase?: InputMaybe<Scalars["String"]>;
  receiver_?: InputMaybe<Account_filter>;
  dataset?: InputMaybe<Scalars["String"]>;
  dataset_not?: InputMaybe<Scalars["String"]>;
  dataset_gt?: InputMaybe<Scalars["String"]>;
  dataset_lt?: InputMaybe<Scalars["String"]>;
  dataset_gte?: InputMaybe<Scalars["String"]>;
  dataset_lte?: InputMaybe<Scalars["String"]>;
  dataset_in?: InputMaybe<Array<Scalars["String"]>>;
  dataset_not_in?: InputMaybe<Array<Scalars["String"]>>;
  dataset_contains?: InputMaybe<Scalars["String"]>;
  dataset_contains_nocase?: InputMaybe<Scalars["String"]>;
  dataset_not_contains?: InputMaybe<Scalars["String"]>;
  dataset_not_contains_nocase?: InputMaybe<Scalars["String"]>;
  dataset_starts_with?: InputMaybe<Scalars["String"]>;
  dataset_starts_with_nocase?: InputMaybe<Scalars["String"]>;
  dataset_not_starts_with?: InputMaybe<Scalars["String"]>;
  dataset_not_starts_with_nocase?: InputMaybe<Scalars["String"]>;
  dataset_ends_with?: InputMaybe<Scalars["String"]>;
  dataset_ends_with_nocase?: InputMaybe<Scalars["String"]>;
  dataset_not_ends_with?: InputMaybe<Scalars["String"]>;
  dataset_not_ends_with_nocase?: InputMaybe<Scalars["String"]>;
  dataset_?: InputMaybe<Token_filter>;
  algorithm?: InputMaybe<Scalars["String"]>;
  algorithm_not?: InputMaybe<Scalars["String"]>;
  algorithm_gt?: InputMaybe<Scalars["String"]>;
  algorithm_lt?: InputMaybe<Scalars["String"]>;
  algorithm_gte?: InputMaybe<Scalars["String"]>;
  algorithm_lte?: InputMaybe<Scalars["String"]>;
  algorithm_in?: InputMaybe<Array<Scalars["String"]>>;
  algorithm_not_in?: InputMaybe<Array<Scalars["String"]>>;
  algorithm_contains?: InputMaybe<Scalars["String"]>;
  algorithm_contains_nocase?: InputMaybe<Scalars["String"]>;
  algorithm_not_contains?: InputMaybe<Scalars["String"]>;
  algorithm_not_contains_nocase?: InputMaybe<Scalars["String"]>;
  algorithm_starts_with?: InputMaybe<Scalars["String"]>;
  algorithm_starts_with_nocase?: InputMaybe<Scalars["String"]>;
  algorithm_not_starts_with?: InputMaybe<Scalars["String"]>;
  algorithm_not_starts_with_nocase?: InputMaybe<Scalars["String"]>;
  algorithm_ends_with?: InputMaybe<Scalars["String"]>;
  algorithm_ends_with_nocase?: InputMaybe<Scalars["String"]>;
  algorithm_not_ends_with?: InputMaybe<Scalars["String"]>;
  algorithm_not_ends_with_nocase?: InputMaybe<Scalars["String"]>;
  algorithm_?: InputMaybe<Token_filter>;
  verifier?: InputMaybe<Scalars["String"]>;
  verifier_not?: InputMaybe<Scalars["String"]>;
  verifier_gt?: InputMaybe<Scalars["String"]>;
  verifier_lt?: InputMaybe<Scalars["String"]>;
  verifier_gte?: InputMaybe<Scalars["String"]>;
  verifier_lte?: InputMaybe<Scalars["String"]>;
  verifier_in?: InputMaybe<Array<Scalars["String"]>>;
  verifier_not_in?: InputMaybe<Array<Scalars["String"]>>;
  verifier_contains?: InputMaybe<Scalars["String"]>;
  verifier_contains_nocase?: InputMaybe<Scalars["String"]>;
  verifier_not_contains?: InputMaybe<Scalars["String"]>;
  verifier_not_contains_nocase?: InputMaybe<Scalars["String"]>;
  verifier_starts_with?: InputMaybe<Scalars["String"]>;
  verifier_starts_with_nocase?: InputMaybe<Scalars["String"]>;
  verifier_not_starts_with?: InputMaybe<Scalars["String"]>;
  verifier_not_starts_with_nocase?: InputMaybe<Scalars["String"]>;
  verifier_ends_with?: InputMaybe<Scalars["String"]>;
  verifier_ends_with_nocase?: InputMaybe<Scalars["String"]>;
  verifier_not_ends_with?: InputMaybe<Scalars["String"]>;
  verifier_not_ends_with_nocase?: InputMaybe<Scalars["String"]>;
  pkUrl?: InputMaybe<Scalars["String"]>;
  pkUrl_not?: InputMaybe<Scalars["String"]>;
  pkUrl_gt?: InputMaybe<Scalars["String"]>;
  pkUrl_lt?: InputMaybe<Scalars["String"]>;
  pkUrl_gte?: InputMaybe<Scalars["String"]>;
  pkUrl_lte?: InputMaybe<Scalars["String"]>;
  pkUrl_in?: InputMaybe<Array<Scalars["String"]>>;
  pkUrl_not_in?: InputMaybe<Array<Scalars["String"]>>;
  pkUrl_contains?: InputMaybe<Scalars["String"]>;
  pkUrl_contains_nocase?: InputMaybe<Scalars["String"]>;
  pkUrl_not_contains?: InputMaybe<Scalars["String"]>;
  pkUrl_not_contains_nocase?: InputMaybe<Scalars["String"]>;
  pkUrl_starts_with?: InputMaybe<Scalars["String"]>;
  pkUrl_starts_with_nocase?: InputMaybe<Scalars["String"]>;
  pkUrl_not_starts_with?: InputMaybe<Scalars["String"]>;
  pkUrl_not_starts_with_nocase?: InputMaybe<Scalars["String"]>;
  pkUrl_ends_with?: InputMaybe<Scalars["String"]>;
  pkUrl_ends_with_nocase?: InputMaybe<Scalars["String"]>;
  pkUrl_not_ends_with?: InputMaybe<Scalars["String"]>;
  pkUrl_not_ends_with_nocase?: InputMaybe<Scalars["String"]>;
  depth?: InputMaybe<Scalars["BigInt"]>;
  depth_not?: InputMaybe<Scalars["BigInt"]>;
  depth_gt?: InputMaybe<Scalars["BigInt"]>;
  depth_lt?: InputMaybe<Scalars["BigInt"]>;
  depth_gte?: InputMaybe<Scalars["BigInt"]>;
  depth_lte?: InputMaybe<Scalars["BigInt"]>;
  depth_in?: InputMaybe<Array<Scalars["BigInt"]>>;
  depth_not_in?: InputMaybe<Array<Scalars["BigInt"]>>;
  length?: InputMaybe<Scalars["BigInt"]>;
  length_not?: InputMaybe<Scalars["BigInt"]>;
  length_gt?: InputMaybe<Scalars["BigInt"]>;
  length_lt?: InputMaybe<Scalars["BigInt"]>;
  length_gte?: InputMaybe<Scalars["BigInt"]>;
  length_lte?: InputMaybe<Scalars["BigInt"]>;
  length_in?: InputMaybe<Array<Scalars["BigInt"]>>;
  length_not_in?: InputMaybe<Array<Scalars["BigInt"]>>;
  n?: InputMaybe<Scalars["BigInt"]>;
  n_not?: InputMaybe<Scalars["BigInt"]>;
  n_gt?: InputMaybe<Scalars["BigInt"]>;
  n_lt?: InputMaybe<Scalars["BigInt"]>;
  n_gte?: InputMaybe<Scalars["BigInt"]>;
  n_lte?: InputMaybe<Scalars["BigInt"]>;
  n_in?: InputMaybe<Array<Scalars["BigInt"]>>;
  n_not_in?: InputMaybe<Array<Scalars["BigInt"]>>;
  timeout?: InputMaybe<Scalars["BigInt"]>;
  timeout_not?: InputMaybe<Scalars["BigInt"]>;
  timeout_gt?: InputMaybe<Scalars["BigInt"]>;
  timeout_lt?: InputMaybe<Scalars["BigInt"]>;
  timeout_gte?: InputMaybe<Scalars["BigInt"]>;
  timeout_lte?: InputMaybe<Scalars["BigInt"]>;
  timeout_in?: InputMaybe<Array<Scalars["BigInt"]>>;
  timeout_not_in?: InputMaybe<Array<Scalars["BigInt"]>>;
  timeoutInterval?: InputMaybe<Scalars["BigInt"]>;
  timeoutInterval_not?: InputMaybe<Scalars["BigInt"]>;
  timeoutInterval_gt?: InputMaybe<Scalars["BigInt"]>;
  timeoutInterval_lt?: InputMaybe<Scalars["BigInt"]>;
  timeoutInterval_gte?: InputMaybe<Scalars["BigInt"]>;
  timeoutInterval_lte?: InputMaybe<Scalars["BigInt"]>;
  timeoutInterval_in?: InputMaybe<Array<Scalars["BigInt"]>>;
  timeoutInterval_not_in?: InputMaybe<Array<Scalars["BigInt"]>>;
  price?: InputMaybe<Scalars["BigInt"]>;
  price_not?: InputMaybe<Scalars["BigInt"]>;
  price_gt?: InputMaybe<Scalars["BigInt"]>;
  price_lt?: InputMaybe<Scalars["BigInt"]>;
  price_gte?: InputMaybe<Scalars["BigInt"]>;
  price_lte?: InputMaybe<Scalars["BigInt"]>;
  price_in?: InputMaybe<Array<Scalars["BigInt"]>>;
  price_not_in?: InputMaybe<Array<Scalars["BigInt"]>>;
  keyCommit?: InputMaybe<Scalars["String"]>;
  keyCommit_not?: InputMaybe<Scalars["String"]>;
  keyCommit_gt?: InputMaybe<Scalars["String"]>;
  keyCommit_lt?: InputMaybe<Scalars["String"]>;
  keyCommit_gte?: InputMaybe<Scalars["String"]>;
  keyCommit_lte?: InputMaybe<Scalars["String"]>;
  keyCommit_in?: InputMaybe<Array<Scalars["String"]>>;
  keyCommit_not_in?: InputMaybe<Array<Scalars["String"]>>;
  keyCommit_contains?: InputMaybe<Scalars["String"]>;
  keyCommit_contains_nocase?: InputMaybe<Scalars["String"]>;
  keyCommit_not_contains?: InputMaybe<Scalars["String"]>;
  keyCommit_not_contains_nocase?: InputMaybe<Scalars["String"]>;
  keyCommit_starts_with?: InputMaybe<Scalars["String"]>;
  keyCommit_starts_with_nocase?: InputMaybe<Scalars["String"]>;
  keyCommit_not_starts_with?: InputMaybe<Scalars["String"]>;
  keyCommit_not_starts_with_nocase?: InputMaybe<Scalars["String"]>;
  keyCommit_ends_with?: InputMaybe<Scalars["String"]>;
  keyCommit_ends_with_nocase?: InputMaybe<Scalars["String"]>;
  keyCommit_not_ends_with?: InputMaybe<Scalars["String"]>;
  keyCommit_not_ends_with_nocase?: InputMaybe<Scalars["String"]>;
  key?: InputMaybe<Scalars["String"]>;
  key_not?: InputMaybe<Scalars["String"]>;
  key_gt?: InputMaybe<Scalars["String"]>;
  key_lt?: InputMaybe<Scalars["String"]>;
  key_gte?: InputMaybe<Scalars["String"]>;
  key_lte?: InputMaybe<Scalars["String"]>;
  key_in?: InputMaybe<Array<Scalars["String"]>>;
  key_not_in?: InputMaybe<Array<Scalars["String"]>>;
  key_contains?: InputMaybe<Scalars["String"]>;
  key_contains_nocase?: InputMaybe<Scalars["String"]>;
  key_not_contains?: InputMaybe<Scalars["String"]>;
  key_not_contains_nocase?: InputMaybe<Scalars["String"]>;
  key_starts_with?: InputMaybe<Scalars["String"]>;
  key_starts_with_nocase?: InputMaybe<Scalars["String"]>;
  key_not_starts_with?: InputMaybe<Scalars["String"]>;
  key_not_starts_with_nocase?: InputMaybe<Scalars["String"]>;
  key_ends_with?: InputMaybe<Scalars["String"]>;
  key_ends_with_nocase?: InputMaybe<Scalars["String"]>;
  key_not_ends_with?: InputMaybe<Scalars["String"]>;
  key_not_ends_with_nocase?: InputMaybe<Scalars["String"]>;
  fileRoot?: InputMaybe<Scalars["String"]>;
  fileRoot_not?: InputMaybe<Scalars["String"]>;
  fileRoot_gt?: InputMaybe<Scalars["String"]>;
  fileRoot_lt?: InputMaybe<Scalars["String"]>;
  fileRoot_gte?: InputMaybe<Scalars["String"]>;
  fileRoot_lte?: InputMaybe<Scalars["String"]>;
  fileRoot_in?: InputMaybe<Array<Scalars["String"]>>;
  fileRoot_not_in?: InputMaybe<Array<Scalars["String"]>>;
  fileRoot_contains?: InputMaybe<Scalars["String"]>;
  fileRoot_contains_nocase?: InputMaybe<Scalars["String"]>;
  fileRoot_not_contains?: InputMaybe<Scalars["String"]>;
  fileRoot_not_contains_nocase?: InputMaybe<Scalars["String"]>;
  fileRoot_starts_with?: InputMaybe<Scalars["String"]>;
  fileRoot_starts_with_nocase?: InputMaybe<Scalars["String"]>;
  fileRoot_not_starts_with?: InputMaybe<Scalars["String"]>;
  fileRoot_not_starts_with_nocase?: InputMaybe<Scalars["String"]>;
  fileRoot_ends_with?: InputMaybe<Scalars["String"]>;
  fileRoot_ends_with_nocase?: InputMaybe<Scalars["String"]>;
  fileRoot_not_ends_with?: InputMaybe<Scalars["String"]>;
  fileRoot_not_ends_with_nocase?: InputMaybe<Scalars["String"]>;
  ciphertextRoot?: InputMaybe<Scalars["String"]>;
  ciphertextRoot_not?: InputMaybe<Scalars["String"]>;
  ciphertextRoot_gt?: InputMaybe<Scalars["String"]>;
  ciphertextRoot_lt?: InputMaybe<Scalars["String"]>;
  ciphertextRoot_gte?: InputMaybe<Scalars["String"]>;
  ciphertextRoot_lte?: InputMaybe<Scalars["String"]>;
  ciphertextRoot_in?: InputMaybe<Array<Scalars["String"]>>;
  ciphertextRoot_not_in?: InputMaybe<Array<Scalars["String"]>>;
  ciphertextRoot_contains?: InputMaybe<Scalars["String"]>;
  ciphertextRoot_contains_nocase?: InputMaybe<Scalars["String"]>;
  ciphertextRoot_not_contains?: InputMaybe<Scalars["String"]>;
  ciphertextRoot_not_contains_nocase?: InputMaybe<Scalars["String"]>;
  ciphertextRoot_starts_with?: InputMaybe<Scalars["String"]>;
  ciphertextRoot_starts_with_nocase?: InputMaybe<Scalars["String"]>;
  ciphertextRoot_not_starts_with?: InputMaybe<Scalars["String"]>;
  ciphertextRoot_not_starts_with_nocase?: InputMaybe<Scalars["String"]>;
  ciphertextRoot_ends_with?: InputMaybe<Scalars["String"]>;
  ciphertextRoot_ends_with_nocase?: InputMaybe<Scalars["String"]>;
  ciphertextRoot_not_ends_with?: InputMaybe<Scalars["String"]>;
  ciphertextRoot_not_ends_with_nocase?: InputMaybe<Scalars["String"]>;
  createdAtTimestamp?: InputMaybe<Scalars["BigInt"]>;
  createdAtTimestamp_not?: InputMaybe<Scalars["BigInt"]>;
  createdAtTimestamp_gt?: InputMaybe<Scalars["BigInt"]>;
  createdAtTimestamp_lt?: InputMaybe<Scalars["BigInt"]>;
  createdAtTimestamp_gte?: InputMaybe<Scalars["BigInt"]>;
  createdAtTimestamp_lte?: InputMaybe<Scalars["BigInt"]>;
  createdAtTimestamp_in?: InputMaybe<Array<Scalars["BigInt"]>>;
  createdAtTimestamp_not_in?: InputMaybe<Array<Scalars["BigInt"]>>;
  createdAtBlockNumber?: InputMaybe<Scalars["BigInt"]>;
  createdAtBlockNumber_not?: InputMaybe<Scalars["BigInt"]>;
  createdAtBlockNumber_gt?: InputMaybe<Scalars["BigInt"]>;
  createdAtBlockNumber_lt?: InputMaybe<Scalars["BigInt"]>;
  createdAtBlockNumber_gte?: InputMaybe<Scalars["BigInt"]>;
  createdAtBlockNumber_lte?: InputMaybe<Scalars["BigInt"]>;
  createdAtBlockNumber_in?: InputMaybe<Array<Scalars["BigInt"]>>;
  createdAtBlockNumber_not_in?: InputMaybe<Array<Scalars["BigInt"]>>;
  updatedAtTimestamp?: InputMaybe<Scalars["BigInt"]>;
  updatedAtTimestamp_not?: InputMaybe<Scalars["BigInt"]>;
  updatedAtTimestamp_gt?: InputMaybe<Scalars["BigInt"]>;
  updatedAtTimestamp_lt?: InputMaybe<Scalars["BigInt"]>;
  updatedAtTimestamp_gte?: InputMaybe<Scalars["BigInt"]>;
  updatedAtTimestamp_lte?: InputMaybe<Scalars["BigInt"]>;
  updatedAtTimestamp_in?: InputMaybe<Array<Scalars["BigInt"]>>;
  updatedAtTimestamp_not_in?: InputMaybe<Array<Scalars["BigInt"]>>;
  updatedAtBlockNumber?: InputMaybe<Scalars["BigInt"]>;
  updatedAtBlockNumber_not?: InputMaybe<Scalars["BigInt"]>;
  updatedAtBlockNumber_gt?: InputMaybe<Scalars["BigInt"]>;
  updatedAtBlockNumber_lt?: InputMaybe<Scalars["BigInt"]>;
  updatedAtBlockNumber_gte?: InputMaybe<Scalars["BigInt"]>;
  updatedAtBlockNumber_lte?: InputMaybe<Scalars["BigInt"]>;
  updatedAtBlockNumber_in?: InputMaybe<Array<Scalars["BigInt"]>>;
  updatedAtBlockNumber_not_in?: InputMaybe<Array<Scalars["BigInt"]>>;
  events?: InputMaybe<Array<Scalars["String"]>>;
  events_not?: InputMaybe<Array<Scalars["String"]>>;
  events_contains?: InputMaybe<Array<Scalars["String"]>>;
  events_contains_nocase?: InputMaybe<Array<Scalars["String"]>>;
  events_not_contains?: InputMaybe<Array<Scalars["String"]>>;
  events_not_contains_nocase?: InputMaybe<Array<Scalars["String"]>>;
  events_?: InputMaybe<Event_filter>;
  /** Filter for the block changed event. */
  _change_block?: InputMaybe<BlockChangedFilter>;
};

export type FileSaleSession_orderBy =
  | "id"
  | "phase"
  | "sender"
  | "receiver"
  | "dataset"
  | "algorithm"
  | "verifier"
  | "pkUrl"
  | "depth"
  | "length"
  | "n"
  | "timeout"
  | "timeoutInterval"
  | "price"
  | "keyCommit"
  | "key"
  | "fileRoot"
  | "ciphertextRoot"
  | "createdAtTimestamp"
  | "createdAtBlockNumber"
  | "updatedAtTimestamp"
  | "updatedAtBlockNumber"
  | "events";

export type Offer = {
  /** The item id */
  id: Scalars["ID"];
  /** The current owner of the token */
  sender: Account;
  /** The creator of the token */
  price: Scalars["BigInt"];
  /** The corresponding algorithm token */
  algorithm: Token;
  /** The corresponding dataset token */
  dataset: Token;
  /** The timestamp of the block the offer was created */
  createdAtTimestamp: Scalars["BigInt"];
  /** The number of the block the offer was created */
  createdAtBlockNumber: Scalars["BigInt"];
  /** The timestamp of the block the offer was updated */
  updatedAtTimestamp: Scalars["BigInt"];
  /** The number of the block the offer was updated */
  updatedAtBlockNumber: Scalars["BigInt"];
};

export type Offer_filter = {
  id?: InputMaybe<Scalars["ID"]>;
  id_not?: InputMaybe<Scalars["ID"]>;
  id_gt?: InputMaybe<Scalars["ID"]>;
  id_lt?: InputMaybe<Scalars["ID"]>;
  id_gte?: InputMaybe<Scalars["ID"]>;
  id_lte?: InputMaybe<Scalars["ID"]>;
  id_in?: InputMaybe<Array<Scalars["ID"]>>;
  id_not_in?: InputMaybe<Array<Scalars["ID"]>>;
  sender?: InputMaybe<Scalars["String"]>;
  sender_not?: InputMaybe<Scalars["String"]>;
  sender_gt?: InputMaybe<Scalars["String"]>;
  sender_lt?: InputMaybe<Scalars["String"]>;
  sender_gte?: InputMaybe<Scalars["String"]>;
  sender_lte?: InputMaybe<Scalars["String"]>;
  sender_in?: InputMaybe<Array<Scalars["String"]>>;
  sender_not_in?: InputMaybe<Array<Scalars["String"]>>;
  sender_contains?: InputMaybe<Scalars["String"]>;
  sender_contains_nocase?: InputMaybe<Scalars["String"]>;
  sender_not_contains?: InputMaybe<Scalars["String"]>;
  sender_not_contains_nocase?: InputMaybe<Scalars["String"]>;
  sender_starts_with?: InputMaybe<Scalars["String"]>;
  sender_starts_with_nocase?: InputMaybe<Scalars["String"]>;
  sender_not_starts_with?: InputMaybe<Scalars["String"]>;
  sender_not_starts_with_nocase?: InputMaybe<Scalars["String"]>;
  sender_ends_with?: InputMaybe<Scalars["String"]>;
  sender_ends_with_nocase?: InputMaybe<Scalars["String"]>;
  sender_not_ends_with?: InputMaybe<Scalars["String"]>;
  sender_not_ends_with_nocase?: InputMaybe<Scalars["String"]>;
  sender_?: InputMaybe<Account_filter>;
  price?: InputMaybe<Scalars["BigInt"]>;
  price_not?: InputMaybe<Scalars["BigInt"]>;
  price_gt?: InputMaybe<Scalars["BigInt"]>;
  price_lt?: InputMaybe<Scalars["BigInt"]>;
  price_gte?: InputMaybe<Scalars["BigInt"]>;
  price_lte?: InputMaybe<Scalars["BigInt"]>;
  price_in?: InputMaybe<Array<Scalars["BigInt"]>>;
  price_not_in?: InputMaybe<Array<Scalars["BigInt"]>>;
  algorithm?: InputMaybe<Scalars["String"]>;
  algorithm_not?: InputMaybe<Scalars["String"]>;
  algorithm_gt?: InputMaybe<Scalars["String"]>;
  algorithm_lt?: InputMaybe<Scalars["String"]>;
  algorithm_gte?: InputMaybe<Scalars["String"]>;
  algorithm_lte?: InputMaybe<Scalars["String"]>;
  algorithm_in?: InputMaybe<Array<Scalars["String"]>>;
  algorithm_not_in?: InputMaybe<Array<Scalars["String"]>>;
  algorithm_contains?: InputMaybe<Scalars["String"]>;
  algorithm_contains_nocase?: InputMaybe<Scalars["String"]>;
  algorithm_not_contains?: InputMaybe<Scalars["String"]>;
  algorithm_not_contains_nocase?: InputMaybe<Scalars["String"]>;
  algorithm_starts_with?: InputMaybe<Scalars["String"]>;
  algorithm_starts_with_nocase?: InputMaybe<Scalars["String"]>;
  algorithm_not_starts_with?: InputMaybe<Scalars["String"]>;
  algorithm_not_starts_with_nocase?: InputMaybe<Scalars["String"]>;
  algorithm_ends_with?: InputMaybe<Scalars["String"]>;
  algorithm_ends_with_nocase?: InputMaybe<Scalars["String"]>;
  algorithm_not_ends_with?: InputMaybe<Scalars["String"]>;
  algorithm_not_ends_with_nocase?: InputMaybe<Scalars["String"]>;
  algorithm_?: InputMaybe<Token_filter>;
  dataset?: InputMaybe<Scalars["String"]>;
  dataset_not?: InputMaybe<Scalars["String"]>;
  dataset_gt?: InputMaybe<Scalars["String"]>;
  dataset_lt?: InputMaybe<Scalars["String"]>;
  dataset_gte?: InputMaybe<Scalars["String"]>;
  dataset_lte?: InputMaybe<Scalars["String"]>;
  dataset_in?: InputMaybe<Array<Scalars["String"]>>;
  dataset_not_in?: InputMaybe<Array<Scalars["String"]>>;
  dataset_contains?: InputMaybe<Scalars["String"]>;
  dataset_contains_nocase?: InputMaybe<Scalars["String"]>;
  dataset_not_contains?: InputMaybe<Scalars["String"]>;
  dataset_not_contains_nocase?: InputMaybe<Scalars["String"]>;
  dataset_starts_with?: InputMaybe<Scalars["String"]>;
  dataset_starts_with_nocase?: InputMaybe<Scalars["String"]>;
  dataset_not_starts_with?: InputMaybe<Scalars["String"]>;
  dataset_not_starts_with_nocase?: InputMaybe<Scalars["String"]>;
  dataset_ends_with?: InputMaybe<Scalars["String"]>;
  dataset_ends_with_nocase?: InputMaybe<Scalars["String"]>;
  dataset_not_ends_with?: InputMaybe<Scalars["String"]>;
  dataset_not_ends_with_nocase?: InputMaybe<Scalars["String"]>;
  dataset_?: InputMaybe<Token_filter>;
  createdAtTimestamp?: InputMaybe<Scalars["BigInt"]>;
  createdAtTimestamp_not?: InputMaybe<Scalars["BigInt"]>;
  createdAtTimestamp_gt?: InputMaybe<Scalars["BigInt"]>;
  createdAtTimestamp_lt?: InputMaybe<Scalars["BigInt"]>;
  createdAtTimestamp_gte?: InputMaybe<Scalars["BigInt"]>;
  createdAtTimestamp_lte?: InputMaybe<Scalars["BigInt"]>;
  createdAtTimestamp_in?: InputMaybe<Array<Scalars["BigInt"]>>;
  createdAtTimestamp_not_in?: InputMaybe<Array<Scalars["BigInt"]>>;
  createdAtBlockNumber?: InputMaybe<Scalars["BigInt"]>;
  createdAtBlockNumber_not?: InputMaybe<Scalars["BigInt"]>;
  createdAtBlockNumber_gt?: InputMaybe<Scalars["BigInt"]>;
  createdAtBlockNumber_lt?: InputMaybe<Scalars["BigInt"]>;
  createdAtBlockNumber_gte?: InputMaybe<Scalars["BigInt"]>;
  createdAtBlockNumber_lte?: InputMaybe<Scalars["BigInt"]>;
  createdAtBlockNumber_in?: InputMaybe<Array<Scalars["BigInt"]>>;
  createdAtBlockNumber_not_in?: InputMaybe<Array<Scalars["BigInt"]>>;
  updatedAtTimestamp?: InputMaybe<Scalars["BigInt"]>;
  updatedAtTimestamp_not?: InputMaybe<Scalars["BigInt"]>;
  updatedAtTimestamp_gt?: InputMaybe<Scalars["BigInt"]>;
  updatedAtTimestamp_lt?: InputMaybe<Scalars["BigInt"]>;
  updatedAtTimestamp_gte?: InputMaybe<Scalars["BigInt"]>;
  updatedAtTimestamp_lte?: InputMaybe<Scalars["BigInt"]>;
  updatedAtTimestamp_in?: InputMaybe<Array<Scalars["BigInt"]>>;
  updatedAtTimestamp_not_in?: InputMaybe<Array<Scalars["BigInt"]>>;
  updatedAtBlockNumber?: InputMaybe<Scalars["BigInt"]>;
  updatedAtBlockNumber_not?: InputMaybe<Scalars["BigInt"]>;
  updatedAtBlockNumber_gt?: InputMaybe<Scalars["BigInt"]>;
  updatedAtBlockNumber_lt?: InputMaybe<Scalars["BigInt"]>;
  updatedAtBlockNumber_gte?: InputMaybe<Scalars["BigInt"]>;
  updatedAtBlockNumber_lte?: InputMaybe<Scalars["BigInt"]>;
  updatedAtBlockNumber_in?: InputMaybe<Array<Scalars["BigInt"]>>;
  updatedAtBlockNumber_not_in?: InputMaybe<Array<Scalars["BigInt"]>>;
  /** Filter for the block changed event. */
  _change_block?: InputMaybe<BlockChangedFilter>;
};

export type Offer_orderBy =
  | "id"
  | "sender"
  | "price"
  | "algorithm"
  | "dataset"
  | "createdAtTimestamp"
  | "createdAtBlockNumber"
  | "updatedAtTimestamp"
  | "updatedAtBlockNumber";

/** Defines the order direction, either ascending or descending */
export type OrderDirection = "asc" | "desc";

export type Query = {
  token?: Maybe<Token>;
  tokens: Array<Token>;
  account?: Maybe<Account>;
  accounts: Array<Account>;
  event?: Maybe<Event>;
  events: Array<Event>;
  offer?: Maybe<Offer>;
  offers: Array<Offer>;
  fileSaleSession?: Maybe<FileSaleSession>;
  fileSaleSessions: Array<FileSaleSession>;
  /** Access to subgraph metadata */
  _meta?: Maybe<_Meta_>;
};

export type QuerytokenArgs = {
  id: Scalars["ID"];
  block?: InputMaybe<Block_height>;
  subgraphError?: _SubgraphErrorPolicy_;
};

export type QuerytokensArgs = {
  skip?: InputMaybe<Scalars["Int"]>;
  first?: InputMaybe<Scalars["Int"]>;
  orderBy?: InputMaybe<Token_orderBy>;
  orderDirection?: InputMaybe<OrderDirection>;
  where?: InputMaybe<Token_filter>;
  block?: InputMaybe<Block_height>;
  subgraphError?: _SubgraphErrorPolicy_;
};

export type QueryaccountArgs = {
  id: Scalars["ID"];
  block?: InputMaybe<Block_height>;
  subgraphError?: _SubgraphErrorPolicy_;
};

export type QueryaccountsArgs = {
  skip?: InputMaybe<Scalars["Int"]>;
  first?: InputMaybe<Scalars["Int"]>;
  orderBy?: InputMaybe<Account_orderBy>;
  orderDirection?: InputMaybe<OrderDirection>;
  where?: InputMaybe<Account_filter>;
  block?: InputMaybe<Block_height>;
  subgraphError?: _SubgraphErrorPolicy_;
};

export type QueryeventArgs = {
  id: Scalars["ID"];
  block?: InputMaybe<Block_height>;
  subgraphError?: _SubgraphErrorPolicy_;
};

export type QueryeventsArgs = {
  skip?: InputMaybe<Scalars["Int"]>;
  first?: InputMaybe<Scalars["Int"]>;
  orderBy?: InputMaybe<Event_orderBy>;
  orderDirection?: InputMaybe<OrderDirection>;
  where?: InputMaybe<Event_filter>;
  block?: InputMaybe<Block_height>;
  subgraphError?: _SubgraphErrorPolicy_;
};

export type QueryofferArgs = {
  id: Scalars["ID"];
  block?: InputMaybe<Block_height>;
  subgraphError?: _SubgraphErrorPolicy_;
};

export type QueryoffersArgs = {
  skip?: InputMaybe<Scalars["Int"]>;
  first?: InputMaybe<Scalars["Int"]>;
  orderBy?: InputMaybe<Offer_orderBy>;
  orderDirection?: InputMaybe<OrderDirection>;
  where?: InputMaybe<Offer_filter>;
  block?: InputMaybe<Block_height>;
  subgraphError?: _SubgraphErrorPolicy_;
};

export type QueryfileSaleSessionArgs = {
  id: Scalars["ID"];
  block?: InputMaybe<Block_height>;
  subgraphError?: _SubgraphErrorPolicy_;
};

export type QueryfileSaleSessionsArgs = {
  skip?: InputMaybe<Scalars["Int"]>;
  first?: InputMaybe<Scalars["Int"]>;
  orderBy?: InputMaybe<FileSaleSession_orderBy>;
  orderDirection?: InputMaybe<OrderDirection>;
  where?: InputMaybe<FileSaleSession_filter>;
  block?: InputMaybe<Block_height>;
  subgraphError?: _SubgraphErrorPolicy_;
};

export type Query_metaArgs = {
  block?: InputMaybe<Block_height>;
};

export type Subscription = {
  token?: Maybe<Token>;
  tokens: Array<Token>;
  account?: Maybe<Account>;
  accounts: Array<Account>;
  event?: Maybe<Event>;
  events: Array<Event>;
  offer?: Maybe<Offer>;
  offers: Array<Offer>;
  fileSaleSession?: Maybe<FileSaleSession>;
  fileSaleSessions: Array<FileSaleSession>;
  /** Access to subgraph metadata */
  _meta?: Maybe<_Meta_>;
};

export type SubscriptiontokenArgs = {
  id: Scalars["ID"];
  block?: InputMaybe<Block_height>;
  subgraphError?: _SubgraphErrorPolicy_;
};

export type SubscriptiontokensArgs = {
  skip?: InputMaybe<Scalars["Int"]>;
  first?: InputMaybe<Scalars["Int"]>;
  orderBy?: InputMaybe<Token_orderBy>;
  orderDirection?: InputMaybe<OrderDirection>;
  where?: InputMaybe<Token_filter>;
  block?: InputMaybe<Block_height>;
  subgraphError?: _SubgraphErrorPolicy_;
};

export type SubscriptionaccountArgs = {
  id: Scalars["ID"];
  block?: InputMaybe<Block_height>;
  subgraphError?: _SubgraphErrorPolicy_;
};

export type SubscriptionaccountsArgs = {
  skip?: InputMaybe<Scalars["Int"]>;
  first?: InputMaybe<Scalars["Int"]>;
  orderBy?: InputMaybe<Account_orderBy>;
  orderDirection?: InputMaybe<OrderDirection>;
  where?: InputMaybe<Account_filter>;
  block?: InputMaybe<Block_height>;
  subgraphError?: _SubgraphErrorPolicy_;
};

export type SubscriptioneventArgs = {
  id: Scalars["ID"];
  block?: InputMaybe<Block_height>;
  subgraphError?: _SubgraphErrorPolicy_;
};

export type SubscriptioneventsArgs = {
  skip?: InputMaybe<Scalars["Int"]>;
  first?: InputMaybe<Scalars["Int"]>;
  orderBy?: InputMaybe<Event_orderBy>;
  orderDirection?: InputMaybe<OrderDirection>;
  where?: InputMaybe<Event_filter>;
  block?: InputMaybe<Block_height>;
  subgraphError?: _SubgraphErrorPolicy_;
};

export type SubscriptionofferArgs = {
  id: Scalars["ID"];
  block?: InputMaybe<Block_height>;
  subgraphError?: _SubgraphErrorPolicy_;
};

export type SubscriptionoffersArgs = {
  skip?: InputMaybe<Scalars["Int"]>;
  first?: InputMaybe<Scalars["Int"]>;
  orderBy?: InputMaybe<Offer_orderBy>;
  orderDirection?: InputMaybe<OrderDirection>;
  where?: InputMaybe<Offer_filter>;
  block?: InputMaybe<Block_height>;
  subgraphError?: _SubgraphErrorPolicy_;
};

export type SubscriptionfileSaleSessionArgs = {
  id: Scalars["ID"];
  block?: InputMaybe<Block_height>;
  subgraphError?: _SubgraphErrorPolicy_;
};

export type SubscriptionfileSaleSessionsArgs = {
  skip?: InputMaybe<Scalars["Int"]>;
  first?: InputMaybe<Scalars["Int"]>;
  orderBy?: InputMaybe<FileSaleSession_orderBy>;
  orderDirection?: InputMaybe<OrderDirection>;
  where?: InputMaybe<FileSaleSession_filter>;
  block?: InputMaybe<Block_height>;
  subgraphError?: _SubgraphErrorPolicy_;
};

export type Subscription_metaArgs = {
  block?: InputMaybe<Block_height>;
};

export type Token = {
  /** The contract address */
  id: Scalars["ID"];
  /** Kind of the token */
  kind: Scalars["BigInt"];
  /** The transaction hash the token was created at */
  transactionHash: Scalars["String"];
  /** The current owner of the token */
  owner: Account;
  /** The creator of the token */
  creator: Account;
  /** The previous owner of the token */
  prevOwner: Account;
  /** The approved user of the token */
  approved?: Maybe<Account>;
  /** The uri of the metadata */
  metadataURI: Scalars["String"];
  /** The timestamp of the block the token was minted in */
  createdAtTimestamp: Scalars["BigInt"];
  /** The number of the block the token was minted in */
  createdAtBlockNumber: Scalars["BigInt"];
  /** The timestamp of the block the token was updated */
  updatedAtTimestamp: Scalars["BigInt"];
  /** The number of the block the token was updated */
  updatedAtBlockNumber: Scalars["BigInt"];
  /** Supports ERC721 metadata */
  supportsMetadata?: Maybe<Scalars["Boolean"]>;
  /** The token name */
  name: Scalars["String"];
  /** Metadata of token */
  metadata?: Maybe<Scalars["String"]>;
  /** The token symbol */
  symbol: Scalars["String"];
  /** The address of the template */
  template: Scalars["String"];
  /** All addresses of managers */
  managers?: Maybe<Array<Scalars["String"]>>;
  /** The paused state of the token */
  paused?: Maybe<Scalars["Boolean"]>;
  /** The offerings of the Media */
  offers?: Maybe<Array<Offer>>;
  /** The file sessions of the token */
  sessions?: Maybe<Array<FileSaleSession>>;
  /** All events of the media */
  events?: Maybe<Array<Event>>;
};

export type TokenoffersArgs = {
  skip?: InputMaybe<Scalars["Int"]>;
  first?: InputMaybe<Scalars["Int"]>;
  orderBy?: InputMaybe<Offer_orderBy>;
  orderDirection?: InputMaybe<OrderDirection>;
  where?: InputMaybe<Offer_filter>;
};

export type TokensessionsArgs = {
  skip?: InputMaybe<Scalars["Int"]>;
  first?: InputMaybe<Scalars["Int"]>;
  orderBy?: InputMaybe<FileSaleSession_orderBy>;
  orderDirection?: InputMaybe<OrderDirection>;
  where?: InputMaybe<FileSaleSession_filter>;
};

export type TokeneventsArgs = {
  skip?: InputMaybe<Scalars["Int"]>;
  first?: InputMaybe<Scalars["Int"]>;
  orderBy?: InputMaybe<Event_orderBy>;
  orderDirection?: InputMaybe<OrderDirection>;
  where?: InputMaybe<Event_filter>;
};

export type Token_filter = {
  id?: InputMaybe<Scalars["ID"]>;
  id_not?: InputMaybe<Scalars["ID"]>;
  id_gt?: InputMaybe<Scalars["ID"]>;
  id_lt?: InputMaybe<Scalars["ID"]>;
  id_gte?: InputMaybe<Scalars["ID"]>;
  id_lte?: InputMaybe<Scalars["ID"]>;
  id_in?: InputMaybe<Array<Scalars["ID"]>>;
  id_not_in?: InputMaybe<Array<Scalars["ID"]>>;
  kind?: InputMaybe<Scalars["BigInt"]>;
  kind_not?: InputMaybe<Scalars["BigInt"]>;
  kind_gt?: InputMaybe<Scalars["BigInt"]>;
  kind_lt?: InputMaybe<Scalars["BigInt"]>;
  kind_gte?: InputMaybe<Scalars["BigInt"]>;
  kind_lte?: InputMaybe<Scalars["BigInt"]>;
  kind_in?: InputMaybe<Array<Scalars["BigInt"]>>;
  kind_not_in?: InputMaybe<Array<Scalars["BigInt"]>>;
  transactionHash?: InputMaybe<Scalars["String"]>;
  transactionHash_not?: InputMaybe<Scalars["String"]>;
  transactionHash_gt?: InputMaybe<Scalars["String"]>;
  transactionHash_lt?: InputMaybe<Scalars["String"]>;
  transactionHash_gte?: InputMaybe<Scalars["String"]>;
  transactionHash_lte?: InputMaybe<Scalars["String"]>;
  transactionHash_in?: InputMaybe<Array<Scalars["String"]>>;
  transactionHash_not_in?: InputMaybe<Array<Scalars["String"]>>;
  transactionHash_contains?: InputMaybe<Scalars["String"]>;
  transactionHash_contains_nocase?: InputMaybe<Scalars["String"]>;
  transactionHash_not_contains?: InputMaybe<Scalars["String"]>;
  transactionHash_not_contains_nocase?: InputMaybe<Scalars["String"]>;
  transactionHash_starts_with?: InputMaybe<Scalars["String"]>;
  transactionHash_starts_with_nocase?: InputMaybe<Scalars["String"]>;
  transactionHash_not_starts_with?: InputMaybe<Scalars["String"]>;
  transactionHash_not_starts_with_nocase?: InputMaybe<Scalars["String"]>;
  transactionHash_ends_with?: InputMaybe<Scalars["String"]>;
  transactionHash_ends_with_nocase?: InputMaybe<Scalars["String"]>;
  transactionHash_not_ends_with?: InputMaybe<Scalars["String"]>;
  transactionHash_not_ends_with_nocase?: InputMaybe<Scalars["String"]>;
  owner?: InputMaybe<Scalars["String"]>;
  owner_not?: InputMaybe<Scalars["String"]>;
  owner_gt?: InputMaybe<Scalars["String"]>;
  owner_lt?: InputMaybe<Scalars["String"]>;
  owner_gte?: InputMaybe<Scalars["String"]>;
  owner_lte?: InputMaybe<Scalars["String"]>;
  owner_in?: InputMaybe<Array<Scalars["String"]>>;
  owner_not_in?: InputMaybe<Array<Scalars["String"]>>;
  owner_contains?: InputMaybe<Scalars["String"]>;
  owner_contains_nocase?: InputMaybe<Scalars["String"]>;
  owner_not_contains?: InputMaybe<Scalars["String"]>;
  owner_not_contains_nocase?: InputMaybe<Scalars["String"]>;
  owner_starts_with?: InputMaybe<Scalars["String"]>;
  owner_starts_with_nocase?: InputMaybe<Scalars["String"]>;
  owner_not_starts_with?: InputMaybe<Scalars["String"]>;
  owner_not_starts_with_nocase?: InputMaybe<Scalars["String"]>;
  owner_ends_with?: InputMaybe<Scalars["String"]>;
  owner_ends_with_nocase?: InputMaybe<Scalars["String"]>;
  owner_not_ends_with?: InputMaybe<Scalars["String"]>;
  owner_not_ends_with_nocase?: InputMaybe<Scalars["String"]>;
  owner_?: InputMaybe<Account_filter>;
  creator?: InputMaybe<Scalars["String"]>;
  creator_not?: InputMaybe<Scalars["String"]>;
  creator_gt?: InputMaybe<Scalars["String"]>;
  creator_lt?: InputMaybe<Scalars["String"]>;
  creator_gte?: InputMaybe<Scalars["String"]>;
  creator_lte?: InputMaybe<Scalars["String"]>;
  creator_in?: InputMaybe<Array<Scalars["String"]>>;
  creator_not_in?: InputMaybe<Array<Scalars["String"]>>;
  creator_contains?: InputMaybe<Scalars["String"]>;
  creator_contains_nocase?: InputMaybe<Scalars["String"]>;
  creator_not_contains?: InputMaybe<Scalars["String"]>;
  creator_not_contains_nocase?: InputMaybe<Scalars["String"]>;
  creator_starts_with?: InputMaybe<Scalars["String"]>;
  creator_starts_with_nocase?: InputMaybe<Scalars["String"]>;
  creator_not_starts_with?: InputMaybe<Scalars["String"]>;
  creator_not_starts_with_nocase?: InputMaybe<Scalars["String"]>;
  creator_ends_with?: InputMaybe<Scalars["String"]>;
  creator_ends_with_nocase?: InputMaybe<Scalars["String"]>;
  creator_not_ends_with?: InputMaybe<Scalars["String"]>;
  creator_not_ends_with_nocase?: InputMaybe<Scalars["String"]>;
  creator_?: InputMaybe<Account_filter>;
  prevOwner?: InputMaybe<Scalars["String"]>;
  prevOwner_not?: InputMaybe<Scalars["String"]>;
  prevOwner_gt?: InputMaybe<Scalars["String"]>;
  prevOwner_lt?: InputMaybe<Scalars["String"]>;
  prevOwner_gte?: InputMaybe<Scalars["String"]>;
  prevOwner_lte?: InputMaybe<Scalars["String"]>;
  prevOwner_in?: InputMaybe<Array<Scalars["String"]>>;
  prevOwner_not_in?: InputMaybe<Array<Scalars["String"]>>;
  prevOwner_contains?: InputMaybe<Scalars["String"]>;
  prevOwner_contains_nocase?: InputMaybe<Scalars["String"]>;
  prevOwner_not_contains?: InputMaybe<Scalars["String"]>;
  prevOwner_not_contains_nocase?: InputMaybe<Scalars["String"]>;
  prevOwner_starts_with?: InputMaybe<Scalars["String"]>;
  prevOwner_starts_with_nocase?: InputMaybe<Scalars["String"]>;
  prevOwner_not_starts_with?: InputMaybe<Scalars["String"]>;
  prevOwner_not_starts_with_nocase?: InputMaybe<Scalars["String"]>;
  prevOwner_ends_with?: InputMaybe<Scalars["String"]>;
  prevOwner_ends_with_nocase?: InputMaybe<Scalars["String"]>;
  prevOwner_not_ends_with?: InputMaybe<Scalars["String"]>;
  prevOwner_not_ends_with_nocase?: InputMaybe<Scalars["String"]>;
  prevOwner_?: InputMaybe<Account_filter>;
  approved?: InputMaybe<Scalars["String"]>;
  approved_not?: InputMaybe<Scalars["String"]>;
  approved_gt?: InputMaybe<Scalars["String"]>;
  approved_lt?: InputMaybe<Scalars["String"]>;
  approved_gte?: InputMaybe<Scalars["String"]>;
  approved_lte?: InputMaybe<Scalars["String"]>;
  approved_in?: InputMaybe<Array<Scalars["String"]>>;
  approved_not_in?: InputMaybe<Array<Scalars["String"]>>;
  approved_contains?: InputMaybe<Scalars["String"]>;
  approved_contains_nocase?: InputMaybe<Scalars["String"]>;
  approved_not_contains?: InputMaybe<Scalars["String"]>;
  approved_not_contains_nocase?: InputMaybe<Scalars["String"]>;
  approved_starts_with?: InputMaybe<Scalars["String"]>;
  approved_starts_with_nocase?: InputMaybe<Scalars["String"]>;
  approved_not_starts_with?: InputMaybe<Scalars["String"]>;
  approved_not_starts_with_nocase?: InputMaybe<Scalars["String"]>;
  approved_ends_with?: InputMaybe<Scalars["String"]>;
  approved_ends_with_nocase?: InputMaybe<Scalars["String"]>;
  approved_not_ends_with?: InputMaybe<Scalars["String"]>;
  approved_not_ends_with_nocase?: InputMaybe<Scalars["String"]>;
  approved_?: InputMaybe<Account_filter>;
  metadataURI?: InputMaybe<Scalars["String"]>;
  metadataURI_not?: InputMaybe<Scalars["String"]>;
  metadataURI_gt?: InputMaybe<Scalars["String"]>;
  metadataURI_lt?: InputMaybe<Scalars["String"]>;
  metadataURI_gte?: InputMaybe<Scalars["String"]>;
  metadataURI_lte?: InputMaybe<Scalars["String"]>;
  metadataURI_in?: InputMaybe<Array<Scalars["String"]>>;
  metadataURI_not_in?: InputMaybe<Array<Scalars["String"]>>;
  metadataURI_contains?: InputMaybe<Scalars["String"]>;
  metadataURI_contains_nocase?: InputMaybe<Scalars["String"]>;
  metadataURI_not_contains?: InputMaybe<Scalars["String"]>;
  metadataURI_not_contains_nocase?: InputMaybe<Scalars["String"]>;
  metadataURI_starts_with?: InputMaybe<Scalars["String"]>;
  metadataURI_starts_with_nocase?: InputMaybe<Scalars["String"]>;
  metadataURI_not_starts_with?: InputMaybe<Scalars["String"]>;
  metadataURI_not_starts_with_nocase?: InputMaybe<Scalars["String"]>;
  metadataURI_ends_with?: InputMaybe<Scalars["String"]>;
  metadataURI_ends_with_nocase?: InputMaybe<Scalars["String"]>;
  metadataURI_not_ends_with?: InputMaybe<Scalars["String"]>;
  metadataURI_not_ends_with_nocase?: InputMaybe<Scalars["String"]>;
  createdAtTimestamp?: InputMaybe<Scalars["BigInt"]>;
  createdAtTimestamp_not?: InputMaybe<Scalars["BigInt"]>;
  createdAtTimestamp_gt?: InputMaybe<Scalars["BigInt"]>;
  createdAtTimestamp_lt?: InputMaybe<Scalars["BigInt"]>;
  createdAtTimestamp_gte?: InputMaybe<Scalars["BigInt"]>;
  createdAtTimestamp_lte?: InputMaybe<Scalars["BigInt"]>;
  createdAtTimestamp_in?: InputMaybe<Array<Scalars["BigInt"]>>;
  createdAtTimestamp_not_in?: InputMaybe<Array<Scalars["BigInt"]>>;
  createdAtBlockNumber?: InputMaybe<Scalars["BigInt"]>;
  createdAtBlockNumber_not?: InputMaybe<Scalars["BigInt"]>;
  createdAtBlockNumber_gt?: InputMaybe<Scalars["BigInt"]>;
  createdAtBlockNumber_lt?: InputMaybe<Scalars["BigInt"]>;
  createdAtBlockNumber_gte?: InputMaybe<Scalars["BigInt"]>;
  createdAtBlockNumber_lte?: InputMaybe<Scalars["BigInt"]>;
  createdAtBlockNumber_in?: InputMaybe<Array<Scalars["BigInt"]>>;
  createdAtBlockNumber_not_in?: InputMaybe<Array<Scalars["BigInt"]>>;
  updatedAtTimestamp?: InputMaybe<Scalars["BigInt"]>;
  updatedAtTimestamp_not?: InputMaybe<Scalars["BigInt"]>;
  updatedAtTimestamp_gt?: InputMaybe<Scalars["BigInt"]>;
  updatedAtTimestamp_lt?: InputMaybe<Scalars["BigInt"]>;
  updatedAtTimestamp_gte?: InputMaybe<Scalars["BigInt"]>;
  updatedAtTimestamp_lte?: InputMaybe<Scalars["BigInt"]>;
  updatedAtTimestamp_in?: InputMaybe<Array<Scalars["BigInt"]>>;
  updatedAtTimestamp_not_in?: InputMaybe<Array<Scalars["BigInt"]>>;
  updatedAtBlockNumber?: InputMaybe<Scalars["BigInt"]>;
  updatedAtBlockNumber_not?: InputMaybe<Scalars["BigInt"]>;
  updatedAtBlockNumber_gt?: InputMaybe<Scalars["BigInt"]>;
  updatedAtBlockNumber_lt?: InputMaybe<Scalars["BigInt"]>;
  updatedAtBlockNumber_gte?: InputMaybe<Scalars["BigInt"]>;
  updatedAtBlockNumber_lte?: InputMaybe<Scalars["BigInt"]>;
  updatedAtBlockNumber_in?: InputMaybe<Array<Scalars["BigInt"]>>;
  updatedAtBlockNumber_not_in?: InputMaybe<Array<Scalars["BigInt"]>>;
  supportsMetadata?: InputMaybe<Scalars["Boolean"]>;
  supportsMetadata_not?: InputMaybe<Scalars["Boolean"]>;
  supportsMetadata_in?: InputMaybe<Array<Scalars["Boolean"]>>;
  supportsMetadata_not_in?: InputMaybe<Array<Scalars["Boolean"]>>;
  name?: InputMaybe<Scalars["String"]>;
  name_not?: InputMaybe<Scalars["String"]>;
  name_gt?: InputMaybe<Scalars["String"]>;
  name_lt?: InputMaybe<Scalars["String"]>;
  name_gte?: InputMaybe<Scalars["String"]>;
  name_lte?: InputMaybe<Scalars["String"]>;
  name_in?: InputMaybe<Array<Scalars["String"]>>;
  name_not_in?: InputMaybe<Array<Scalars["String"]>>;
  name_contains?: InputMaybe<Scalars["String"]>;
  name_contains_nocase?: InputMaybe<Scalars["String"]>;
  name_not_contains?: InputMaybe<Scalars["String"]>;
  name_not_contains_nocase?: InputMaybe<Scalars["String"]>;
  name_starts_with?: InputMaybe<Scalars["String"]>;
  name_starts_with_nocase?: InputMaybe<Scalars["String"]>;
  name_not_starts_with?: InputMaybe<Scalars["String"]>;
  name_not_starts_with_nocase?: InputMaybe<Scalars["String"]>;
  name_ends_with?: InputMaybe<Scalars["String"]>;
  name_ends_with_nocase?: InputMaybe<Scalars["String"]>;
  name_not_ends_with?: InputMaybe<Scalars["String"]>;
  name_not_ends_with_nocase?: InputMaybe<Scalars["String"]>;
  metadata?: InputMaybe<Scalars["String"]>;
  metadata_not?: InputMaybe<Scalars["String"]>;
  metadata_gt?: InputMaybe<Scalars["String"]>;
  metadata_lt?: InputMaybe<Scalars["String"]>;
  metadata_gte?: InputMaybe<Scalars["String"]>;
  metadata_lte?: InputMaybe<Scalars["String"]>;
  metadata_in?: InputMaybe<Array<Scalars["String"]>>;
  metadata_not_in?: InputMaybe<Array<Scalars["String"]>>;
  metadata_contains?: InputMaybe<Scalars["String"]>;
  metadata_contains_nocase?: InputMaybe<Scalars["String"]>;
  metadata_not_contains?: InputMaybe<Scalars["String"]>;
  metadata_not_contains_nocase?: InputMaybe<Scalars["String"]>;
  metadata_starts_with?: InputMaybe<Scalars["String"]>;
  metadata_starts_with_nocase?: InputMaybe<Scalars["String"]>;
  metadata_not_starts_with?: InputMaybe<Scalars["String"]>;
  metadata_not_starts_with_nocase?: InputMaybe<Scalars["String"]>;
  metadata_ends_with?: InputMaybe<Scalars["String"]>;
  metadata_ends_with_nocase?: InputMaybe<Scalars["String"]>;
  metadata_not_ends_with?: InputMaybe<Scalars["String"]>;
  metadata_not_ends_with_nocase?: InputMaybe<Scalars["String"]>;
  symbol?: InputMaybe<Scalars["String"]>;
  symbol_not?: InputMaybe<Scalars["String"]>;
  symbol_gt?: InputMaybe<Scalars["String"]>;
  symbol_lt?: InputMaybe<Scalars["String"]>;
  symbol_gte?: InputMaybe<Scalars["String"]>;
  symbol_lte?: InputMaybe<Scalars["String"]>;
  symbol_in?: InputMaybe<Array<Scalars["String"]>>;
  symbol_not_in?: InputMaybe<Array<Scalars["String"]>>;
  symbol_contains?: InputMaybe<Scalars["String"]>;
  symbol_contains_nocase?: InputMaybe<Scalars["String"]>;
  symbol_not_contains?: InputMaybe<Scalars["String"]>;
  symbol_not_contains_nocase?: InputMaybe<Scalars["String"]>;
  symbol_starts_with?: InputMaybe<Scalars["String"]>;
  symbol_starts_with_nocase?: InputMaybe<Scalars["String"]>;
  symbol_not_starts_with?: InputMaybe<Scalars["String"]>;
  symbol_not_starts_with_nocase?: InputMaybe<Scalars["String"]>;
  symbol_ends_with?: InputMaybe<Scalars["String"]>;
  symbol_ends_with_nocase?: InputMaybe<Scalars["String"]>;
  symbol_not_ends_with?: InputMaybe<Scalars["String"]>;
  symbol_not_ends_with_nocase?: InputMaybe<Scalars["String"]>;
  template?: InputMaybe<Scalars["String"]>;
  template_not?: InputMaybe<Scalars["String"]>;
  template_gt?: InputMaybe<Scalars["String"]>;
  template_lt?: InputMaybe<Scalars["String"]>;
  template_gte?: InputMaybe<Scalars["String"]>;
  template_lte?: InputMaybe<Scalars["String"]>;
  template_in?: InputMaybe<Array<Scalars["String"]>>;
  template_not_in?: InputMaybe<Array<Scalars["String"]>>;
  template_contains?: InputMaybe<Scalars["String"]>;
  template_contains_nocase?: InputMaybe<Scalars["String"]>;
  template_not_contains?: InputMaybe<Scalars["String"]>;
  template_not_contains_nocase?: InputMaybe<Scalars["String"]>;
  template_starts_with?: InputMaybe<Scalars["String"]>;
  template_starts_with_nocase?: InputMaybe<Scalars["String"]>;
  template_not_starts_with?: InputMaybe<Scalars["String"]>;
  template_not_starts_with_nocase?: InputMaybe<Scalars["String"]>;
  template_ends_with?: InputMaybe<Scalars["String"]>;
  template_ends_with_nocase?: InputMaybe<Scalars["String"]>;
  template_not_ends_with?: InputMaybe<Scalars["String"]>;
  template_not_ends_with_nocase?: InputMaybe<Scalars["String"]>;
  managers?: InputMaybe<Array<Scalars["String"]>>;
  managers_not?: InputMaybe<Array<Scalars["String"]>>;
  managers_contains?: InputMaybe<Array<Scalars["String"]>>;
  managers_contains_nocase?: InputMaybe<Array<Scalars["String"]>>;
  managers_not_contains?: InputMaybe<Array<Scalars["String"]>>;
  managers_not_contains_nocase?: InputMaybe<Array<Scalars["String"]>>;
  paused?: InputMaybe<Scalars["Boolean"]>;
  paused_not?: InputMaybe<Scalars["Boolean"]>;
  paused_in?: InputMaybe<Array<Scalars["Boolean"]>>;
  paused_not_in?: InputMaybe<Array<Scalars["Boolean"]>>;
  offers_?: InputMaybe<Offer_filter>;
  sessions_?: InputMaybe<FileSaleSession_filter>;
  events?: InputMaybe<Array<Scalars["String"]>>;
  events_not?: InputMaybe<Array<Scalars["String"]>>;
  events_contains?: InputMaybe<Array<Scalars["String"]>>;
  events_contains_nocase?: InputMaybe<Array<Scalars["String"]>>;
  events_not_contains?: InputMaybe<Array<Scalars["String"]>>;
  events_not_contains_nocase?: InputMaybe<Array<Scalars["String"]>>;
  events_?: InputMaybe<Event_filter>;
  /** Filter for the block changed event. */
  _change_block?: InputMaybe<BlockChangedFilter>;
};

export type Token_orderBy =
  | "id"
  | "kind"
  | "transactionHash"
  | "owner"
  | "creator"
  | "prevOwner"
  | "approved"
  | "metadataURI"
  | "createdAtTimestamp"
  | "createdAtBlockNumber"
  | "updatedAtTimestamp"
  | "updatedAtBlockNumber"
  | "supportsMetadata"
  | "name"
  | "metadata"
  | "symbol"
  | "template"
  | "managers"
  | "paused"
  | "offers"
  | "sessions"
  | "events";

export type _Block_ = {
  /** The hash of the block */
  hash?: Maybe<Scalars["Bytes"]>;
  /** The block number */
  number: Scalars["Int"];
  /** Integer representation of the timestamp stored in blocks for the chain */
  timestamp?: Maybe<Scalars["Int"]>;
};

/** The type for the top-level _meta field */
export type _Meta_ = {
  /**
   * Information about a specific subgraph block. The hash of the block
   * will be null if the _meta field has a block constraint that asks for
   * a block number. It will be filled if the _meta field has no block constraint
   * and therefore asks for the latest  block
   *
   */
  block: _Block_;
  /** The deployment ID */
  deployment: Scalars["String"];
  /** If `true`, the subgraph encountered indexing errors at some past block */
  hasIndexingErrors: Scalars["Boolean"];
};

export type _SubgraphErrorPolicy_ =
  /** Data will be returned even if the subgraph has indexing errors */
  | "allow"
  /** If the subgraph has indexing errors, data will be omitted. The default. */
  | "deny";

export type WithIndex<TObject> = TObject & Record<string, any>;
export type ResolversObject<TObject> = WithIndex<TObject>;

export type ResolverTypeWrapper<T> = Promise<T> | T;

export type ResolverWithResolve<TResult, TParent, TContext, TArgs> = {
  resolve: ResolverFn<TResult, TParent, TContext, TArgs>;
};

export type LegacyStitchingResolver<TResult, TParent, TContext, TArgs> = {
  fragment: string;
  resolve: ResolverFn<TResult, TParent, TContext, TArgs>;
};

export type NewStitchingResolver<TResult, TParent, TContext, TArgs> = {
  selectionSet: string | ((fieldNode: FieldNode) => SelectionSetNode);
  resolve: ResolverFn<TResult, TParent, TContext, TArgs>;
};
export type StitchingResolver<TResult, TParent, TContext, TArgs> =
  | LegacyStitchingResolver<TResult, TParent, TContext, TArgs>
  | NewStitchingResolver<TResult, TParent, TContext, TArgs>;
export type Resolver<TResult, TParent = {}, TContext = {}, TArgs = {}> =
  | ResolverFn<TResult, TParent, TContext, TArgs>
  | ResolverWithResolve<TResult, TParent, TContext, TArgs>
  | StitchingResolver<TResult, TParent, TContext, TArgs>;

export type ResolverFn<TResult, TParent, TContext, TArgs> = (
  parent: TParent,
  args: TArgs,
  context: TContext,
  info: GraphQLResolveInfo,
) => Promise<TResult> | TResult;

export type SubscriptionSubscribeFn<TResult, TParent, TContext, TArgs> = (
  parent: TParent,
  args: TArgs,
  context: TContext,
  info: GraphQLResolveInfo,
) => AsyncIterable<TResult> | Promise<AsyncIterable<TResult>>;

export type SubscriptionResolveFn<TResult, TParent, TContext, TArgs> = (
  parent: TParent,
  args: TArgs,
  context: TContext,
  info: GraphQLResolveInfo,
) => TResult | Promise<TResult>;

export interface SubscriptionSubscriberObject<
  TResult,
  TKey extends string,
  TParent,
  TContext,
  TArgs,
> {
  subscribe: SubscriptionSubscribeFn<
    { [key in TKey]: TResult },
    TParent,
    TContext,
    TArgs
  >;
  resolve?: SubscriptionResolveFn<
    TResult,
    { [key in TKey]: TResult },
    TContext,
    TArgs
  >;
}

export interface SubscriptionResolverObject<TResult, TParent, TContext, TArgs> {
  subscribe: SubscriptionSubscribeFn<any, TParent, TContext, TArgs>;
  resolve: SubscriptionResolveFn<TResult, any, TContext, TArgs>;
}

export type SubscriptionObject<
  TResult,
  TKey extends string,
  TParent,
  TContext,
  TArgs,
> =
  | SubscriptionSubscriberObject<TResult, TKey, TParent, TContext, TArgs>
  | SubscriptionResolverObject<TResult, TParent, TContext, TArgs>;

export type SubscriptionResolver<
  TResult,
  TKey extends string,
  TParent = {},
  TContext = {},
  TArgs = {},
> =
  | ((
      ...args: any[]
    ) => SubscriptionObject<TResult, TKey, TParent, TContext, TArgs>)
  | SubscriptionObject<TResult, TKey, TParent, TContext, TArgs>;

export type TypeResolveFn<TTypes, TParent = {}, TContext = {}> = (
  parent: TParent,
  context: TContext,
  info: GraphQLResolveInfo,
) => Maybe<TTypes> | Promise<Maybe<TTypes>>;

export type IsTypeOfResolverFn<T = {}, TContext = {}> = (
  obj: T,
  context: TContext,
  info: GraphQLResolveInfo,
) => boolean | Promise<boolean>;

export type NextResolverFn<T> = () => Promise<T>;

export type DirectiveResolverFn<
  TResult = {},
  TParent = {},
  TContext = {},
  TArgs = {},
> = (
  next: NextResolverFn<TResult>,
  parent: TParent,
  args: TArgs,
  context: TContext,
  info: GraphQLResolveInfo,
) => TResult | Promise<TResult>;

/** Mapping between all available schema types and the resolvers types */
export type ResolversTypes = ResolversObject<{
  Account: ResolverTypeWrapper<Account>;
  Account_filter: Account_filter;
  Account_orderBy: Account_orderBy;
  BigDecimal: ResolverTypeWrapper<Scalars["BigDecimal"]>;
  BigInt: ResolverTypeWrapper<Scalars["BigInt"]>;
  BlockChangedFilter: BlockChangedFilter;
  Block_height: Block_height;
  Boolean: ResolverTypeWrapper<Scalars["Boolean"]>;
  Bytes: ResolverTypeWrapper<Scalars["Bytes"]>;
  Event: ResolverTypeWrapper<Event>;
  EventType: EventType;
  Event_filter: Event_filter;
  Event_orderBy: Event_orderBy;
  FileSaleSession: ResolverTypeWrapper<FileSaleSession>;
  FileSaleSession_filter: FileSaleSession_filter;
  FileSaleSession_orderBy: FileSaleSession_orderBy;
  Float: ResolverTypeWrapper<Scalars["Float"]>;
  ID: ResolverTypeWrapper<Scalars["ID"]>;
  Int: ResolverTypeWrapper<Scalars["Int"]>;
  Offer: ResolverTypeWrapper<Offer>;
  Offer_filter: Offer_filter;
  Offer_orderBy: Offer_orderBy;
  OrderDirection: OrderDirection;
  Query: ResolverTypeWrapper<{}>;
  String: ResolverTypeWrapper<Scalars["String"]>;
  Subscription: ResolverTypeWrapper<{}>;
  Token: ResolverTypeWrapper<Token>;
  Token_filter: Token_filter;
  Token_orderBy: Token_orderBy;
  _Block_: ResolverTypeWrapper<_Block_>;
  _Meta_: ResolverTypeWrapper<_Meta_>;
  _SubgraphErrorPolicy_: _SubgraphErrorPolicy_;
}>;

/** Mapping between all available schema types and the resolvers parents */
export type ResolversParentTypes = ResolversObject<{
  Account: Account;
  Account_filter: Account_filter;
  BigDecimal: Scalars["BigDecimal"];
  BigInt: Scalars["BigInt"];
  BlockChangedFilter: BlockChangedFilter;
  Block_height: Block_height;
  Boolean: Scalars["Boolean"];
  Bytes: Scalars["Bytes"];
  Event: Event;
  Event_filter: Event_filter;
  FileSaleSession: FileSaleSession;
  FileSaleSession_filter: FileSaleSession_filter;
  Float: Scalars["Float"];
  ID: Scalars["ID"];
  Int: Scalars["Int"];
  Offer: Offer;
  Offer_filter: Offer_filter;
  Query: {};
  String: Scalars["String"];
  Subscription: {};
  Token: Token;
  Token_filter: Token_filter;
  _Block_: _Block_;
  _Meta_: _Meta_;
}>;

export type entityDirectiveArgs = {};

export type entityDirectiveResolver<
  Result,
  Parent,
  ContextType = MeshContext,
  Args = entityDirectiveArgs,
> = DirectiveResolverFn<Result, Parent, ContextType, Args>;

export type subgraphIdDirectiveArgs = {
  id: Scalars["String"];
};

export type subgraphIdDirectiveResolver<
  Result,
  Parent,
  ContextType = MeshContext,
  Args = subgraphIdDirectiveArgs,
> = DirectiveResolverFn<Result, Parent, ContextType, Args>;

export type derivedFromDirectiveArgs = {
  field: Scalars["String"];
};

export type derivedFromDirectiveResolver<
  Result,
  Parent,
  ContextType = MeshContext,
  Args = derivedFromDirectiveArgs,
> = DirectiveResolverFn<Result, Parent, ContextType, Args>;

export type AccountResolvers<
  ContextType = MeshContext,
  ParentType extends ResolversParentTypes["Account"] = ResolversParentTypes["Account"],
> = ResolversObject<{
  id?: Resolver<ResolversTypes["ID"], ParentType, ContextType>;
  possessions?: Resolver<
    Array<ResolversTypes["Token"]>,
    ParentType,
    ContextType,
    RequireFields<AccountpossessionsArgs, "skip" | "first">
  >;
  creations?: Resolver<
    Array<ResolversTypes["Token"]>,
    ParentType,
    ContextType,
    RequireFields<AccountcreationsArgs, "skip" | "first">
  >;
  purchases?: Resolver<
    Array<ResolversTypes["FileSaleSession"]>,
    ParentType,
    ContextType,
    RequireFields<AccountpurchasesArgs, "skip" | "first">
  >;
  sales?: Resolver<
    Array<ResolversTypes["FileSaleSession"]>,
    ParentType,
    ContextType,
    RequireFields<AccountsalesArgs, "skip" | "first">
  >;
  activities?: Resolver<
    Array<ResolversTypes["Event"]>,
    ParentType,
    ContextType,
    RequireFields<AccountactivitiesArgs, "skip" | "first">
  >;
  __isTypeOf?: IsTypeOfResolverFn<ParentType, ContextType>;
}>;

export interface BigDecimalScalarConfig
  extends GraphQLScalarTypeConfig<ResolversTypes["BigDecimal"], any> {
  name: "BigDecimal";
}

export interface BigIntScalarConfig
  extends GraphQLScalarTypeConfig<ResolversTypes["BigInt"], any> {
  name: "BigInt";
}

export interface BytesScalarConfig
  extends GraphQLScalarTypeConfig<ResolversTypes["Bytes"], any> {
  name: "Bytes";
}

export type EventResolvers<
  ContextType = MeshContext,
  ParentType extends ResolversParentTypes["Event"] = ResolversParentTypes["Event"],
> = ResolversObject<{
  id?: Resolver<ResolversTypes["ID"], ParentType, ContextType>;
  from?: Resolver<ResolversTypes["Account"], ParentType, ContextType>;
  to?: Resolver<ResolversTypes["String"], ParentType, ContextType>;
  createdAtTimestamp?: Resolver<
    ResolversTypes["BigInt"],
    ParentType,
    ContextType
  >;
  createdAtBlockNumber?: Resolver<
    ResolversTypes["BigInt"],
    ParentType,
    ContextType
  >;
  gasPrice?: Resolver<ResolversTypes["BigInt"], ParentType, ContextType>;
  value?: Resolver<ResolversTypes["BigInt"], ParentType, ContextType>;
  type?: Resolver<ResolversTypes["EventType"], ParentType, ContextType>;
  transactionHash?: Resolver<ResolversTypes["String"], ParentType, ContextType>;
  __isTypeOf?: IsTypeOfResolverFn<ParentType, ContextType>;
}>;

export type FileSaleSessionResolvers<
  ContextType = MeshContext,
  ParentType extends ResolversParentTypes["FileSaleSession"] = ResolversParentTypes["FileSaleSession"],
> = ResolversObject<{
  id?: Resolver<ResolversTypes["ID"], ParentType, ContextType>;
  phase?: Resolver<ResolversTypes["BigInt"], ParentType, ContextType>;
  sender?: Resolver<ResolversTypes["Account"], ParentType, ContextType>;
  receiver?: Resolver<ResolversTypes["Account"], ParentType, ContextType>;
  dataset?: Resolver<ResolversTypes["Token"], ParentType, ContextType>;
  algorithm?: Resolver<ResolversTypes["Token"], ParentType, ContextType>;
  verifier?: Resolver<ResolversTypes["String"], ParentType, ContextType>;
  pkUrl?: Resolver<ResolversTypes["String"], ParentType, ContextType>;
  depth?: Resolver<ResolversTypes["BigInt"], ParentType, ContextType>;
  length?: Resolver<ResolversTypes["BigInt"], ParentType, ContextType>;
  n?: Resolver<ResolversTypes["BigInt"], ParentType, ContextType>;
  timeout?: Resolver<ResolversTypes["BigInt"], ParentType, ContextType>;
  timeoutInterval?: Resolver<ResolversTypes["BigInt"], ParentType, ContextType>;
  price?: Resolver<ResolversTypes["BigInt"], ParentType, ContextType>;
  keyCommit?: Resolver<ResolversTypes["String"], ParentType, ContextType>;
  key?: Resolver<ResolversTypes["String"], ParentType, ContextType>;
  fileRoot?: Resolver<ResolversTypes["String"], ParentType, ContextType>;
  ciphertextRoot?: Resolver<ResolversTypes["String"], ParentType, ContextType>;
  createdAtTimestamp?: Resolver<
    ResolversTypes["BigInt"],
    ParentType,
    ContextType
  >;
  createdAtBlockNumber?: Resolver<
    ResolversTypes["BigInt"],
    ParentType,
    ContextType
  >;
  updatedAtTimestamp?: Resolver<
    ResolversTypes["BigInt"],
    ParentType,
    ContextType
  >;
  updatedAtBlockNumber?: Resolver<
    ResolversTypes["BigInt"],
    ParentType,
    ContextType
  >;
  events?: Resolver<
    Maybe<Array<ResolversTypes["Event"]>>,
    ParentType,
    ContextType,
    RequireFields<FileSaleSessioneventsArgs, "skip" | "first">
  >;
  __isTypeOf?: IsTypeOfResolverFn<ParentType, ContextType>;
}>;

export type OfferResolvers<
  ContextType = MeshContext,
  ParentType extends ResolversParentTypes["Offer"] = ResolversParentTypes["Offer"],
> = ResolversObject<{
  id?: Resolver<ResolversTypes["ID"], ParentType, ContextType>;
  sender?: Resolver<ResolversTypes["Account"], ParentType, ContextType>;
  price?: Resolver<ResolversTypes["BigInt"], ParentType, ContextType>;
  algorithm?: Resolver<ResolversTypes["Token"], ParentType, ContextType>;
  dataset?: Resolver<ResolversTypes["Token"], ParentType, ContextType>;
  createdAtTimestamp?: Resolver<
    ResolversTypes["BigInt"],
    ParentType,
    ContextType
  >;
  createdAtBlockNumber?: Resolver<
    ResolversTypes["BigInt"],
    ParentType,
    ContextType
  >;
  updatedAtTimestamp?: Resolver<
    ResolversTypes["BigInt"],
    ParentType,
    ContextType
  >;
  updatedAtBlockNumber?: Resolver<
    ResolversTypes["BigInt"],
    ParentType,
    ContextType
  >;
  __isTypeOf?: IsTypeOfResolverFn<ParentType, ContextType>;
}>;

export type QueryResolvers<
  ContextType = MeshContext,
  ParentType extends ResolversParentTypes["Query"] = ResolversParentTypes["Query"],
> = ResolversObject<{
  token?: Resolver<
    Maybe<ResolversTypes["Token"]>,
    ParentType,
    ContextType,
    RequireFields<QuerytokenArgs, "id" | "subgraphError">
  >;
  tokens?: Resolver<
    Array<ResolversTypes["Token"]>,
    ParentType,
    ContextType,
    RequireFields<QuerytokensArgs, "skip" | "first" | "subgraphError">
  >;
  account?: Resolver<
    Maybe<ResolversTypes["Account"]>,
    ParentType,
    ContextType,
    RequireFields<QueryaccountArgs, "id" | "subgraphError">
  >;
  accounts?: Resolver<
    Array<ResolversTypes["Account"]>,
    ParentType,
    ContextType,
    RequireFields<QueryaccountsArgs, "skip" | "first" | "subgraphError">
  >;
  event?: Resolver<
    Maybe<ResolversTypes["Event"]>,
    ParentType,
    ContextType,
    RequireFields<QueryeventArgs, "id" | "subgraphError">
  >;
  events?: Resolver<
    Array<ResolversTypes["Event"]>,
    ParentType,
    ContextType,
    RequireFields<QueryeventsArgs, "skip" | "first" | "subgraphError">
  >;
  offer?: Resolver<
    Maybe<ResolversTypes["Offer"]>,
    ParentType,
    ContextType,
    RequireFields<QueryofferArgs, "id" | "subgraphError">
  >;
  offers?: Resolver<
    Array<ResolversTypes["Offer"]>,
    ParentType,
    ContextType,
    RequireFields<QueryoffersArgs, "skip" | "first" | "subgraphError">
  >;
  fileSaleSession?: Resolver<
    Maybe<ResolversTypes["FileSaleSession"]>,
    ParentType,
    ContextType,
    RequireFields<QueryfileSaleSessionArgs, "id" | "subgraphError">
  >;
  fileSaleSessions?: Resolver<
    Array<ResolversTypes["FileSaleSession"]>,
    ParentType,
    ContextType,
    RequireFields<QueryfileSaleSessionsArgs, "skip" | "first" | "subgraphError">
  >;
  _meta?: Resolver<
    Maybe<ResolversTypes["_Meta_"]>,
    ParentType,
    ContextType,
    Partial<Query_metaArgs>
  >;
}>;

export type SubscriptionResolvers<
  ContextType = MeshContext,
  ParentType extends ResolversParentTypes["Subscription"] = ResolversParentTypes["Subscription"],
> = ResolversObject<{
  token?: SubscriptionResolver<
    Maybe<ResolversTypes["Token"]>,
    "token",
    ParentType,
    ContextType,
    RequireFields<SubscriptiontokenArgs, "id" | "subgraphError">
  >;
  tokens?: SubscriptionResolver<
    Array<ResolversTypes["Token"]>,
    "tokens",
    ParentType,
    ContextType,
    RequireFields<SubscriptiontokensArgs, "skip" | "first" | "subgraphError">
  >;
  account?: SubscriptionResolver<
    Maybe<ResolversTypes["Account"]>,
    "account",
    ParentType,
    ContextType,
    RequireFields<SubscriptionaccountArgs, "id" | "subgraphError">
  >;
  accounts?: SubscriptionResolver<
    Array<ResolversTypes["Account"]>,
    "accounts",
    ParentType,
    ContextType,
    RequireFields<SubscriptionaccountsArgs, "skip" | "first" | "subgraphError">
  >;
  event?: SubscriptionResolver<
    Maybe<ResolversTypes["Event"]>,
    "event",
    ParentType,
    ContextType,
    RequireFields<SubscriptioneventArgs, "id" | "subgraphError">
  >;
  events?: SubscriptionResolver<
    Array<ResolversTypes["Event"]>,
    "events",
    ParentType,
    ContextType,
    RequireFields<SubscriptioneventsArgs, "skip" | "first" | "subgraphError">
  >;
  offer?: SubscriptionResolver<
    Maybe<ResolversTypes["Offer"]>,
    "offer",
    ParentType,
    ContextType,
    RequireFields<SubscriptionofferArgs, "id" | "subgraphError">
  >;
  offers?: SubscriptionResolver<
    Array<ResolversTypes["Offer"]>,
    "offers",
    ParentType,
    ContextType,
    RequireFields<SubscriptionoffersArgs, "skip" | "first" | "subgraphError">
  >;
  fileSaleSession?: SubscriptionResolver<
    Maybe<ResolversTypes["FileSaleSession"]>,
    "fileSaleSession",
    ParentType,
    ContextType,
    RequireFields<SubscriptionfileSaleSessionArgs, "id" | "subgraphError">
  >;
  fileSaleSessions?: SubscriptionResolver<
    Array<ResolversTypes["FileSaleSession"]>,
    "fileSaleSessions",
    ParentType,
    ContextType,
    RequireFields<
      SubscriptionfileSaleSessionsArgs,
      "skip" | "first" | "subgraphError"
    >
  >;
  _meta?: SubscriptionResolver<
    Maybe<ResolversTypes["_Meta_"]>,
    "_meta",
    ParentType,
    ContextType,
    Partial<Subscription_metaArgs>
  >;
}>;

export type TokenResolvers<
  ContextType = MeshContext,
  ParentType extends ResolversParentTypes["Token"] = ResolversParentTypes["Token"],
> = ResolversObject<{
  id?: Resolver<ResolversTypes["ID"], ParentType, ContextType>;
  kind?: Resolver<ResolversTypes["BigInt"], ParentType, ContextType>;
  transactionHash?: Resolver<ResolversTypes["String"], ParentType, ContextType>;
  owner?: Resolver<ResolversTypes["Account"], ParentType, ContextType>;
  creator?: Resolver<ResolversTypes["Account"], ParentType, ContextType>;
  prevOwner?: Resolver<ResolversTypes["Account"], ParentType, ContextType>;
  approved?: Resolver<
    Maybe<ResolversTypes["Account"]>,
    ParentType,
    ContextType
  >;
  metadataURI?: Resolver<ResolversTypes["String"], ParentType, ContextType>;
  createdAtTimestamp?: Resolver<
    ResolversTypes["BigInt"],
    ParentType,
    ContextType
  >;
  createdAtBlockNumber?: Resolver<
    ResolversTypes["BigInt"],
    ParentType,
    ContextType
  >;
  updatedAtTimestamp?: Resolver<
    ResolversTypes["BigInt"],
    ParentType,
    ContextType
  >;
  updatedAtBlockNumber?: Resolver<
    ResolversTypes["BigInt"],
    ParentType,
    ContextType
  >;
  supportsMetadata?: Resolver<
    Maybe<ResolversTypes["Boolean"]>,
    ParentType,
    ContextType
  >;
  name?: Resolver<ResolversTypes["String"], ParentType, ContextType>;
  metadata?: Resolver<Maybe<ResolversTypes["String"]>, ParentType, ContextType>;
  symbol?: Resolver<ResolversTypes["String"], ParentType, ContextType>;
  template?: Resolver<ResolversTypes["String"], ParentType, ContextType>;
  managers?: Resolver<
    Maybe<Array<ResolversTypes["String"]>>,
    ParentType,
    ContextType
  >;
  paused?: Resolver<Maybe<ResolversTypes["Boolean"]>, ParentType, ContextType>;
  offers?: Resolver<
    Maybe<Array<ResolversTypes["Offer"]>>,
    ParentType,
    ContextType,
    RequireFields<TokenoffersArgs, "skip" | "first">
  >;
  sessions?: Resolver<
    Maybe<Array<ResolversTypes["FileSaleSession"]>>,
    ParentType,
    ContextType,
    RequireFields<TokensessionsArgs, "skip" | "first">
  >;
  events?: Resolver<
    Maybe<Array<ResolversTypes["Event"]>>,
    ParentType,
    ContextType,
    RequireFields<TokeneventsArgs, "skip" | "first">
  >;
  __isTypeOf?: IsTypeOfResolverFn<ParentType, ContextType>;
}>;

export type _Block_Resolvers<
  ContextType = MeshContext,
  ParentType extends ResolversParentTypes["_Block_"] = ResolversParentTypes["_Block_"],
> = ResolversObject<{
  hash?: Resolver<Maybe<ResolversTypes["Bytes"]>, ParentType, ContextType>;
  number?: Resolver<ResolversTypes["Int"], ParentType, ContextType>;
  timestamp?: Resolver<Maybe<ResolversTypes["Int"]>, ParentType, ContextType>;
  __isTypeOf?: IsTypeOfResolverFn<ParentType, ContextType>;
}>;

export type _Meta_Resolvers<
  ContextType = MeshContext,
  ParentType extends ResolversParentTypes["_Meta_"] = ResolversParentTypes["_Meta_"],
> = ResolversObject<{
  block?: Resolver<ResolversTypes["_Block_"], ParentType, ContextType>;
  deployment?: Resolver<ResolversTypes["String"], ParentType, ContextType>;
  hasIndexingErrors?: Resolver<
    ResolversTypes["Boolean"],
    ParentType,
    ContextType
  >;
  __isTypeOf?: IsTypeOfResolverFn<ParentType, ContextType>;
}>;

export type Resolvers<ContextType = MeshContext> = ResolversObject<{
  Account?: AccountResolvers<ContextType>;
  BigDecimal?: GraphQLScalarType;
  BigInt?: GraphQLScalarType;
  Bytes?: GraphQLScalarType;
  Event?: EventResolvers<ContextType>;
  FileSaleSession?: FileSaleSessionResolvers<ContextType>;
  Offer?: OfferResolvers<ContextType>;
  Query?: QueryResolvers<ContextType>;
  Subscription?: SubscriptionResolvers<ContextType>;
  Token?: TokenResolvers<ContextType>;
  _Block_?: _Block_Resolvers<ContextType>;
  _Meta_?: _Meta_Resolvers<ContextType>;
}>;

export type DirectiveResolvers<ContextType = MeshContext> = ResolversObject<{
  entity?: entityDirectiveResolver<any, any, ContextType>;
  subgraphId?: subgraphIdDirectiveResolver<any, any, ContextType>;
  derivedFrom?: derivedFromDirectiveResolver<any, any, ContextType>;
}>;

export type MeshContext = C2DTypes.Context & BaseMeshContext;

const baseDir = pathModule.join(
  typeof __dirname === "string" ? __dirname : "/",
  "..",
);

const importFn: ImportFn = <T>(moduleId: string) => {
  const relativeModuleId = (
    pathModule.isAbsolute(moduleId)
      ? pathModule.relative(baseDir, moduleId)
      : moduleId
  )
    .split("\\")
    .join("/")
    .replace(baseDir + "/", "");
  switch (relativeModuleId) {
    case ".graphclient/sources/C2D/introspectionSchema":
      return import("./sources/C2D/introspectionSchema") as T;

    default:
      return Promise.reject(
        new Error(`Cannot find module '${relativeModuleId}'.`),
      );
  }
};

const rootStore = new MeshStore(
  ".graphclient",
  new FsStoreStorageAdapter({
    cwd: baseDir,
    importFn,
    fileType: "ts",
  }),
  {
    readonly: true,
    validate: false,
  },
);

export const rawServeConfig: YamlConfig.Config["serve"] = undefined as any;
export async function getMeshOptions(): Promise<GetMeshOptions> {
  const pubsub = new PubSub();
  const sourcesStore = rootStore.child("sources");
  const logger = new DefaultLogger("GraphClient");
  const cache = new (MeshCache as any)({
    ...({} as any),
    importFn,
    store: rootStore.child("cache"),
    pubsub,
    logger,
  } as any);

  const sources: MeshResolvedSource[] = [];
  const transforms: MeshTransform[] = [];
  const additionalEnvelopPlugins: MeshPlugin<any>[] = [];
  const c2DTransforms = [];
  const additionalTypeDefs = [] as any[];
  const c2DHandler = new GraphqlHandler({
    name: "C2D",
    config: {
      endpoint: "http://localhost:8000/subgraphs/name/c2d-trading/subgraph",
    },
    baseDir,
    cache,
    pubsub,
    store: sourcesStore.child("C2D"),
    logger: logger.child("C2D"),
    importFn,
  });
  sources[0] = {
    name: "C2D",
    handler: c2DHandler,
    transforms: c2DTransforms,
  };
  const additionalResolvers = [] as any[];
  const merger = new (BareMerger as any)({
    cache,
    pubsub,
    logger: logger.child("bareMerger"),
    store: rootStore.child("bareMerger"),
  });

  return {
    sources,
    transforms,
    additionalTypeDefs,
    additionalResolvers,
    cache,
    pubsub,
    merger,
    logger,
    additionalEnvelopPlugins,
    get documents() {
      return [
        {
          document: GetAlgorithmsDocument,
          get rawSDL() {
            return printWithCache(GetAlgorithmsDocument);
          },
          location: "GetAlgorithmsDocument.graphql",
        },
        {
          document: GetDatasetsDocument,
          get rawSDL() {
            return printWithCache(GetDatasetsDocument);
          },
          location: "GetDatasetsDocument.graphql",
        },
        {
          document: GetOrdersDocument,
          get rawSDL() {
            return printWithCache(GetOrdersDocument);
          },
          location: "GetOrdersDocument.graphql",
        },
        {
          document: GetFileSessionsDocument,
          get rawSDL() {
            return printWithCache(GetFileSessionsDocument);
          },
          location: "GetFileSessionsDocument.graphql",
        },
        {
          document: GetTokensWithOffersDocument,
          get rawSDL() {
            return printWithCache(GetTokensWithOffersDocument);
          },
          location: "GetTokensWithOffersDocument.graphql",
        },
      ];
    },
    fetchFn,
  };
}

export function createBuiltMeshHTTPHandler(): MeshHTTPHandler<MeshContext> {
  return createMeshHTTPHandler<MeshContext>({
    baseDir,
    getBuiltMesh: getBuiltGraphClient,
    rawServeConfig: undefined,
  });
}

let meshInstance$: Promise<MeshInstance> | undefined;

export function getBuiltGraphClient(): Promise<MeshInstance> {
  if (meshInstance$ == null) {
    meshInstance$ = getMeshOptions()
      .then(meshOptions => getMesh(meshOptions))
      .then(mesh => {
        const id = mesh.pubsub.subscribe("destroy", () => {
          meshInstance$ = undefined;
          mesh.pubsub.unsubscribe(id);
        });
        return mesh;
      });
  }
  return meshInstance$;
}

export const execute: ExecuteMeshFn = (...args) =>
  getBuiltGraphClient().then(({ execute }) => execute(...args));

export const subscribe: SubscribeMeshFn = (...args) =>
  getBuiltGraphClient().then(({ subscribe }) => subscribe(...args));
export function getBuiltGraphSDK<TGlobalContext = any, TOperationContext = any>(
  globalContext?: TGlobalContext,
) {
  const sdkRequester$ = getBuiltGraphClient().then(({ sdkRequesterFactory }) =>
    sdkRequesterFactory(globalContext),
  );
  return getSdk<TOperationContext, TGlobalContext>((...args) =>
    sdkRequester$.then(sdkRequester => sdkRequester(...args)),
  );
}
export type GetAlgorithmsQueryVariables = Exact<{
  kind?: InputMaybe<Scalars["BigInt"]>;
}>;

export type GetAlgorithmsQuery = {
  tokens: Array<
    Pick<
      Token,
      "id" | "kind" | "metadataURI" | "metadata" | "name" | "symbol"
    > & {
      owner: Pick<Account, "id">;
      offers?: Maybe<
        Array<
          Pick<
            Offer,
            | "price"
            | "id"
            | "updatedAtBlockNumber"
            | "updatedAtTimestamp"
            | "createdAtTimestamp"
            | "createdAtBlockNumber"
          >
        >
      >;
    }
  >;
};

export type GetDatasetsQueryVariables = Exact<{
  kind?: InputMaybe<Scalars["BigInt"]>;
}>;

export type GetDatasetsQuery = {
  tokens: Array<
    Pick<
      Token,
      "id" | "kind" | "metadataURI" | "metadata" | "name" | "symbol"
    > & {
      owner: Pick<Account, "id">;
      offers?: Maybe<
        Array<
          Pick<Offer, "id" | "price"> & {
            dataset: Pick<Token, "id" | "metadata">;
            algorithm: Pick<Token, "id" | "metadata">;
          }
        >
      >;
    }
  >;
};

export type GetOrdersQueryVariables = Exact<{ [key: string]: never }>;

export type GetOrdersQuery = {
  fileSaleSessions: Array<
    Pick<
      FileSaleSession,
      | "ciphertextRoot"
      | "createdAtBlockNumber"
      | "createdAtTimestamp"
      | "depth"
      | "fileRoot"
      | "id"
      | "key"
      | "keyCommit"
      | "length"
      | "n"
      | "phase"
      | "pkUrl"
      | "price"
      | "timeout"
      | "timeoutInterval"
      | "updatedAtBlockNumber"
      | "updatedAtTimestamp"
      | "verifier"
    >
  >;
};

export type GetFileSessionsQueryVariables = Exact<{ [key: string]: never }>;

export type GetFileSessionsQuery = {
  fileSaleSessions: Array<
    Pick<
      FileSaleSession,
      | "ciphertextRoot"
      | "createdAtBlockNumber"
      | "createdAtTimestamp"
      | "depth"
      | "fileRoot"
      | "id"
      | "key"
      | "keyCommit"
      | "length"
      | "n"
      | "phase"
      | "pkUrl"
      | "price"
      | "timeout"
      | "timeoutInterval"
      | "updatedAtBlockNumber"
      | "updatedAtTimestamp"
      | "verifier"
    > & {
      events?: Maybe<
        Array<
          Pick<
            Event,
            | "createdAtBlockNumber"
            | "createdAtTimestamp"
            | "gasPrice"
            | "id"
            | "to"
            | "transactionHash"
            | "type"
            | "value"
          >
        >
      >;
    }
  >;
};

export type GetTokensWithOffersQueryVariables = Exact<{ [key: string]: never }>;

export type GetTokensWithOffersQuery = {
  tokens: Array<
    Pick<
      Token,
      | "id"
      | "kind"
      | "managers"
      | "metadataURI"
      | "name"
      | "paused"
      | "supportsMetadata"
      | "symbol"
      | "template"
      | "transactionHash"
      | "updatedAtBlockNumber"
      | "updatedAtTimestamp"
      | "createdAtTimestamp"
      | "createdAtBlockNumber"
    > & {
      offers?: Maybe<
        Array<
          Pick<
            Offer,
            | "createdAtBlockNumber"
            | "createdAtTimestamp"
            | "id"
            | "price"
            | "updatedAtBlockNumber"
            | "updatedAtTimestamp"
          > & { algorithm: Pick<Token, "id"> & { owner: Pick<Account, "id"> } }
        >
      >;
      owner: Pick<Account, "id">;
    }
  >;
};

export const GetAlgorithmsDocument = gql`
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
` as unknown as DocumentNode<GetAlgorithmsQuery, GetAlgorithmsQueryVariables>;
export const GetDatasetsDocument = gql`
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
` as unknown as DocumentNode<GetDatasetsQuery, GetDatasetsQueryVariables>;
export const GetOrdersDocument = gql`
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
` as unknown as DocumentNode<GetOrdersQuery, GetOrdersQueryVariables>;
export const GetFileSessionsDocument = gql`
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
` as unknown as DocumentNode<
  GetFileSessionsQuery,
  GetFileSessionsQueryVariables
>;
export const GetTokensWithOffersDocument = gql`
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
` as unknown as DocumentNode<
  GetTokensWithOffersQuery,
  GetTokensWithOffersQueryVariables
>;

export type Requester<C = {}, E = unknown> = <R, V>(
  doc: DocumentNode,
  vars?: V,
  options?: C,
) => Promise<R> | AsyncIterable<R>;
export function getSdk<C, E>(requester: Requester<C, E>) {
  return {
    GetAlgorithms(
      variables?: GetAlgorithmsQueryVariables,
      options?: C,
    ): Promise<GetAlgorithmsQuery> {
      return requester<GetAlgorithmsQuery, GetAlgorithmsQueryVariables>(
        GetAlgorithmsDocument,
        variables,
        options,
      ) as Promise<GetAlgorithmsQuery>;
    },
    GetDatasets(
      variables?: GetDatasetsQueryVariables,
      options?: C,
    ): Promise<GetDatasetsQuery> {
      return requester<GetDatasetsQuery, GetDatasetsQueryVariables>(
        GetDatasetsDocument,
        variables,
        options,
      ) as Promise<GetDatasetsQuery>;
    },
    GetOrders(
      variables?: GetOrdersQueryVariables,
      options?: C,
    ): Promise<GetOrdersQuery> {
      return requester<GetOrdersQuery, GetOrdersQueryVariables>(
        GetOrdersDocument,
        variables,
        options,
      ) as Promise<GetOrdersQuery>;
    },
    GetFileSessions(
      variables?: GetFileSessionsQueryVariables,
      options?: C,
    ): Promise<GetFileSessionsQuery> {
      return requester<GetFileSessionsQuery, GetFileSessionsQueryVariables>(
        GetFileSessionsDocument,
        variables,
        options,
      ) as Promise<GetFileSessionsQuery>;
    },
    GetTokensWithOffers(
      variables?: GetTokensWithOffersQueryVariables,
      options?: C,
    ): Promise<GetTokensWithOffersQuery> {
      return requester<
        GetTokensWithOffersQuery,
        GetTokensWithOffersQueryVariables
      >(
        GetTokensWithOffersDocument,
        variables,
        options,
      ) as Promise<GetTokensWithOffersQuery>;
    },
  };
}
export type Sdk = ReturnType<typeof getSdk>;
