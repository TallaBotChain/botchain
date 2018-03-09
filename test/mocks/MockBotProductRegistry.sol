pragma solidity ^0.4.18;

import "../../contracts/Upgradability/PublicStorage.sol";
import "../../contracts/Delegates/BotProductRegistryDelegate.sol";

contract MockBotProductRegistry is BotProductRegistryDelegate {

  function MockBotProductRegistry(
    PublicStorage storage_,
    address ownerRegistryAddress,
    address botCoinAddress
  )
    BotProductRegistryDelegate(storage_)
    public
  {
    storage_.setAddress("ownerRegistryAddress", ownerRegistryAddress);
  	storage_.setAddress("botCoinAddress", botCoinAddress);
  }

}
