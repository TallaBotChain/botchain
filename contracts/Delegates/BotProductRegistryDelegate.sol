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
