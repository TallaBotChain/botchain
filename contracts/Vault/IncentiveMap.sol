pragma solidity ^0.4.18;

import "../Upgradability/OwnableKeyed.sol";
import "../Upgradability/ArbiterKeyed.sol";

/**
* @title IncentiveMap
* @dev Contract for creating a map of balances for incentive stakers.
*/
contract IncentiveMap is ArbiterKeyed {

  /**
  * @dev Event for when the balance of a payee is changed 
  * @param _balance The current balance once the entry has been updated.
  */
  event BalanceUpdate(uint256 _balance);

  /**
  * @dev Creates an map of balances for 
  * @param _storage The BaseStorage contract that stores ApprovableRegistry's state
  */
  function IncentiveMap(BaseStorage _storage, address _arbiter)
    ArbiterKeyed(_storage,_arbiter)
    public
    {}

  /**
  * @dev Checks approval status of entry
  * @return true if entry id has approval status
  */
  function balance() public view returns (uint) {
    return _storage.getUint(keccak256("payeeBalance", tx.origin));
  }

  /**
  * @dev Sets the balance in the Vault for a particular address.
  * @param addr the address of the balance to set.
  * @return true if entry id has approval status
  */
  function setBalance(address addr, uint _balance) internal returns (uint) {
    _storage.setUint(keccak256("payeeBalance", addr), _balance);
    BalanceUpdate(_balance);
  }

}
