pragma solidity ^0.4.18;

import "./Registry.sol";

/**
 * @title OwnerRegistry interface
 * Interface for a registry with entries that own entries in another registry
 */
contract OwnerRegistry is Registry {
  function mintingAllowed(address _minter, uint256 _entryId) public view returns (bool _mintingAllowed);
}
