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

  function applyDeveloperReward() onlyArbiter public; 

  function availableBalance() public returns (uint); 

  function reservedTokens() public returns (uint); 

  function setCuratorRewardRate(uint rate) onlyOwner public; 

  function setDevRewardRate(uint rate) onlyOwner public; 

  function vaultBalance() internal returns (uint); 

  function collectCuratorReward() internal; 
}
