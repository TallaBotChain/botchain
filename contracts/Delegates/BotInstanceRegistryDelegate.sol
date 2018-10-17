pragma solidity ^0.4.18;

import "../Registry/BotEntryStorableRegistry.sol";

/**
 * @title BotInstanceRegistryDelegate
 * @dev Delegate contract for functionality that handles ownership of bot instances.
 *  Bot instances belong to a bot product. Ownership of a bot instance is determined
 *  by the developer that owns the bot product that the instance belongs to.
 */
contract BotInstanceRegistryDelegate is BotEntryStorableRegistry {

  string public constant name = "BotInstanceRegistry";

  /**
  * @dev Constructor for BotInstanceRegistryDelegate
  * @param storage_ address of a BaseStorage contract
  */
  function BotInstanceRegistryDelegate(BaseStorage storage_)
    BotEntryStorableRegistry(storage_)
    public
  {}

  /**
  * @dev Returns bot instance data for a given bot instance ID
  * @param botInstanceId ID of the bot instance
  * @return _owner The address that owns the bot instance
  * @return IpfsDigest IPFS Digest of the data associated with the bot
  * @return IpfsFnCode IPFS Function Code associated with the bot
  * @return IpfsSize IPFS Digest size associated with the bot
  */
  function getBotInstance(uint256 botInstanceId) public view returns
  (
    address _owner,
    address _botEntryAddress,
    bytes32 _digest,
    uint8 _fnCode, 
    uint8 _size
  ) {
    return getBotEntry(botInstanceId);
  }

  /**
  * @dev Creates a new bot instance.
  * @param botProductId ID of the bot product that will own this bot instance
  * @param botInstanceAddress Address of the bot instance
  * @param IpfsDigest IPFS Digest of the data associated with the new bot
  * @param IpfsFnCode IPFS Function Code associated with the new bot
  * @param IpfsSize IPFS Digest size associated with the new bot
  */
  function createBotInstance(
    uint256 botProductId, 
    address botInstanceAddress, 
    bytes32 IpfsDigest,
    uint8 IpfsFnCode,
    uint8 IpfsSize
  )
    public 
  {
    createBotEntry(botProductId, botInstanceAddress, IpfsDigest, IpfsFnCode, IpfsSize);
  }

}
