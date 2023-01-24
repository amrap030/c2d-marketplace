/* eslint-disable */
import { ERC721Template } from "../generated/templates";
import { ERC721Created } from "../generated/ERC721Factory/ERC721Factory";
import { DataSourceContext, log } from "@graphprotocol/graph-ts";
import { handleMint } from "./helpers";

/**
 * Handler called when the `ERC721Created` Event is called on ERC721Factory contract
 * @param event
 */
export function handleERC721Created(event: ERC721Created): void {
  log.info(
    `Starting handler for ERC721Created Event of token: {}, owner: {}, creator: {}, name: {}, symbol: {}, template: {}, metadataURI: {}`,
    [
      event.params.tokenAddress.toHexString(),
      event.params.owner.toHexString(),
      event.params.creator.toHexString(),
      event.params.tokenName,
      event.params.tokenSymbol,
      event.params.templateAddress.toHexString(),
      event.params.metadataURI,
    ]
  );
  let context = new DataSourceContext();
  context.setString("template", event.params.templateAddress.toHexString());
  context.setString("name", event.params.tokenName);
  context.setString("symbol", event.params.tokenSymbol);
  ERC721Template.createWithContext(event.params.tokenAddress, context);

  handleMint(event);

  log.info(`Completed handler for ERC721Created Event.`, []);
}
