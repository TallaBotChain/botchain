pragma solidity ^0.4.18;

import "../../contracts/Registry/OwnerRegistry.sol";

contract MockOwnerRegistry is OwnerRegistry {

  mapping(uint256 => address) public mockOwners;
  bool public allowMinting = true;
  
  function mintingAllowed(address _minter, uint256 _entryId) public view returns (bool) {
    return allowMinting;
  }

  function disableMinting() public {
    allowMinting = false;
  }

  function ownerOfEntry(uint256 _entryId) public view returns (address) {
    return mockOwners[_entryId];
  }

  function setMockOwner(uint256 id, address owner) public {
    mockOwners[id] = owner;
  }

}
