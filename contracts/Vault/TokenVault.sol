pragma solidity ^0.4.18;

import "../Upgradability/OwnableKeyed.sol";
import "../Upgradability/ArbiterKeyed.sol";
import '../Vault/IncentiveMap.sol';
import 'zeppelin-solidity/contracts/token/ERC20/StandardToken.sol';

/**
* @title IncentiveMap
* @dev Contract for creating a map of balances for incentive stakers.
*/
contract TokenVaultDelegate is IncentiveMap {

  /**
  * @dev Creates an map of balances for 
  * @param _storage The BaseStorage contract that stores ApprovableRegistry's state
  */
  function TokenVaultDelegate(BaseStorage _storage, address _arbiter)
    IncentiveMap(_storage,_arbiter)
    ArbiterKeyed(_storage,_arbiter)
    public
    {}

	function botcoin() public view returns (StandardToken) {
   	return StandardToken(_storage.getAddress("botCoinAddress"));
  }

  /**
  * @dev 
  * @param addr The ID of the entry
  * @return true if entry id has approval status
  */
  function applyCuratorReward(address addr) onlyArbiter public {
    // TODO: this should be done by fetching a value stored by the governance board
    //       It can't currently be done this way because storage getters don't support
    //       alternative scoping for fetches.
    reserveTokens(curatorRewardRate());
    setBalance(addr, this.balance() + curatorRewardRate());
  }

  //function applyDeveloperReward() onlyArbiter public {
  //  require(devRewardRate() >= availableBalance());
  //  botcoin().transfer(tx.origin, devRewardRate());
  //}

  function availableBalance() public returns (uint) {
    return _storage.getUint(keccak256('availableBalance'));
  }

  function reservedTokens() public returns (uint) {
    return botcoin().balanceOf(address(this)) - availableBalance();
  }

  function reserveTokens(uint amount) private {
    uint available = availableBalance();
    require(available >= amount);
    _storage.setUint(keccak256('availableBalance'), available - amount);
  }

  function curatorRewardRate() private returns (uint) {
    return _storage.getUint(keccak256('curatorEmissionRate'));
  }

  function setCuratorRewardRate(uint rate) onlyOwner public {
    _storage.setUint(keccak256('curatorEmissionRate'), rate);
  }

  function devRewardRate() private returns (uint) {
    return _storage.getUint(keccak256('devEmissionRate'));
  }

  function setDevRewardRate(uint rate) onlyOwner public {
    _storage.setUint(keccak256('devEmissionRate'), rate);
  }

  function vaultBalance() internal returns (uint) {
    return botcoin().balanceOf(address(this));
  }

	function collectCuratorReward() internal {
    uint _balance = this.balance();
    require(_balance <= vaultBalance());
   	require(botcoin().transfer(tx.origin, _balance));
  }
}
