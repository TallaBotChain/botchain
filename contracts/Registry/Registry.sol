pragma solidity ^0.4.18;

/**
 * @title Registry interface
 * Interface for a registry
 */
contract Registry {
	/**
	* @dev Returns address of owner of entry
	* @param _entryId An id associated with the entry
	*/
  	function ownerOfEntry(uint256 _entryId) public view returns (address _owner);
}
