pragma solidity ^0.4.18;

import "../../contracts/Upgradability/PublicStorage.sol";
import "../../contracts/Registry/BotEntryStorableRegistry.sol";

contract MockBotEntryStorableRegistry is BotEntryStorableRegistry {

  function MockBotEntryStorableRegistry(
    PublicStorage storage_,
    address ownerRegistryAddress,
    address botCoinAddress
  )
    BotEntryStorableRegistry(storage_)
    public
  {
    storage_.setAddress("ownerRegistryAddress", ownerRegistryAddress);
  	storage_.setAddress("botCoinAddress", botCoinAddress);
  }

}
