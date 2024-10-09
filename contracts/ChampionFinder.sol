// SPDX-License-Identifier: CC0-1.0
pragma solidity 0.8.27;

import "hardhat/console.sol";

/// @notice This prototype finds endurance champion and chrono-warrior.
/// @dev A test needs to call `bid` 1+ times, and then `endRound`.
/// The cycle may be be repeated multiple times.
contract ChampionFinder {
	// #region State

	address public lastBidder;

	/// @dev We will validate that bid timestamps are at least this big.
	/// We want any timestamp to be positive, which is guaranteed in the production.
	/// Otherwise the logic would not necessarily work correct.
	uint256 public lastBidTime = 1;

	address public enduranceChampion;
	uint256 public enduranceChampionStartTime;
	uint256 public enduranceChampionDuration;
	uint256 public prevEnduranceChampionDuration;
	address public chronoWarrior;
	uint256 public chronoWarriorStartTime;
	uint256 public chronoWarriorEndTime;
	uint256 public chronoWarriorDuration;

	// #endregion

	function bid(address bidder_, uint256 bidTime_) external {
		require(bidder_ != address(0));
		if(lastBidder == address(0)) {
			_roundBeginResets();
		}
		_updateEnduranceChampionAndChronoWarrior(bidder_, bidTime_);
	}

	function endRound(uint256 roundEndTime_) external {
		// There was supposed to be at least 1 bid in the round.
		require(lastBidder != address(0));

		_updateEnduranceChampionAndChronoWarrior(address(0), roundEndTime_);
		_updateChronoWarrior(roundEndTime_);
		_roundEndResets();
	}

	/// @dev On bidding round end, we call this with a zero `bidder_`.
	function _updateEnduranceChampionAndChronoWarrior(address bidder_, uint256 bidTime_) private {
		require(bidTime_ >= lastBidTime);

		if (lastBidder != address(0)) {
			uint256 enduranceDuration_ = bidTime_ - lastBidTime;

			if (enduranceChampion == address(0)) {
				enduranceChampion = lastBidder;
				enduranceChampionStartTime = lastBidTime;
				enduranceChampionDuration = enduranceDuration_;
			} else if (enduranceDuration_ > enduranceChampionDuration) {
				uint256 chronoEndTime_ = lastBidTime + enduranceChampionDuration;
				_updateChronoWarrior(chronoEndTime_);
				prevEnduranceChampionDuration = enduranceChampionDuration;
				enduranceChampion = lastBidder;
				enduranceChampionStartTime = lastBidTime;
				enduranceChampionDuration = enduranceDuration_;
			}
		}

		lastBidder = bidder_;
		lastBidTime = bidTime_;
	}

	function _updateChronoWarrior(uint256 chronoEndTime_) private {
		uint256 chronoStartTime_ = enduranceChampionStartTime + prevEnduranceChampionDuration;
		uint256 chronoDuration_ = chronoEndTime_ - chronoStartTime_;
		if (int256(chronoDuration_) > int256(chronoWarriorDuration)) {
			chronoWarrior = enduranceChampion;
			chronoWarriorStartTime = chronoStartTime_;
			chronoWarriorEndTime = chronoEndTime_;
			chronoWarriorDuration = chronoDuration_;
		}
	}

	function _roundBeginResets() private {
		// It's unnecessary to reset this.
		// Actually, in our test data this gets reset, so we must reset this too.
		lastBidTime = 1;

		enduranceChampion = address(0);
		enduranceChampionStartTime = 0;
		enduranceChampionDuration = 0;
		prevEnduranceChampionDuration = 0;
		chronoWarrior = address(0);
		chronoWarriorStartTime = 0;
		chronoWarriorEndTime = 0;
		chronoWarriorDuration = uint256(int256(-1));
	}

	function _roundEndResets() private view {
		// We have already reset this.
		assert(lastBidder == address(0));
	}
}
