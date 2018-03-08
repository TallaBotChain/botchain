pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/math/SafeMath.sol';
import "./OwnableRegistry.sol";
import "./ActivatableRegistryDelegate.sol";
import "./ApprovableRegistryDelegate.sol";
import './BotProductRegistryDelegate.sol';

/// @dev Handles ownership of bot services. Bot services are owned by a developer in the developer registry.
contract BotInstanceRegistryDelegate is ActivatableRegistryDelegate, ApprovableRegistryDelegate, OwnableRegistry {
  using SafeMath for uint256;

  event BotInstanceCreated(uint256 botInstanceId, uint256 botProductId, address ownerAddress, address botInstanceAddress, bytes32 data);

  function BotInstanceRegistryDelegate(BaseStorage storage_)
    ActivatableRegistryDelegate(storage_)
    ApprovableRegistryDelegate(storage_)
    OwnableRegistry(storage_)
    public
  {}

  function botProductRegistry() public view returns (BotProductRegistryDelegate) {
    return BotProductRegistryDelegate(_storage.getAddress("botProductRegistry"));
  }

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
    _owner = ownerOfBotInstance(botInstanceId); 
    _botInstanceAddress = botInstanceAddress(botInstanceId);
    _data = botInstanceDataHash(botInstanceId);
  }

  /// @dev Creates a new bot product.
  /// @param botInstanceAddress Address of the bot
  /// @param dataHash Hash of data associated with the bot
  function createBotInstance(address botInstanceAddress, bytes32 dataHash) public {

    // TODO: fix this check
    // require(isApprovedDeveloperAddress(msg.sender));
    require(botInstanceAddress != 0x0);
    require(dataHash != 0x0);
    require(!botInstanceAddressExists(botInstanceAddress));

    uint256 botInstanceId = totalSupply().add(1);

    // TODO: implement minting
    // uint256 botProductId = botProductIdFor(msg.sender);
    // _mint(botProductId, botInstanceId);

    setBotInstanceData(botInstanceId, botInstanceAddress, dataHash);
    setBotInstanceIdForAddress(botInstanceAddress, botInstanceId);
    setApprovalStatus(botInstanceId, true);
    setActiveStatus(botInstanceId, true);

    // BotInstanceCreated(botInstanceId, developerId, msg.sender, botInstanceAddress, dataHash);
  }

  function ownerOfBotInstance(uint256 _botInstanceId) private view returns (address) {
    // TODO: implement
    // uint256 developerId = ownerOf(_botInstanceId);
    // return botProductRegistry().ownerOf(developerId);
  }

  function checkEntryOwnership(uint256 _botInstanceId) private view returns (bool) {
    return ownerOfBotInstance(_botInstanceId) == msg.sender;
  }

  function entryExists(uint256 _botInstanceId) private view returns (bool) {
    return ownerOfBotInstance(_botInstanceId) != 0x0;
  }

  function setBotInstanceData(uint256 botInstanceId, address botInstanceAddress, bytes32 botDataHash) private {
    _storage.setAddress(keccak256("botInstanceAddresses", botInstanceId), botInstanceAddress);
    _storage.setBytes32(keccak256("botInstanceDataHashes", botInstanceId), botDataHash);
  }

  function setBotInstanceIdForAddress(address botInstanceAddress, uint256 botInstanceId) private {
    _storage.setUint(keccak256("botInstanceIdsByAddress", botInstanceAddress), botInstanceId);
  }

}
