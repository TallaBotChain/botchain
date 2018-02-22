pragma solidity ^0.4.18;

import "levelk-upgradability-contracts/contracts/Ownership/OwnableConsumer.sol";
import '../BotOwnershipManager.sol';

/// @title BotChainDelegate
/// @dev Delegate contract for BotChain functionality
contract BotChainDelegate is OwnableConsumer {

  event DeveloperAdded(address developer, bytes32 data);
  event DeveloperUpdated(address developer, bytes32 data);
  event DeveloperApprovalRevoked(address developer);

  function BotChainDelegate(BaseStorage storage_) public OwnableConsumer(storage_) { }

  function getBotOwnershipManager() public view returns (BotOwnershipManager) {
    return BotOwnershipManager(_storage.getAddress("botOwnershipManager"));
  }

  function setBotOwnershipManager(BotOwnershipManager botOwnershipManager) internal {
    _storage.setAddress("botOwnershipManager", botOwnershipManager);
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
  function addDeveloper(address _developer, bytes32 _data) onlyOwner external {
    require(_developer != 0x0);
    require(_data != 0x0);

    setDeveloperApprovalStatus(_developer, true);
    setDeveloperDataHash(_developer, _data);
    pushDeveloper(_developer);

    DeveloperAdded(_developer, _data);
  }

  /// @dev Updates an existing developer. Only callable by owner.
  /// @param _developer The address of the developer to update
  /// @param _data A hash of the data associated with this developer
  function updateDeveloper(address _developer, bytes32 _data) onlyOwner external {
    require(_developer != 0x0);
    require(_data != 0x0);

    setDeveloperDataHash(_developer, _data);

    DeveloperUpdated(_developer, _data);
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
  function createBot(address _botPublicKey, bytes32 _botData) external {
    require(isApprovedDeveloper(msg.sender));
    
    getBotOwnershipManager().createBot(msg.sender, _botPublicKey, _botData);
  }
  
  /// @dev Updates an existing bot.
  /// @param _botPublicKey The public key of the new Bot
  /// @param _botData A hash of the data associated with this Bot
  function updateBot(uint256 _botId, address _botPublicKey, bytes32 _botData) external {
    require(isApprovedDeveloper(msg.sender));
    
    getBotOwnershipManager().updateBot(_botId, _botPublicKey, _botData);
  }

}
