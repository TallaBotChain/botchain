pragma solidity ^0.4.18;

import "./ApprovableRegistryDelegate.sol";
import './BotProductRegistryDelegate.sol';
import 'zeppelin-solidity/contracts/token/ERC20/StandardToken.sol';

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

  function tallaWallet() public view returns (address) {
    return _storage.getAddress("tallaWallet");
  }

  function getEntryPrice() public view returns (uint256) {
    return _storage.getUint("entryPrice");
  }

  function botCoin() public view returns (StandardToken) {
    return StandardToken(_storage.getAddress("botCoinAddress"));
  }

  function owns(address owner) public view returns (uint256) {
    return _storage.getUint(keccak256("ownerToId", owner));
  }

  /// @dev Adds the sender's address as a new developer. defaults to unapproved.
  /// @param _data A hash of the data associated with the new developer
  /// @param _url A url associated with this developer
  function addDeveloper(bytes32 _data, bytes32 _url) public {
    require(owns(msg.sender) == 0);
    require(_data != 0x0);
    require(_url != 0x0);

    uint256 _developerId = super.totalSupply().add(1);

    setDeveloperDataHash(_developerId, _data);
    setDeveloperUrl(_developerId, _url);
    setOwnerId(msg.sender, _developerId);

    botCoin().transferFrom(msg.sender, tallaWallet(), getEntryPrice());

    super._mint(msg.sender, _developerId);

    DeveloperAdded(msg.sender, _developerId, _data, _url);
  }

  function setTallaWallet(address tallaWallet) onlyOwner public {
    require(tallaWallet != 0x0);
    _storage.setAddress("tallaWallet", tallaWallet);
  }

  function setEntryPrice(uint256 entryPrice) onlyOwner public {
    _storage.setUint("entryPrice", entryPrice);
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

}
