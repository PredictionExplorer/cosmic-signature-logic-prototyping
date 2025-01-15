"use strict";

// const { expect } = require("chai");
const hre = require("hardhat");
const { /*time,*/ loadFixture, } = require("@nomicfoundation/hardhat-toolbox/network-helpers");
// const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");

// We define a fixture to reuse the same setup in every test.
// We use loadFixture to run this setup once, snapshot that state,
// and reset Hardhat Network to that snapshot in every test.
async function deployContract() {
	// // Contracts are deployed using the first signer/account by default
	// const [owner, otherAccount] = await hre.ethers.getSigners();

	const RandomNumberGenerator = await hre.ethers.getContractFactory("RandomNumberGenerator");
	const randomNumberGenerator = await RandomNumberGenerator.deploy();
	randomNumberGenerator.waitForDeployment();

	return { randomNumberGenerator, /*owner, otherAccount,*/ };
}

describe("RandomNumberGenerator", function () {
	it("Test 1", async function () {
		// {
		// 	const s = hre.ethers.hashMessage(Math.random().toString());
		// 	console.log(s);
		// 	const n = BigInt(s);
		// 	console.log(n);
		// 	console.log();
		// }

		const { randomNumberGenerator } = await loadFixture(deployContract);

		await randomNumberGenerator.claimMainPrize1();
		await randomNumberGenerator.claimMainPrize2();
	});
});
