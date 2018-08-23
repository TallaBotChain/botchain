pragma solidity ^0.4.18;

import '../Registry/BotEntryStorableRegistry.sol';

/**
 * @title BotServiceRegistryDelegate
 * @dev Delegate contract for functionality that handles ownership of bot services.
 *  Bot services belong to a developer. Ownership of a bot service is determined by
 *  the developer that the bot services belongs to.
 */
contract BotServiceRegistryDelegate is BotEntryStorableRegistry {

  string public constant name = "BotServiceRegistry";

  /**
  * @dev Constructor for BotServiceRegistryDelegate
  * @param storage_ address of a BaseStorage contract
  */
  function BotServiceRegistryDelegate(BaseStorage storage_)
    BotEntryStorableRegistry(storage_)
    public
  {}

  /**
  * @dev Returns data for the given bot service ID
  * @param botServiceId A bot service ID
  * @return _owner The address that owns the bot service
  * @return _botServiceAddress The address of the bot service
  * @return _data A hash of data associated with the bot service
  * @return _url A URL for the bot service
  */
  function getBotService(uint256 botServiceId) public view returns
  (
    address _owner,
    address _botServiceAddress,
    bytes32 _data,
    bytes32 _url
  ) {
    return getBotEntry(botServiceId);
  }

  /**
  * @dev Creates a new bot service.
  * @param developerId ID for the developer that this bot service will belong to
  * @param botServiceAddress Address of the bot service
  * @param dataHash Hash of data associated with the bot service
  * @param url A URL associated with this bot service
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

  /**
  * @dev Override for BotEntryStorableRegistry.createBotEntry()
  */
  function createBotEntry(
    uint256 developerId, 
    address botServiceAddress, 
    bytes32 dataHash,
    bytes32 url
  )
    public
  {
    require(url != 0x0);
    super.createBotEntry(developerId, botServiceAddress, dataHash, url);
  }

}
