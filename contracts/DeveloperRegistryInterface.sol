pragma solidity ^0.4.18;

contract DeveloperRegistryInterface {

  /**
  * @dev Event for when developer is added
  * @param owner address that owns the developer
  * @param developerId ID of the developer
  * @param IpfsDigest IPFS Digest of the data associated with the new developer
  * @param IpfsFnCode IPFS Function Code associated with the new developer
  * @param IpfsSize IPRS Digest size associated with the new developer
  */
  event DeveloperAdded(address owner, uint256 developerId, bytes32 IpfsDigest, uint8 IpfsFnCode, uint8 IpfsSize);

  /**
  * @dev Returns IPFS hash for a given developer ID 
  * @param developerId A developer ID
  * @return bytes32 URL
  */
  function developerIpfs(uint256 developerId) public view returns (bytes32 digest, uint8 fnCode, uint8 size);

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
  * @param IpfsDigest IPFS Digest of the data associated with the new developer
  * @param IpfsFnCode IPFS Function Code associated with the new developer
  * @param IpfsSize IPRS Digest size associated with the new developer
  */
  function addDeveloper(bytes32 IpfsDigest, uint8 IpfsFnCode, uint8 IpfsSize) public;

  /**
  * @dev Private function to set a IPFS Hash for a developer
  * @param developerId A developer ID
  * @param digest bytes32 Multihash digest
  * @param fnCode uint8 Multihash function code
  * @param size uint8 URL Multihash digest size
  */
  function setDeveloperIpfs(uint256 developerId, bytes32 digest, uint8 fnCode, uint8 size) private ;

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
