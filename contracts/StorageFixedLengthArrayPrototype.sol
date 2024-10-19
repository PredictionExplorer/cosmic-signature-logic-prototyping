// SPDX-License-Identifier: CC0-1.0
pragma solidity 0.8.26;

/// @dev
/// solc --storage-layout StorageFixedLengthArrayPrototype.sol > StorageFixedLengthArrayPrototype-StorageLayout.json
contract StorageFixedLengthArrayPrototype {
	struct _StakeAction {
		uint256 nftId;
		address nftOwnerAddress;
		uint256 test1;
	}

	struct _TestStruct {
		_StakeAction[1 << 160] addressToStakeActionMapping;
	}

	_StakeAction[] public dynamicArray;

	mapping(uint256 stakeActionId => _StakeAction) public badStakeActions;
	_StakeAction[1 << 64] public goodStakeActions;

	mapping(uint256 roundNum => mapping(address => _StakeAction)) public badTests;
	_TestStruct[1 << 64] internal _goodTests;

	uint256 public actionCounter;

	function testFunction1() external {
		{
			_StakeAction storage stakeActionReference_ = dynamicArray.push();
			_StakeAction memory newStakeAction_ = _StakeAction(6123, address(6345), 63);

			// The compiler forces us to assign every individual fieldd.
			stakeActionReference_.nftId = newStakeAction_.nftId;
			stakeActionReference_.nftOwnerAddress = newStakeAction_.nftOwnerAddress;
			stakeActionReference_.test1 = newStakeAction_.test1;
		}

		{
			// This formula gives the compiler a hint to not perform array bounds check.
			actionCounter = (actionCounter + 1) & ((1 << 64) - 1);

			_StakeAction storage stakeActionReference_ = goodStakeActions[actionCounter];
			_StakeAction memory newStakeAction_ = _StakeAction(123, address(345), 3);

			// The compiler forces us to assign every individual fieldd.
			stakeActionReference_.nftId = newStakeAction_.nftId;
			stakeActionReference_.nftOwnerAddress = newStakeAction_.nftOwnerAddress;
			stakeActionReference_.test1 = newStakeAction_.test1;
		}

		{
			// This formula gives the compiler a hint to not perform array bounds check.
			actionCounter = (actionCounter + 1) & ((1 << 64) - 1);

			_TestStruct storage testStructReference_ = _goodTests[actionCounter];
			_StakeAction storage stakeActionReference_ =
				testStructReference_.addressToStakeActionMapping[uint256(uint160(msg.sender))];
			_StakeAction memory newStakeAction_ = _StakeAction(2123, address(2345), 23);

			// The compiler forces us to assign every individual fieldd.
			stakeActionReference_.nftId = newStakeAction_.nftId;
			stakeActionReference_.nftOwnerAddress = newStakeAction_.nftOwnerAddress;
			stakeActionReference_.test1 = newStakeAction_.test1;
		}
	}
}

