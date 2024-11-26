// SPDX-License-Identifier: CC0-1.0
pragma solidity 0.8.27;

import "hardhat/console.sol";

contract RandomNumberGenerator {
	// #region State

	uint256 public raffleEntropy;

	// #endregion

	constructor() {
		// Initializing this with a hardcoded value.
		raffleEntropy = 0x4e48fcb2afb4dabb2bc40604dc13d21579f2ce6b3a3f60b8dca0227d0535b31a;
	}

	function claimPrize1() public {
		uint256 randomNumber_ = raffleEntropy ^ generateRandomNumber();
		randomNumber_ = generateAndUseRandomNumber(randomNumber_);

		// At the end, saving the last generated value.
		// But `claimPrize2` doesn't do it.
		raffleEntropy = randomNumber_;
	}

	function claimPrize2() public view {
		// It's actually unnecessary to store the last generated random number because doing so won't be helpful for our logic.
		// It would be helpful if it was possible that multiple transactions executed within the same block
		// needed to generate random numbers.

		uint256 randomNumber_ = generateRandomNumber();
		generateAndUseRandomNumber(randomNumber_);
	}

	function generateAndUseRandomNumber(uint256 randomNumber_) public pure returns(uint256) {
		// Generating and using a random number multiple times.
		// Simply calculating `keccak256` of the previously calculated value.
		for ( uint256 counter_ = 0; counter_ < 2; ++ counter_ ) {
			randomNumber_ = calculateHashSumOf(randomNumber_);
			console.log(randomNumber_);
		}

		console.log();
		return randomNumber_;
	}

	function generateRandomNumber() public view returns(uint256) {
		unchecked {
			// console.log(block.number, block.timestamp);
			// console.log(block.prevrandao, uint256(blockhash(block.number)), uint256(blockhash(block.number - 1)));
			// console.log(block.basefee, block.blobbasefee);
			// console.log(tx.origin.balance, address(this).balance, address(0x123456789a).balance);

			return
				// The production code will not use this.
				// This would make no difference for our logic.
				uint160(tx.origin) +

				// The production code will not use this.
				// This would make no difference for our logic.
				uint160(msg.sender) +

				// The production code will not use this.
				// This is zero, but `RandomWalkNFT` uses this.
				uint256(blockhash(block.number)) +

				// The production code will not use this.
				// It will use `block.prevrandao` instead.
				uint256(blockhash(block.number - 1)) +

				// This value was generated in the past and therefore can be known to a sophisticated attacker.
				block.prevrandao +

				// The production code will not use this.
				// Arbitrum creates 4 blocks per second, so this value is the same in all the blocks created during a given second.
				block.timestamp +

				// The production code will not use this.
				// This is easy to predict.
				block.number +

				// This looks like a better source of randomness.
				// Although a sophisticated attacker could be able to calculate this from the previous block data.
				// So this could turn out to be even less random than `block.prevrandao`.
				block.basefee +

				// The production code will not use this.
				// Arbitrum doesn't support this.
				block.blobbasefee +

				// The production code will probably not use this, although it could be a good idea to use this.
				// We can try to find a contract account, like UniSwap, which balance changes frequently,
				// and use it as a source of randomness.
				// I have taken a look at some accounts, but balance there was changing not very frequently.
				address(0x123456789a).balance;
		}
	}

	function calculateHashSumOf(uint256 value_) public pure returns(uint256) {
		return uint256(keccak256(abi.encodePacked(value_)));
	}
}
