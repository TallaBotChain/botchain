pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/math/SafeMath.sol';
import "../Registry/OwnableRegistry.sol";
import "../Registry/ActivatableRegistry.sol";
import "../Registry/ApprovableRegistry.sol";
import '../Registry/BotCoinPayableRegistry.sol';

/**
* @title BotServiceRegistryDelegate
* @dev handles ownership of bot services
*/
contract BotServiceRegistryDelegate is ActivatableRegistry, ApprovableRegistry, BotCoinPayableRegistry, OwnableRegistry {
  using SafeMath for uint256;

  /**
  * @dev Event for when bot service is created
  * @param botServiceId An id associated with the bot service  
  * @param developerId An id associated with the developer
  * @param developerOwnerAddress The address that owns the bot service
  * @param botServiceAddress An address associated with the bot service
  * @param data Data associated with the bot service
  * @param url A url associated with this bot service
  */
  event BotServiceCreated(
    uint256 botServiceId, 
    uint256 developerId, 
    address developerOwnerAddress, 
    address botServiceAddress, 
    bytes32 data, 
    bytes32 url
  );

  /** @dev Constructor for BotServiceRegistryDelegate */
  function BotServiceRegistryDelegate(BaseStorage storage_)
    ActivatableRegistry(storage_)
    ApprovableRegistry(storage_)
    BotCoinPayableRegistry(storage_)
    OwnableRegistry(storage_)
    public
    {}

  /**
  * @dev Returns address of bot service id  
  * @param botServiceId An id associated with the bot service
  * @return Returns address of bot service id   
  */
  function botServiceAddress(uint256 botServiceId) public view returns (address) {
    return _storage.getAddress(keccak256("botServiceAddresses", botServiceId));
  }

  /**
  * @dev Returns dataHash of botServiceId 
  * @param botServiceId An id associated with the bot service
  * @return Returns data hash corresponding to bot service id  
  */
  function botServiceDataHash(uint256 botServiceId) public view returns (bytes32) {
    return _storage.getBytes32(keccak256("botServiceDataHashes", botServiceId));
  }

  /**
  * @dev Returns bot service url of botServiceId 
  * @param botServiceId An id associated with the bot service
  * @return Returns url corresponding to bot service id    
  */
  function botServiceUrl(uint256 botServiceId) public view returns (bytes32) {
    return _storage.getBytes32(keccak256("botServiceUrl", botServiceId));
  }

  /**
  * @dev Returns id of botServiceAddress 
  * @param botServiceAddress An address associated with the bot service
  * @return Returns id corresponding to bot service address    
  */
  function botServiceIdForAddress(address botServiceAddress) public view returns (uint256) {
    return _storage.getUint(keccak256("botServiceIdsByAddress", botServiceAddress));
  }

  /**
  * @dev Checks if botServiceAddress exists
  * @param botServiceAddress An address associated with the bot service
  * @return Returns true if botServiceAddress exists
  */
  function botServiceAddressExists(address botServiceAddress) public view returns (bool) {
    return botServiceIdForAddress(botServiceAddress) > 0;
  }

  /**
  * @dev Returns bot service associated with a bot service id
  * @param botServiceId An id associated with the bot service
  * @return Returns the owner, botInstanceAddress, data, and url of the bot service
  */
  function getBotService(uint256 botServiceId) public view returns
  (
    address _owner,
    address _botServiceAddress,
    bytes32 _data, 
    bytes32 _url
  ) {
    _owner = ownerOfEntry(botServiceId); 
    _botServiceAddress = botServiceAddress(botServiceId);
    _data = botServiceDataHash(botServiceId);
    _url = botServiceUrl(botServiceId);
  }

  /**
  * @dev Returns address of owner of entry
  * @param _botServiceId An id associated with the bot service
  * @return Returns address of owner of entry
  */
  function ownerOfEntry(uint256 _botServiceId) public view returns (address) {
    uint256 developerId = ownerOf(_botServiceId);
    return ownerRegistry().ownerOfEntry(developerId);
  }

  /**
  * @dev Creates a new bot service.
  * @param developerId ID of the developer that will own this bot service
  * @param botServiceAddress Address of the bot service
  * @param dataHash Hash of data associated with the bot service
  * @param url A url associated with this bot service
  */
  function createBotService(
    uint256 developerId, 
    address botServiceAddress, 
    bytes32 dataHash, 
    bytes32 url
  ) public {
    require(ownerRegistry().mintingAllowed(msg.sender, developerId));
    require(botServiceAddress != 0x0);
    require(dataHash != 0x0);
    require(!botServiceAddressExists(botServiceAddress));
    require(url != 0x0);

    uint256 botServiceId = totalSupply().add(1);

    transferBotCoin();

    _mint(developerId, botServiceId);
    setBotServiceData(botServiceId, botServiceAddress, dataHash);
    setBotServiceIdForAddress(botServiceAddress, botServiceId);
    setBotServiceUrl(botServiceId, url);
    setApprovalStatus(botServiceId, true);
    setActiveStatus(botServiceId, true);

    BotServiceCreated(botServiceId, developerId, msg.sender, botServiceAddress, dataHash, url);
  }

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

  /**
  * @dev Sets bot service data
  * @param botServiceId An id associated with the bot service
  * @param botServiceAddress An address associated with the bot service
  * @param botDataHash An data hash associated with the bot service
  */
  function setBotServiceData(uint256 botServiceId, address botServiceAddress, bytes32 botDataHash) private {
    _storage.setAddress(keccak256("botServiceAddresses", botServiceId), botServiceAddress);
    _storage.setBytes32(keccak256("botServiceDataHashes", botServiceId), botDataHash);
  }

  /**
  * @dev Sets bot service id for address
  * @param botServiceAddress An address associated with the bot service
  * @param botServiceId An id associated with the bot service
  */
  function setBotServiceIdForAddress(address botServiceAddress, uint256 botServiceId) private {
    _storage.setUint(keccak256("botServiceIdsByAddress", botServiceAddress), botServiceId);
  }

  /**
  * @dev Sets url of botServiceId 
  * @param botServiceId An id associated with the bot service
  * @param url An url associated with the bot service
  */
  function setBotServiceUrl(uint256 botServiceId, bytes32 url) private {
    _storage.setBytes32(keccak256("botServiceId", botServiceId), url);
  }

}
