pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/math/SafeMath.sol';
import "../Registry/OwnableRegistry.sol";
import "../Registry/ActivatableRegistry.sol";
import "../Registry/ApprovableRegistry.sol";
import './BotProductRegistryDelegate.sol';

/// @dev Handles ownership of bot services. Bot services are owned by a developer in the developer registry.
contract BotInstanceRegistryDelegate is ActivatableRegistry, ApprovableRegistry, OwnableRegistry {
  using SafeMath for uint256;

  event BotInstanceCreated(uint256 botInstanceId, uint256 botProductId, address ownerAddress, address botInstanceAddress, bytes32 data);

  function BotInstanceRegistryDelegate(BaseStorage storage_)
    ActivatableRegistry(storage_)
    ApprovableRegistry(storage_)
    OwnableRegistry(storage_)
    public
  {}

  function botInstanceAddress(uint botInstanceId) public view returns (address) {
    return _storage.getAddress(keccak256("botInstanceAddresses", botInstanceId));
  }

  function botInstanceDataHash(uint botInstanceId) public view returns (bytes32) {
    return _storage.getBytes32(keccak256("botInstanceDataHashes", botInstanceId));
  }

  function botInstanceIdForAddress(address botInstanceAddress) public view returns (uint256) {
    return _storage.getUint(keccak256("botInstanceIdsByAddress", botInstanceAddress));
  }

  function botInstanceAddressExists(address botInstanceAddress) public view returns (bool) {
    return botInstanceIdForAddress(botInstanceAddress) > 0;
  }

  function getBotInstance(uint256 botInstanceId) public view returns
  (
    address _owner,
    address _botInstanceAddress,
    bytes32 _data
  ) {
    _owner = ownerOfEntry(botInstanceId); 
    _botInstanceAddress = botInstanceAddress(botInstanceId);
    _data = botInstanceDataHash(botInstanceId);
  }

  /// @dev Creates a new bot product.
  /// @param botProductId ID of the bot product that will own this bot instance
  /// @param botInstanceAddress Address of the bot
  /// @param dataHash Hash of data associated with the bot
  function createBotInstance(uint256 botProductId, address botInstanceAddress, bytes32 dataHash) public {
    require(ownerRegistry().mintingAllowed(msg.sender, botProductId));
    require(botInstanceAddress != 0x0);
    require(dataHash != 0x0);
    require(!botInstanceAddressExists(botInstanceAddress));

    uint256 botInstanceId = totalSupply().add(1);
    _mint(botProductId, botInstanceId);

    setBotInstanceData(botInstanceId, botInstanceAddress, dataHash);
    setBotInstanceIdForAddress(botInstanceAddress, botInstanceId);
    setApprovalStatus(botInstanceId, true);
    setActiveStatus(botInstanceId, true);

    BotInstanceCreated(botInstanceId, botProductId, msg.sender, botInstanceAddress, dataHash);
  }

  function ownerOfEntry(uint256 _botInstanceId) public view returns (address) {
    uint256 botProductId = ownerOf(_botInstanceId);
    return ownerRegistry().ownerOfEntry(botProductId);
  }

  function checkEntryOwnership(uint256 _botInstanceId) private view returns (bool) {
    ownerOfEntry(_botInstanceId) == msg.sender;
  }

  function entryExists(uint256 _botInstanceId) private view returns (bool) {
    return ownerOf(_botInstanceId) > 0;
  }

  function setBotInstanceData(uint256 botInstanceId, address botInstanceAddress, bytes32 botDataHash) private {
    _storage.setAddress(keccak256("botInstanceAddresses", botInstanceId), botInstanceAddress);
    _storage.setBytes32(keccak256("botInstanceDataHashes", botInstanceId), botDataHash);
  }

  function setBotInstanceIdForAddress(address botInstanceAddress, uint256 botInstanceId) private {
    _storage.setUint(keccak256("botInstanceIdsByAddress", botInstanceAddress), botInstanceId);
  }

}
