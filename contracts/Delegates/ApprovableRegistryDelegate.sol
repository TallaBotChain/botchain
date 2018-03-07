pragma solidity ^0.4.18;

import "levelk-upgradability-contracts/contracts/Implementations/ownership/OwnableKeyed.sol";
import "levelk-upgradability-contracts/contracts/Implementations/token/ERC721/ERC721TokenKeyed.sol";

contract ApprovableRegistryDelegate is ERC721TokenKeyed, OwnableKeyed {

  event ApprovalGranted(uint256 entryId);
  event ApprovalRevoked(uint256 entryId);

  function ApprovableRegistryDelegate(BaseStorage storage_)
    OwnableKeyed(storage_)
    ERC721TokenKeyed(storage_)
    public
  {}

  function approvalStatus(uint256 _entryId) public view returns (bool) {
    return _storage.getBool(keccak256("approvalStatus", _entryId));
  }

  /// @dev Grants approval for an existing entry. Only callable by owner.
  /// @param _entryId The ID of the entry to grant approval for.
  function grantApproval(uint256 _entryId) onlyOwner public {
    require(ownerOf(_entryId) != 0x0);
    require(!approvalStatus(_entryId));

    setApprovalStatus(_entryId, true);

    ApprovalGranted(_entryId);
  }

  /// @dev Revokes approval for an existing developer. Only callable by owner.
  /// @param _entryId The ID of the developer to revoke approval for.
  function revokeApproval(uint256 _entryId) onlyOwner public {
    require(ownerOf(_entryId) != 0x0);
    require(approvalStatus(_entryId));

    setApprovalStatus(_entryId, false);

    ApprovalRevoked(_entryId);
  }

  function setApprovalStatus(uint256 _entryId, bool _approvalStatus) internal {
    _storage.setBool(keccak256("approvalStatus", _entryId), _approvalStatus);
  }
}