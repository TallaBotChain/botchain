pragma solidity ^0.4.18;

import "../Upgradability/OwnableKeyed.sol";
import "../Upgradability/ArbiterKeyed.sol";
import '../Upgradability/BaseStorage.sol';
import './IncentiveMap.sol';

/**
* @title TokenVault
* @dev Contract defining the external interfaces to the TokenVault.
*/
contract TokenVault is IncentiveMap {

  /**
   * @dev Creates a new TokenVault.
   * @param _storage The BaseStorage contract that stores TokenVault's internal map.
   * @param _arbiter The address of the wallet or contract that acts as the arbiter.
   */
  function TokenVault(BaseStorage _storage, address _arbiter)
    IncentiveMap(_storage,_arbiter)
    public
    {}

  /**
   * @dev Applies a reward to the balance of a curator address.
   */
  function applyCuratorReward() onlyArbiter public; 

  /**
   * @dev Sends reward to the address of a successfully registered developer.
   *  It also updates the relevent balanace information stored in the TokenVault.
   */
  function applyDeveloperReward() onlyArbiter public; 

  /**
   * @return uint Returns the number of tokens that have been reserved for Curator rewards
   * that have already been earned, but not collected.
   */
  function reservedBalance() public returns (uint); 

  /**
   * @dev Sets the current emission rate rewarded to curators for performing work.
   * @param rate the rate to set denominated in BOTC.
   */
  function setCuratorRewardRate(uint rate) onlyOwner public; 

  /**
   * @dev Sets the current emission rate rewarded to developers for successfully
   *  completing their registration.
   * @param rate the rate to set denominated in BOTC.
   */
  function setDeveloperRewardRate(uint rate) onlyOwner public; 

  /**
   * @dev Gets the current emission rate rewarded to curators for doing work to
   *  validate developer registrations.
   * @return uint the reward rate denominated in BOTC.
   */
  function curatorRewardRate() public view returns (uint);

  /**
   * @dev Gets the current emission rate rewarded to developers for successfully
   *  completing their registration.
   * @return uint the reward rate denominated in BOTC.
   */
  function developerRewardRate() public view returns (uint);

  /**
    * @dev 
    * @return uint The total balance held by the TokenVault.
    */
  function vaultBalance() internal returns (uint); 

  /**
    * @dev Send the current balance of a curator held in the TokenVault to the transaction origin.
    * @return uint The total balance held by the TokenVault.
    */
  function collectCuratorReward() public; 
}
