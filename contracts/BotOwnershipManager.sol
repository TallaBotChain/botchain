pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/lifecycle/Pausable.sol';
import 'zeppelin-solidity/contracts/math/SafeMath.sol';
import './BotChain.sol';
import './ERC721.sol';

/// @dev Non-Fungible token (ERC-721) that handles ownership and transfer
///  of Bots. Bots can be transferred to and from approved developers.
contract BotOwnershipManager is Pausable, ERC721 {
  using SafeMath for uint256;

  event BotCreated(uint256 botId, address botOwner, address botAddress, bytes32 data);
  event BotUpdated(uint256 botId, address botAddress, bytes32 data);

  /// @dev A mapping from owner address to count of tokens that address owns.
  ///  Used internally inside balanceOf() to resolve ownership count.
  mapping(address => uint256) ownershipCount;
  
  /// @dev A mapping from Bot Id to Bot owner address
  mapping(uint256 => address) botIdToOwner;

  /// @dev A mapping from Bot address to bot ID
  mapping(address => uint256) botAddressToId;

  /// @dev A mapping from Bot ID to an address approved for transfer.
  mapping(uint256 => address) botIdToApproved;

  Bot[] bots;

  BotChain public botChain;

  struct Bot {
    /// @dev Address (public key hash) of the bot. Used for off-chain verification.
    address botAddress;

    /// @dev A hash of data associated with the Bot
    bytes32 botData;
  }

  function BotOwnershipManager(BotChain _botChain) public {
    botChain = _botChain;

    // Create `0` ID bot. The first valid bot ID will be `1`.
    bots.push(Bot(0x0, bytes32(0)));
  }

  /// @dev Returns the number of Bots owned by a specific address.
  /// @param _owner The owner address to check.
  function balanceOf(address _owner) public view returns (uint256 count) {
    return ownershipCount[_owner];
  }

  /// @dev Returns `true` if a bot exists, and `false` if not. When a bot signs a message
  ///  off-chain with it's public/private key, this function should be used to verify that
  ///  a record of the bot exists.
  /// @param _botAddress The bot address to check. 
  function botExists(address _botAddress) public view returns (bool) {
    return botAddressToId[_botAddress] > 0;
  }

  /// @dev Creates a new bot.
  /// @param _botOwner Address of the developer who owns the bot
  /// @param _botAddress Address of the bot
  /// @param _data Hash of data associated with the bot
  function createBot(address _botOwner, address _botAddress, bytes32 _data) onlyOwner external {
    require(_botOwner != 0x0);
    require(_botAddress != 0x0);
    require(_data != 0x0);
    require(!botExists(_botAddress));

    Bot memory _bot = Bot({
      botAddress: _botAddress,
      botData: _data
    });

    uint256 _newBotId = bots.push(_bot) - 1;
    botIdToOwner[_newBotId] = _botOwner;
    botAddressToId[_botAddress] = _newBotId;

    ownershipCount[_botOwner] = ownershipCount[_botOwner].add(1);

    BotCreated(_newBotId, _botOwner, _botAddress, _data);
  }

  function updateBot(uint256 _botId, address _botAddress, bytes32 _data) onlyOwner external {
    require(_botId > 0 && _botId < bots.length);
    require(_botAddress != 0x0);
    require(_data != 0x0);

    Bot storage _bot = bots[_botId];
    botAddressToId[_bot.botAddress] = 0;

    bots[_botId] = Bot({
      botAddress: _botAddress,
      botData: _data
    });

    botAddressToId[_botAddress] = _botId;

    BotUpdated(_botId, _botAddress, _data);
  }

  /// @dev Returns the ID of a bot, given the bot's address.
  /// @param _botAddress The address of the bot.
  function getBotId(address _botAddress) external view returns (uint256) {
    require(botExists(_botAddress));
    uint256 _botId = botAddressToId[_botAddress];
    return _botId;
  }

  function getBot(uint256 _botId)
    external
    view
    returns
  (
    address owner,
    address botAddress,
    bytes32 data
  ) {
    Bot storage _bot = bots[_botId];
    owner = _getBotOwner(_botId);
    botAddress = _bot.botAddress;
    data = _bot.botData;
  }

  /// @dev Transfers a Bot to another address.
  /// @param _to The address of the recipient, can be a user or contract.
  /// @param _botId The ID of the Bot to transfer.
  function transfer(address _to, uint256 _botId) external whenNotPaused {
    require(_to != address(0));
    require(_to != address(this));
    require(_owns(msg.sender, _botId));
    require(botChain.isApprovedDeveloper(_to));

    _transfer(msg.sender, _to, _botId);
  }

  /// @dev Grant another address the right to transfer a Bot with transferFrom()
  /// @param _to The address to be granted transfer approval.
  /// @param _botId The ID of the Bot to approve for transfer.
  function approve(address _to, uint256 _botId) external whenNotPaused {
    require(_to != address(0));
    require(_to != address(this));
    require(_owns(msg.sender, _botId));

    botIdToApproved[_botId] = _to;

    Approval(msg.sender, _to, _botId);
  }

  /// @notice Transfer a Bot owned by another address.
  /// @param _from The address that owns the Bot to be transfered.
  /// @param _to The address that should take ownership of the Bot
  /// @param _botId The ID of the Bot to transfer.
  function transferFrom(address _from, address _to, uint256 _botId) external whenNotPaused {
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
    owner = botIdToOwner[_botId];
    require(owner != address(0));
  }

  /// @dev Given a bot ID, returns the address of the developer who owns the bot
  /// @param _botId The ID of the bot.
  function _getBotOwner(uint256 _botId) internal view returns (address) {
    require(_botId > 0);
    require(botIdToOwner[_botId] != 0x0);
    return botIdToOwner[_botId];
  }

  /// @dev Transfers ownership of a bot from one developer address to another
  /// @param _from Developer address to transfer from
  /// @param _to Developer address to transfer to
  function _transfer(address _from, address _to, uint256 _botId) internal {
    ownershipCount[_to]++;
    botIdToOwner[_botId] = _to;
    if (_from != address(0)) {
      ownershipCount[_from]--;
    }
    Transfer(_from, _to, _botId);
  }

  /// @dev Checks if a given address owns a Bot.
  /// @param _claimant the address we are validating against.
  /// @param _botId Id of the bot.
  function _owns(address _claimant, uint256 _botId) internal view returns (bool) {
      return botIdToOwner[_botId] == _claimant;
  }

  /// @dev Checks if a given address has transfer approval for a Bot
  /// @param _claimant Address to check for transfer approval
  /// @param _botId ID of the bot to check
  function _approvedFor(address _claimant, uint256 _botId) internal view returns (bool) {
    return botIdToApproved[_botId] == _claimant;
  }
}
