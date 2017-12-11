pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/ownership/Ownable.sol';
import './BotOwnershipManager.sol';

/// @title BotChain
/// @dev Contract for managing ownership of BotChain resources
contract BotChain is Ownable {

  event DeveloperAdded(address developer, bytes32 data);
  event DeveloperUpdated(address developer, bytes32 data);
  event DeveloperApprovalRevoked(address developer);

  /// @dev The address of the BotOwnershipManager contract (ERC-721 implementation)
  ///  that handles ownership and transfer of Bots.
  BotOwnershipManager public botOwnershipManager;

  /// @dev A mapping of developer addresses to a boolean that is `true` if
  ///  the developer is approved, and `false` if not.
  mapping(address => bool) public developerToApproved;

  /// @dev A mapping of developer addresses to a hash of related data.
  mapping(address => bytes32) public developerToData;

  /// @dev An array of developer addresses.
  address[] public developers;

  /// @dev Constructor for BotChain contracts. Creates a new BotOwnershipManager contract,
  ///  which it owns by default.
  function BotChain() public {
    botOwnershipManager = new BotOwnershipManager();
    developers.push(0x0);
  }

  /// @dev Checks if a developer is approved
  /// @param _developer Address of developer to check for approval
  function isApprovedDeveloper(address _developer) public returns(bool) {
    return developerToApproved[_developer] == true;
  }

  /// @dev Adds a new developer. Only callable by owner.
  /// @param _developer The address of the developer to add
  /// @param _data A hash of the data associated with this developer
  function addDeveloper(address _developer, bytes32 _data) onlyOwner external {
    require(_developer != 0x0);
    require(_data != 0x0);

    developerToApproved[_developer] = true;
    developerToData[_developer] = _data;
    developers.push(_developer);

    DeveloperAdded(_developer, _data);
  }

  /// @dev Updates an existing developer. Only callable by owner.
  /// @param _developer The address of the developer to update
  /// @param _data A hash of the data associated with this developer
  function updateDeveloper(address _developer, bytes32 _data) onlyOwner external {
    require(_developer != 0x0);
    require(_data != 0x0);

    developerToData[_developer] = _data;

    DeveloperUpdated(_developer, _data);
  }

  /// @dev Revokes approval for an existing developer. Only callable by owner.
  /// @param _developer The address of the developer to revoke approval for.
  function revokeDeveloperApproval(address _developer) onlyOwner external {
    require(developerToApproved[_developer]);

    developerToApproved[_developer] = false;

    DeveloperApprovalRevoked(_developer);
  }
  
  /// @dev Creates a new bot. The new bot is owned by msg.sender, which needs
  ///  to be an approved developer.
  /// @param _botPublicKey The public key of the new Bot
  /// @param _botData A hash of the data associated with this Bot
  function createBot(address _botPublicKey, bytes _botData) external {
    require(isApprovedDeveloper(msg.sender));
    botOwnershipManager.createBot(msg.sender, _botPublicKey, _botData);
  }
  
  /// @dev Creates a new bot. The new bot is owned by msg.sender, which needs
  ///  to be an approved developer.
  /// @param _botPublicKey The public key of the new Bot
  /// @param _botData A hash of the data associated with this Bot
  function updateBot(address _botPublicKey, bytes _botData) external {
    require(isApprovedDeveloper(msg.sender));
    botOwnershipManager.updateBot(_botPublicKey, _botData);
  }

}
