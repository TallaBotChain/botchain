pragma solidity ^0.4.18;

import "../../contracts/Registry/OwnableRegistry.sol";

/**
 * @title MockOwnableRegistry
 * This mock just provides a public mint function for testing purposes.
 */
contract MockOwnableRegistry is OwnableRegistry {

  function MockOwnableRegistry(BaseStorage storage_) OwnableRegistry(storage_) public { }

  function mint(uint256 _to, uint256 _tokenId) public {
    super._mint(_to, _tokenId);
  }
}
