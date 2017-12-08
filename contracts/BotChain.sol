pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/ownership/Ownable.sol';
import './BotOwnershipManager.sol';

/// @title BotChain
/// @dev Contract for managing ownership of BotChain resources
contract BotChain is Ownable {

  /// @dev The address of the BotOwnershipManager contract (ERC-721 implementation)
  ///  that handles ownership and transfer of Bots.
  BotOwnershipManager public botOwnershipManager;

  /// @dev A mapping of developer addresses to a boolean that is `true` if
  ///  the developer is approved, and `false` if not.
  mapping(address => bool) public developerToApproved;

  /// @dev A mapping of developer addresses to a hash of related data.
  mapping(address => bytes) public developerToData;

  /// @dev An array of developer addresses.
  address[] public developers;

  /// @dev Constructor for BotChain contracts. Creates a new BotOwnershipManager contract,
  ///  which it owns by default.
  function BotChain() public {
    botOwnershipManager = new BotOwnershipManager();
  }

  /// @dev Adds a new developer. Only callable by owner.
  /// @param _developer The address of the developer to add
  /// @param _data A hash of the data associated with this developer
  function addDeveloper(address _developer, bytes _data) onlyOwner public {
    //
  }

  /// @dev Updates an existing developer. Only callable by owner.
  /// @param _developer The address of the developer to update
  /// @param _data A hash of the data associated with this developer
  function updateDeveloper(address _developer, bytes _data) onlyOwner public {
    //
  }

  /// @dev Revokes approval for an existing developer. Only callable by owner.
  /// @param _developer The address of the developer to revoke approval for.
  function revokeDeveloperApproval(address _developer) onlyOwner public {
    //
  }
  
  /// @dev Creates a new bot. The new bot is owned by msg.sender, which needs
  ///  to be an approved developer.
  /// @param _botPublicKey The public key of the new Bot
  /// @param _botData A hash of the data associated with this Bot
  function createBot(address _botPublicKey, bytes _botData) public {
    require(isApprovedDeveloper(msg.sender));
    botOwnershipManager.createBot(msg.sender, _botPublicKey, _botData);
  }
  
  /// @dev Creates a new bot. The new bot is owned by msg.sender, which needs
  ///  to be an approved developer.
  /// @param _botPublicKey The public key of the new Bot
  /// @param _botData A hash of the data associated with this Bot
  function updateBot(address _botPublicKey, bytes _botData) public {
    require(isApprovedDeveloper(msg.sender));
    botOwnershipManager.updateBot(_botPublicKey, _botData);
  }

  /// @dev Checks if a developer is approved
  /// @param _developer Address of developer to check for approval
  function isApprovedDeveloper(address _developer) public returns(bool) {
    return developerToApproved[msg.sender] == true;
  }
}
