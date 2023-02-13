/* eslint-disable prefer-const */
import { Token, Item } from "../generated/schema";
import { ItemCreated } from "../generated/Marketplace/Marketplace";
import { log } from "@graphprotocol/graph-ts";
import { findOrCreateUser } from "./helpers";

/**
 * Handler called when the `Transfer` Event is called
 * @param event
 */
export function handleItemCreated(event: ItemCreated): void {
  let nftAddress = event.params.nftAddress.toHexString();
  let sellerAddress = event.params.item.seller.toHexString();
  let algorithmAddress = event.params.algorithm.toHexString();
  let price = event.params.item.price;

  log.info(`Starting handler for ItemCreated Event of token: {}`, [nftAddress]);

  let itemId = nftAddress.concat("-").concat(algorithmAddress);
  let item = Item.load(itemId);

  let seller = findOrCreateUser(sellerAddress);

  if (item == null) {
    item = new Item(itemId);
    item.price = price;
    item.seller = seller.id;

    let token = Token.load(nftAddress);

    if (token != null) {
      item.token = token.id;
    }

    item.save();
  }

  log.info(`Completed handler for ItemCreated Event of token: {}`, [
    nftAddress,
  ]);
}
