pragma solidity ^0.4.18;

import "../../contracts/Registry/OwnerRegistry.sol";

contract MockOwnedRegistry {

  OwnerRegistry ownerRegistry;

  function MockOwnedRegistry(OwnerRegistry _ownerRegistry) public {
    ownerRegistry = _ownerRegistry;
  }

  function mintingAllowedOnOwner(address _minter, uint256 _entryId) public view returns (bool) {
    return ownerRegistry.mintingAllowed(_minter, _entryId);
  }

}
