pragma solidity ^0.4.18;

import "./BaseStorage.sol";
import "./StorageConsumer.sol";
import "./OwnableKeyed.sol";
import "./BaseProxy.sol";

contract OwnableProxy is OwnableKeyed, BaseProxy {

  event Upgraded(address indexed implementation_);

  function OwnableProxy(BaseStorage storage_, address implementation_)
    public
    OwnableKeyed(storage_)
  {
    setImplementation(implementation_);
  }

  function implementation() public view returns (address) {
    return _storage.getAddress("implementation");
  }

  function upgradeTo(address impl) public onlyOwner {
    require(implementation() != impl);
    setImplementation(impl);
    Upgraded(impl);
  }

  function setImplementation(address implementation_) internal {
    _storage.setAddress("implementation", implementation_);
  }

}
