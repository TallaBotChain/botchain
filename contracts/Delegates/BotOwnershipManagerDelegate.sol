pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/math/SafeMath.sol';
import "levelk-upgradability-contracts/contracts/Delegates/lifecycle/PausableDelegate.sol";
import '../ERC721.sol';
import './BotChainDelegate.sol';

/// @dev Non-Fungible token (ERC-721) that handles ownership and transfer
///  of Bots. Bots can be transferred to and from approved developers.
contract BotOwnershipManagerDelegate is PausableDelegate, ERC721 {
  using SafeMath for uint256;

  event BotCreated(uint256 botId, address botOwner, address botAddress, bytes32 data);
  event BotUpdated(uint256 botId, address botAddress, bytes32 data);
  event BotDisabled(uint256 botId);
  event BotEnabled(uint256 botId);

  /// @dev A mapping from owner address to count of tokens that address owns.
  ///  Used internally inside balanceOf() to resolve ownership count.
  // mapping(address => uint256) ownershipCount;

  function incrementOwnershipCount(address owner) internal {
    _storage.setUint(keccak256("ownershipCount", owner), balanceOf(owner) + 1);
  }

  function decrementOwnershipCount(address owner) internal {
    _storage.setUint(keccak256("ownershipCount", owner), balanceOf(owner) - 1);
  }
  
  /// @dev A mapping from Bot Id to Bot owner address
  // mapping(uint256 => address) botIdToOwner;

  function getBotOwner(uint256 botId) public view returns (address) {
    return _storage.getAddress(keccak256("botOwners", botId));
  }

  function setBotOwner(uint256 botId, address owner) internal {
    return _storage.setAddress(keccak256("botOwners", botId), owner);
  }

  /// @dev A mapping from Bot address to bot ID
  // mapping(address => uint256) botAddressToId;

  function getBotIdForAddress(address botAddress) public view returns (uint256) {
    return _storage.getUint(keccak256("botIdsByAddress", botAddress));
  }

  function setBotIdForAddress(address botAddress, uint256 botId) internal {
    _storage.setUint(keccak256("botIdsByAddress", botAddress), botId);
  }

  /// @dev A mapping from Bot ID to an address approved for transfer.
  // mapping(uint256 => address) botIdToApproved;

  function getApprovedTransferAddressForBot(uint256 botId) public view returns (address) {
    return _storage.getAddress(keccak256("approvedTransferAddresses", botId));
  }

  function setApprovedTransferAddressForBot(uint256 botId, address approvedAddress) internal {
    return _storage.setAddress(keccak256("approvedTransferAddresses", botId), approvedAddress);
  }

  /// @dev A mapping from Bot ID to a boolean indicating if the bot is disabled
  // mapping(uint256 => bool) botIdToDisabled;

  function getBotDisabledStatus(uint256 botId) public view returns (bool) {
    return _storage.getBool(keccak256("botDisabledStatuses", botId));
  }

  function setBotDisabledStatus(uint256 botId, bool disabled) internal {
    _storage.setBool(keccak256("botDisabledStatuses", botId), disabled);
  }

  function getBotChain() public view returns (BotChainDelegate) {
    return BotChainDelegate(_storage.getAddress("botChainAddress"));
  }

  function getBotCount() public view returns (uint) {
    return _storage.getUint("botCount");
  }

  function getBotAddress(uint botId) public view returns (address) {
    return _storage.getAddress(keccak256("botAddresses", botId));
  }

  function getBotDataHash(uint botId) public view returns (bytes32) {
    return _storage.getBytes32(keccak256("botDataHashes", botId));
  }

  function BotOwnershipManagerDelegate(BotChainDelegate botChain, BaseStorage storage_)
    public
    PausableDelegate(storage_)
  {}

  /// @dev Returns the number of Bots owned by a specific address.
  /// @param owner The owner address to check.
  function balanceOf(address owner) public view returns (uint256 count) {
    return _storage.getUint(keccak256("ownershipCount", owner));
  }

  /// @dev Returns `true` if a bot exists, and `false` if not. When a bot signs a message
  ///  off-chain with it's public/private key, this function should be used to verify that
  ///  a record of the bot exists.
  /// @param botAddress The bot address to check. 
  function botExists(address botAddress) public view returns (bool) {
    return getBotIdForAddress(botAddress) > 0;
  }

  /// @dev Creates a new bot.
  /// @param botOwner Address of the developer who owns the bot
  /// @param botAddress Address of the bot
  /// @param dataHash Hash of data associated with the bot
  function createBot(address botOwner, address botAddress, bytes32 dataHash) onlyOwner external {
    require(botOwner != 0x0);
    require(botAddress != 0x0);
    require(dataHash != 0x0);
    require(!botExists(botAddress));

    pushBot(botAddress, dataHash);
    uint256 newBotId = getBotCount() - 1;

    setBotOwner(newBotId, botOwner);
    incrementOwnershipCount(botOwner);
    setBotIdForAddress(botAddress, newBotId);

    BotCreated(newBotId, botOwner, botAddress, dataHash);
  }

  function updateBot(uint256 botId, address newBotAddress, bytes32 newDataHash) onlyOwner external {
    require(botId > 0 && botId < getBotCount());
    require(newBotAddress != 0x0);
    require(newDataHash != 0x0);

    setBotIdForAddress(getBotAddress(botId), 0);
    setBotIdForAddress(newBotAddress, botId);
    setBotData(botId, newBotAddress, newDataHash);

    BotUpdated(botId, newBotAddress, newDataHash);
  }

  /// @dev Disables a bot. Disabled bots cannot be transferred.
  ///      When a bot is created, it is enabled by default.
  /// @param botId The ID of the bot to disable.
  function disableBot(uint256 botId) onlyOwner external {
    require(getBotOwner(botId) != 0x0);
    require(botIsEnabled(botId));

    setBotDisabledStatus(botId, true);

    BotDisabled(botId);
  }

  /// @dev Enables a bot.
  /// @param botId The ID of the bot to enable.
  function enableBot(uint256 botId) onlyOwner external {
    require(getBotOwner(botId) != 0x0);
    require(!botIsEnabled(botId));

    setBotDisabledStatus(botId, false);

    BotEnabled(botId);
  }

  /// @dev Returns the ID of a bot, given the bot's address.
  /// @param botAddress The address of the bot.
  function getBotId(address botAddress) external view returns (uint256) {
    require(botExists(botAddress));
    return getBotIdForAddress(botAddress);
  }

  function getBot(uint256 botId)
    external
    view
    returns
  (
    address owner,
    address botAddress,
    bytes32 data
  ) {
    owner = getBotOwner(botId);
    botAddress = getBotAddress(botId);
    data = getBotDataHash(botId);
  }

  /// @dev Transfers a Bot to another address.
  /// @param to The address of the recipient, can be a user or contract.
  /// @param botId The ID of the Bot to transfer.
  function transfer(address to, uint256 botId) external whenNotPaused {
    require(_owns(msg.sender, botId));
    _transfer(msg.sender, to, botId);
  }

  /// @dev Grant another address the right to transfer a Bot with transferFrom()
  /// @param to The address to be granted transfer approval.
  /// @param botId The ID of the Bot to approve for transfer.
  function approve(address to, uint256 botId) external whenNotPaused {
    require(to != address(0));
    require(to != address(this));
    require(_owns(msg.sender, botId));

    setApprovedTransferAddressForBot(botId, to);

    Approval(msg.sender, to, botId);
  }

  /// @notice Transfer a Bot owned by another address.
  /// @param from The address that owns the Bot to be transfered.
  /// @param to The address that should take ownership of the Bot
  /// @param botId The ID of the Bot to transfer.
  function transferFrom(address from, address to, uint256 botId) external whenNotPaused {
    require(_approvedFor(msg.sender, botId));
    require(_owns(from, botId));
    _transfer(from, to, botId);
  }

  /// @dev Returns the total number of Bots in existence.
  function totalSupply() public view returns (uint) {
      return getBotCount() - 1;
  }

  /// @dev Returns true if the given bot is enabled
  /// @param botId The ID of the bot to check
  function botIsEnabled(uint256 botId) public view returns (bool) {
    require(botId > 0);
    require(getBotOwner(botId) != 0x0);
    return getBotDisabledStatus(botId) == false;
  }

  /// @dev Returns the address that owns a given Bot
  /// @param botId The ID of the Bot.
  function ownerOf(uint256 botId) external view returns (address owner) {
    owner = getBotOwner(botId);
    require(owner != address(0));
  }

  /// @dev Given a bot ID, returns the address of the developer who owns the bot
  /// @param botId The ID of the bot.
  function _getBotOwner(uint256 botId) internal view returns (address) {
    require(botId > 0);
    require(getBotOwner(botId) != 0x0);
    return getBotOwner(botId);
  }

  /// @dev Transfers ownership of a bot from one developer address to another
  /// @param from Developer address to transfer from
  /// @param to Developer address to transfer to
  /// @param botId The ID of the bot to transfer
  function _transfer(address from, address to, uint256 botId) internal {
    require(to != address(0));
    require(to != address(this));
    require(getBotChain().isApprovedDeveloper(to));
    require(botIsEnabled(botId));

    incrementOwnershipCount(to);
    setBotOwner(botId, to);
    if (from != address(0)) {
      decrementOwnershipCount(from);
    }
    Transfer(from, to, botId);
  }

  /// @dev Checks if a given address owns a Bot.
  /// @param claimant the address we are validating against.
  /// @param botId Id of the bot.
  function _owns(address claimant, uint256 botId) internal view returns (bool) {
      return getBotOwner(botId) == claimant;
  }

  /// @dev Checks if a given address has transfer approval for a Bot
  /// @param claimant Address to check for transfer approval
  /// @param botId ID of the bot to check
  function _approvedFor(address claimant, uint256 botId) internal view returns (bool) {
    return getApprovedTransferAddressForBot(botId) == claimant;
  }

  function pushBot(address botAddress, bytes32 botDataHash) internal {
    setBotData(getBotCount(), botAddress, botDataHash);
    incrementBotCount();
  }

  function setBotData(uint256 botId, address botAddress, bytes32 botDataHash) internal {
    _storage.setAddress(keccak256("botAddresses", botId), botAddress);
    _storage.setBytes32(keccak256("botDataHashes", botId), botDataHash);
  }

  function incrementBotCount() internal {
    _storage.setUint("botCount", getBotCount() + 1);
  }
}
