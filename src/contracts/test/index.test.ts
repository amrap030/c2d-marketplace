import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { ethers } from "hardhat";
import { expect } from "chai";
import { ERC721Template, ERC721Factory } from "../typechain";
import { INTERFACES } from "../utils/constants";
// eslint-disable-next-line @typescript-eslint/no-var-requires
const { makeInterfaceId } = require("@openzeppelin/test-helpers");

describe("ERC721Factory", async () => {
  let erc721Factory: ERC721Factory,
    erc721Template: ERC721Template,
    owner: SignerWithAddress,
    user1: SignerWithAddress,
    user2: SignerWithAddress,
    newErc721Token: ERC721Template;

  before(async function () {
    [owner, user1, user2] = await ethers.getSigners();

    const ERC721Template = await ethers.getContractFactory("ERC721Template");
    const ERC721Factory = await ethers.getContractFactory("ERC721Factory");

    erc721Template = await ERC721Template.deploy();
    await erc721Template.deployed();

    erc721Factory = await ERC721Factory.deploy(erc721Template.address);
    await erc721Factory.deployed();
  });

  it("create erc721 and mint 1 token for owner", async () => {
    const tx = await erc721Factory.cloneContract(
      owner.address,
      "C2D",
      "C2DYMBOL",
      "ipfs://trd4ertz/",
      true
    );
    const txReceipt = await tx.wait();

    if (txReceipt.events) {
      const event = txReceipt.events.find(
        (event) => event.event === "NFTCreated"
      );
      const newTokenAddress = (event?.args as string[])[3] as string;

      newErc721Token = await ethers.getContractAt(
        "ERC721Template",
        newTokenAddress
      );
    } else {
      throw "Transaction failed!";
    }
  });

  it("balance of owner equals 1", async () => {
    expect(await newErc721Token.balanceOf(owner.address)).to.equal(1);
  });

  it("total supply equals 1", async () => {
    expect(await newErc721Token.totalSupply()).to.equal(1);
  });

  it("new contract supports all interfaces", async () => {
    for (const k of ["ERC165", "ERC721", "ERC721Metadata"]) {
      const interfaceId = makeInterfaceId.ERC165(INTERFACES[k]);
      expect(await newErc721Token.supportsInterface(interfaceId)).to.equal(
        true
      );
    }
  });
});
