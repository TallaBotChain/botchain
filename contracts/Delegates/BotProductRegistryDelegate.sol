pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/math/SafeMath.sol';
import "./TokenOwnedRegistry.sol";
import "./ActivatableRegistryDelegate.sol";
import "./ApprovableRegistryDelegate.sol";

/// @dev Non-Fungible token (ERC-721) that handles ownership and transfer
///  of Bots. Bots can be transferred to and from approved developers.
contract BotProductRegistryDelegate is ActivatableRegistryDelegate, ApprovableRegistryDelegate, TokenOwnedRegistry {
  using SafeMath for uint256;

  event BotProductCreated(uint256 botProductId, uint256 developerId, address developerOwnerAddress, address botProductAddress, bytes32 data);

  function BotProductRegistryDelegate(BaseStorage storage_)
    ActivatableRegistryDelegate(storage_)
    ApprovableRegistryDelegate(storage_)
    TokenOwnedRegistry(storage_)
    public
  {}

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
    _owner = ownerAddressOf(botProductId); 
    _botProductAddress = botProductAddress(botProductId);
    _data = botProductDataHash(botProductId);
  }

  /// @dev Creates a new bot product.
  /// @param botProductAddress Address of the bot
  /// @param dataHash Hash of data associated with the bot
  function createBotProduct(address botProductAddress, bytes32 dataHash) public {
    require(ownerRegistry().canMintOwnedEntry(msg.sender));
    require(botProductAddress != 0x0);
    require(dataHash != 0x0);
    require(!botProductAddressExists(botProductAddress));

    uint256 botProductId = totalSupply().add(1);
    uint256 developerId = ownerRegistry().entryForOwner(msg.sender);
    _mint(developerId, botProductId);
    setBotProductData(botProductId, botProductAddress, dataHash);
    setBotProductIdForAddress(botProductAddress, botProductId);
    setApprovalStatus(botProductId, true);
    setActiveStatus(botProductId, true);

    BotProductCreated(botProductId, developerId, msg.sender, botProductAddress, dataHash);
  }

  function checkEntryOwnership(uint256 _botProductId) private view returns (bool) {
    return ownerAddressOf(_botProductId) == msg.sender;
  }

  function entryExists(uint256 _botProductId) private view returns (bool) {
    return ownerAddressOf(_botProductId) != 0x0;
  }

  function setBotProductData(uint256 botProductId, address botProductAddress, bytes32 botDataHash) private {
    _storage.setAddress(keccak256("botProductAddresses", botProductId), botProductAddress);
    _storage.setBytes32(keccak256("botProductDataHashes", botProductId), botDataHash);
  }

  function setBotProductIdForAddress(address botProductAddress, uint256 botProductId) private {
    _storage.setUint(keccak256("botProductIdsByAddress", botProductAddress), botProductId);
  }

}
