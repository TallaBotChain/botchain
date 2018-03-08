pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/math/SafeMath.sol';
import "./OwnableRegistry.sol";
import "./ActivatableRegistryDelegate.sol";
import "./ApprovableRegistryDelegate.sol";
import './DeveloperRegistryDelegate.sol';

/// @dev Handles ownership of bot services. Bot services are owned by a developer in the developer registry.
contract BotServiceRegistryDelegate is ActivatableRegistryDelegate, ApprovableRegistryDelegate, OwnableRegistry {
  using SafeMath for uint256;

  event BotServiceCreated(uint256 botServiceId, uint256 developerId, address developerOwnerAddress, address botServiceAddress, bytes32 data);

  function BotServiceRegistryDelegate(BaseStorage storage_)
    ActivatableRegistryDelegate(storage_)
    ApprovableRegistryDelegate(storage_)
    OwnableRegistry(storage_)
    public
  {}

  function developerRegistry() public view returns (DeveloperRegistryDelegate) {
    return DeveloperRegistryDelegate(_storage.getAddress("developerRegistryAddress"));
  }

  function botServiceAddress(uint botServiceId) public view returns (address) {
    return _storage.getAddress(keccak256("botServiceAddresses", botServiceId));
  }

  function botServiceDataHash(uint botServiceId) public view returns (bytes32) {
    return _storage.getBytes32(keccak256("botServiceDataHashes", botServiceId));
  }

  function botServiceIdForAddress(address botServiceAddress) public view returns (uint256) {
    return _storage.getUint(keccak256("botServiceIdsByAddress", botServiceAddress));
  }

  function botServiceAddressExists(address botServiceAddress) public view returns (bool) {
    return botServiceIdForAddress(botServiceAddress) > 0;
  }

  function getBotService(uint256 botServiceId) public view returns
  (
    address _owner,
    address _botServiceAddress,
    bytes32 _data
  ) {
    _owner = ownerOfBotService(botServiceId); 
    _botServiceAddress = botServiceAddress(botServiceId);
    _data = botServiceDataHash(botServiceId);
  }

  /// @dev Creates a new bot product.
  /// @param botServiceAddress Address of the bot
  /// @param dataHash Hash of data associated with the bot
  function createBotService(address botServiceAddress, bytes32 dataHash) public {
    require(isApprovedDeveloperAddress(msg.sender));
    require(botServiceAddress != 0x0);
    require(dataHash != 0x0);
    require(!botServiceAddressExists(botServiceAddress));

    uint256 botServiceId = totalSupply().add(1);
    uint256 developerId = developerIdFor(msg.sender);
    _mint(developerId, botServiceId);
    setBotServiceData(botServiceId, botServiceAddress, dataHash);
    setBotServiceIdForAddress(botServiceAddress, botServiceId);
    setApprovalStatus(botServiceId, true);
    setActiveStatus(botServiceId, true);

    BotServiceCreated(botServiceId, developerId, msg.sender, botServiceAddress, dataHash);
  }

  function isApprovedDeveloperAddress(address _developerAddress) private view returns (bool) {
    return isApprovedDeveloperId(developerIdFor(_developerAddress));
  }

  function isApprovedDeveloperId(uint256 _developerId) private view returns (bool) {
    return developerRegistry().approvalStatus(_developerId);
  }

  function developerIdFor(address _developerAddress) private view returns (uint256) {
    return developerRegistry().owns(_developerAddress);
  }

  function ownerOfBotService(uint256 _botServiceId) private view returns (address) {
    uint256 developerId = ownerOf(_botServiceId);
    return developerRegistry().ownerOf(developerId);
  }

  function checkEntryOwnership(uint256 _botServiceId) private view returns (bool) {
    return ownerOfBotService(_botServiceId) == msg.sender;
  }

  function entryExists(uint256 _botServiceId) private view returns (bool) {
    return ownerOfBotService(_botServiceId) != 0x0;
  }

  function setBotServiceData(uint256 botServiceId, address botServiceAddress, bytes32 botDataHash) private {
    _storage.setAddress(keccak256("botServiceAddresses", botServiceId), botServiceAddress);
    _storage.setBytes32(keccak256("botServiceDataHashes", botServiceId), botDataHash);
  }

  function setBotServiceIdForAddress(address botServiceAddress, uint256 botServiceId) private {
    _storage.setUint(keccak256("botServiceIdsByAddress", botServiceAddress), botServiceId);
  }

}
