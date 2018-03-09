pragma solidity ^0.4.18;

import "../Registry/BotEntryStorableRegistry.sol";
import "../Registry/OwnerRegistry.sol";

/**
* @title BotProductRegistryDelegate
* @dev Non-Fungible token (ERC-721) that handles ownership and transfer
*  of Bots. Bots can be transferred to and from approved developers.
*/
contract BotProductRegistryDelegate is BotEntryStorableRegistry, OwnerRegistry {

  string public constant name = "BotProductRegistry";

  /** @dev Constructor for BotProductRegistryDelegate */
  function BotProductRegistryDelegate(BaseStorage storage_)
    BotEntryStorableRegistry(storage_)
    public
  {}

  /**
  * @dev Returns bot product associated with a bot product id
  * @param botProductId An id associated with the bot product
  */
  function getBotProduct(uint256 botProductId) public view returns
  (
    address _owner,
    address _botEntryAddress,
    bytes32 _data, 
    bytes32 _url
  ) {
    return getBotEntry(botProductId);
  }

  /**
  * @dev Creates a new bot product.
  * @param developerId ID of the developer that will own this bot product
  * @param botProductAddress Address of the bot product
  * @param dataHash Hash of data associated with the bot product
  * @param url A url associated with this bot product
  */
  function createBotProduct(
    uint256 developerId, 
    address botProductAddress, 
    bytes32 dataHash, 
    bytes32 url
  )
    public 
  {
    createBotEntry(developerId, botProductAddress, dataHash, url);
  }

  /**
  * @dev Override for BotEntryStorableRegistry.createBotEntry()
  */
  function createBotEntry(
    uint256 developerId, 
    address botProductAddress, 
    bytes32 dataHash,
    bytes32 url
  )
    public
  {
    require(url != 0x0);
    super.createBotEntry(developerId, botProductAddress, dataHash, url);
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

}
