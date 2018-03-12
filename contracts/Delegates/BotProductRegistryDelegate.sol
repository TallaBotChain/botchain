pragma solidity ^0.4.18;

import "../Registry/BotEntryStorableRegistry.sol";
import "../Registry/OwnerRegistry.sol";

/**
 * @title BotProductRegistryDelegate
 * @dev Delegate contract for functionality that handles ownership of bot products.
 *  Bot products belong to a developer. Bot instances can be minted for a bot product.
 *  Ownership of a bot product is determined by the developer that the bot product belongs to.
 */
contract BotProductRegistryDelegate is BotEntryStorableRegistry, OwnerRegistry {

  string public constant name = "BotProductRegistry";

  /**
  * @dev Constructor for BotProductRegistryDelegate
  * @param storage_ address of a BaseStorage contract
  */
  function BotProductRegistryDelegate(BaseStorage storage_)
    BotEntryStorableRegistry(storage_)
    public
  {}

  /**
  * @dev Returns bot product data for the given bot product ID
  * @param botProductId A bot product ID
  * @return _owner The address that owns the bot product
  * @return _botEntryAddress The address of the bot product
  * @return _data A hash of data associated with the bot product
  * @return _url A URL for the bot product
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
  * @param url A URL associated with this bot product
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
  * @dev Returns true if the given address is allowed to mint bot instances under the
  *  given bot product ID. Implementation for OwnerRegistry abstract.
  * @param _minter Address of minter
  * @param _botProductId A bot product ID
  * @return True if minting is allowed
  */
  function mintingAllowed(address _minter, uint256 _botProductId) public view returns (bool) {
    uint256 developerId = ownerOf(_botProductId);
    return ownerRegistry().mintingAllowed(_minter, developerId) && ownerOfEntry(_botProductId) == _minter && approvalStatus(_botProductId) == true && active(_botProductId) == true;
  }

}
