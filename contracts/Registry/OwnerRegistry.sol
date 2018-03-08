pragma solidity ^0.4.18;

import "./Registry.sol";

/**
 * @title OwnerRegistry interface
 * Interface for a registry with entries that own entries in another registry
 */
contract OwnerRegistry is Registry {
	/**
	 * @dev Returns true if minting is allowed
	 * @param _minter Address of minter
	 * @param _entryId An id associated with the entry
	 */
  	function mintingAllowed(address _minter, uint256 _entryId) public view returns (bool _mintingAllowed);
}
