pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/math/SafeMath.sol';
import "../Upgradability/ERC721TokenKeyed.sol";
import "./ActivatableRegistryDelegate.sol";
import "./ApprovableRegistryDelegate.sol";
import './DeveloperRegistryDelegate.sol';

/// @dev Non-Fungible token (ERC-721) that handles ownership and transfer
///  of Bots. Bots can be transferred to and from approved developers.
contract BotProductRegistryDelegate is ActivatableRegistryDelegate, ApprovableRegistryDelegate, ERC721TokenKeyed {
  using SafeMath for uint256;

  event BotProductCreated(uint256 botProductId, address botProductOwner, address botProductAddress, bytes32 data);

  function BotProductRegistryDelegate(BaseStorage storage_)
    ActivatableRegistryDelegate(storage_)
    ApprovableRegistryDelegate(storage_)
    ERC721TokenKeyed(storage_)
    public
  {}

  function developerRegistry() public view returns (DeveloperRegistryDelegate) {
    return DeveloperRegistryDelegate(_storage.getAddress("developerRegistryAddress"));
  }

  function botProductAddress(uint botProductId) public view returns (address) {
    return _storage.getAddress(keccak256("botProductAddresses", botProductId));
  }

  function botProductDataHash(uint botProductId) public view returns (bytes32) {
    return _storage.getBytes32(keccak256("botProductDataHashes", botProductId));
  }

  function botProductIdForAddress(address botProductAddress) public view returns (uint256) {
    return _storage.getUint(keccak256("botProductIdsByAddress", botProductAddress));
  }

  function botProductAddressExists(address botProductAddress) public view returns (bool) {
    return botProductIdForAddress(botProductAddress) > 0;
  }

  function getBotProduct(uint256 botProductId) public view returns
  (
    address _owner,
    address _botProductAddress,
    bytes32 _data
  ) {
    _owner = ownerOf(botProductId);
    _botProductAddress = botProductAddress(botProductId);
    _data = botProductDataHash(botProductId);
  }

  /// @dev Creates a new bot product.
  /// @param botProductAddress Address of the bot
  /// @param dataHash Hash of data associated with the bot
  function createBotProduct(address botProductAddress, bytes32 dataHash) public {
    require(isApprovedDeveloperAddress(msg.sender));
    require(botProductAddress != 0x0);
    require(dataHash != 0x0);
    require(!botProductAddressExists(botProductAddress));

    uint256 botProductId = totalSupply().add(1);
    _mint(msg.sender, botProductId);
    setBotProductData(botProductId, botProductAddress, dataHash);
    setBotProductIdForAddress(botProductAddress, botProductId);
    setApprovalStatus(botProductId, true);
    setActiveStatus(botProductId, true);

    BotProductCreated(botProductId, msg.sender, botProductAddress, dataHash);
  }

  /**
  * @dev Internal function to clear current approval and transfer the ownership of a given bot product ID
  * @param _from address which you want to send a bot product from
  * @param _to address which you want to transfer the bot product to
  * @param _botProductId uint256 ID of the bot product to be transferred
  */
  function clearApprovalAndTransfer(address _from, address _to, uint256 _botProductId) internal {
    require(approvalStatus(_botProductId) == true);
    require(isApprovedDeveloperAddress(_to));
    super.clearApprovalAndTransfer(_from, _to, _botProductId);
  }

  function isApprovedDeveloperAddress(address _developerAddress) private view returns (bool) {
    uint256 developerId = developerRegistry().owns(_developerAddress);
    return developerRegistry().approvalStatus(developerId);
  }

  function checkEntryOwnership(uint256 _entryId) private view returns (bool) {
    return ownerOf(_entryId) == msg.sender;
  }

  function entryExists(uint256 _entryId) private view returns (bool) {
    return ownerOf(_entryId) != 0x0;
  }

  function setBotProductData(uint256 botProductId, address botProductAddress, bytes32 botDataHash) private {
    _storage.setAddress(keccak256("botProductAddresses", botProductId), botProductAddress);
    _storage.setBytes32(keccak256("botProductDataHashes", botProductId), botDataHash);
  }

  function setBotProductIdForAddress(address botProductAddress, uint256 botProductId) private {
    _storage.setUint(keccak256("botProductIdsByAddress", botProductAddress), botProductId);
  }

}
