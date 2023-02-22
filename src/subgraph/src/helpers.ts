/* eslint-disable */
import { BigInt, Bytes, ethereum } from "@graphprotocol/graph-ts/index";
import { ERC721Created } from "../generated/ERC721Factory/ERC721Factory";
import { Token, Account, Event, FileSaleSession } from "../generated/schema";
import { ERC721 } from "../generated/templates/ERC721Template/ERC721";

export const ZERO_ADDRESS = "0x0000000000000000000000000000000000000000";

/**
 * Check if token supports specific interfaces
 *
 * @param contract
 * @param interfaceId
 * @param expected
 */
export function supportsInterface(
  contract: ethereum.SmartContract,
  interfaceId: String,
  expected: boolean = true,
): boolean {
  let result = ethereum.call(
    new ethereum.SmartContractCall(
      contract._name,
      contract._address,
      "supportsInterface",
      "supportsInterface(bytes4):(bool)",
      [
        ethereum.Value.fromFixedBytes(
          Bytes.fromHexString(interfaceId as string) as Bytes,
        ),
      ],
    ),
  );

  return (
    result != null &&
    (result as Array<ethereum.Value>)[0].toBoolean() == expected
  );
}

/**
 * Find or Create a User entity with `id` and return it
 *
 * @param id
 */
export function findOrCreateUser(id: string): Account {
  let user = Account.load(id);

  if (user == null) {
    user = new Account(id);
    user.save();
  }

  return user as Account;
}

/**
 * Creates token initially after minting
 *
 * @param event
 */
export function handleMint(event: ERC721Created): void {
  let owner = findOrCreateUser(event.params.owner.toHexString());
  let creator = findOrCreateUser(event.params.creator.toHexString());

  let erc721 = ERC721.bind(event.params.tokenAddress);
  let supportsERC721Metadata = supportsInterface(erc721, "5b5e139f"); // ERC721Metadata

  let token = createToken(
    event.params.tokenAddress.toHexString(),
    event.transaction.hash.toHexString(),
    owner.id,
    creator.id,
    ZERO_ADDRESS,
    event.params.metadataURI,
    event.block.timestamp,
    event.block.number,
    supportsERC721Metadata,
    event.params.tokenName,
    event.params.tokenSymbol,
    event.params.templateAddress.toHexString(),
    false,
    BigInt.fromI32(event.params.kind),
  );

  let eventId = event.transaction.hash
    .toHexString()
    .concat("-")
    .concat(event.transactionLogIndex.toString());

  createEvent(
    eventId,
    event.transaction.from.toHexString(),
    event.address.toHexString(),
    event.block.timestamp,
    event.block.number,
    event.transaction.gasPrice,
    event.transaction.value,
    "ERC721Created",
    event.transaction.hash.toHexString(),
  );

  if (token.events == null) {
    token.events = [];
  }
  token.events!.push(eventId);

  token.save();
}

/**
 * Create Token
 *
 * @param id
 * @param transactionHash
 * @param owner
 * @param contract
 * @param creator
 * @param prevOwner
 * @param contentURI
 * @param metadataURI
 * @param createdAtTimestamp
 * @param createdAtBlockNumber
 * @param supportsMetadata
 * @param name
 * @param symbol
 * @param template
 * @param paused
 */
export function createToken(
  id: string,
  transactionHash: string,
  owner: string,
  creator: string,
  prevOwner: string,
  metadataURI: string,
  createdAtTimestamp: BigInt,
  createdAtBlockNumber: BigInt,
  supportsMetadata: boolean,
  name: string,
  symbol: string,
  template: string,
  paused: boolean,
  kind: BigInt,
): Token {
  let token = new Token(id);
  token.owner = owner;
  token.transactionHash = transactionHash;
  token.creator = creator;
  token.prevOwner = prevOwner;
  token.metadataURI = metadataURI;
  token.createdAtTimestamp = createdAtTimestamp;
  token.updatedAtTimestamp = createdAtTimestamp;
  token.createdAtBlockNumber = createdAtBlockNumber;
  token.updatedAtBlockNumber = createdAtBlockNumber;
  token.supportsMetadata = supportsMetadata;
  token.name = name;
  token.symbol = symbol;
  token.template = template;
  token.paused = paused;
  token.kind = kind;

  return token;
}

/**
 * Create Event
 *
 * @param id
 * @param from
 * @param to
 * @param createdAtTimestamp
 * @param createdAtBlockNumber
 * @param gasPrice
 * @param value
 * @param type
 */
export function createEvent(
  id: string,
  from: string,
  to: string,
  createdAtTimestamp: BigInt,
  createdAtBlockNumber: BigInt,
  gasPrice: BigInt,
  value: BigInt,
  type: string,
  hash: string,
): Event {
  let event = new Event(id);

  event.from = from;
  event.to = to;
  event.createdAtTimestamp = createdAtTimestamp;
  event.createdAtBlockNumber = createdAtBlockNumber;
  event.gasPrice = gasPrice;
  event.value = value;
  event.type = type;
  event.transactionHash = hash;

  event.save();
  return event;
}

/**
 * Create FileSaleSession
 *
 * @param id
 * @param sender
 * @param receiver
 * @param dataset
 * @param algorithm
 * @param verifier
 * @param pkUrl
 * @param timeout
 * @param timeoutInterval
 * @param price
 * @param createdAtTimestamp
 */
export function createFileSaleSession(
  id: string,
  sender: string,
  receiver: string,
  dataset: string,
  algorithm: string,
  verifier: string,
  pkUrl: string,
  timeout: BigInt,
  timeoutInterval: BigInt,
  price: BigInt,
  createdAtTimestamp: BigInt,
  createdAtBlockNumber: BigInt,
): FileSaleSession {
  let fileSaleSession = new FileSaleSession(id);

  fileSaleSession.phase = BigInt.fromI32(0);
  fileSaleSession.sender = sender;
  fileSaleSession.receiver = receiver;
  fileSaleSession.dataset = dataset;
  fileSaleSession.algorithm = algorithm;
  fileSaleSession.verifier = verifier;
  fileSaleSession.pkUrl = pkUrl;
  fileSaleSession.depth = BigInt.fromI32(0);
  fileSaleSession.length = BigInt.fromI32(0);
  fileSaleSession.n = BigInt.fromI32(0);
  fileSaleSession.timeout = timeout;
  fileSaleSession.timeoutInterval = timeoutInterval;
  fileSaleSession.price = price;
  fileSaleSession.createdAtTimestamp = createdAtTimestamp;
  fileSaleSession.updatedAtTimestamp = createdAtTimestamp;
  fileSaleSession.createdAtBlockNumber = createdAtBlockNumber;
  fileSaleSession.updatedAtBlockNumber = createdAtBlockNumber;
  fileSaleSession.key = "";
  fileSaleSession.keyCommit = "";
  fileSaleSession.fileRoot = "";
  fileSaleSession.ciphertextRoot = "";

  fileSaleSession.save();
  return fileSaleSession;
}
