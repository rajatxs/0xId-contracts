// SPDX-License-Identifier: MIT
pragma solidity 0.8.5;

abstract contract Context {
	function _msgSender() internal view returns(address) {
		return msg.sender;
	}

	function _timestamp() internal view returns(uint256) {
		return block.timestamp;
	}
}
