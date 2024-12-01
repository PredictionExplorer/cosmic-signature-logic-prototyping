"use strict";

const nodeFsModule = require('node:fs');
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

	const ChampionFinder = await hre.ethers.getContractFactory("ChampionFinder");
	const championFinder = await ChampionFinder.deploy();
	championFinder.waitForDeployment();

	return { championFinder, /*owner, otherAccount,*/ };
}

/**
 * @param {string} char
 */
function charToAddress(char) {
	const charCode = char.charCodeAt(0);
	const hexString = charCode.toString(16);
	const paddedHexString = hexString.padStart(40, "0");
	const rawAddress = "0x" + paddedHexString;
	const address = hre.ethers.getAddress(rawAddress);
	// console.log(address);
	return address;
}

/**
 * @param {string} char
 */
function addressToChar(address) {
	const charCode = parseInt(address, 16)
	const char = String.fromCharCode(charCode);
	return char;
}

/**
 * @param {string} filePath
 */
async function loadJsonFile(filePath) {
		const data = await nodeFsModule.promises.readFile(filePath, 'utf8');
		const jsonData = JSON.parse(data);
		return jsonData;
}

describe("ChampionFinder", function () {
	it("Deployment", async function () {
		const { championFinder } = await loadFixture(deployContract);

		// expect(await championFinder.lastBidTimeStamp()).to.equal(1n);
		// expect(await championFinder.prevEnduranceChampionDuration()).to.equal(2n ** 256n - 1n);
	});

	it("Smoke test", async function () {
		const { championFinder } = await loadFixture(deployContract);

		const char = "m";
		const address = charToAddress(char);
		// console.log(address);
		// console.log(addressToChar(address));

		expect(await championFinder.bid(address, 1n)).not.to.be.reverted;
		expect(await championFinder.lastBidder()).to.equal(address);
		expect(await championFinder.endRound(2)).not.to.be.reverted;
		expect(await championFinder.lastBidder()).to.equal(hre.ethers.ZeroAddress);
	});

	it("Test data test", async function () {
		const { championFinder } = await loadFixture(deployContract);

		const testData = await loadJsonFile("test/data/endurance_test_cases_2.json");

		let counter = 0;
		for (let roundInfo of testData) {
			++ counter;
			console.log(counter);

			for (let bidInfo of roundInfo.bid_times) {
				// console.log(bidInfo[0]);
				// console.log(bidInfo[1]);
				expect(await championFinder.bid(charToAddress(bidInfo[1]), bidInfo[0])).not.to.be.reverted;
			}
			expect(await championFinder.endRound(roundInfo.game_end_time)).not.to.be.reverted;
			// console.log(
			// 	addressToChar(await championFinder.enduranceChampion()),
			// 	await championFinder.enduranceChampionStartTimeStamp(),
			// 	await championFinder.enduranceChampionDuration()
			// );
			// console.log(
			// 	addressToChar(await championFinder.chronoWarrior()),
			// 	await championFinder.chronoWarriorStartTimeStamp(),
			// 	await championFinder.chronoWarriorEndTimeStamp(),
			// 	await championFinder.chronoWarriorDuration()
			// );
			const roundResult = roundInfo.result;
			expect(await championFinder.enduranceChampion()).to.equal(charToAddress(roundResult.endurance_champion.name));
			expect(await championFinder.enduranceChampionStartTimeStamp()).to.equal(roundResult.endurance_champion.endurance_start_time);
			expect(await championFinder.enduranceChampionDuration()).to.equal(roundResult.endurance_champion.endurance_length);
			expect(await championFinder.chronoWarrior()).to.equal(charToAddress(roundResult.chrono_warrior.name));
			expect(await championFinder.chronoWarriorStartTimeStamp()).to.equal(roundResult.chrono_warrior.chrono_start_time);
			expect(await championFinder.chronoWarriorEndTimeStamp()).to.equal(roundResult.chrono_warrior.chrono_end_time);
			expect(await championFinder.chronoWarriorDuration()).to.equal(roundResult.chrono_warrior.chrono_length);
			
			if (counter >= 10) break;
		}
	});
});
