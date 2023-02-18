import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { ethers } from "hardhat";
import { expect } from "chai";
import { ERC721Template, ERC721Factory } from "../typechain";
import { INTERFACES } from "../utils/constants";
// eslint-disable-next-line @typescript-eslint/no-var-requires
const { makeInterfaceId } = require("@openzeppelin/test-helpers");

export let datasetToken: ERC721Template;
export let algorithmTokenOne: ERC721Template;
export let algorithmTokenTwo: ERC721Template;

describe("ERC721Factory", async () => {
  let erc721Factory: ERC721Factory,
    erc721Template: ERC721Template,
    sender: SignerWithAddress,
    developer: SignerWithAddress;

  before(async function() {
    [, , sender, developer] = await ethers.getSigners();

    const ERC721Template = await ethers.getContractFactory("ERC721Template");
    const ERC721Factory = await ethers.getContractFactory("ERC721Factory");

    erc721Template = await ERC721Template.deploy();
    await erc721Template.deployed();

    erc721Factory = await ERC721Factory.deploy(erc721Template.address);
    await erc721Factory.deployed();
  });

  it("create dataset and mint token for sender", async () => {
    const tx = await erc721Factory.cloneContract(
      sender.address,
      "GODDOG-95",
      "Godly Dogma Token",
      "ipfs://bafkreihuk7qqpdskouyjax5wzpn4wwaktquzjd3flbluz6wbv46m7kt74u/",
      0,
    );

    const txReceipt = await tx.wait();

    if (txReceipt.events) {
      const event = txReceipt.events.find(
        event => event.event === "ERC721Created",
      );
      const newTokenAddress = (event?.args as string[])[3] as string;

      datasetToken = await ethers.getContractAt(
        "ERC721Template",
        newTokenAddress,
      );
    } else {
      throw "Transaction failed!";
    }
  });

  it("balance of sender after mint eq 1", async () => {
    expect(await datasetToken.balanceOf(sender.address)).to.equal(1);
  });

  it("dataset supports all interfaces", async () => {
    for (const k of ["ERC165", "ERC721", "ERC721Metadata"]) {
      const interfaceId = makeInterfaceId.ERC165(INTERFACES[k]);
      expect(await datasetToken.supportsInterface(interfaceId)).to.equal(true);
    }
  });

  it("create algorithm and mint token for developer", async () => {
    const tx = await erc721Factory.cloneContract(
      developer.address,
      "SPINOS-67",
      "Spiky Nose Token",
      "ipfs://bafkreihuk7qqpdskouyjax5wzpn4wwaktquzjd3flbluz6wbv46m7kt74u/",
      1,
    );

    const txReceipt = await tx.wait();

    if (txReceipt.events) {
      const event = txReceipt.events.find(
        event => event.event === "ERC721Created",
      );
      const newTokenAddress = (event?.args as string[])[3] as string;

      algorithmTokenOne = await ethers.getContractAt(
        "ERC721Template",
        newTokenAddress,
      );
    } else {
      throw "Transaction failed!";
    }
  });

  it("balance of developer after mint eq 1", async () => {
    expect(await algorithmTokenOne.balanceOf(developer.address)).to.equal(1);
  });

  it("algorithm supports all interfaces", async () => {
    for (const k of ["ERC165", "ERC721", "ERC721Metadata"]) {
      const interfaceId = makeInterfaceId.ERC165(INTERFACES[k]);
      expect(await algorithmTokenOne.supportsInterface(interfaceId)).to.equal(
        true,
      );
    }
  });

  it("create second algorithm and mint token for developer", async () => {
    const tx = await erc721Factory.cloneContract(
      developer.address,
      "SPITEE-33",
      "Spiky Teeth Token",
      "ipfs://bafkreihuk7qqpdskouyjax5wzpn4wwaktquzjd3flbluz6wbv46m7kt74u/",
      1,
    );

    const txReceipt = await tx.wait();

    if (txReceipt.events) {
      const event = txReceipt.events.find(
        event => event.event === "ERC721Created",
      );
      const newTokenAddress = (event?.args as string[])[3] as string;

      algorithmTokenTwo = await ethers.getContractAt(
        "ERC721Template",
        newTokenAddress,
      );
    } else {
      throw "Transaction failed!";
    }
  });

  it("balance of developer after mint eq 1", async () => {
    expect(await algorithmTokenTwo.balanceOf(developer.address)).to.equal(1);
  });

  it("algorithm supports all interfaces", async () => {
    for (const k of ["ERC165", "ERC721", "ERC721Metadata"]) {
      const interfaceId = makeInterfaceId.ERC165(INTERFACES[k]);
      expect(await algorithmTokenTwo.supportsInterface(interfaceId)).to.equal(
        true,
      );
    }
  });
});
