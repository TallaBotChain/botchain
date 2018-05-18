pragma solidity ^0.4.18;

import "../Upgradability/ERC721TokenKeyed.sol";
import '../CurationCouncil.sol'

/**
* @title TokenVaultDelegate
* @dev Delegate contract that handles functionality for token rewards and fees processed by the network.
*/
contract TokenVaultDelegate is IncentiveMap {

  /**
  * @dev Event for when a curator is added to track rewards
  * @param owner address that is owned by the curator 
  * @param stake the number of tokens staked against the CurationCouncil
  */
  event CuratorAdded(address owner, uint256 stake);

  /**
  * @dev Constructor for TokenVaultDelegate
  * @param storage_ address of the BaseStorage contract
  * @param council_ address of the CurationCouncil contract
  * @param board_   address of the GovernanceBoard contract
  */
  function TokenVaultDelegate(BaseStorage storage_) 
    ApprovableRegistry(storage_)
    BotCoinPayableRegistry(storage_)
    ERC721TokenKeyed(storage_)
    public 
    {}

  /**
  * @dev Returns hash of data for the given developer ID
  * @param developerId A developer ID
  * @return bytes32 hash of data
  */
  function curatorBalance(address curatorAddr) public view returns (uint256) {
    return _storage.getUint(keccak256("curatorBalance", curatorAddr));
  }

  /**
  * @dev Returns URL for a given developer ID 
  * @param developerId A developer ID
  * @return bytes32 URL
  */
  function developerUrl(uint256 developerId) public view returns (bytes32) {
    return _storage.getBytes32(keccak256("developerUrl", developerId));
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
  function addDeveloper(bytes32 _data, bytes32 _url) public {
    require(owns(msg.sender) == 0);
    require(_data != 0x0);
    require(_url != 0x0);

    uint256 _developerId = totalSupply().add(1);

    setDeveloperDataHash(_developerId, _data);
    setDeveloperUrl(_developerId, _url);
    setOwnerId(msg.sender, _developerId);

    transferBotCoin();

    _mint(msg.sender, _developerId);

    DeveloperAdded(msg.sender, _developerId, _data, _url);
  }

  /**
  * @dev Private function to set a data hash for a developer
  * @param developerId A developer ID
  * @param dataHash bytes32 hash of data associated with the given developer ID
  */
  function setDeveloperDataHash(uint256 developerId, bytes32 dataHash) private {
    _storage.setBytes32(keccak256("developerDataHash", developerId), dataHash);
  }

  /**
  * @dev Private function to set a URL for a developer
  * @param developerId A developer ID
  * @param url bytes32 URL associated with the given developer ID
  */
  function setDeveloperUrl(uint256 developerId, bytes32 url) private {
    _storage.setBytes32(keccak256("developerUrl", developerId), url);
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
