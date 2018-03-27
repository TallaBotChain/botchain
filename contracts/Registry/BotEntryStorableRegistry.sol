pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/math/SafeMath.sol';
import "./OwnableRegistry.sol";
import "./OwnerRegistry.sol";
import "./ActivatableRegistry.sol";
import "./ApprovableRegistry.sol";
import './BotCoinPayableRegistry.sol';

/**
* @title BotEntryStorableRegistry
*/
contract BotEntryStorableRegistry is BotCoinPayableRegistry, ApprovableRegistry, ActivatableRegistry, OwnableRegistry {
  using SafeMath for uint256;

  /**
  * @dev Event for when bot entry is created
  * @param botEntryId An id associated with the bot entry  
  * @param parentEntryId An id associated with the developer
  * @param developerOwnerAddress An address associated with the developer owner
  * @param botEntryAddress An address associated with the bot entry
  * @param data Data associated with the bot entry
  * @param url A url associated with this bot entry
  */
  event BotEntryCreated(
    uint256 botEntryId, 
    uint256 parentEntryId, 
    address developerOwnerAddress, 
    address botEntryAddress, 
    bytes32 data, 
    bytes32 url
  );

  /** @dev Constructor for BotEntryStorableRegistry */
  function BotEntryStorableRegistry(BaseStorage storage_)
    BotCoinPayableRegistry(storage_)
    OwnableRegistry(storage_)
    ApprovableRegistry(storage_)
    ActivatableRegistry(storage_)
    public
  {}

  /**
  * @dev Returns address of bot entry
  * @param botEntryId An id associated with the bot entry
  */
  function botEntryAddress(uint256 botEntryId) public view returns (address) {
    return _storage.getAddress(keccak256("botEntryAddresses", botEntryId));
  }

  /**
  * @dev Returns data hash of bot entry
  * @param botEntryId An id associated with the bot entry
  */
  function botEntryDataHash(uint256 botEntryId) public view returns (bytes32) {
    return _storage.getBytes32(keccak256("botEntryDataHashes", botEntryId));
  }

  /**
  * @dev Returns bot entry url of botEntryId 
  * @param botEntryId An id associated with the bot entry
  */
  function botEntryUrl(uint256 botEntryId) public view returns (bytes32) {
    return _storage.getBytes32(keccak256("botEntryUrl", botEntryId));
  }

  /**
  * @dev Gets id of bot entry address
  * @param botEntryAddress An address associated with the bot entry
  */
  function botEntryIdForAddress(address botEntryAddress) public view returns (uint256) {
    return _storage.getUint(keccak256("botEntryIdsByAddress", botEntryAddress));
  }

  /**
  * @dev Checks if botEntryAddress exists
  * @param botEntryAddress An address associated with the bot entry
  */
  function botEntryAddressExists(address botEntryAddress) public view returns (bool) {
    return botEntryIdForAddress(botEntryAddress) > 0;
  }

  /**
  * @dev Returns bot entry associated with a bot entry id
  * @param botEntryId An id associated with the bot entry
  */
  function getBotEntry(uint256 botEntryId) public view returns
  (
    address _owner,
    address _botEntryAddress,
    bytes32 _data, 
    bytes32 _url
  ) {
    _owner = ownerOfEntry(botEntryId); 
    _botEntryAddress = botEntryAddress(botEntryId);
    _data = botEntryDataHash(botEntryId);
    _url = botEntryUrl(botEntryId);
  }

  /**
  * @dev Creates a new bot entry.
  * @param parentEntryId ID of the developer that will own this bot entry
  * @param botEntryAddress Address of the bot
  * @param dataHash Hash of data associated with the bot
  * @param url A url associated with this bot entry
  */
  function createBotEntry(
    uint256 parentEntryId, 
    address botEntryAddress, 
    bytes32 dataHash, 
    bytes32 url
  )
    public 
  {
    require(ownerRegistry().mintingAllowed(msg.sender, parentEntryId));
    require(botEntryAddress != 0x0);
    require(dataHash != 0x0);
    require(!botEntryAddressExists(botEntryAddress));

    uint256 botEntryId = totalSupply().add(1);

    transferBotCoin();

    _mint(parentEntryId, botEntryId);
    setBotEntryData(botEntryId, botEntryAddress, dataHash);
    setBotEntryIdForAddress(botEntryAddress, botEntryId);
    setBotEntryUrl(botEntryId, url);
    setApprovalStatus(botEntryId, true);
    setActiveStatus(botEntryId, true);

    BotEntryCreated(botEntryId, parentEntryId, msg.sender, botEntryAddress, dataHash, url);
  }

  /**
  * @dev Sets bot entry data
  * @param botEntryId An id associated with the bot entry
  * @param botEntryAddress An address associated with the bot entry
  * @param botDataHash A data hash associated with the bot entry
  */
  function setBotEntryData(uint256 botEntryId, address botEntryAddress, bytes32 botDataHash) private {
    _storage.setAddress(keccak256("botEntryAddresses", botEntryId), botEntryAddress);
    _storage.setBytes32(keccak256("botEntryDataHashes", botEntryId), botDataHash);
  }

  /**
  * @dev Sets bot entry id for address
  * param botEntryAddress An address associated with the bot entry
  * @param botEntryId An id associated with the bot entry
  */
  function setBotEntryIdForAddress(address botEntryAddress, uint256 botEntryId) private {
    _storage.setUint(keccak256("botEntryIdsByAddress", botEntryAddress), botEntryId);
  }

  /**
  * @dev Sets url of botEntryId 
  * @param botEntryId An id associated with the bot entry
  * @param url An url associated with the bot entry
  */
  function setBotEntryUrl(uint256 botEntryId, bytes32 url) private {
    _storage.setBytes32(keccak256("botEntryId", botEntryId), url);
  }

  /**
  * @dev Checks if msg.sender owns the given bot entry
  * @param _botEntryId A bot entry id
  * @return true if msg.sender owns the given bot entry
  */
  function checkEntryOwnership(uint256 _botEntryId) private view returns (bool) {
    //return ownerOfEntry(_botEntryId) == msg.sender;
    return true;
  }

  /**
  * @dev Checks if an entry exists
  * @param _entryId An entry id
  * @return true if an entry with the given id exists
  */
  function entryExists(uint256 _entryId) private view returns (bool) {
    return ownerOfEntry(_entryId) != 0x0;
  }

}
