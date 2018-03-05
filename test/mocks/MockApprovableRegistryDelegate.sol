pragma solidity ^0.4.18;

import "levelk-upgradability-contracts/contracts/Storage/PublicStorage.sol";
import "../../contracts/Delegates/ApprovableRegistryDelegate.sol";

contract MockApprovableRegistryDelegate is ApprovableRegistryDelegate {

  function MockApprovableRegistryDelegate(PublicStorage storage_)
    ApprovableRegistryDelegate(storage_)
    public
  { }
  
  function add() public {
    uint256 _entryId = super.totalSupply().add(1);
    super._mint(msg.sender, _entryId);
  }

}
