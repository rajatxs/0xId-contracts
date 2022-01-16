// SPDX-License-Identifier: MIT
pragma solidity 0.8.5;

import "./interfaces/IApp.sol";
import "./Context.sol";

contract App is IApp, Context {
	mapping(address => Profile) internal profiles;
	mapping(string => address) internal usernames;

	modifier validateSenderAddress {
		require(_msgSender() != address(0x0));
		_;
	}

	modifier validateUsername(string memory _username) {
		uint8 usernameLength = uint8(bytes(_username).length);
		require(usernameLength > 2 && usernameLength < 28, "Inappropriate Username");
		_;
	}

	modifier verifyUsernameOwnership(string memory _username) {
		require(usernames[_username] == _msgSender(), "Forbidden");
		_;
	}

	modifier validateDataHash(string memory _dataHash) {
		require(bytes(_dataHash).length > 0, "Inappropriate Data Hash");
		_;
	}

	modifier requireDistinctUsername(string memory _username) {
		require(usernames[_username] == address(0x0), "Username is taken");
		_;
	}

	modifier requireProfile {
		require(bytes(profiles[_msgSender()].username).length != 0, "Profile does not found");
		_;
	}

	modifier willMutateProfile {
		address sender = _msgSender();

		_;
		profiles[sender].updatedAt = _timestamp();
		emit ProfileUpdated(sender);
	}

	/**
	 * @dev Returns address and username of sender
	 */
	function _getIdentity() internal view returns(address, string memory) {
		address sender = _msgSender();
		return (sender, usernameOf(sender));
	}

	/**
	 * @dev Returns address of `_username`
	 */
	function addressOf(string memory _username) public view override returns(address) {
		return usernames[_username];
	}

	/**
	 * @dev Returns username of `_profile`
	 */
	function usernameOf(address _profile) public view override returns(string memory) {
		return profiles[_profile].username;
	}

	/**
	 * @dev Returns profile by `_username`
	 */
	function getProfileByUsername(string memory _username) public view override returns(Profile memory) {
		return profiles[usernames[_username]];
	}

	/**
	 * @dev Returns profile by `_profile`
	 */ 
	function getProfileByAddress(address _profile) public view override returns(Profile memory) {
		return profiles[_profile];
	}

	/**
	 * @dev Returns `dataHash` by `_username`
	 */
	function getProfileHashByUsername(string memory _username) public view override returns(string memory) {
		return profiles[usernames[_username]].dataHash;
	}

	/**
	 * @dev Returns `dataHash` by `_profile`
	 */
	function getProfileHashByAddress(address _profile) public view override returns(string memory) {
		return profiles[_profile].dataHash;
	}

	/**
	 * @dev Creates new profile associated with `_username`
	 */
	function createProfile(string memory _username, string memory _dataHash) external override
		validateSenderAddress
	 	validateUsername(_username) 
	 	requireDistinctUsername(_username)
	 	validateDataHash(_dataHash) {

		address sender = _msgSender();
		Profile memory newProfile;

	 	require(bytes(profiles[sender].username).length == 0, "Profile already exists");

		newProfile = Profile(
			_username,
			_dataHash,
			_timestamp(),
			0
		);

		usernames[_username] = sender;
		profiles[sender] = newProfile;

		emit ProfileCreated(sender);
 	}

	/**
	 * @dev Allows owner to change their `_dataHash`
	 */
	function changeProfileHash(string memory _dataHash) external override
		validateSenderAddress
		requireProfile
		validateDataHash(_dataHash)
		willMutateProfile {

		address sender = _msgSender();
	 	profiles[sender].dataHash = _dataHash;
 	}


 	/**
	 * @dev Allows owner to change their username
	 */
	function changeUsername(string memory _newUsername) external override 
		validateSenderAddress
		validateUsername(_newUsername) 
		requireDistinctUsername(_newUsername)
		requireProfile
		willMutateProfile {

		address sender;
		string memory username;

		(sender, username) = _getIdentity();

		delete usernames[username];
		usernames[_newUsername] = sender;
		profiles[sender].username = _newUsername;
	}

	/**
	 * @dev Allows owner to delete their profile
	 */
	function deleteProfile() external override
		validateSenderAddress
		requireProfile {

		address sender;
		string memory username;

		(sender, username) = _getIdentity();

		delete usernames[username];
		delete profiles[sender];
		emit ProfileDeleted(sender);
	}
}
