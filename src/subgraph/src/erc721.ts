/* eslint-disable prefer-const */
import { Token } from "../generated/schema";
import {
  Approval,
  Transfer,
  Paused as PausedEvent,
  Unpaused as UnpausedEvent,
  MetadataUpdated,
} from "../generated/templates/ERC721Template/ERC721Template";
import { log } from "@graphprotocol/graph-ts";
import { findOrCreateUser, ZERO_ADDRESS, createEvent } from "./helpers";

/**
 * Handler called when the `Transfer` Event is called
 * @param event
 */
export function handleTransfer(event: Transfer): void {
  let tokenId = event.params.tokenId.toString();
  let to = findOrCreateUser(event.params.to.toHexString());
  let from = findOrCreateUser(event.params.from.toHexString());

  log.info(
    `Starting handler for Transfer Event of tokenId: {}, from: {}. to: {}`,
    [tokenId, from.id, to.id],
  );

  let token = Token.load(event.address.toHexString());

  if (token === null) {
    log.error(`Media is null for token id: {}`, [tokenId]);
    return;
  }

  token.prevOwner = from.id;
  token.owner = to.id;
  token.approved = null;

  let eventId = event.transaction.hash
    .toHexString()
    .concat("-")
    .concat(event.transactionLogIndex.toString());

  let transferEvent = createEvent(
    eventId,
    event.transaction.from.toHexString(),
    event.address.toHexString(),
    event.block.timestamp,
    event.block.number,
    event.transaction.gasPrice,
    event.transaction.value,
    "Transfer",
    event.transaction.hash.toHexString(),
  );

  token.events = [transferEvent.id];
  token.save();

  log.info(
    `Completed handler for Transfer Event of tokenId: {}, from: {}. to: {}`,
    [tokenId, from.id, to.id],
  );
}

/**
 * Handler called when the `Approval` Event is called
 * @param event
 */
export function handleApproval(event: Approval): void {
  let owner = event.params.owner.toHexString();
  let approvedUser = event.params.approved.toHexString();
  let tokenId = event.params.tokenId.toString();

  log.info(
    `Starting handler for Approval Event of tokenId: {}, owner: {}, approved: {}`,
    [tokenId, owner, approvedUser],
  );

  let token = Token.load(event.address.toHexString());

  if (token === null) {
    log.error(`Media is null for token id: {}`, [tokenId]);
    return;
  }

  if (approvedUser == ZERO_ADDRESS) {
    token.approved = null;
  } else {
    let user = findOrCreateUser(approvedUser);
    token.approved = user.id;
  }

  token.save();

  log.info(
    `Completed handler for Approval Event of tokenId: {}, owner: {}, approved: {}`,
    [tokenId, owner, approvedUser],
  );
}

export function handlePaused(event: PausedEvent): void {
  log.info(`Starting handler for Paused Event of contract: {}`, [
    event.address.toHexString(),
  ]);

  let token = Token.load(event.address.toHexString());

  if (token === null) {
    log.error(`Media is null for token address: {}`, [
      event.address.toHexString(),
    ]);
    return;
  }

  token.paused = true;
  token.updatedAtBlockNumber = event.block.number;
  token.updatedAtTimestamp = event.block.timestamp;
  token.save();

  log.info(
    `Completed handler for Paused Event. Contract execution paused for address: {}`,
    [event.address.toHexString()],
  );
}

export function handleUnpaused(event: UnpausedEvent): void {
  log.info(`Starting handler for Unpaused Event of contract: {}`, [
    event.address.toHexString(),
  ]);

  let token = Token.load(event.address.toHexString());

  if (token === null) {
    log.error(`Media is null for token address: {}`, [
      event.address.toHexString(),
    ]);
    return;
  }

  token.paused = false;
  token.updatedAtBlockNumber = event.block.number;
  token.updatedAtTimestamp = event.block.timestamp;
  token.save();

  log.info(
    `Completed handler for Unpaused Event. Contract execution unpaused for address: {}`,
    [event.address.toHexString()],
  );
}

export function handleMetadataUpdated(event: MetadataUpdated): void {
  log.info(`Starting handler for MetadataUpdated Event of contract: {}`, [
    event.address.toHexString(),
  ]);

  let token = Token.load(event.address.toHexString());

  if (token === null) {
    log.error(`Media is null for token address: {}`, [
      event.address.toHexString(),
    ]);
    return;
  }

  token.metadataURI = event.params.metadataURI;
  token.updatedAtBlockNumber = event.block.number;
  token.updatedAtTimestamp = event.block.timestamp;
  token.save();

  log.info(`Completed handler for MetadataUpdated Event`, []);
}
