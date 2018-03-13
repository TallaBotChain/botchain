pragma solidity ^0.4.18;

/**
* @title Registry interface
* @dev Interface for a registry
*/
contract Registry {
	/**
	* @dev Returns address of owner of entry
	* @param _entryId An id associated with the entry
	* @return address of owner of entry
	*/
  function ownerOfEntry(uint256 _entryId) public view returns (address _owner);
}
