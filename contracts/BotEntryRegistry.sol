pragma solidity ^0.4.18;

import "./Upgradability/OwnableProxy.sol";
import "./Upgradability/PublicStorage.sol";

contract BotEntryRegistry is OwnableProxy {

  function BotEntryRegistry(
    address ownerRegistryAddress,
    PublicStorage storage_,
    address delegate
  )
    OwnableProxy(storage_, delegate)
    public
  {
    storage_.setAddress("ownerRegistryAddress", ownerRegistryAddress);
  }

}
