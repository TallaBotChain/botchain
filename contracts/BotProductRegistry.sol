pragma solidity ^0.4.18;

import "./Upgradability/OwnableProxy.sol";
import "./Upgradability/PublicStorage.sol";

contract BotProductRegistry is OwnableProxy {

  function BotProductRegistry(
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
