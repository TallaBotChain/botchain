pragma solidity ^0.4.18;

/**
 * @title OwnerRegistry interface
 * Interface for a registry with entries that own entries in another registry
 */
contract OwnerRegistry {
  function canMintOwnedEntry(address _owner) public view returns (bool _canMint);
  function entryForOwner(address _owner) public view returns (uint256 _entryId);
  function ownerForEntry(uint256 _entryId) public view returns (address _owner);
}
