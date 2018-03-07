pragma solidity ^0.4.18;

import "levelk-upgradability-contracts/contracts/Implementations/ownership/OwnableKeyed.sol";
import "levelk-upgradability-contracts/contracts/Implementations/token/ERC721/ERC721TokenKeyed.sol";

contract ActivatableRegistryDelegate is ERC721TokenKeyed, OwnableKeyed {

  event Activate(uint256 entryId);
  event Deactivate(uint256 entryId);

  function ActivatableRegistryDelegate(BaseStorage storage_)
    OwnableKeyed(storage_)
    ERC721TokenKeyed(storage_)
    public
  {}

  function active(uint256 _entryId) public view returns (bool) {
    return _storage.getBool(keccak256("activeStatus", _entryId));
  }

  /// @dev Activates a given entry
  /// @param _entryId The ID of the entry to grant approval for.
  function activate(uint256 _entryId) public {
    require(ownerOf(_entryId) == msg.sender);
    require(!active(_entryId));

    setActiveStatus(_entryId, true);

    Activate(_entryId);
  }

  /// @dev Deactivates a given entry
  /// @param _entryId The ID of the entry to revoke approval for.
  function deactivate(uint256 _entryId) public {
    require(ownerOf(_entryId) == msg.sender);
    require(active(_entryId));

    setActiveStatus(_entryId, false);

    Deactivate(_entryId);
  }

  function setActiveStatus(uint256 _entryId, bool _approvalStatus) internal {
    _storage.setBool(keccak256("activeStatus", _entryId), _approvalStatus);
  }
}