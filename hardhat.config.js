"use strict";

require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.27",

	mocha: {
		timeout: 60 * 60 * 1000,
	},
};
