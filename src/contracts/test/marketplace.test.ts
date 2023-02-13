import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { ethers } from "hardhat";
import { expect } from "chai";
import { Marketplace, Verifier } from "../typechain";
import proof from "../contracts/mock/proof.json";
import { BigNumber } from "ethers";
import { newErc721Token } from "./erc721Factory.test";

describe("Marketplace", async () => {
  let marketplace: Marketplace,
    verifier: Verifier,
    buyer: SignerWithAddress,
    seller: SignerWithAddress;

  before(async function() {
    [, buyer, seller] = await ethers.getSigners();

    const Marketplace = await ethers.getContractFactory("Marketplace");
    const Verifier = await ethers.getContractFactory("Verifier");

    marketplace = await Marketplace.deploy();
    await marketplace.deployed();

    verifier = await Verifier.deploy();
    await verifier.deployed();
  });

  it("list two items", async () => {
    await expect(
      marketplace
        .connect(seller)
        .createItem(
          newErc721Token.address,
          [
            "0xB7c7653c6eDd43d482704f0A7C8e7bc04c367f48",
            "0x798c72E326BF7A7d848caeD892DCae9C233D27Ec",
          ],
          [5, 10],
        ),
    )
      .to.emit(marketplace, "ItemCreated")
      .withArgs(
        newErc721Token.address,
        "0xB7c7653c6eDd43d482704f0A7C8e7bc04c367f48",
        [seller.address, 5],
      )
      .to.emit(marketplace, "ItemCreated")
      .withArgs(
        newErc721Token.address,
        "0x798c72E326BF7A7d848caeD892DCae9C233D27Ec",
        [seller.address, 10],
      );
  });

  it("create order", async () => {
    await expect(
      marketplace
        .connect(buyer)
        .createOrder(
          newErc721Token.address,
          verifier.address,
          "0xB7c7653c6eDd43d482704f0A7C8e7bc04c367f48",
          "ipfs://bafkreihuk7qqpdskouyjax5wzpn4wwaktquzjd3flbluz6wbv46m7kt74u/",
          {
            value: BigNumber.from(5),
          },
        ),
    )
      .to.emit(marketplace, "OrderCreated")
      .withArgs(
        seller.address,
        "0x70997970C51812dc3A010C7d01b50e0d17dc79C8",
        newErc721Token.address,
        "ipfs://bafkreihuk7qqpdskouyjax5wzpn4wwaktquzjd3flbluz6wbv46m7kt74u/",
        5,
      );

    expect(await marketplace.provider.getBalance(marketplace.address)).equal(5);
  });

  it("verify computation", async () => {
    const sellerBalance = await marketplace.provider.getBalance(seller.address);

    const tx = await marketplace.connect(buyer).verifyComputation(
      newErc721Token.address,
      0,
      proof.inputs,
      proof.proof as any, // eslint-disable-line
    );

    await tx.wait();

    expect(await marketplace.provider.getBalance(seller.address)).equal(
      sellerBalance.add(BigNumber.from(5)),
    );
  });
});
