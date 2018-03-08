pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/math/SafeMath.sol';
import "../Registry/OwnableRegistry.sol";
import "../Registry/OwnerRegistry.sol";
import "../Registry/ActivatableRegistry.sol";
import "../Registry/ApprovableRegistry.sol";

/// @dev Non-Fungible token (ERC-721) that handles ownership and transfer
///  of Bots. Bots can be transferred to and from approved developers.
contract BotProductRegistryDelegate is ActivatableRegistry, ApprovableRegistry, OwnableRegistry, OwnerRegistry {
  using SafeMath for uint256;

  event BotProductCreated(uint256 botProductId, uint256 developerId, address developerOwnerAddress, address botProductAddress, bytes32 data);

  function BotProductRegistryDelegate(BaseStorage storage_)
    ActivatableRegistry(storage_)
    ApprovableRegistry(storage_)
    OwnableRegistry(storage_)
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
    _owner = ownerOfEntry(botProductId); 
    _botProductAddress = botProductAddress(botProductId);
    _data = botProductDataHash(botProductId);
  }

  function mintingAllowed(address _minter, uint256 _botProductId) public view returns (bool) {
    uint256 developerId = ownerOf(_botProductId);
    return ownerRegistry().mintingAllowed(_minter, developerId) && ownerOfEntry(_botProductId) == _minter && approvalStatus(_botProductId) == true && active(_botProductId) == true;
  }

  function ownerOfEntry(uint256 _botProductId) public view returns (address) {
    uint256 developerId = ownerOf(_botProductId);
    return ownerRegistry().ownerOfEntry(developerId);
  }

  /// @dev Creates a new bot product.
  /// @param developerId ID of the developer that will own this bot product
  /// @param botProductAddress Address of the bot
  /// @param dataHash Hash of data associated with the bot
  function createBotProduct(uint256 developerId, address botProductAddress, bytes32 dataHash) public {
    require(ownerRegistry().mintingAllowed(msg.sender, developerId));
    require(botProductAddress != 0x0);
    require(dataHash != 0x0);
    require(!botProductAddressExists(botProductAddress));

    uint256 botProductId = totalSupply().add(1);
    _mint(developerId, botProductId);
    setBotProductData(botProductId, botProductAddress, dataHash);
    setBotProductIdForAddress(botProductAddress, botProductId);
    setApprovalStatus(botProductId, true);
    setActiveStatus(botProductId, true);

    BotProductCreated(botProductId, developerId, msg.sender, botProductAddress, dataHash);
  }

  function checkEntryOwnership(uint256 _botProductId) private view returns (bool) {
    return ownerOfEntry(_botProductId) == msg.sender;
  }

  function entryExists(uint256 _botProductId) private view returns (bool) {
    return ownerOfEntry(_botProductId) != 0x0;
  }

  function setBotProductData(uint256 botProductId, address botProductAddress, bytes32 botDataHash) private {
    _storage.setAddress(keccak256("botProductAddresses", botProductId), botProductAddress);
    _storage.setBytes32(keccak256("botProductDataHashes", botProductId), botDataHash);
  }

  function setBotProductIdForAddress(address botProductAddress, uint256 botProductId) private {
    _storage.setUint(keccak256("botProductIdsByAddress", botProductAddress), botProductId);
  }

}
