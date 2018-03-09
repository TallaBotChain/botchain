pragma solidity ^0.4.18;

import "../Registry/BotEntryStorableRegistry.sol";

/**
 * @title BotInstanceRegistryDelegate
 * @dev Handles ownership of bot instances. Bot instances belong to a bot product. Ownership of a bot instance is determined by the developer that owns the bot product that the instance belongs to.
 */
contract BotInstanceRegistryDelegate is BotEntryStorableRegistry {

  string public constant name = "BotInstanceRegistry";

  /** @dev Constructor for BotInstanceRegistryDelegate */
  function BotInstanceRegistryDelegate(BaseStorage storage_)
    BotEntryStorableRegistry(storage_)
    public
  {}

  /**
  * @dev Returns bot instance associated with a bot instance id
  * @param botInstanceId An id associated with the bot instance
  */
  function getBotInstance(uint256 botInstanceId) public view returns
  (
    address _owner,
    address _botInstanceAddress,
    bytes32 _data,
    bytes32 _url
  ) {
    return getBotEntry(botInstanceId);
  }

  /**
  * @dev Creates a new bot instance.
  * @param botProductId ID of the bot product that will own this bot instance
  * @param botInstanceAddress Address of the bot instance
  * @param dataHash Hash of data associated with the bot instance
  * @param url A url associated with this bot instance
  */
  function createBotInstance(
    uint256 botProductId, 
    address botInstanceAddress, 
    bytes32 dataHash, 
    bytes32 url
  )
    public 
  {
    createBotEntry(botProductId, botInstanceAddress, dataHash, url);
  }

}
