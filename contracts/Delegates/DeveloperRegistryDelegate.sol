pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/token/ERC20/StandardToken.sol';
import "../Upgradability/ERC721TokenKeyed.sol";
import "../Registry/ApprovableRegistry.sol";
import '../Registry/BotCoinPayableRegistry.sol';
import "../Registry/OwnerRegistry.sol";
import './BotProductRegistryDelegate.sol';

/// @title DeveloperRegistryDelegate
/// @dev Delegate contract for DeveloperRegistry functionality
contract DeveloperRegistryDelegate is ApprovableRegistry, OwnerRegistry, BotCoinPayableRegistry, ERC721TokenKeyed {

  event DeveloperAdded(address owner, uint256 developerId, bytes32 dataHash, bytes32 url);

  function DeveloperRegistryDelegate(BaseStorage storage_) 
    ApprovableRegistry(storage_)
    BotCoinPayableRegistry(storage_)
    ERC721TokenKeyed(storage_)
    public 
    { }

  function developerDataHash(uint256 developerId) public view returns (bytes32) {
    return _storage.getBytes32(keccak256("developerDataHash", developerId));
  }

  function developerUrl(uint256 developerId) public view returns (bytes32) {
    return _storage.getBytes32(keccak256("developerUrl", developerId));
  }

  function owns(address owner) public view returns (uint256) {
    return _storage.getUint(keccak256("ownerToId", owner));
  }

  function ownerOfEntry(uint256 _developerId) public view returns (address _owner) {
    return ownerOf(_developerId);
  }

  function mintingAllowed(address minter, uint256 _developerId) public view returns (bool) {
    return ownerOf(_developerId) == minter && approvalStatus(_developerId) == true;
  }

  /// @dev Adds the sender's address as a new developer. defaults to unapproved.
  /// @param _data A hash of the data associated with the new developer
  /// @param _url A url associated with this developer
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

  function setDeveloperDataHash(uint256 developerId, bytes32 dataHash) private {
    _storage.setBytes32(keccak256("developerDataHash", developerId), dataHash);
  }

  function setDeveloperUrl(uint256 developerId, bytes32 url) private {
    _storage.setBytes32(keccak256("developerUrl", developerId), url);
  }

  function setOwnerId(address owner, uint256 developerId) private {
    _storage.setUint(keccak256("ownerToId", owner), developerId);
  }

  function setBotProductRegistry(BotProductRegistryDelegate botProductRegistry) private {
    _storage.setAddress("botProductRegistry", botProductRegistry);
  }

  function entryExists(uint256 _entryId) private view returns (bool) {
    return ownerOf(_entryId) != 0x0;
  }

}
