pragma solidity ^0.4.18;

import "../../contracts/Registry/OwnerRegistry.sol";

contract MockOwnerRegistry is OwnerRegistry {

  mapping(uint256 => address) public mockOwners;
  
  function mintingAllowed(address _minter, uint256 _entryId) public view returns (bool) {
    return _minter != 0x0 && _entryId != 0 && _entryId != 6;
  }

  function ownerOfEntry(uint256 _entryId) public view returns (address) {
    return mockOwners[_entryId];
  }

  function setMockOwner(uint256 id, address owner) public {
    mockOwners[id] = owner;
  }

}
