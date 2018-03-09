pragma solidity ^0.4.18;

import "../../contracts/Upgradability/PublicStorage.sol";
import "../../contracts/Delegates/BotServiceRegistryDelegate.sol";

contract MockBotServiceRegistry is BotServiceRegistryDelegate {

  function MockBotServiceRegistry(
    PublicStorage storage_,
    address ownerRegistryAddress,
    address botCoinAddress
  )
    BotServiceRegistryDelegate(storage_)
    public
  {
    storage_.setAddress("ownerRegistryAddress", ownerRegistryAddress);
  	storage_.setAddress("botCoinAddress", botCoinAddress);
  }

}
