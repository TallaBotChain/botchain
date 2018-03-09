pragma solidity ^0.4.18;

import '../Registry/BotEntryStorableRegistry.sol';

/**
* @title BotServiceRegistryDelegate
* @dev handles ownership of bot services
*/
contract BotServiceRegistryDelegate is BotEntryStorableRegistry {

  /** @dev Constructor for BotServiceRegistryDelegate */
  function BotServiceRegistryDelegate(BaseStorage storage_)
    BotEntryStorableRegistry(storage_)
    public
  {}

}
