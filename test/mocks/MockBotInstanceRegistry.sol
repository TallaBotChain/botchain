pragma solidity ^0.4.18;

import "../../contracts/Upgradability/PublicStorage.sol";
import "../../contracts/Delegates/BotInstanceRegistryDelegate.sol";

contract MockBotInstanceRegistry is BotInstanceRegistryDelegate {

  function MockBotInstanceRegistry(
    PublicStorage storage_,
    address ownerRegistryAddress,
    address botCoinAddress
  )
    BotInstanceRegistryDelegate(storage_)
    public
  {
    storage_.setAddress("ownerRegistryAddress", ownerRegistryAddress);
  	storage_.setAddress("botCoinAddress", botCoinAddress);
  }

}
