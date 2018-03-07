pragma solidity ^0.4.18;

import "../../contracts/Upgradability/PublicStorage.sol";
import "../../contracts/Delegates/ActivatableRegistryDelegate.sol";

contract MockActivatableRegistryDelegate is ActivatableRegistryDelegate {

  function MockActivatableRegistryDelegate(PublicStorage storage_)
    ActivatableRegistryDelegate(storage_)
    public
  { }
  
  function add() public {
    uint256 _entryId = super.totalSupply().add(1);
    super._mint(msg.sender, _entryId);
  }

}
