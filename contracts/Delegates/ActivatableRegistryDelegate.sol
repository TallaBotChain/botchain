pragma solidity ^0.4.18;

import "../Upgradability/OwnableKeyed.sol";
import "../Upgradability/ERC721TokenKeyed.sol";

contract ActivatableRegistryDelegate is ERC721TokenKeyed, OwnableKeyed {

  /**
   * @dev Event for when an entry is activated
   * @param entryId The ID of the entry that was activated
   */
  event Activate(uint256 entryId);

  /**
   * @dev Event for when an entry is deactivated
   * @param entryId The ID of the entry that was deactivated
   */
  event Deactivate(uint256 entryId);

  /**
   * @dev Creates a registry of activatable entries
   * @param storage_ The BaseStorage contract that stores ActivatableRegistryDelegate's state
   */
  function ActivatableRegistryDelegate(BaseStorage storage_)
    OwnableKeyed(storage_)
    ERC721TokenKeyed(storage_)
    public
  {}

  /**
   * @dev Check if an entry is active
   * @param _entryId The ID of the entry
   * @return true if the entry is active
   */
  function active(uint256 _entryId) public view returns (bool) {
    return _storage.getBool(keccak256("activeStatus", _entryId));
  }

  /**
   * @dev Activates a given entry
   * @param _entryId The ID of the entry to grant approval for.
   */
  function activate(uint256 _entryId) public {
    require(ownerOf(_entryId) == msg.sender);
    require(!active(_entryId));

    setActiveStatus(_entryId, true);

    Activate(_entryId);
  }

  /**
   * @dev Deactivates a given entry
   * @param _entryId The ID of the entry to revoke approval for.
   */
  function deactivate(uint256 _entryId) public {
    require(ownerOf(_entryId) == msg.sender);
    require(active(_entryId));

    setActiveStatus(_entryId, false);

    Deactivate(_entryId);
  }

  /**
   * @dev Sets the entry's status to _approvalStatus
   * @param _entryId The ID of the entry
   * @param _approvalStatus The status that will be set
   */
  function setActiveStatus(uint256 _entryId, bool _approvalStatus) internal {
    _storage.setBool(keccak256("activeStatus", _entryId), _approvalStatus);
  }
}
