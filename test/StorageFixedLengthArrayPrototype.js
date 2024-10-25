"use strict";

const { expect } = require("chai");
const hre = require("hardhat");
const { /*time,*/ loadFixture, } = require("@nomicfoundation/hardhat-toolbox/network-helpers");
// const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");

// We define a fixture to reuse the same setup in every test.
// We use loadFixture to run this setup once, snapshot that state,
// and reset Hardhat Network to that snapshot in every test.
async function deployContract() {
	// // Contracts are deployed using the first signer/account by default
	// const [owner, otherAccount] = await hre.ethers.getSigners();

	const StorageFixedLengthArrayPrototype = await hre.ethers.getContractFactory("StorageFixedLengthArrayPrototype");
	const storageFixedLengthArrayPrototype = await StorageFixedLengthArrayPrototype.deploy();

	return { storageFixedLengthArrayPrototype, /*owner, otherAccount,*/ };
}

describe("StorageFixedLengthArrayPrototype", function () {
	it("Deployment", async function () {
		const { storageFixedLengthArrayPrototype } = await loadFixture(deployContract);
	});

	it("testFunction1", async function () {
		const { storageFixedLengthArrayPrototype } = await loadFixture(deployContract);

		expect(await storageFixedLengthArrayPrototype.testFunction1()).not.to.be.reverted;
	});
});
