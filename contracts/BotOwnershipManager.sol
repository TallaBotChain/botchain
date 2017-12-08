pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/lifecycle/Pausable.sol';
import './ERC721.sol';

/// @dev Non-Fungible token (ERC-721) that handles ownership and transfer
///  of Bots. Bots can be transferred to and from approved developers.
contract BotOwnershipManager is Pausable, ERC721 {

  /// @dev A mapping from owner address to count of tokens that address owns.
  ///  Used internally inside balanceOf() to resolve ownership count.
  mapping(address => uint256) ownershipCount;
  
  /// @dev A mapping from Bot index to Bot owner address
  mapping(uint256 => address) public botIndexToOwner;

  /// @dev A mapping from Bot public keys to bot index
  mapping(address => uint256) public botPublicKeyToIndex;

  /// @dev A mapping from Bot index to an address approved or transfer.
  mapping(uint256 => address) public botIndexToApproved;

  Bot[] bots;

  struct Bot {
    /// @dev Address (public key) of the bot. Used for off-chain verification.
    address publicKey;

    /// @dev A hash of data associated with the Bot
    bytes data;
  }

  /// @dev Creates a new bot. 
  function createBot(address _botOwner, address _botPublicKey, bytes _data) onlyOwner public returns(uint) {
    // TODO: require checks for valid data

    Bot memory _bot = Bot({
      publicKey: _botPublicKey,
      data: _data
    }); 
    
    // TODO: bot array 0 should be invalid. needs to start at 1 in order to do require
    // checks properly
    
    uint256 newBotId = bots.push(_bot) - 1;
    botIndexToOwner[newBotId] = _botOwner;
    botPublicKeyToIndex[_botPublicKey] = newBotId;
    Transfer(0x0, _botOwner, newBotId);
    return newBotId;
  }

  function updateBot(address _botPublicKey, bytes _data) onlyOwner public {
    // TODO: require checks for valid data

    uint256 _botIndex = botPublicKeyToIndex[_botPublicKey];
    require(_botIndex > 0);

    // TODO: require bot exists

    bots[_botIndex].publicKey = _botPublicKey;
    bots[_botIndex].data = _data;
  }

  /// @dev Returns the number of Bots owned by a specific address.
  /// @param _owner The owner address to check.
  function balanceOf(address _owner) public view returns (uint256 count) {
    return ownershipCount[_owner];
  }

  /// @dev Transfers a Bot to another address.
  /// @param _to The address of the recipient, can be a user or contract.
  /// @param _botId The ID of the Bot to transfer.
  function transfer(
    address _to,
    uint256 _botId
  )
    external
    whenNotPaused
  {
    // TODO: only allow approved developers
    require(_to != address(0));
    require(_to != address(this));
    // TODO: dissallow transfers to other BotChain contracts?
    require(_owns(msg.sender, _botId));

    _transfer(msg.sender, _to, _botId);
  }

  /// @dev Grant another address the right to transfer a Bot with transferFrom()
  /// @param _to The address to be granted transfer approval.
  /// @param _botId The ID of the Bot to approve for transfer.
  function approve(
    address _to,
    uint256 _botId
  )
    external
    whenNotPaused
  {
    require(_owns(msg.sender, _botId));

    botIndexToApproved[_botId] = _to;

    Approval(msg.sender, _to, _botId);
  }

  /// @notice Transfer a Bot owned by another address.
  /// @param _from The address that owns the Bot to be transfered.
  /// @param _to The address that should take ownership of the Bot
  /// @param _botId The ID of the Bot to transfer.
  function transferFrom(
      address _from,
      address _to,
      uint256 _botId
  )
      external
      whenNotPaused
  {
    require(_to != address(0));
    require(_to != address(this));
    require(_approvedFor(msg.sender, _botId));
    require(_owns(_from, _botId));

    _transfer(_from, _to, _botId);
  }

  /// @dev Returns the total number of Bots in existence.
  function totalSupply() public view returns (uint) {
      return bots.length - 1;
  }

  /// @dev Returns the address that owns a given Bot
  /// @param _botId The ID of the Bot.
  function ownerOf(uint256 _botId) external view returns (address owner) {
    owner = botIndexToOwner[_botId];
    require(owner != address(0));
  }

  /// @dev Transfers ownership of a bot from one developer address to another
  /// @param _from Developer address to transfer from
  /// @param _to Developer address to transfer to
  function _transfer(address _from, address _to, uint256 _botId) internal {
    ownershipCount[_to]++;
    botIndexToOwner[_botId] = _to;
    if (_from != address(0)) {
      ownershipCount[_from]--;
    }
    Transfer(_from, _to, _botId);
  }

  /// @dev Checks if a given address owns a Bot.
  /// @param _claimant the address we are validating against.
  /// @param _botId Id of the bot.
  function _owns(address _claimant, uint256 _botId) internal view returns (bool) {
      return botIndexToOwner[_botId] == _claimant;
  }
  /// @dev Checks if a given address has transfer approval for a Bot
  /// @param _claimant Address to check for transfer approval
  /// @param _botId ID of the bot to check
  function _approvedFor(address _claimant, uint256 _botId) internal view returns (bool) {
    return botIndexToApproved[_botId] == _claimant;
  }
}
