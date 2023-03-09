import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { time } from "@nomicfoundation/hardhat-network-helpers";
import { ethers } from "hardhat";
import { expect } from "chai";
import { Marketplace, Verifier } from "../typechain";
import proof from "../contracts/mock/proof.json";
import { BigNumber } from "ethers";
import {
  datasetToken,
  algorithmTokenOne,
  algorithmTokenTwo,
} from "./erc721Factory.test";

const n = 2;
const length = 32;
const depth = 2;

const keyCommit =
  "0x661ffbd00de5aea14a1cdfb143127566abdc469ffe1160b006acc5eacb0f0ead";
const key =
  "0x000000000000000000000000000000000000000000000000000000000000007b";
const fakeKeyCommit =
  "0xc6c6fd4c742e3f2b985047de939c1045901b5fc445f4436e5322623c001eebdc";
const fakeKey =
  "0xddc7b15845dcabf17870858845a4e5c3f091f8dc831fd04503abb2331fb7f376";

const cipherTextRoot =
  "0xa5215d05f9f454d2395e8604813ff4667435e1308d6781a9f437a51a6dd853f1";
const plainDataRoot =
  "0x20f948130ae3957beaeaa9b97c39a76b95be3ce8b2d6e45049a86c7cc7cedcad";

const complainRootData = {
  correctLeaf:
    "0xe53974cbacd1f311587e5eb095adab49f116832949d86ac74cfcc055d4b822db",
  correctProof: [
    "0xbb6b2c6f73b6fafa09c2d00871d921604ffc378f21cc8a88e8a8be95b4e7f5ea",
    "0x0000000000000000000000000000000000000000000000000000000000000000",
  ],
};

const prices = [5, 10];

const pkAddress =
  "ipfs://bafkreihuk7qqpdskouyjax5wzpn4wwaktquzjd3flbluz6wbv46m7kt74u/";

const complainLeafData = {
  indexOut: 2,
  indexIn: 0,
  Zout: "0x84e68d3d42bf62961ab1a3ca38631ba089c4178aa0eab5c355f4ee761dcd6e6a",
  Zin1: ["0xa82f4ee331bcebaf0a215a715903c89194aba5870af05651db498e58420c5bf0"],
  Zin2: ["0xbabfac87c72b527d9ea485bf5c47c4f6a0804bb0deee2c857bb58df735f9967f"],
  proofZout: [
    "0x5464455ff0684b4442b81a53889452ca094534f8c92dec57b4980d49d20ecba6",
    "0x0000000000000000000000000000000000000000000000000000000000000000",
  ],
  proofZin: [
    "0x12c4515305ae87d82f12d90d2a3c07698971a9aa8ccfea2e0cfd5661fcd0e124",
    "0xbd31efa3dd2994356e6e57ed601db2938a369fb6f27e0577fd07a78aac509414",
  ],
};

describe("Marketplace", async () => {
  let marketplace: Marketplace,
    verifier: Verifier,
    receiver: SignerWithAddress,
    sender: SignerWithAddress,
    firstSessionId: string,
    secondSessionId: string;

  before(async function () {
    [, receiver, sender] = await ethers.getSigners();

    const Marketplace = await ethers.getContractFactory("Marketplace");
    const Verifier = await ethers.getContractFactory("Verifier");

    marketplace = await Marketplace.deploy();
    await marketplace.deployed();

    verifier = await Verifier.deploy();
    await verifier.deployed();
  });

  it("create two offerings", async () => {
    await expect(
      marketplace
        .connect(sender)
        .createOffer(
          datasetToken.address,
          [algorithmTokenOne.address, algorithmTokenTwo.address],
          prices,
        ),
    )
      .to.emit(marketplace, "OfferCreated")
      .withArgs(
        datasetToken.address,
        algorithmTokenOne.address,
        sender.address,
        prices[0],
      )
      .to.emit(marketplace, "OfferCreated")
      .withArgs(
        datasetToken.address,
        algorithmTokenTwo.address,
        sender.address,
        prices[1],
      );
  });

  it("create first order", async () => {
    const oneHour = 60 * 60;

    const currentBlock = await ethers.provider.getBlockNumber();
    const block = await ethers.provider.getBlock(currentBlock);

    firstSessionId = ethers.utils.soliditySha256(
      ["address", "address", "address"],
      [sender.address, receiver.address, algorithmTokenOne.address],
    );

    await expect(
      marketplace
        .connect(receiver)
        .createOrder(
          datasetToken.address,
          verifier.address,
          algorithmTokenOne.address,
          pkAddress,
        ),
    )
      .to.emit(marketplace, "OrderCreated")
      .withArgs(
        0,
        sender.address,
        receiver.address,
        datasetToken.address,
        algorithmTokenOne.address,
        verifier.address,
        pkAddress,
        block.timestamp + (oneHour + 1),
        oneHour,
        prices[0],
        firstSessionId,
      );

    expect(await marketplace.provider.getBalance(marketplace.address)).equal(0);
  });

  it("failed proof of computation with fake data", async () => {
    await expect(
      marketplace.connect(sender).proofComputation(
        firstSessionId,
        depth,
        length,
        n,
        keyCommit,
        cipherTextRoot,
        [proof.inputs[0].replace(/c/g, "b"), ...proof.inputs.slice(1)],
        proof.proof as any, // eslint-disable-line
      ),
    ).to.be.reverted;
  });

  it("successful proof of computation with correct data", async () => {
    await expect(
      marketplace.connect(sender).proofComputation(
        firstSessionId,
        depth,
        length,
        n,
        keyCommit,
        cipherTextRoot,
        proof.inputs,
        proof.proof as any, // eslint-disable-line
      ),
    )
      .to.emit(marketplace, "OrderInitialized")
      .withArgs(
        depth,
        length,
        n,
        keyCommit,
        cipherTextRoot,
        plainDataRoot,
        firstSessionId,
      );
  });

  it("pay for first order", async () => {
    await expect(
      marketplace.connect(receiver).buy(firstSessionId, {
        value: BigNumber.from(5),
      }),
    )
      .to.emit(marketplace, "OrderAccepted")
      .withArgs(firstSessionId);

    expect(await marketplace.provider.getBalance(marketplace.address)).equal(5);
  });

  it("reveal correct key for first order", async () => {
    await expect(marketplace.connect(sender).reveal(firstSessionId, key))
      .to.emit(marketplace, "OrderRevealed")
      .withArgs(key, firstSessionId);
  });

  it("failed complain about root with correct data because sender was honest", async () => {
    const tx = await marketplace
      .connect(receiver)
      .complainAboutRoot(
        firstSessionId,
        complainRootData.correctLeaf,
        complainRootData.correctProof,
      );

    await tx.wait();

    expect(await marketplace.provider.getBalance(marketplace.address)).equal(5);
  });

  it("failed complain about root with fake data from receiver", async () => {
    const fakeLeaf = complainRootData.correctLeaf.replace(/c/g, "b");

    await expect(
      marketplace
        .connect(receiver)
        .complainAboutRoot(
          firstSessionId,
          fakeLeaf,
          complainRootData.correctProof,
        ),
    ).to.be.revertedWith("Not in encoding");
  });

  it("failed complain about leaf with fake data from receiver", async () => {
    await expect(
      marketplace
        .connect(receiver)
        .complainAboutLeaf(
          firstSessionId,
          complainLeafData.indexOut,
          complainLeafData.indexIn,
          complainLeafData.Zout,
          complainLeafData.Zin1,
          complainLeafData.Zin2,
          complainLeafData.proofZout,
          complainLeafData.proofZin,
        ),
    ).to.be.revertedWith("Not in encoding");
  });

  it("failed complain about node with fake data from receiver", async () => {
    await expect(
      marketplace
        .connect(receiver)
        .complainAboutNode(
          firstSessionId,
          complainLeafData.indexOut,
          complainLeafData.indexIn,
          complainLeafData.Zout,
          complainLeafData.Zin1[0],
          complainLeafData.Zin2[0],
          complainLeafData.proofZout,
          complainLeafData.proofZin,
        ),
    ).to.be.revertedWith("Not in encoding");
  });

  it("create second order", async () => {
    const oneHour = 60 * 60;
    secondSessionId = ethers.utils.soliditySha256(
      ["address", "address", "address"],
      [sender.address, receiver.address, algorithmTokenTwo.address],
    );

    const currentBlock = await ethers.provider.getBlockNumber();
    const block = await ethers.provider.getBlock(currentBlock);

    await expect(
      marketplace
        .connect(receiver)
        .createOrder(
          datasetToken.address,
          verifier.address,
          algorithmTokenTwo.address,
          pkAddress,
        ),
    )
      .to.emit(marketplace, "OrderCreated")
      .withArgs(
        0,
        sender.address,
        receiver.address,
        datasetToken.address,
        algorithmTokenTwo.address,
        verifier.address,
        pkAddress,
        block.timestamp + (oneHour + 1),
        oneHour,
        prices[1],
        secondSessionId,
      );

    expect(await marketplace.provider.getBalance(marketplace.address)).equal(5);
  });

  it("successful proof of computation but fake key commit submitted", async () => {
    await expect(
      marketplace.connect(sender).proofComputation(
        secondSessionId,
        depth,
        length,
        n,
        fakeKeyCommit,
        cipherTextRoot,
        proof.inputs,
        proof.proof as any, // eslint-disable-line
      ),
    )
      .to.emit(marketplace, "OrderInitialized")
      .withArgs(
        depth,
        length,
        n,
        fakeKeyCommit,
        cipherTextRoot,
        plainDataRoot,
        secondSessionId,
      );
  });

  it("pay for second order", async () => {
    await expect(
      marketplace.connect(receiver).buy(secondSessionId, {
        value: BigNumber.from(10),
      }),
    )
      .to.emit(marketplace, "OrderAccepted")
      .withArgs(secondSessionId);

    expect(await marketplace.provider.getBalance(marketplace.address)).equal(
      15,
    );
  });

  it("reveal fake key for second order", async () => {
    await expect(marketplace.connect(sender).reveal(secondSessionId, fakeKey))
      .to.emit(marketplace, "OrderRevealed")
      .withArgs(fakeKey, secondSessionId);
  });

  it("successful complain about root because of fake key", async () => {
    const tx = await marketplace
      .connect(receiver)
      .complainAboutRoot(
        secondSessionId,
        complainRootData.correctLeaf,
        complainRootData.correctProof,
      );

    await tx.wait();

    expect(await marketplace.provider.getBalance(marketplace.address)).equal(5);
  });

  it("failed withdraw as sender for successful trade because timeout still active", async () => {
    await expect(marketplace.connect(sender).refund(firstSessionId)).to.be
      .reverted;
  });

  it("successful withdraw as sender for successful trade", async () => {
    await time.increase(10800);

    const tx = await marketplace.connect(sender).refund(firstSessionId);
    await tx.wait();

    expect(await marketplace.provider.getBalance(marketplace.address)).equal(0);
  });
});
