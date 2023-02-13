/* eslint-disable */
import { BigInt, Bytes, ethereum } from "@graphprotocol/graph-ts/index";
import { ERC721Created } from "../generated/ERC721Factory/ERC721Factory";
import { Token, Transfer, Account } from "../generated/schema";
import { ERC721 } from "../generated/templates/ERC721Template/ERC721";

export const ZERO_ADDRESS = "0x0000000000000000000000000000000000000000";

function getKind(kind: BigInt): string {
  if (kind.equals(new BigInt(0))) {
    return "dataset";
  }
  return "algorithm";
}

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

  let kind = getKind(new BigInt(event.params.kind));

  createToken(
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
    kind,
  );
}

/**
 * Create New Token Entity
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
  kind: string,
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

  token.save();
  return token;
}

/**
 * Create New Transfer Entity
 *
 * @param id
 * @param transactionHash
 * @param token
 * @param from
 * @param to
 * @param createdAtTimestamp
 * @param createdAtBlockNumber
 * @param gasPrice
 * @param value
 */
export function createTransfer(
  id: string,
  transactionHash: string,
  token: Token,
  from: string,
  to: string,
  createdAtTimestamp: BigInt,
  createdAtBlockNumber: BigInt,
  gasPrice: BigInt,
  value: BigInt,
): Transfer {
  let transfer = new Transfer(id);
  transfer.token = token.id;
  transfer.transactionHash = transactionHash;
  transfer.from = from;
  transfer.to = to;
  transfer.createdAtTimestamp = createdAtTimestamp;
  transfer.createdAtBlockNumber = createdAtBlockNumber;
  transfer.gasPrice = gasPrice;
  transfer.value = value;

  transfer.save();
  return transfer;
}
