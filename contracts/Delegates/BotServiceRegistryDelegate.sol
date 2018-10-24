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
  * @return IpfsDigest IPFS Digest of the data associated with the bot
  * @return IpfsFnCode IPFS Function Code associated with the bot
  * @return IpfsSize IPFS Digest size associated with the bot
  */
  function getBotService(uint256 botServiceId) public view returns
  (
    address _owner,
    address _botServiceAddress,
    bytes32 IpfsDigest,
    uint8 IpfsFnCode,
    uint8 IpfsSize
  ) {
    return getBotEntry(botServiceId);
  }

  /**
  * @dev Creates a new bot service.
  * @param developerId ID for the developer that this bot service will belong to
  * @param botServiceAddress Address of the bot service
  * @param IpfsDigest IPFS Digest of the data associated with the new bot
  * @param IpfsFnCode IPFS Function Code associated with the new bot
  * @param IpfsSize IPFS Digest size associated with the new bot
  */
  function createBotService(
    uint256 developerId, 
    address botServiceAddress, 
    bytes32 IpfsDigest,
    uint8 IpfsFnCode,
    uint8 IpfsSize
  )
    public 
  {
    createBotEntry(developerId, botServiceAddress, IpfsDigest, IpfsFnCode, IpfsSize);
  }

  /**
  * @dev Override for BotEntryStorableRegistry.createBotEntry()
  */
  function createBotEntry(
    uint256 developerId, 
    address botServiceAddress, 
    bytes32 IpfsDigest,
    uint8 IpfsFnCode,
    uint8 IpfsSize
  )
    public
  {
    super.createBotEntry(developerId, botServiceAddress, IpfsDigest, IpfsFnCode, IpfsSize);
  }

}
