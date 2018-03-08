pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/math/SafeMath.sol';
import "../Registry/OwnableRegistry.sol";
import "../Registry/ActivatableRegistry.sol";
import "../Registry/ApprovableRegistry.sol";

/// @dev handles ownership of bot services
contract BotServiceRegistryDelegate is ActivatableRegistry, ApprovableRegistry, OwnableRegistry {
  using SafeMath for uint256;

  event BotServiceCreated(uint256 botServiceId, uint256 developerId, address developerOwnerAddress, address botServiceAddress, bytes32 data);

  function BotServiceRegistryDelegate(BaseStorage storage_)
    ActivatableRegistry(storage_)
    ApprovableRegistry(storage_)
    OwnableRegistry(storage_)
    public
  {}

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
    _owner = ownerOfEntry(botServiceId); 
    _botServiceAddress = botServiceAddress(botServiceId);
    _data = botServiceDataHash(botServiceId);
  }

  function ownerOfEntry(uint256 _botServiceId) public view returns (address) {
    uint256 developerId = ownerOf(_botServiceId);
    return ownerRegistry().ownerOfEntry(developerId);
  }

  /// @dev Creates a new bot service.
  /// @param developerId ID of the developer that will own this bot service
  /// @param botServiceAddress Address of the bot service
  /// @param dataHash Hash of data associated with the bot service
  function createBotService(uint256 developerId, address botServiceAddress, bytes32 dataHash) public {
    require(ownerRegistry().mintingAllowed(msg.sender, developerId));
    require(botServiceAddress != 0x0);
    require(dataHash != 0x0);
    require(!botServiceAddressExists(botServiceAddress));

    uint256 botServiceId = totalSupply().add(1);
    _mint(developerId, botServiceId);
    setBotServiceData(botServiceId, botServiceAddress, dataHash);
    setBotServiceIdForAddress(botServiceAddress, botServiceId);
    setApprovalStatus(botServiceId, true);
    setActiveStatus(botServiceId, true);

    BotServiceCreated(botServiceId, developerId, msg.sender, botServiceAddress, dataHash);
  }

  function checkEntryOwnership(uint256 _botServiceId) private view returns (bool) {
    return ownerOfEntry(_botServiceId) == msg.sender;
  }

  function entryExists(uint256 _botServiceId) private view returns (bool) {
    return ownerOfEntry(_botServiceId) != 0x0;
  }

  function setBotServiceData(uint256 botServiceId, address botServiceAddress, bytes32 botDataHash) private {
    _storage.setAddress(keccak256("botServiceAddresses", botServiceId), botServiceAddress);
    _storage.setBytes32(keccak256("botServiceDataHashes", botServiceId), botDataHash);
  }

  function setBotServiceIdForAddress(address botServiceAddress, uint256 botServiceId) private {
    _storage.setUint(keccak256("botServiceIdsByAddress", botServiceAddress), botServiceId);
  }

}
