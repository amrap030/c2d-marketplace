/* eslint-disable prefer-const */
import { Token, Offer, FileSaleSession } from "../generated/schema";
import {
  OfferCreated,
  OrderCreated,
  OrderInitialized,
  OrderAccepted,
  OrderRevealed,
  OrderFulfilled,
  OrderCancelled,
} from "../generated/Marketplace/Marketplace";
import { BigInt, log } from "@graphprotocol/graph-ts";
import {
  createEvent,
  createFileSaleSession,
  findOrCreateUser,
} from "./helpers";

/**
 * Handler called when the `Transfer` Event is called
 * @param event
 */
export function handleOfferCreated(event: OfferCreated): void {
  let nftAddress = event.params.nftAddress.toHexString();
  let senderAddress = event.params.sender.toHexString();
  let algorithmAddress = event.params.algorithm.toHexString();
  let price = event.params.price;

  log.info(
    `Starting handler for OfferCreated Event of token: {}, algorithm: {}`,
    [nftAddress, algorithmAddress],
  );

  let offerId = nftAddress.concat("-").concat(algorithmAddress);
  let offer = Offer.load(offerId);

  let sender = findOrCreateUser(senderAddress);

  if (offer == null) {
    offer = new Offer(offerId);
    offer.price = price;
    offer.sender = sender.id;
    offer.createdAtTimestamp = event.block.timestamp;
    offer.updatedAtTimestamp = event.block.timestamp;
    offer.createdAtBlockNumber = event.block.number;
    offer.updatedAtBlockNumber = event.block.number;

    let algorithm = Token.load(algorithmAddress);
    let dataset = Token.load(nftAddress);

    if (algorithm != null && dataset != null) {
      offer.dataset = dataset.id;
      offer.algorithm = algorithm.id;
    }

    offer.save();
  }

  log.info(`Completed handler for OfferCeated Event of token: {}`, [
    nftAddress,
  ]);
}

/**
 * Handler called when the `OrderCreated` Event is called
 * @param event
 */
export function handleOrderCreated(event: OrderCreated): void {
  let sender = findOrCreateUser(event.params.sender.toHexString());
  let receiver = findOrCreateUser(event.params.receiver.toHexString());
  let dataset = Token.load(event.params.nftAddress.toHexString());
  let algorithm = Token.load(event.params.algorithm.toHexString());

  log.info(
    `Starting handler for OrderCreated Event of token: {}, algorithm: {}`,
    [
      event.params.nftAddress.toHexString(),
      event.params.algorithm.toHexString(),
    ],
  );

  let fileSaleSessionId = event.params.sessionId.toHexString();
  let fileSaleSession = FileSaleSession.load(fileSaleSessionId);

  if (fileSaleSession == null) {
    if (dataset && algorithm) {
      fileSaleSession = createFileSaleSession(
        fileSaleSessionId,
        sender.id,
        receiver.id,
        dataset.id,
        algorithm.id,
        event.params.verifier.toHexString(),
        event.params.pkAddress,
        event.params.timeout,
        event.params.timeoutInterval,
        event.params.price,
        event.block.timestamp,
        event.block.number,
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
        "OrderCreated",
        event.transaction.hash.toHexString(),
      );

      let events = fileSaleSession.events;
      if (events == null) {
        events = [];
      }
      events.push(eventId);
      fileSaleSession.events = events;
      fileSaleSession.save();
    }
  }

  log.info(
    `Completed handler for OrderCreated Event of token: {}, algorithm: {}`,
    [
      event.params.nftAddress.toHexString(),
      event.params.algorithm.toHexString(),
    ],
  );
}

/**
 * Handler called when the `OrderInitialized` Event is called
 * @param event
 */
export function handleOrderInitialized(event: OrderInitialized): void {
  log.info(
    `Starting handler for OrderInitialized Event of File Sale Session: {}`,
    [event.params.sessionId.toHexString()],
  );

  let fileSaleSession = FileSaleSession.load(
    event.params.sessionId.toHexString(),
  );

  if (fileSaleSession) {
    fileSaleSession.phase = BigInt.fromI32(1);
    fileSaleSession.keyCommit = event.params.keyCommit.toHexString();
    fileSaleSession.ciphertextRoot = event.params.ciphertextRoot.toHexString();
    fileSaleSession.n = event.params.n;
    fileSaleSession.length = event.params.length;
    fileSaleSession.depth = event.params.depth;
    fileSaleSession.fileRoot = event.params.fileRoot.toHexString();
    fileSaleSession.updatedAtBlockNumber = event.block.number;
    fileSaleSession.updatedAtTimestamp = event.block.timestamp;

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
      "OrderInitialized",
      event.transaction.hash.toHexString(),
    );

    let events = fileSaleSession.events;
    if (events == null) {
      events = [];
    }
    events.push(eventId);
    fileSaleSession.events = events;
    fileSaleSession.save();
  }

  log.info(
    `Completed handler for OrderInitialized Event of File Sale Session: {}`,
    [event.params.sessionId.toHexString()],
  );
}

/**
 * Handler called when the `OrderAccepted` Event is called
 * @param event
 */
export function handleOrderAccepted(event: OrderAccepted): void {
  log.info(
    `Starting handler for OrderAccepted Event of File Sale Session: {}`,
    [event.params.sessionId.toHexString()],
  );

  let fileSaleSession = FileSaleSession.load(
    event.params.sessionId.toHexString(),
  );

  if (fileSaleSession) {
    fileSaleSession.phase = BigInt.fromI32(2);
    fileSaleSession.updatedAtBlockNumber = event.block.number;
    fileSaleSession.updatedAtTimestamp = event.block.timestamp;

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
      "OrderAccepted",
      event.transaction.hash.toHexString(),
    );

    let events = fileSaleSession.events;
    if (events == null) {
      events = [];
    }
    events.push(eventId);
    fileSaleSession.events = events;
    fileSaleSession.save();
  }

  log.info(
    `Completed handler for OrderAccepted Event of File Sale Session: {}`,
    [event.params.sessionId.toHexString()],
  );
}

/**
 * Handler called when the `OrderRevealed` Event is called
 * @param event
 */
export function handleOrderRevealed(event: OrderRevealed): void {
  log.info(
    `Starting handler for OrderRevealed Event of File Sale Session: {}`,
    [event.params.sessionId.toHexString()],
  );

  let fileSaleSession = FileSaleSession.load(
    event.params.sessionId.toHexString(),
  );

  if (fileSaleSession) {
    fileSaleSession.phase = BigInt.fromI32(3);
    fileSaleSession.key = event.params.key.toHexString();
    fileSaleSession.updatedAtBlockNumber = event.block.number;
    fileSaleSession.updatedAtTimestamp = event.block.timestamp;

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
      "OrderRevealed",
      event.transaction.hash.toHexString(),
    );

    let events = fileSaleSession.events;
    if (events == null) {
      events = [];
    }
    events.push(eventId);
    fileSaleSession.events = events;
    fileSaleSession.save();
  }

  log.info(
    `Completed handler for OrderRevealed Event of File Sale Session: {}`,
    [event.params.sessionId.toHexString()],
  );
}

/**
 * Handler called when the `OrderFulfilled` Event is called
 * @param event
 */
export function handleOrderFulfilled(event: OrderFulfilled): void {
  log.info(
    `Starting handler for OrderFulfilled Event of File Sale Session: {}`,
    [event.params.sessionId.toHexString()],
  );

  let fileSaleSession = FileSaleSession.load(
    event.params.sessionId.toHexString(),
  );

  if (fileSaleSession) {
    fileSaleSession.phase = BigInt.fromI32(4);
    fileSaleSession.updatedAtBlockNumber = event.block.number;
    fileSaleSession.updatedAtTimestamp = event.block.timestamp;

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
      "OrderFulfilled",
      event.transaction.hash.toHexString(),
    );

    let events = fileSaleSession.events;
    if (events == null) {
      events = [];
    }
    events.push(eventId);
    fileSaleSession.events = events;
    fileSaleSession.save();
  }

  log.info(
    `Completed handler for OrderFulfilled Event of File Sale Session: {}`,
    [event.params.sessionId.toHexString()],
  );
}

/**
 * Handler called when the `OrderCancelled` Event is called
 * @param event
 */
export function handleOrderCancelled(event: OrderCancelled): void {
  log.info(
    `Starting handler for OrderCancelled Event of File Sale Session: {}`,
    [event.params.sessionId.toHexString()],
  );

  let fileSaleSession = FileSaleSession.load(
    event.params.sessionId.toHexString(),
  );

  if (fileSaleSession) {
    fileSaleSession.phase = BigInt.fromI32(4);
    fileSaleSession.updatedAtBlockNumber = event.block.number;
    fileSaleSession.updatedAtTimestamp = event.block.timestamp;

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
      "OrderCancelled",
      event.transaction.hash.toHexString(),
    );

    let events = fileSaleSession.events;
    if (events == null) {
      events = [];
    }
    events.push(eventId);
    fileSaleSession.events = events;
    fileSaleSession.save();
  }

  log.info(
    `Completed handler for OrderCancelled Event of File Sale Session: {}`,
    [event.params.sessionId.toHexString()],
  );
}
