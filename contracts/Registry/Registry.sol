pragma solidity ^0.4.18;

/**
 * @title Registry interface
 * Interface for a registry
 */
contract Registry {
  function ownerOfEntry(uint256 _entryId) public view returns (address _owner);
}
