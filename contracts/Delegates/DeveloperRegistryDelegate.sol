pragma solidity ^0.4.18;

import "levelk-upgradability-contracts/contracts/Implementations/ownership/OwnableKeyed.sol";
import './BotProductRegistryDelegate.sol';

/// @title DeveloperRegistryDelegate
/// @dev Delegate contract for DeveloperRegistry functionality
contract DeveloperRegistryDelegate is OwnableKeyed {

  //use bytes32 for url and offload conversion chores to front-ends
  event DeveloperAdded(address developer, bytes32 data, bytes32 url);
  event DeveloperUpdated(address developer, bytes32 data, bytes32 url);
  event DeveloperApprovalRevoked(address developer);

  function DeveloperRegistryDelegate(BaseStorage storage_) public OwnableKeyed(storage_) { }

  function getBotProductProductRegistry() public view returns (BotProductRegistryDelegate) {
    return BotProductRegistryDelegate(_storage.getAddress("botProductRegistry"));
  }

  function setBotProductRegistry(BotProductRegistryDelegate botProductRegistry) internal {
    _storage.setAddress("botProductRegistry", botProductRegistry);
  }

  function setDeveloperApprovalStatus(address developer, bool approvalStatus) internal {
    _storage.setBool(keccak256("developerApprovalStatus", developer), approvalStatus);
  }

  function getDeveloperApprovalStatus(address developer) public view returns (bool) {
    return _storage.getBool(keccak256("developerApprovalStatus", developer));
  }

  function setDeveloperDataHash(address developer, bytes32 dataHash) internal {
    _storage.setBytes32(keccak256("developerDataHash", developer), dataHash);
  }

  function getDeveloperDataHash(address developer) public view returns (bytes32) {
    return _storage.getBytes32(keccak256("developerDataHash", developer));
  }

  function setDeveloperUrl(address developer, bytes32 url) internal {
    _storage.setBytes32(keccak256("developerUrl", developer), url);
  }

  function getDeveloperUrl(address developer) public view returns (bytes32) {
    return _storage.getBytes32(keccak256("developerUrl", developer));
  }

  function getDeveloperCount() public view returns (uint) {
    return _storage.getUint("developerCount");
  }

  function incrementDeveloperCount() internal {
    _storage.setUint("developerCount", getDeveloperCount() + 1);
  }

  function pushDeveloper(address developerAddress) internal {
    _storage.setAddress(keccak256("developers", getDeveloperCount()), developerAddress);
    incrementDeveloperCount();
  }

  function getDeveloper(uint developerIndex) public view returns (address) {
    return _storage.getAddress(keccak256("developers", developerIndex));
  }

  /// @dev Checks if a developer is approved
  /// @param _developer Address of developer to check for approval
  function isApprovedDeveloper(address _developer) public returns (bool) {
    return getDeveloperApprovalStatus(_developer);
  }

  /// @dev Adds a new developer. Only callable by owner.
  /// @param _developer The address of the developer to add
  /// @param _data A hash of the data associated with this developer
  /// @param _url A url associated with this developer
  function addDeveloper(address _developer, bytes32 _data, bytes32 _url) onlyOwner external {
    require(_developer != 0x0);
    require(_data != 0x0);
    require(_url != 0x0);

    setDeveloperApprovalStatus(_developer, true);
    setDeveloperDataHash(_developer, _data);
    setDeveloperUrl(_developer, _url);
    pushDeveloper(_developer);

    DeveloperAdded(_developer, _data, _url);
  }

  /// @dev Updates an existing developer. Only callable by owner.
  /// @param _developer The address of the developer to update
  /// @param _data A hash of the data associated with this developer
  /// @param _url A url associated with this developer
  function updateDeveloper(address _developer, bytes32 _data, bytes32 _url) onlyOwner external {
    require(_developer != 0x0);
    require(_data != 0x0);
    require(_url != 0x0);

    setDeveloperDataHash(_developer, _data);
    setDeveloperUrl(_developer, _url);

    DeveloperUpdated(_developer, _data, _url);
  }

  /// @dev Revokes approval for an existing developer. Only callable by owner.
  /// @param _developer The address of the developer to revoke approval for.
  function revokeDeveloperApproval(address _developer) onlyOwner external {
    require(getDeveloperApprovalStatus(_developer));

    setDeveloperApprovalStatus(_developer, false);

    DeveloperApprovalRevoked(_developer);
  }
  
  /// @dev Creates a new bot. The new bot is owned by msg.sender, which needs
  ///  to be an approved developer.
  /// @param _botPublicKey The public key of the new Bot
  /// @param _botData A hash of the data associated with this Bot
  function createBotProduct(address _botPublicKey, bytes32 _botData) external {
    require(isApprovedDeveloper(msg.sender));
    
    getBotProductProductRegistry().createBotProduct(msg.sender, _botPublicKey, _botData);
  }
  
  /// @dev Updates an existing bot.
  /// @param _botPublicKey The public key of the new Bot
  /// @param _botData A hash of the data associated with this Bot
  function updateBotProduct(uint256 _botProductId, address _botPublicKey, bytes32 _botData) external {
    require(isApprovedDeveloper(msg.sender));
    
    getBotProductProductRegistry().updateBotProduct(_botProductId, _botPublicKey, _botData);
  }

}
