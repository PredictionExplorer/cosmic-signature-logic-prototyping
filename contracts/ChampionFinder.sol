// SPDX-License-Identifier: CC0-1.0
pragma solidity 0.8.27;

// A test needs to call `bid` 1+ times, and then `endRound`.
// The cycle may be be repeated multiple times.
contract ChampionFinder {
	// #region State

	address public lastBidder;

	// We will validate that bid timestamps are at least this big.
	// We want any timestamp to be positive, which is guaranteed in the production.
	// Otherwise the logic would not necessarily work correct.
	uint256 public lastBidTime = 1;

	address public enduranceChampion;
	uint256 public enduranceChampionStartTime;
	uint256 public enduranceChampionDuration;
	address public prevEnduranceChampion;
	uint256 public prevEnduranceChampionStartTime;
	uint256 public prevEnduranceChampionDuration = type(uint256).max;
	// address public prevPrevEnduranceChampion;
	// uint256 public prevPrevEnduranceChampionStartTime;
	uint256 public prevPrevEnduranceChampionDuration = type(uint256).max;
	address public chronoWarrior;
	uint256 public chronoWarriorStartTime;
	uint256 public chronoWarriorEndTime;
	uint256 public chronoWarriorDuration;

	// #endregion

	function bid(address bidder_, uint256 bidTime_) external {
		require(bidder_ != address(0));
		_updateEnduranceChampion(bidder_, bidTime_);
	}

	function endRound(uint256 roundEndTime_) external {
		// There was supposed to be at least 1 bid in the round.
		require(lastBidder != address(0));

		_updateEnduranceChampion(address(0), roundEndTime_);
		_roundEndResets();
	}

	// On round end, we call this with a zero `bidder_`.
	function _updateEnduranceChampion(address bidder_, uint256 bidTime_) private {
		require(bidTime_ >= lastBidTime);

		if (lastBidder != address(0)) {
			uint256 enduranceDuration_ = bidTime_ - lastBidTime;

			if (enduranceChampion == address(0)) {
				enduranceChampion = lastBidder;
				enduranceChampionStartTime = lastBidTime;
				enduranceChampionDuration = enduranceDuration_;

				chronoWarrior = lastBidder;
				chronoWarriorStartTime = lastBidTime;
				chronoWarriorEndTime = bidTime_;
				chronoWarriorDuration = enduranceDuration_;
			} else if (enduranceDuration_ > enduranceChampionDuration) {
				prevPrevEnduranceChampionDuration = prevEnduranceChampionDuration;
				prevEnduranceChampion = enduranceChampion;
				prevEnduranceChampionStartTime = enduranceChampionStartTime;
				prevEnduranceChampionDuration = enduranceChampionDuration;

				enduranceChampion = lastBidder;
				enduranceChampionStartTime = lastBidTime;
				enduranceChampionDuration = enduranceDuration_;

				_updateChronoWarrior();
			}
		}

		lastBidder = bidder_;
		lastBidTime = bidTime_;
	}

	function _updateChronoWarrior() private {
		// if (prevEnduranceChampion == address(0)) {
		// 	return;
		// }

		uint256 chronoStartTime_ = prevEnduranceChampionStartTime;
		if (prevPrevEnduranceChampionDuration < type(uint256).max) {
			chronoStartTime_ += prevPrevEnduranceChampionDuration;
		}

		uint256 chronoEndTime_ = enduranceChampionStartTime + prevEnduranceChampionDuration;
		uint256 chronoDuration_ = chronoEndTime_ - chronoStartTime_;

		if (/* chronoWarrior == address(0) || */ chronoDuration_ > chronoWarriorDuration) {
			chronoWarrior = prevEnduranceChampion;
			chronoWarriorStartTime = chronoStartTime_;
			chronoWarriorEndTime = chronoEndTime_;
			chronoWarriorDuration = chronoDuration_;
		}
	}

	function _roundEndResets() private {
		// We have already reset this.
		assert(lastBidder == address(0));

		// // It's unnecessary to reset this.
		// lastBidTime = ...;

		enduranceChampion = address(0);
		enduranceChampionStartTime = 0;
		enduranceChampionDuration = 0;
		prevEnduranceChampion = address(0);
		prevEnduranceChampionStartTime = 0;
		prevEnduranceChampionDuration = type(uint256).max;
		prevPrevEnduranceChampionDuration = type(uint256).max;
		chronoWarrior = address(0);
		chronoWarriorStartTime = 0;
		chronoWarriorEndTime = 0;
		chronoWarriorDuration = 0;
	}
}
