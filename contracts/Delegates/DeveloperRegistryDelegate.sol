pragma solidity ^0.4.18;

import "../Upgradability/ERC721TokenKeyed.sol";
import "../Registry/ApprovableRegistry.sol";
import '../Registry/BotCoinPayableRegistry.sol';
import "../Registry/OwnerRegistry.sol";
import './BotProductRegistryDelegate.sol';

/**
* @title DeveloperRegistryDelegate
* @dev Delegate contract that handles functionality for ownership of developer entries. Implements
*  ERC721 standard, which allows for transferability of developer entries.
*/
contract DeveloperRegistryDelegate is ApprovableRegistry, OwnerRegistry, BotCoinPayableRegistry, ERC721TokenKeyed {

  /**
  * @dev Event for when developer is added
  * @param owner address that owns the developer
  * @param developerId ID of the developer
  * @param dataHash Hash of data associated with the developer
  * @param url A URL associated with the developer
  */
  event DeveloperAdded(address owner, uint256 developerId, bytes32 dataHash, bytes32 url);

  /**
  * @dev Constructor for DeveloperRegistryDelegate
  * @param storage_ address of a BaseStorage contract
  */
  function DeveloperRegistryDelegate(BaseStorage storage_) 
    ApprovableRegistry(storage_, this)
    BotCoinPayableRegistry(storage_)
    ERC721TokenKeyed(storage_)
    public 
    {}

  /**
  * @dev Returns IPFS hash for a given developer ID 
  * @param developerId A developer ID
  * @return bytes32 URL
  */
  function developerIpfs(uint256 developerId) public view returns (bytes32 digest, uint8 fnCode, uint8 size) {
    return _storage.getIpfs(keccak256("developerIpfsHash", developerId));
  }

  /**
  * @dev Returns ID of the developer entry that is owned by the given address. An address
  *  can only own one developer entry.
  * @param owner address of the owner
  * @return A developer ID, or 0 if the given address does not own a developer entry
  */
  function owns(address owner) public view returns (uint256) {
    return _storage.getUint(keccak256("ownerToId", owner));
  }

  /**
  * @dev Returns address that owns the given developer ID.
  *  Implements Registry.ownerOfEntry() abstract
  * @param _developerId A developer ID
  * @return The address that owns the given developer ID
  */
  function ownerOfEntry(uint256 _developerId) public view returns (address _owner) {
    return ownerOf(_developerId);
  }

  /**
  * @dev Returns true if the given address is allowed to mint bot products for the given
  *  developer ID
  * @param minter Address of minter
  * @param _developerId A developer ID
  * @return True if minting is allowed
  */
  function mintingAllowed(address minter, uint256 _developerId) public view returns (bool) {
    return ownerOf(_developerId) == minter && approvalStatus(_developerId) == true;
  }

  /**
  * @dev Adds a new developer entry which is owned by the sender address. Defaults to unapproved,
  *  but can be approved by the contract owner in a subsequent transaction.
  * @param _data A hash of the data associated with the new developer
  * @param _url A URL associated with the new developer
  */
  function addDeveloper(bytes32 IpfsDigest, uint8 IpfsFnCode, uint8 IpfsSize, bytes32 _url) public {
    require(owns(msg.sender) == 0);
    require(IpfsDigest != 0x0);
    require(IpfsFnCode != 0);
    require(IpfsSize != 0);
    require(_url != 0x0);

    uint256 _developerId = totalSupply().add(1);

    setDeveloperUrl(_developerId, _url);
    setOwnerId(msg.sender, _developerId);

    transferBotCoin();

    _mint(msg.sender, _developerId);

    DeveloperAdded(msg.sender, _developerId, _data, _url);
  }


  /**
  * @dev Private function to set a IPFS Hash for a developer
  * @param developerId A developer ID
  * @param digest bytes32 Multihash digest
  * @param fnCode uint8 Multihash function code
  * @param size uint8 URL Multihash digest size
  */
  function setDeveloperIpfs(uint256 developerId, bytes32 digest, uint8 fnCode, uint8 size) private {
    _storage.setIpfs(keccak256("developerIpfsHash", developerId), digest, fnCode, size);
  }

  /**
  * @dev Private function to set the owner for a developer
  * @param owner Address of the owner
  * @param developerId A developer ID
  */
  function setOwnerId(address owner, uint256 developerId) private {
    _storage.setUint(keccak256("ownerToId", owner), developerId);
  }

  /**
  * @dev Private function to set the address of the bot product registry
  * @param botProductRegistry Address of a bot product registry
  */
  function setBotProductRegistry(BotProductRegistryDelegate botProductRegistry) private {
    _storage.setAddress("botProductRegistry", botProductRegistry);
  }

  /**
  * @dev Checks if the given entry ID exists in the registry.
  *  Implements ApprovableRegistry.entryExists() abstract.
  * @param _entryId An entry ID
  * @return bool indicating if the given entry ID exists
  */
  function entryExists(uint256 _entryId) private view returns (bool) {
    return ownerOf(_entryId) != 0x0;
  }

}
