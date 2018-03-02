pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/math/SafeMath.sol';
import "levelk-upgradability-contracts/contracts/Implementations/ownership/OwnableKeyed.sol";
import "levelk-upgradability-contracts/contracts/Implementations/token/ERC721/ERC721TokenKeyed.sol";
import './DeveloperRegistryDelegate.sol';

/// @dev Non-Fungible token (ERC-721) that handles ownership and transfer
///  of Bots. Bots can be transferred to and from approved developers.
contract BotProductRegistryDelegate is ERC721TokenKeyed, OwnableKeyed {
  using SafeMath for uint256;

  event BotProductCreated(uint256 botProductId, address botProductOwner, address botProductAddress, bytes32 data);
  event BotProductDisabled(uint256 botProductId);
  event BotProductEnabled(uint256 botProductId);

  function BotProductRegistryDelegate(BaseStorage storage_)
    OwnableKeyed(storage_)
    ERC721TokenKeyed(storage_)
    public
  {}

  function developerRegistry() public view returns (DeveloperRegistryDelegate) {
    return DeveloperRegistryDelegate(_storage.getAddress("developerRegistryAddress"));
  }
  
  function getBotProductDisabledStatus(uint256 botProductId) public view returns (bool) {
    return _storage.getBool(keccak256("botDisabledStatuses", botProductId));
  }

  function getBotProductAddress(uint botProductId) public view returns (address) {
    return _storage.getAddress(keccak256("botProductAddresses", botProductId));
  }

  function getBotProductDataHash(uint botProductId) public view returns (bytes32) {
    return _storage.getBytes32(keccak256("botProductDataHashes", botProductId));
  }

  /// @dev Returns true if the given bot product is enabled
  /// @param botProductId The ID of the bot product to check
  function botProductIsEnabled(uint256 botProductId) public view returns (bool) {
    require(botProductId > 0);
    require(super.ownerOf(botProductId) != 0x0);
    return getBotProductDisabledStatus(botProductId) == false;
  }

  function getBotProductIdForAddress(address botProductAddress) public view returns (uint256) {
    return _storage.getUint(keccak256("botProductIdsByAddress", botProductAddress));
  }

  function botProductAddressExists(address botProductAddress) public view returns (bool) {
    return getBotProductIdForAddress(botProductAddress) > 0;
  }

  function getBotProduct(uint256 botProductId) public view returns
  (
    address owner,
    address botProductAddress,
    bytes32 data
  ) {
    owner = super.ownerOf(botProductId);
    botProductAddress = getBotProductAddress(botProductId);
    data = getBotProductDataHash(botProductId);
  }

  /// @dev Creates a new bot product.
  /// @param owner Address of the developer who owns the bot
  /// @param botProductAddress Address of the bot
  /// @param dataHash Hash of data associated with the bot
  function createBotProduct(address owner, address botProductAddress, bytes32 dataHash) onlyOwner public {
    require(owner != 0x0);
    require(botProductAddress != 0x0);
    require(dataHash != 0x0);
    require(!botProductAddressExists(botProductAddress));

    uint256 botProductId = super.totalSupply().add(1);
    super._mint(owner, botProductId);
    setBotProductData(botProductId, botProductAddress, dataHash);
    setBotProductIdForAddress(botProductAddress, botProductId);

    BotProductCreated(botProductId, owner, botProductAddress, dataHash);
  }

  /// @dev Disables a bot product. Disabled bot products cannot be transferred.
  ///      When a bot is created, it is enabled by default.
  /// @param botProductId The ID of the bot to disable.
  function disableBotProduct(uint256 botProductId) onlyOwner public {
    require(super.ownerOf(botProductId) != 0x0);
    require(botProductIsEnabled(botProductId));

    setBotProductDisabledStatus(botProductId, true);

    BotProductDisabled(botProductId);
  }

  /// @dev Enables a bot product.
  /// @param botProductId The ID of the bot to enable.
  function enableBotProduct(uint256 botProductId) onlyOwner public {
    require(super.ownerOf(botProductId) != 0x0);
    require(!botProductIsEnabled(botProductId));

    setBotProductDisabledStatus(botProductId, false);

    BotProductEnabled(botProductId);
  }

  function setBotProductData(uint256 botProductId, address botProductAddress, bytes32 botDataHash) private {
    _storage.setAddress(keccak256("botProductAddresses", botProductId), botProductAddress);
    _storage.setBytes32(keccak256("botProductDataHashes", botProductId), botDataHash);
  }

  function setBotProductDisabledStatus(uint256 botProductId, bool disabled) private {
    _storage.setBool(keccak256("botDisabledStatuses", botProductId), disabled);
  }

  function setBotProductIdForAddress(address botProductAddress, uint256 botProductId) private {
    _storage.setUint(keccak256("botProductIdsByAddress", botProductAddress), botProductId);
  }

}
