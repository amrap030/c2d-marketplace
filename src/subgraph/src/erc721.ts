import { Token } from "../generated/schema";
import {
  Approval,
  Transfer,
  Paused as PausedEvent,
  Unpaused as UnpausedEvent,
} from "../generated/templates/ERC721Template/ERC721Template";
import { log } from "@graphprotocol/graph-ts";
import { createTransfer, findOrCreateUser, ZERO_ADDRESS } from "./helpers";

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
    [tokenId, from.id, to.id]
  );

  let token = Token.load(event.address.toHexString());

  if (token === null) {
    log.error(`Media is null for token id: {}`, [tokenId]);
    return;
  }

  token.prevOwner = from.id;
  token.owner = to.id;
  token.approved = null;
  token.save();

  let transferId = tokenId
    .concat("-")
    .concat(event.transaction.hash.toHexString())
    .concat("-")
    .concat(event.transactionLogIndex.toString());

  createTransfer(
    transferId,
    event.transaction.hash.toHexString(),
    token,
    from.id,
    to.id,
    event.block.timestamp,
    event.block.number,
    event.transaction.gasPrice,
    event.transaction.value
  );

  log.info(
    `Completed handler for Transfer Event of tokenId: {}, from: {}. to: {}`,
    [tokenId, from.id, to.id]
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
    [tokenId, owner, approvedUser]
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
    [tokenId, owner, approvedUser]
  );
}

// /**
//  * Handler called when the `ApprovalForAll` Event is called
//  * @param event
//  */
// export function handleApprovalForAll(event: ApprovalForAll): void {
//   let ownerAddr = event.params.owner.toHexString();
//   let operatorAddr = event.params.operator.toHexString();
//   let approved = event.params.approved;

//   log.info(
//     `Starting handler for ApprovalForAll Event for owner: {}, operator: {}, approved: {}`,
//     [ownerAddr, operatorAddr, approved.toString()]
//   );

//   let owner: Account = findOrCreateUser(ownerAddr) as Account;
//   let operator: Account = findOrCreateUser(operatorAddr) as Account;

//   if (owner !== null) {
//     if (approved == true) {
//       owner.authorizedUsers = (owner.authorizedUsers as string[]).concat([
//         operator.id as string,
//       ]);
//     } else {
//       // if authorizedUsers array is null, no-op
//       if (!owner.authorizedUsers) {
//         log.info(
//           "Owner does not currently have any authorized users. No db changes neccessary. Returning early.",
//           []
//         );
//         log.info(
//           `Completed handler for ApprovalForAll Event for owner: {}, operator: {}, approved: {}`,
//           [ownerAddr, operatorAddr, approved.toString()]
//         );
//         return;
//       }

//       let index = (owner.authorizedUsers as string[]).indexOf(operator.id);
//       let copyAuthorizedUsers: string[] = owner.authorizedUsers as string[];
//       copyAuthorizedUsers.splice(index, 1);
//       owner.authorizedUsers = copyAuthorizedUsers;
//     }
//     owner.save();
//   }

//   log.info(
//     `Completed handler for ApprovalForAll Event for owner: {}, operator: {}, approved: {}`,
//     [ownerAddr, operatorAddr, approved.toString()]
//   );
// }

// export function handleOwnershipTransferred(
//   event: OwnershipTransferredEvent
// ): void {
//   let token = Token.load(event.address.toHexString());

//   if (token === null) {
//     log.error(`Media is null for token id: {}`, [event.]);
//     return;
//   }

//   token.prevOwner = from.id;
//   token.owner = to.id;
//   token.approved = null;
//   token.save();
// }

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
  token.save();

  log.info(
    `Completed handler for Paused Event. Contract execution paused for address: {}`,
    [event.address.toHexString()]
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
  token.save();

  log.info(
    `Completed handler for Unpaused Event. Contract execution unpaused for address: {}`,
    [event.address.toHexString()]
  );
}
