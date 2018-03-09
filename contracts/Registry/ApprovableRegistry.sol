pragma solidity ^0.4.18;

import "../Upgradability/OwnableKeyed.sol";

contract ApprovableRegistry is OwnableKeyed {

  /**
   * @dev Event for when approval is granted
   * @param entryId The ID of the entry that was approved
   */
  event ApprovalGranted(uint256 entryId);

  /**
   * @dev Event for when approval is revoked
   * @param entryId The ID of the entry that was revoked
   */
  event ApprovalRevoked(uint256 entryId);

  /**
   * @dev Creates a registry of approvable entries
   * @param storage_ The BaseStorage contract that stores ApprovableRegistry's state
   */
  function ApprovableRegistry(BaseStorage storage_)
    OwnableKeyed(storage_)
    public
    {}

  /**
   * @dev Checks approval status of entry
   * @param _entryId The ID of the entry
   */
  function approvalStatus(uint256 _entryId) public view returns (bool) {
    return _storage.getBool(keccak256("approvalStatus", _entryId));
  }

  /**
  * @dev Grants approval for an existing entry. Only callable by owner.
  * @param _entryId The ID of the entry to grant approval for.
  */
  function grantApproval(uint256 _entryId) onlyOwner public {
    require(entryExists(_entryId));
    require(!approvalStatus(_entryId));

    setApprovalStatus(_entryId, true);

    ApprovalGranted(_entryId);
  }

  /**
  * @dev Revokes approval for an existing developer. Only callable by owner.
  * @param _entryId The ID of the developer to revoke approval for.
  */
  function revokeApproval(uint256 _entryId) onlyOwner public {
    require(entryExists(_entryId));
    require(approvalStatus(_entryId));

    setApprovalStatus(_entryId, false);

    ApprovalRevoked(_entryId);
  }

  /**
   * @dev Sets the entry's status to _approvalStatus
   * @param _entryId The ID of the entry
   * @param _approvalStatus The status that will be set
   */
  function setApprovalStatus(uint256 _entryId, bool _approvalStatus) internal {
    _storage.setBool(keccak256("approvalStatus", _entryId), _approvalStatus);
  }

  /**
  * @dev Checks if entry exists for id
  * @param _entryId An id associated entry
  */
  function entryExists(uint256 _entryId) private view returns (bool);
}
