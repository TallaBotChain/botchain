pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/math/SafeMath.sol';
import "./OwnableRegistry.sol";
import "./OwnerRegistry.sol";
import "./ActivatableRegistry.sol";
import "./ApprovableRegistry.sol";
import './BotCoinPayableRegistry.sol';

/**
* @title BotEntryStorableRegistry
*/
contract BotEntryStorableRegistry is BotCoinPayableRegistry, ApprovableRegistry, ActivatableRegistry, OwnableRegistry {
  using SafeMath for uint256;

  /**
  * @dev Event for when bot entry is created
  * @param botEntryId An id associated with the bot entry  
  * @param parentEntryId An id associated with the developer
  * @param developerOwnerAddress An address associated with the developer owner
  * @param botEntryAddress An address associated with the bot entry
  * @param IpfsDigest IPFS Digest of the data associated with the new bot
  * @param IpfsFnCode IPFS Function Code associated with the new bot
  * @param IpfsSize IPFS Digest size associated with the new bot
  */
  event BotEntryCreated(
    uint256 botEntryId, 
    uint256 parentEntryId, 
    address developerOwnerAddress, 
    address botEntryAddress, 
    bytes32 IpfsDigest,
    uint8 IpfsFnCode,
    uint8 IpfsSize
  );

  /** @dev Constructor for BotEntryStorableRegistry */
  function BotEntryStorableRegistry(BaseStorage storage_)
    BotCoinPayableRegistry(storage_)
    OwnableRegistry(storage_)
    ApprovableRegistry(storage_, this)
    ActivatableRegistry(storage_)
    public
  {}

  /**
  * @dev Returns address of bot entry
  * @param botEntryId An id associated with the bot entry
  */
  function botEntryAddress(uint256 botEntryId) public view returns (address) {
    return _storage.getAddress(keccak256("botEntryAddresses", botEntryId));
  }

  /**
  * @dev Returns bot entry url of botEntryId 
  * @param botEntryId An id associated with the bot entry
  */
  function botEntryIpfs(uint256 botEntryId) public view returns (bytes32 digest, uint8 fnCode, uint8 size) {
    return _storage.getIpfs(keccak256("botEntryIpfsHash", botEntryId));
  }

  /**
  * @dev Gets id of bot entry address
  * @param botEntryAddress An address associated with the bot entry
  */
  function botEntryIdForAddress(address botEntryAddress) public view returns (uint256) {
    return _storage.getUint(keccak256("botEntryIdsByAddress", botEntryAddress));
  }

  /**
  * @dev Checks if botEntryAddress exists
  * @param botEntryAddress An address associated with the bot entry
  */
  function botEntryAddressExists(address botEntryAddress) public view returns (bool) {
    return botEntryIdForAddress(botEntryAddress) > 0;
  }

  /**
  * @dev Returns bot entry associated with a bot entry id
  * @param botEntryId An id associated with the bot entry
  */
  function getBotEntry(uint256 botEntryId) public view returns
  (
    address _owner,
    address _botEntryAddress,
    bytes32 _digest,
    uint8 _fnCode, 
    uint8 _size
  ) {
    _owner = ownerOfEntry(botEntryId); 
    _botEntryAddress = botEntryAddress(botEntryId);
    (_digest, _fnCode, _size) = botEntryIpfs(botEntryId);
  }

  /**
  * @dev Creates a new bot entry.
  * @param parentEntryId ID of the developer that will own this bot entry
  * @param botEntryAddress Address of the bot
  * @param IpfsDigest IPFS Digest of the data associated with the new bot
  * @param IpfsFnCode IPFS Function Code associated with the new bot
  * @param IpfsSize IPFS Digest size associated with the new bot
  */
  function createBotEntry(
    uint256 parentEntryId, 
    address botEntryAddress, 
    bytes32 IpfsDigest,
    uint8 IpfsFnCode,
    uint8 IpfsSize
  )
    public 
  {
    require(ownerRegistry().mintingAllowed(msg.sender, parentEntryId));
    require(botEntryAddress != 0x0);
    require(!botEntryAddressExists(botEntryAddress));
    require(IpfsDigest != 0x0);
    require(IpfsFnCode != 0);
    require(IpfsSize != 0);

    uint256 botEntryId = totalSupply().add(1);

    transferBotCoin();

    _mint(parentEntryId, botEntryId);
    setBotEntryData(botEntryId, botEntryAddress);
    setBotEntryIdForAddress(botEntryAddress, botEntryId);
    setBotEntryIpfs(botEntryId, IpfsDigest, IpfsFnCode, IpfsSize);
    setApprovalStatus(botEntryId, true);
    setActiveStatus(botEntryId, true);

    BotEntryCreated(botEntryId, parentEntryId, msg.sender, botEntryAddress, IpfsDigest, IpfsFnCode, IpfsSize);
  }

  /**
  * @dev Sets bot entry data
  * @param botEntryId An id associated with the bot entry
  * @param botEntryAddress An address associated with the bot entry
  */
  function setBotEntryData(uint256 botEntryId, address botEntryAddress) private {
    _storage.setAddress(keccak256("botEntryAddresses", botEntryId), botEntryAddress);
  }

  /**
  * @dev Sets bot entry id for address
  * param botEntryAddress An address associated with the bot entry
  * @param botEntryId An id associated with the bot entry
  */
  function setBotEntryIdForAddress(address botEntryAddress, uint256 botEntryId) private {
    _storage.setUint(keccak256("botEntryIdsByAddress", botEntryAddress), botEntryId);
  }

  /**
  * @dev Sets url of botEntryId 
  * @param botEntryId An id associated with the bot entry
  * @param digest bytes32 Multihash digest
  * @param fnCode uint8 Multihash function code
  * @param size uint8 URL Multihash digest size
  */
  function setBotEntryIpfs(uint256 botEntryId, bytes32 digest, uint8 fnCode, uint8 size) private {
    _storage.setIpfs(keccak256("botEntryIpfsHash", botEntryId), digest, fnCode, size);
  }

  /**
  * @dev Checks if msg.sender owns the given bot entry
  * @param _botEntryId A bot entry id
  * @return true if msg.sender owns the given bot entry
  */
  function checkEntryOwnership(uint256 _botEntryId) private view returns (bool) {
    return ownerOfEntry(_botEntryId) == msg.sender;
  }

  /**
  * @dev Checks if an entry exists
  * @param _entryId An entry id
  * @return true if an entry with the given id exists
  */
  function entryExists(uint256 _entryId) private view returns (bool) {
    return ownerOfEntry(_entryId) != 0x0;
  }

}
