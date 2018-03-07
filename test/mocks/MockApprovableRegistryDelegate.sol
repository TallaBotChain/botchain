pragma solidity ^0.4.18;

import "../../contracts/Upgradability/PublicStorage.sol";
import "../../contracts/Upgradability/ERC721TokenKeyed.sol";
import "../../contracts/Delegates/ApprovableRegistryDelegate.sol";

contract MockApprovableRegistryDelegate is ApprovableRegistryDelegate, ERC721TokenKeyed {

  function MockApprovableRegistryDelegate(PublicStorage storage_)
    ApprovableRegistryDelegate(storage_)
    ERC721TokenKeyed(storage_)
    public
  { }
  
  function add() public {
    uint256 _entryId = totalSupply().add(1);
    _mint(msg.sender, _entryId);
  }

  function entryExists(uint256 _entryId) private view returns (bool) {
    return ownerOf(_entryId) != 0x0;
  }

}
