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

  /**
  * @dev Checks if botServiceId has entry ownership
  * @param _botServiceId An id associated with the bot service
  * @return Returns true if _botServiceId has entry ownership
  */
  function checkEntryOwnership(uint256 _botServiceId) private view returns (bool) {
    return ownerOfEntry(_botServiceId) == msg.sender;
  }

  /**
  * @dev Checks if botServiceId entry exists
  * @param _botServiceId An id associated with the bot service
  * @return Returns true if entry exists for id
  */
  function entryExists(uint256 _botServiceId) private view returns (bool) {
    return ownerOfEntry(_botServiceId) != 0x0;
  }

}
