pragma solidity ^0.4.18;

import "./ApprovableRegistryDelegate.sol";
import './BotProductRegistryDelegate.sol';

/// @title DeveloperRegistryDelegate
/// @dev Delegate contract for DeveloperRegistry functionality
contract DeveloperRegistryDelegate is ApprovableRegistryDelegate {

  event DeveloperAdded(address owner, uint256 developerId, bytes32 dataHash, bytes32 url);

  function DeveloperRegistryDelegate(BaseStorage storage_) public ApprovableRegistryDelegate(storage_) { }

  function botProductProductRegistry() public view returns (BotProductRegistryDelegate) {
    return BotProductRegistryDelegate(_storage.getAddress("botProductRegistry"));
  }

  function developerDataHash(uint256 developerId) public view returns (bytes32) {
    return _storage.getBytes32(keccak256("developerDataHash", developerId));
  }

  function developerUrl(uint256 developerId) public view returns (bytes32) {
    return _storage.getBytes32(keccak256("developerUrl", developerId));
  }

  /// @dev Adds a new developer. Only callable by owner.
  /// @param _owner The address that will own the new developer
  /// @param _data A hash of the data associated with the new developer
  /// @param _url A url associated with this developer
  function addDeveloper(address _owner, bytes32 _data, bytes32 _url) public {
    require(_owner != 0x0);
    require(_data != 0x0);
    require(_url != 0x0);

    uint256 _developerId = super.totalSupply().add(1);

    setDeveloperDataHash(_developerId, _data);
    setDeveloperUrl(_developerId, _url);
    super._mint(_owner, _developerId);

    DeveloperAdded(_owner, _developerId, _data, _url);
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
