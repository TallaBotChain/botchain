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

  /**
  * @dev Checks if botInstanceId has entry ownership
  * @param _botInstanceId An id associated with the bot instance
  * @return Returns true if _botInstanceId has entry ownership
  */
  function checkEntryOwnership(uint256 _botInstanceId) private view returns (bool) {
    ownerOfEntry(_botInstanceId) == msg.sender;
  }

  /**
  * @dev Checks if botInstanceId entry exists
  * @param _botInstanceId An id associated with the bot instance
  * @return Returns true if entry exists for id
  */
  function entryExists(uint256 _botInstanceId) private view returns (bool) {
    return ownerOf(_botInstanceId) > 0;
  }

}
