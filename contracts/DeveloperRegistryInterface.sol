pragma solidity ^0.4.18;

contract DeveloperRegistryInterface {

  /**
  * @dev Event for when developer is added
  * @param owner address that owns the developer
  * @param developerId ID of the developer
  * @param dataHash Hash of data associated with the developer
  * @param url A URL associated with the developer
  */
  event DeveloperAdded(address owner, uint256 developerId, bytes32 dataHash, bytes32 url);

  /**
  * @dev Returns hash of data for the given developer ID
  * @param developerId A developer ID
  * @return bytes32 hash of data
  */
  function developerDataHash(uint256 developerId) public view returns (bytes32);

  /**
  * @dev Returns URL for a given developer ID 
  * @param developerId A developer ID
  * @return bytes32 URL
  */
  function developerUrl(uint256 developerId) public view returns (bytes32);

  /**
  * @dev Returns ID of the developer entry that is owned by the given address. An address
  *  can only own one developer entry.
  * @param _owner address of the owner
  * @return A developer ID, or 0 if the given address does not own a developer entry
  */
  function owns(address _owner) public view returns (uint256);

  /**
  * @dev Returns address that owns the given developer ID.
  *  Implements Registry.ownerOfEntry() abstract
  * @param _developerId A developer ID
  * @return The address that owns the given developer ID
  */
  function ownerOfEntry(uint256 _developerId) public view returns (address _owner);

  /**
  * @dev Returns true if the given address is allowed to mint bot products for the given
  *  developer ID
  * @param minter Address of minter
  * @param _developerId A developer ID
  * @return True if minting is allowed
  */
  function mintingAllowed(address minter, uint256 _developerId) public view returns (bool);

  /**
  * @dev Adds a new developer entry which is owned by the sender address. Defaults to unapproved,
  *  but can be approved by the contract owner in a subsequent transaction.
  * @param _data A hash of the data associated with the new developer
  * @param _url A URL associated with the new developer
  */
  function addDeveloper(bytes32 _data, bytes32 _url) public;

  /**
  * @dev Private function to set a data hash for a developer
  * @param developerId A developer ID
  * @param dataHash bytes32 hash of data associated with the given developer ID
  */
  function setDeveloperDataHash(uint256 developerId, bytes32 dataHash) private;

  /**
  * @dev Private function to set a URL for a developer
  * @param developerId A developer ID
  * @param url bytes32 URL associated with the given developer ID
  */
  function setDeveloperUrl(uint256 developerId, bytes32 url) private;

  /**
  * @dev Private function to set the owner for a developer
  * @param owner Address of the owner
  * @param developerId A developer ID
  */
  function setOwnerId(address owner, uint256 developerId) private;

  /**
  * @dev Checks if the given entry ID exists in the registry.
  *  Implements ApprovableRegistry.entryExists() abstract.
  * @param _entryId An entry ID
  * @return bool indicating if the given entry ID exists
  */
  function entryExists(uint256 _entryId) private view returns (bool);

  function grantApproval(uint256 _entryId) public;

  function approvalStatus(uint256 _entryId) public view returns (bool);

}
