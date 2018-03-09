pragma solidity ^0.4.18;

import "./Upgradability/OwnableProxy.sol";
import "./Upgradability/PublicStorage.sol";

contract BotEntryRegistry is OwnableProxy {

  /** @dev Creates bot entry registry*/
  function BotEntryRegistry(
    address ownerRegistryAddress,
    PublicStorage storage_,
    address delegate,
    address botCoinAddress
  )
    OwnableProxy(storage_, delegate)
    public
  {
    storage_.setAddress("ownerRegistryAddress", ownerRegistryAddress);
  	storage_.setAddress("botCoinAddress", botCoinAddress);
  }

}
