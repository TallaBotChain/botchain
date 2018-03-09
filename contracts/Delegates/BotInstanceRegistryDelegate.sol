pragma solidity ^0.4.18;

import "../Registry/BotEntryStorableRegistry.sol";

/**
 * @title BotInstanceRegistryDelegate
 * @dev Handles ownership of bot instances. Bot instances belong to a bot product. Ownership of a bot instance is determined by the developer that owns the bot product that the instance belongs to.
 */
contract BotInstanceRegistryDelegate is BotEntryStorableRegistry {

  /** @dev Constructor for BotInstanceRegistryDelegate */
  function BotInstanceRegistryDelegate(BaseStorage storage_)
    BotEntryStorableRegistry(storage_)
    public
  {}

}
