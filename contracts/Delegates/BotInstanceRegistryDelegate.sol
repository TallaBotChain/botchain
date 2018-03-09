pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/math/SafeMath.sol';
import "../Registry/OwnableRegistry.sol";
import "../Registry/ActivatableRegistry.sol";
import "../Registry/ApprovableRegistry.sol";
import '../Registry/BotCoinPayableRegistry.sol';
import './BotProductRegistryDelegate.sol';

/**
 * @title BotInstanceRegistryDelegate
 * @dev Handles ownership of bot services. Bot services are owned by a developer in the developer registry.
 */
contract BotInstanceRegistryDelegate is ActivatableRegistry, ApprovableRegistry, BotCoinPayableRegistry, OwnableRegistry {
  using SafeMath for uint256;

  /**
  * @dev Event for when bot instance is created
  * @param botInstanceId An id associated with the bot instance 
  * @param botProductId An id associated with the bot product
  * @param ownerAddress The address that owns the bot instance
  * @param botInstanceAddress An address associated with the bot instance
  * @param data Data associated with the bot instance
  * @param url A url associated with this bot instance
  */
  event BotInstanceCreated(
    uint256 botInstanceId, 
    uint256 botProductId, 
    address ownerAddress, 
    address botInstanceAddress, 
    bytes32 data, 
    bytes32 url
  );

  /** @dev Constructor for BotInstanceRegistryDelegate */
  function BotInstanceRegistryDelegate(BaseStorage storage_)
    ActivatableRegistry(storage_)
    ApprovableRegistry(storage_)
    BotCoinPayableRegistry(storage_)
    OwnableRegistry(storage_)
    public
    {}

  /**
  * @dev Returns address of bot instance
  * @param botInstanceId An id associated with the bot instance
  */
  function botInstanceAddress(uint256 botInstanceId) public view returns (address) {
    return _storage.getAddress(keccak256("botInstanceAddresses", botInstanceId));
  }

  /**
  * @dev Returns data hash of bot instance
  * @param botInstanceId An id associated with the bot instance
  */
  function botInstanceDataHash(uint256 botInstanceId) public view returns (bytes32) {
    return _storage.getBytes32(keccak256("botInstanceDataHashes", botInstanceId));
  }

  /**
  * @dev Returns bot instance url of botInstanceId 
  * @param botInstanceId An id associated with the bot instance
  */
  function botInstanceUrl(uint256 botInstanceId) public view returns (bytes32) {
    return _storage.getBytes32(keccak256("botInstanceUrl", botInstanceId));
  }

  /**
  * @dev Gets id of bot instance address
  * @param botInstanceAddress An address associated with the bot instance
  */
  function botInstanceIdForAddress(address botInstanceAddress) public view returns (uint256) {
    return _storage.getUint(keccak256("botInstanceIdsByAddress", botInstanceAddress));
  }

  /**
  * @dev Checks if botInstanceAddress exists
  * @param botInstanceAddress An address associated with the bot instance
  */
  function botInstanceAddressExists(address botInstanceAddress) public view returns (bool) {
    return botInstanceIdForAddress(botInstanceAddress) > 0;
  }

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
    _owner = ownerOfEntry(botInstanceId); 
    _botInstanceAddress = botInstanceAddress(botInstanceId);
    _data = botInstanceDataHash(botInstanceId);
    _url = botInstanceUrl(botInstanceId);
  }

  /**
  * @dev Creates a new bot instance.
  * @param botProductId ID of the bot product that will own this bot instance
  * @param botInstanceAddress Address of the bot
  * @param dataHash Hash of data associated with the bot
  * @param url A url associated with this bot instance - NOT required
  */
  function createBotInstance(
    uint256 botProductId, 
    address botInstanceAddress, 
    bytes32 dataHash, 
    bytes32 url
  ) public {
    require(ownerRegistry().mintingAllowed(msg.sender, botProductId));
    require(botInstanceAddress != 0x0);
    require(dataHash != 0x0);
    require(!botInstanceAddressExists(botInstanceAddress));

    uint256 botInstanceId = totalSupply().add(1);

    transferBotCoin();

    _mint(botProductId, botInstanceId);

    setBotInstanceData(botInstanceId, botInstanceAddress, dataHash);
    setBotInstanceIdForAddress(botInstanceAddress, botInstanceId);
    setBotInstanceUrl(botInstanceId, url);
    setApprovalStatus(botInstanceId, true);
    setActiveStatus(botInstanceId, true);

    BotInstanceCreated(botInstanceId, botProductId, msg.sender, botInstanceAddress, dataHash, url);
  }

  /**
  * @dev Returns address of owner of entry
  * @param _botInstanceId An id associated with the bot instance
  */
  function ownerOfEntry(uint256 _botInstanceId) public view returns (address) {
    uint256 botProductId = ownerOf(_botInstanceId);
    return ownerRegistry().ownerOfEntry(botProductId);
  }

  /**
  * @dev Checks if botInstanceId has entry ownership
  * @param _botInstanceId An id associated with the bot instance
  */
  function checkEntryOwnership(uint256 _botInstanceId) private view returns (bool) {
    ownerOfEntry(_botInstanceId) == msg.sender;
  }

  /**
  * @dev Checks if botInstanceId entry exists
  * @param _botInstanceId An id associated with the bot instance
  */
  function entryExists(uint256 _botInstanceId) private view returns (bool) {
    return ownerOf(_botInstanceId) > 0;
  }

  /**
  * @dev Sets bot instance data
  * @param botInstanceId An id associated with the bot instance
  * @param botInstanceAddress An address associated with the bot instance
  * @param botDataHash An data hash associated with the bot instance
  */
  function setBotInstanceData(uint256 botInstanceId, address botInstanceAddress, bytes32 botDataHash) private {
    _storage.setAddress(keccak256("botInstanceAddresses", botInstanceId), botInstanceAddress);
    _storage.setBytes32(keccak256("botInstanceDataHashes", botInstanceId), botDataHash);
  }

  /**
  * @dev Sets bot instance id for address
  * @param botInstanceAddress An address associated with the bot instance
  * @param botInstanceId An id associated with the bot instance
  */
  function setBotInstanceIdForAddress(address botInstanceAddress, uint256 botInstanceId) private {
    _storage.setUint(keccak256("botInstanceIdsByAddress", botInstanceAddress), botInstanceId);
  }

  /**
  * @dev Sets url of botInstanceId 
  * @param botInstanceId An id associated with the bot instance
  * @param url An url associated with the bot instance
  */
  function setBotInstanceUrl(uint256 botInstanceId, bytes32 url) private {
    _storage.setBytes32(keccak256("botInstanceId", botInstanceId), url);
  }
}
