pragma solidity ^0.4.18;

import './BaseStorage.sol';
import './StorageConsumer.sol';
import './OwnableKeyed.sol';

/**
* @title ArbiterKeyed
* @dev This contract allows for a contract to have both an Arbiter and an Owner. This enables
*   contracts to have an impartial third party that can control state outside of the owners
*   domain.  The owner can change the arbiter, but not directly modify values in it's scope.
*/
contract ArbiterKeyed is OwnableKeyed {

  event ArbiterChange(address indexed previousArbiter, address indexed newArbiter);

  /**
   * @dev Throws if called by any account other than the arbiter.
   */
  modifier onlyArbiter() {
    require(msg.sender == getArbiter());
    _;
  }

  /**
   * @dev Throws if called by any account other than the arbiter or the owner.
   */
  modifier onlyArbOrOwner() {
    require(msg.sender == getOwner() || msg.sender == getArbiter());
    _;
  }

  function ArbiterKeyed(BaseStorage _storage, address _arbiter) 
    OwnableKeyed(_storage) 
    StorageConsumer(_storage) public {
    if (_arbiter != 0x0) {
      setArbiter(_arbiter);
    }
  }

  /**
   * @dev Allows the current owner to change the arbiter of the contract.
   * @param newOwner The address to transfer ownership to.
   */
  function changeArbiter(address newArbiter) public onlyOwner {
    require(newArbiter != address(0));
    ArbiterChange(getArbiter(), newArbiter);
    setArbiter(newArbiter);
  }

  function getArbiter() public view returns (address) {
    return _storage.getAddress("arbiter");
  }

  function setArbiter(address arbiter) internal {
    _storage.setAddress("arbiter", arbiter);
  }
}
