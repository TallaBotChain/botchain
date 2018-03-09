pragma solidity ^0.4.18;

import '../Registry/BotEntryStorableRegistry.sol';

/**
* @title BotServiceRegistryDelegate
* @dev handles ownership of bot services
*/
contract BotServiceRegistryDelegate is BotEntryStorableRegistry {

  string public constant name = "BotServiceRegistry";

  /** @dev Constructor for BotServiceRegistryDelegate */
  function BotServiceRegistryDelegate(BaseStorage storage_)
    BotEntryStorableRegistry(storage_)
    public
  {}

  /**
  * @dev Returns bot service associated with a bot service id
  * @param botInstanceId An id associated with the bot service
  */
  function getBotService(uint256 botInstanceId) public view returns
  (
    address _owner,
    address _botServiceAddress,
    bytes32 _data,
    bytes32 _url
  ) {
    return getBotEntry(botInstanceId);
  }

  /**
  * @dev Creates a new bot service.
  * @param developerId ID of the bot product that will own this bot service
  * @param botServiceAddress Address of the bot service
  * @param dataHash Hash of data associated with the bot service
  * @param url A url associated with this bot service
  */
  function createBotService(
    uint256 developerId, 
    address botServiceAddress, 
    bytes32 dataHash,
    bytes32 url
  )
    public 
  {
    createBotEntry(developerId, botServiceAddress, dataHash, url);
  }

}
