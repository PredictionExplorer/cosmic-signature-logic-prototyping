// SPDX-License-Identifier: CC0-1.0
pragma solidity 0.8.27;

// import "hardhat/console.sol";

/// @notice This prototype finds endurance champion and chrono-warrior.
/// @dev A test needs to call `bid` 1+ times, and then `endRound`.
/// The cycle may be be repeated multiple times.
contract ChampionFinder {
	// #region State

	address public lastBidder;
	uint256 public lastBidTimeStamp;
	address public enduranceChampion;
	uint256 public enduranceChampionStartTimeStamp;
	uint256 public enduranceChampionDuration;
	uint256 public prevEnduranceChampionDuration;
	address public chronoWarrior;
	uint256 public chronoWarriorStartTimeStamp;
	uint256 public chronoWarriorEndTimeStamp;
	uint256 public chronoWarriorDuration;

	// #endregion

	function bid(address bidder_, uint256 bidTimeStamp_) external {
		require(bidder_ != address(0));
		if(lastBidder == address(0)) {
			_roundBeginResets();
		}
		_updateEnduranceChampionAndChronoWarriorIfNeeded(bidder_, bidTimeStamp_);
	}

	function endRound(uint256 roundEndTimeStamp_) external {
		// There was supposed to be at least 1 bid in the round.
		require(lastBidder != address(0));

		_updateEnduranceChampionAndChronoWarriorIfNeeded(address(0), roundEndTimeStamp_);
		_updateChronoWarriorIfNeeded(roundEndTimeStamp_);
		_roundEndResets();
	}

	/// @dev On bidding round end, we call this with a zero `bidder_`.
	function _updateEnduranceChampionAndChronoWarriorIfNeeded(address bidder_, uint256 bidTimeStamp_) private {
		require(bidTimeStamp_ >= lastBidTimeStamp);

		if (lastBidder != address(0)) {
			uint256 enduranceDuration_ = bidTimeStamp_ - lastBidTimeStamp;
			if (enduranceChampion == address(0)) {
				enduranceChampion = lastBidder;
				enduranceChampionStartTimeStamp = lastBidTimeStamp;
				enduranceChampionDuration = enduranceDuration_;
				assert(chronoWarrior == address(0));
			} else if (enduranceDuration_ > enduranceChampionDuration) {
				{
					uint256 chronoEndTimeStamp_ = lastBidTimeStamp + enduranceChampionDuration;
					_updateChronoWarriorIfNeeded(chronoEndTimeStamp_);
				}
				prevEnduranceChampionDuration = enduranceChampionDuration;
				enduranceChampion = lastBidder;
				enduranceChampionStartTimeStamp = lastBidTimeStamp;
				enduranceChampionDuration = enduranceDuration_;
			}

			assert(enduranceChampion != address(0));
		}

		lastBidder = bidder_;
		lastBidTimeStamp = bidTimeStamp_;
	}

	function _updateChronoWarriorIfNeeded(uint256 chronoEndTimeStamp_) private {
		assert(enduranceChampion != address(0));
		assert(int256(chronoWarriorDuration) >= -1);
		assert((chronoWarrior == address(0)) == (int256(chronoWarriorDuration) < int256(0)));

		uint256 chronoStartTimeStamp_ = enduranceChampionStartTimeStamp + prevEnduranceChampionDuration;
		uint256 chronoDuration_ = chronoEndTimeStamp_ - chronoStartTimeStamp_;
		if (int256(chronoDuration_) > int256(chronoWarriorDuration)) {
			chronoWarrior = enduranceChampion;
			chronoWarriorStartTimeStamp = chronoStartTimeStamp_;
			chronoWarriorEndTimeStamp = chronoEndTimeStamp_;
			chronoWarriorDuration = chronoDuration_;
		}

		assert(chronoWarrior != address(0));
	}

	function _roundBeginResets() private {
		// We will validate that bid timestamps are at least this big.
		// We want any timestamp to be positive, which is guaranteed in the production.
		// Otherwise the logic would not necessarily work correct.
		lastBidTimeStamp = 1;

		enduranceChampion = address(0);
		enduranceChampionStartTimeStamp = 0;
		enduranceChampionDuration = 0;
		prevEnduranceChampionDuration = 0;
		chronoWarrior = address(0);
		chronoWarriorStartTimeStamp = 0;
		chronoWarriorEndTimeStamp = 0;
		chronoWarriorDuration = uint256(int256(-1));
	}

	function _roundEndResets() private view {
		// We have already reset this.
		assert(lastBidder == address(0));
	}
}
