pragma solidity ^0.4.18;

import "levelk-upgradability-contracts/contracts/Proxy/OwnableProxy.sol";
import "levelk-upgradability-contracts/contracts/Storage/PublicStorage.sol";
import "./Delegates/DeveloperRegistryDelegate.sol";
import "./BotProductRegistry.sol";

contract DeveloperRegistry is OwnableProxy {

  function DeveloperRegistry(
    PublicStorage storage_,
    address developerRegistryDelegateAddress
  )
    public
    OwnableProxy(storage_, developerRegistryDelegateAddress)
  {}

}
