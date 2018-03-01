pragma solidity ^0.4.18;

import "levelk-upgradability-contracts/contracts/Implementations/ownership/OwnableKeyed.sol";
import "levelk-upgradability-contracts/contracts/Implementations/token/ERC721/ERC721TokenKeyed.sol";
import './BotProductRegistryDelegate.sol';

/// @title DeveloperRegistryDelegate
/// @dev Delegate contract for DeveloperRegistry functionality
contract DeveloperRegistryDelegate is ERC721TokenKeyed, OwnableKeyed {

  event DeveloperAdded(address owner, uint256 developerId, bytes32 dataHash, bytes32 url);
  event DeveloperApprovalRevoked(uint256 developerId);

  function DeveloperRegistryDelegate(BaseStorage storage_) public ERC721TokenKeyed(storage_) OwnableKeyed(storage_) { }

  function getBotProductProductRegistry() public view returns (BotProductRegistryDelegate) {
    return BotProductRegistryDelegate(_storage.getAddress("botProductRegistry"));
  }

  function getDeveloperApprovalStatus(uint256 developerId) public view returns (bool) {
    return _storage.getBool(keccak256("developerApprovalStatus", developerId));
  }

  function getDeveloperDataHash(uint256 developerId) public view returns (bytes32) {
    return _storage.getBytes32(keccak256("developerDataHash", developerId));
  }

  function getDeveloperUrl(uint256 developerId) public view returns (bytes32) {
    return _storage.getBytes32(keccak256("developerUrl", developerId));
  }

  /// @dev Adds a new developer. Only callable by owner.
  /// @param _owner The address that will own the new developer
  /// @param _data A hash of the data associated with the new developer
  /// @param _url A url associated with this developer
  function addDeveloper(address _owner, bytes32 _data, bytes32 _url) onlyOwner public {
    require(_owner != 0x0);
    require(_data != 0x0);
    require(_url != 0x0);

    uint256 _developerId = super.totalSupply();

    setDeveloperApprovalStatus(_developerId, true);
    setDeveloperDataHash(_developerId, _data);
    setDeveloperUrl(_developerId, _url);
    super._mint(_owner, _developerId);

    DeveloperAdded(_owner, _developerId, _data, _url);
  }

  /// @dev Revokes approval for an existing developer. Only callable by owner.
  /// @param _developerId The ID of the developer to revoke approval for.
  function revokeDeveloperApproval(uint256 _developerId) onlyOwner public {
    require(getDeveloperApprovalStatus(_developerId));

    setDeveloperApprovalStatus(_developerId, false);

    DeveloperApprovalRevoked(_developerId);
  }

  function setDeveloperApprovalStatus(uint256 developerId, bool approvalStatus) private {
    _storage.setBool(keccak256("developerApprovalStatus", developerId), approvalStatus);
  }

  function setDeveloperDataHash(uint256 developerId, bytes32 dataHash) private {
    _storage.setBytes32(keccak256("developerDataHash", developerId), dataHash);
  }

  function setDeveloperUrl(uint256 developerId, bytes32 url) private {
    _storage.setBytes32(keccak256("developerUrl", developerId), url);
  }

  function setBotProductRegistry(BotProductRegistryDelegate botProductRegistry) private {
    _storage.setAddress("botProductRegistry", botProductRegistry);
  }

}
