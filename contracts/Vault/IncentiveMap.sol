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
  * @param entryId The current balance once the entry has been updated.
  */
  event BalanceUpdate(uint256 balance);

  /**
  * @dev Creates an map of balances for 
  * @param storage_ The BaseStorage contract that stores ApprovableRegistry's state
  */
  function IncentiveMap(BaseStorage _storage, address _arbiter)
    ArbiterKeyed(_storage,_arbiter)
    public
    {}

  /**
  * @dev Checks approval status of entry
  * @param _entryId The ID of the entry
  * @return true if entry id has approval status
  */
  function balance() public view returns (uint) {
    return _storage.getUint(keccak256("payeeBalance", tx.origin));
  }

  /**
  * @dev Checks approval status of entry
  * @param _entryId The ID of the entry
  * @return true if entry id has approval status
  */
  function setBalance(address addr, uint balance) internal returns (uint) {
    _storage.setUint(keccak256("payeeBalance", addr), balance);
    BalanceUpdate(balance);
  }

}
