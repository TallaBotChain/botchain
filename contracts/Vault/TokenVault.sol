pragma solidity ^0.4.18;

import "../Upgradability/OwnableKeyed.sol";
import "../Upgradability/ArbiterKeyed.sol";

/**
* @title IncentiveMap
* @dev Contract for creating a map of balances for incentive stakers.
*/
contract TokenVaultDelegate is IncentiveMap {

  /**
  * @dev Creates an map of balances for 
  * @param storage_ The BaseStorage contract that stores ApprovableRegistry's state
  */
  function TokenVaultDelegate(BaseStorage _storage, address _arbiter)
    IncentiveMap(BaseStorage _storage, address _arbiter)
    ArbiterKeyed(_storage,_arbiter)
    public
    {}

  /**
  * @dev 
  * @param _entryId The ID of the entry
  * @return true if entry id has approval status
  */
  function applyCuratorReward(address addr) onlyArbiter public {
    // TODO: this should be done by fetching a value stored by the governance board
    //       It can't currently be done this way because storage getters don't support
    //       alternative scoping for fetches.
    reserveTokens(curatorRewardRate());
    setBalance(balance(addr) + curatorRewardRate());
  }

  function applyDeveloperReward() onlyArbiter public {
    require(devRewardRate() >= availableBalance());
    botcoin.transfer(tx.origin, devRewardRate());
  }

  function availableBalance() public returns (uint) {
    return _storage.getUint(keccak256('availableBalance'));
  }

  function reservedTokens() public return (uint) {
    return botcoin().balanceOf(address(this)) - availableBalance();
  }

  function reserveTokens(uint amount) private {
    uint available = availableBalance();
    require(available >= amount);
    _storage.setUint(keccak256('availableBalance'), available - amount);
  }

  function curatorRewardRate() private {
    return _storage.getUint(keccak256('curatorEmissionRate'));
  }

  function setCuratorRewardRate(uint rate) onlyOwner public {
    _storage.setUint(keccak256('curatorEmissionRate'), rate);
  }

  function devRewardRate() private {
    return _storage.getUint(keccak256('devEmissionRate'));
  }

  function setDevRewardRate(uint rate) onlyOwner public {
    _storage.setUint(keccak256('devEmissionRate'), rate);
  }

	function botCoin() public view returns (StandardToken) {
   	return StandardToken(_storage.getAddress("botCoinAddress"));
  }

  function vaultBalance() internal returns (uint) {
    return botCoin().balanceOf(address(this));
  }

	function collectCuratorReward() internal {
    uint balance = balance();
    require(balance <= vaultBalance());
   	require(botCoin().transfer(tx.origin, balance));
  }
}
