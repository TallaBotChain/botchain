pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/math/SafeMath.sol';
import "levelk-upgradability-contracts/contracts/Implementations/lifecycle/PausableKeyed.sol";
import "levelk-upgradability-contracts/contracts/Implementations/token/ERC721/ERC721TokenKeyed.sol";
import './DeveloperRegistryDelegate.sol';

/// @dev Non-Fungible token (ERC-721) that handles ownership and transfer
///  of Bots. Bots can be transferred to and from approved developers.
contract BotProductRegistryDelegate is PausableKeyed, ERC721TokenKeyed {
  using SafeMath for uint256;

  event BotProductCreated(uint256 botProductId, address botProductOwner, address botProductAddress, bytes32 data);
  event BotProductUpdated(uint256 botProductId, address botProductAddress, bytes32 data);
  event BotProductDisabled(uint256 botProductId);
  event BotProductEnabled(uint256 botProductId);

  function BotProductRegistryDelegate(
    DeveloperRegistryDelegate developerRegistry,
    BaseStorage storage_
  )
    PausableKeyed(storage_)
    ERC721TokenKeyed(storage_)
    public
  {}

  /*

  /// @dev A mapping from owner address to count of tokens that address owns.
  ///  Used internally inside balanceOf() to resolve ownership count.
  // mapping(address => uint256) ownershipCount;

  function incrementOwnershipCount(address owner) internal {
    _storage.setUint(keccak256("ownershipCount", owner), balanceOf(owner) + 1);
  }

  function decrementOwnershipCount(address owner) internal {
    _storage.setUint(keccak256("ownershipCount", owner), balanceOf(owner) - 1);
  }
  
  /// @dev A mapping from Bot product Id to Bot product owner address
  // mapping(uint256 => address) botProductIdToOwner;

  function getBotProductOwner(uint256 botProductId) public view returns (address) {
    return _storage.getAddress(keccak256("botProductOwners", botProductId));
  }

  function setBotProductOwner(uint256 botProductId, address owner) internal {
    return _storage.setAddress(keccak256("botProductOwners", botProductId), owner);
  }

  /// @dev A mapping from bot product address to bot product ID
  // mapping(address => uint256) botProductAddressToId;

  function getBotProductIdForAddress(address botProductAddress) public view returns (uint256) {
    return _storage.getUint(keccak256("botProductIdsByAddress", botProductAddress));
  }

  function setBotIdForAddress(address botProductAddress, uint256 botProductId) internal {
    _storage.setUint(keccak256("botProductIdsByAddress", botProductAddress), botProductId);
  }

  /// @dev A mapping from bot product ID to an address approved for transfer.
  // mapping(uint256 => address) botProductIdToApproved;

  function getApprovedTransferAddressForBot(uint256 botProductId) public view returns (address) {
    return _storage.getAddress(keccak256("approvedTransferAddresses", botProductId));
  }

  function setApprovedTransferAddressForBot(uint256 botProductId, address approvedAddress) internal {
    return _storage.setAddress(keccak256("approvedTransferAddresses", botProductId), approvedAddress);
  }

  /// @dev A mapping from bot product ID to a boolean indicating if the bot product is disabled
  // mapping(uint256 => bool) botProductIdToDisabled;

  function getBotProductDisabledStatus(uint256 botProductId) public view returns (bool) {
    return _storage.getBool(keccak256("botDisabledStatuses", botProductId));
  }

  function setBotProductDisabledStatus(uint256 botProductId, bool disabled) internal {
    _storage.setBool(keccak256("botDisabledStatuses", botProductId), disabled);
  }

  function getDeveloperRegistry() public view returns (DeveloperRegistryDelegate) {
    return DeveloperRegistryDelegate(_storage.getAddress("developerRegistryAddress"));
  }

  function getBotProductCount() public view returns (uint) {
    return _storage.getUint("botProductCount");
  }

  function getBotProductAddress(uint botProductId) public view returns (address) {
    return _storage.getAddress(keccak256("botProductAddresses", botProductId));
  }

  function getBotDataHash(uint botProductId) public view returns (bytes32) {
    return _storage.getBytes32(keccak256("botProductDataHashes", botProductId));
  }

  /// @dev Returns the number of bot products owned by a specific address.
  /// @param owner The owner address to check.
  function balanceOf(address owner) public view returns (uint256 count) {
    return _storage.getUint(keccak256("ownershipCount", owner));
  }

  /// @dev Returns `true` if a bot product exists, and `false` if not.
  /// @param botProductAddress The bot product address to check. 
  function botProductExists(address botProductAddress) public view returns (bool) {
    return getBotProductIdForAddress(botProductAddress) > 0;
  }

  /// @dev Creates a new bot product.
  /// @param botProductOwner Address of the developer who owns the bot
  /// @param botProductAddress Address of the bot
  /// @param dataHash Hash of data associated with the bot
  function createBotProduct(address botProductOwner, address botProductAddress, bytes32 dataHash) onlyOwner external {
    require(botProductOwner != 0x0);
    require(botProductAddress != 0x0);
    require(dataHash != 0x0);
    require(!botProductExists(botProductAddress));

    pushBot(botProductAddress, dataHash);
    uint256 newBotProductId = getBotProductCount() - 1;

    setBotProductOwner(newBotProductId, botProductOwner);
    incrementOwnershipCount(botProductOwner);
    setBotIdForAddress(botProductAddress, newBotProductId);

    BotProductCreated(newBotProductId, botProductOwner, botProductAddress, dataHash);
    Transfer(0x0, botProductOwner, newBotProductId);
  }

  function updateBotProduct(uint256 botProductId, address newBotProductAddress, bytes32 newDataHash) onlyOwner external {
    require(botProductId > 0 && botProductId < getBotProductCount());
    require(newBotProductAddress != 0x0);
    require(newDataHash != 0x0);

    setBotIdForAddress(getBotProductAddress(botProductId), 0);
    setBotIdForAddress(newBotProductAddress, botProductId);
    setBotProductData(botProductId, newBotProductAddress, newDataHash);

    BotProductUpdated(botProductId, newBotProductAddress, newDataHash);
  }

  /// @dev Disables a bot product. Disabled bot products cannot be transferred.
  ///      When a bot is created, it is enabled by default.
  /// @param botProductId The ID of the bot to disable.
  function disableBotProduct(uint256 botProductId) onlyOwner external {
    require(getBotProductOwner(botProductId) != 0x0);
    require(botProductIsEnabled(botProductId));

    setBotProductDisabledStatus(botProductId, true);

    BotProductDisabled(botProductId);
  }

  /// @dev Enables a bot product.
  /// @param botProductId The ID of the bot to enable.
  function enableBotProduct(uint256 botProductId) onlyOwner external {
    require(getBotProductOwner(botProductId) != 0x0);
    require(!botProductIsEnabled(botProductId));

    setBotProductDisabledStatus(botProductId, false);

    BotProductEnabled(botProductId);
  }

  /// @dev Returns the ID of a bot product, given the bot product's address.
  /// @param botProductAddress The address of the bot product.
  function getBotProductId(address botProductAddress) external view returns (uint256) {
    require(botProductExists(botProductAddress));
    return getBotProductIdForAddress(botProductAddress);
  }

  function getBotProduct(uint256 botProductId)
    external
    view
    returns
  (
    address owner,
    address botProductAddress,
    bytes32 data
  ) {
    owner = getBotProductOwner(botProductId);
    botProductAddress = getBotProductAddress(botProductId);
    data = getBotDataHash(botProductId);
  }

  /// @dev Transfers a bot product to another address.
  /// @param to The address of the recipient, can be a user or contract.
  /// @param botProductId The ID of the bot product to transfer.
  function transfer(address to, uint256 botProductId) external whenNotPaused {
    require(_owns(msg.sender, botProductId));
    _transfer(msg.sender, to, botProductId);
  }

  /// @dev Grant another address the right to transfer a bot product with transferFrom()
  /// @param to The address to be granted transfer approval.
  /// @param botProductId The ID of the bot product to approve for transfer.
  function approve(address to, uint256 botProductId) external whenNotPaused {
    require(to != address(0));
    require(to != address(this));
    require(_owns(msg.sender, botProductId));

    setApprovedTransferAddressForBot(botProductId, to);

    Approval(msg.sender, to, botProductId);
  }

  /// @notice Transfer a bot product owned by another address.
  /// @param from The address that owns the bot product to be transfered.
  /// @param to The address that should take ownership of the bot product
  /// @param botProductId The ID of the bot product to transfer.
  function transferFrom(address from, address to, uint256 botProductId) external whenNotPaused {
    require(_approvedFor(msg.sender, botProductId));
    require(_owns(from, botProductId));
    _transfer(from, to, botProductId);
  }

  /// @dev Returns the total number of Bots in existence.
  function totalSupply() public view returns (uint) {
      return getBotProductCount() - 1;
  }

  /// @dev Returns true if the given bot product is enabled
  /// @param botProductId The ID of the bot product to check
  function botProductIsEnabled(uint256 botProductId) public view returns (bool) {
    require(botProductId > 0);
    require(getBotProductOwner(botProductId) != 0x0);
    return getBotProductDisabledStatus(botProductId) == false;
  }

  /// @dev Returns the address that owns a given bot product
  /// @param botProductId The ID of the bot product.
  function ownerOf(uint256 botProductId) external view returns (address owner) {
    owner = getBotProductOwner(botProductId);
    require(owner != address(0));
  }

  /// @dev Given a bot product ID, returns the address of the developer who owns the bot product
  /// @param botProductId The ID of the bot product.
  function _getBotProductOwner(uint256 botProductId) internal view returns (address) {
    require(botProductId > 0);
    require(getBotProductOwner(botProductId) != 0x0);
    return getBotProductOwner(botProductId);
  }

  /// @dev Transfers ownership of a bot product from one developer address to another
  /// @param from Developer address to transfer from
  /// @param to Developer address to transfer to
  /// @param botProductId The ID of the bot product to transfer
  function _transfer(address from, address to, uint256 botProductId) internal {
    require(to != address(0));
    require(to != address(this));
    require(getDeveloperRegistry().isApprovedDeveloper(to));
    require(botProductIsEnabled(botProductId));

    incrementOwnershipCount(to);
    setBotProductOwner(botProductId, to);
    if (from != address(0)) {
      decrementOwnershipCount(from);
    }
    Transfer(from, to, botProductId);
  }

  /// @dev Checks if a given address owns a bot product.
  /// @param claimant the address we are validating against.
  /// @param botProductId Id of the bot product.
  function _owns(address claimant, uint256 botProductId) internal view returns (bool) {
      return getBotProductOwner(botProductId) == claimant;
  }

  /// @dev Checks if a given address has transfer approval for a bot product
  /// @param claimant Address to check for transfer approval
  /// @param botProductId ID of the bot product to check
  function _approvedFor(address claimant, uint256 botProductId) internal view returns (bool) {
    return getApprovedTransferAddressForBot(botProductId) == claimant;
  }

  function pushBot(address botProductAddress, bytes32 botDataHash) internal {
    setBotProductData(getBotProductCount(), botProductAddress, botDataHash);
    incrementBotProductCount();
  }

  function setBotProductData(uint256 botProductId, address botProductAddress, bytes32 botDataHash) internal {
    _storage.setAddress(keccak256("botProductAddresses", botProductId), botProductAddress);
    _storage.setBytes32(keccak256("botProductDataHashes", botProductId), botDataHash);
  }

  function incrementBotProductCount() internal {
    _storage.setUint("botProductCount", getBotProductCount() + 1);
  } */
}
