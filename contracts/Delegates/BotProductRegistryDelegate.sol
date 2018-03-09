pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/math/SafeMath.sol';
import "../Registry/OwnableRegistry.sol";
import "../Registry/OwnerRegistry.sol";
import "../Registry/ActivatableRegistry.sol";
import "../Registry/ApprovableRegistry.sol";
import '../Registry/BotCoinPayableRegistry.sol';

/**
* @title BotProductRegistryDelegate
* @dev Non-Fungible token (ERC-721) that handles ownership and transfer
*  of Bots. Bots can be transferred to and from approved developers.
*/
contract BotProductRegistryDelegate is ActivatableRegistry, ApprovableRegistry, BotCoinPayableRegistry, OwnableRegistry, OwnerRegistry {
  using SafeMath for uint256;

  /**
  * @dev Event for when bot product is created
  * @param botProductId The id of the bot product that the bot instance belongs to  
  * @param developerId An id associated with the developer
  * @param developerOwnerAddress The address that owns the bot product
  * @param botProductAddress An address associated with the bot product
  * @param data Data associated with the bot product
  * @param url A url associated with this bot product
  */
  event BotProductCreated(
    uint256 botProductId, 
    uint256 developerId, 
    address developerOwnerAddress, 
    address botProductAddress, 
    bytes32 data, 
    bytes32 url
  );

  /** @dev Constructor for BotProductRegistryDelegate */
  function BotProductRegistryDelegate(BaseStorage storage_)
    ActivatableRegistry(storage_)
    ApprovableRegistry(storage_)
    BotCoinPayableRegistry(storage_)
    OwnableRegistry(storage_)
    public
    {}

  /**
  * @dev Returns address of bot product
  * @param botProductId The id of the bot product that the bot instance belongs to 
  * @return Returns address corresponding to botProductId
  */
  function botProductAddress(uint256 botProductId) public view returns (address) {
    return _storage.getAddress(keccak256("botProductAddresses", botProductId));
  }

  /**
  * @dev Returns data hash of bot product
  * @param botProductId The id of the bot product that the bot instance belongs to 
  * @return Reutns data hash corresponding to botProductId
  */
  function botProductDataHash(uint256 botProductId) public view returns (bytes32) {
    return _storage.getBytes32(keccak256("botProductDataHashes", botProductId));
  }

  /**
  * @dev Returns bot product url of botProductId 
  * @param botProductId The id of the bot product that the bot instance belongs to 
  * @return Returns url that corresponds to botProductId
  */
  function botProductUrl(uint256 botProductId) public view returns (bytes32) {
    return _storage.getBytes32(keccak256("botProductUrl", botProductId));
  }

  /**
  * @dev Gets id of bot product address
  * @param botProductAddress An address associated with the bot product
  * @return Returns id of bot product corresponding to address
  */
  function botProductIdForAddress(address botProductAddress) public view returns (uint256) {
    return _storage.getUint(keccak256("botProductIdsByAddress", botProductAddress));
  }

  /**
  * @dev Checks if botProductAddress exists
  * @param botProductAddress An address associated with the bot product
  * @return Returns true if botProductAddress exists
  */
  function botProductAddressExists(address botProductAddress) public view returns (bool) {
    return botProductIdForAddress(botProductAddress) > 0;
  }

  /**
  * @dev Returns bot product associated with a bot product id
  * @param botProductId The id of the bot product that the bot instance belongs to
  * @return Returns the owner, botProductAddress, data, and url of the bot product 
  */
  function getBotProduct(uint256 botProductId) public view returns
  (
    address _owner,
    address _botProductAddress,
    bytes32 _data, 
    bytes32 _url
  ) {
    _owner = ownerOfEntry(botProductId); 
    _botProductAddress = botProductAddress(botProductId);
    _data = botProductDataHash(botProductId);
    _url = botProductUrl(botProductId);
  }

  /**
  * @dev Returns address of owner of entry
  * @param _botProductId The id of the bot product that the bot instance belongs to
  * @return Returns address of owner of entry
  */
  function ownerOfEntry(uint256 _botProductId) public view returns (address) {
    uint256 developerId = ownerOf(_botProductId);
    return ownerRegistry().ownerOfEntry(developerId);
  }

  /**
  * @dev Returns true if minting is allowed
  * @param _minter Address of minter
  * @param _botProductId The id of the bot product that the bot instance belongs to
  * @return Returns true if minting is allowed
  */
  function mintingAllowed(address _minter, uint256 _botProductId) public view returns (bool) {
    uint256 developerId = ownerOf(_botProductId);
    return ownerRegistry().mintingAllowed(_minter, developerId) && ownerOfEntry(_botProductId) == _minter && approvalStatus(_botProductId) == true && active(_botProductId) == true;
  }

  /**
  * @dev Creates a new bot product.
  * @param developerId ID of the developer that will own this bot product
  * @param botProductAddress Address of the bot
  * @param dataHash Hash of data associated with the bot
  * @param url A url associated with this bot product
  */
  function createBotProduct(
    uint256 developerId, 
    address botProductAddress, 
    bytes32 dataHash, 
    bytes32 url
  ) public {
    require(ownerRegistry().mintingAllowed(msg.sender, developerId));
    require(botProductAddress != 0x0);
    require(dataHash != 0x0);
    require(!botProductAddressExists(botProductAddress));
    require(url != 0x0);

    uint256 botProductId = totalSupply().add(1);

    transferBotCoin();

    _mint(developerId, botProductId);
    setBotProductData(botProductId, botProductAddress, dataHash);
    setBotProductIdForAddress(botProductAddress, botProductId);
    setBotProductUrl(botProductId, url);
    setApprovalStatus(botProductId, true);
    setActiveStatus(botProductId, true);

    BotProductCreated(botProductId, developerId, msg.sender, botProductAddress, dataHash, url);
  }

  /**
  * @dev Checks if botProductId has entry ownership
  * @param _botProductId The id of the bot product that the bot instance belongs to 
  * @return Returns true if botProductId has entry ownership
  */
  function checkEntryOwnership(uint256 _botProductId) private view returns (bool) {
    return ownerOfEntry(_botProductId) == msg.sender;
  }

  /**
  * @dev Checks if botProductId entry exists
  * @param _botProductId The id of the bot product that the bot instance belongs to 
  * @return Returns true if entry exists for id
  */
  function entryExists(uint256 _botProductId) private view returns (bool) {
    return ownerOfEntry(_botProductId) != 0x0;
  }

  /**
  * @dev Sets bot product data
  * @param botProductId The id of the bot product that the bot instance belongs to 
  * @param botProductAddress An address associated with the bot product
  * @param botDataHash An data hash associated with the bot product
  */
  function setBotProductData(uint256 botProductId, address botProductAddress, bytes32 botDataHash) private {
    _storage.setAddress(keccak256("botProductAddresses", botProductId), botProductAddress);
    _storage.setBytes32(keccak256("botProductDataHashes", botProductId), botDataHash);
  }

  /**
  * @dev Sets bot product id for address
  * param botProductAddress An address associated with the bot product
  * @param botProductId The id of the bot product that the bot instance belongs to 
  */
  function setBotProductIdForAddress(address botProductAddress, uint256 botProductId) private {
    _storage.setUint(keccak256("botProductIdsByAddress", botProductAddress), botProductId);
  }

  /**
  * @dev Sets url of botProductId 
  * @param botProductId The id of the bot product that the bot instance belongs to 
  * @param url An url associated with the bot product
  */
  function setBotProductUrl(uint256 botProductId, bytes32 url) private {
    _storage.setBytes32(keccak256("botProductId", botProductId), url);
  }

}
