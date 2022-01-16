// SPDX-License-Identifier: MIT
pragma solidity 0.8.5;

interface IApp {
	struct Profile {
		string username;
		string dataHash;
		uint256 createdAt;
		uint256 updatedAt;
	}

	event ProfileCreated(address);
	event ProfileUpdated(address);
	event ProfileDeleted(address);

	function addressOf(string memory) external view returns(address);
	function usernameOf(address) external view returns(string memory);
	function getProfileByUsername(string memory) external view returns(Profile memory);
	function getProfileByAddress(address) external view returns(Profile memory);
	function getProfileHashByUsername(string memory) external view returns(string memory);
	function getProfileHashByAddress(address) external view returns(string memory);

	function createProfile(string memory, string memory) external;
	function changeProfileHash(string memory) external;
	function changeUsername(string memory) external;
	function deleteProfile() external;
}
