pragma solidity ^0.4.18;

import "../../contracts/Upgradability/PublicStorage.sol";
import "../../contracts/Upgradability/ERC721TokenKeyed.sol";
import "../../contracts/Registry/ActivatableRegistry.sol";

contract MockActivatableRegistryDelegate is ActivatableRegistry, ERC721TokenKeyed {

  function MockActivatableRegistryDelegate(PublicStorage storage_)
    ActivatableRegistry(storage_)
    ERC721TokenKeyed(storage_)
    public
  { }
  
  function add() public {
    uint256 _entryId = totalSupply().add(1);
    _mint(msg.sender, _entryId);
  }

  function checkEntryOwnership(uint256 _entryId) private view returns (bool) {
    return ownerOf(_entryId) == msg.sender;
  }

}
