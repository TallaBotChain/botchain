pragma solidity ^0.4.18;

import '../Vault/TokenVault.sol';
import '../Upgradability/BaseStorage.sol';
import 'zeppelin-solidity/contracts/token/ERC20/StandardToken.sol';

contract TokenVaultDelegate is TokenVault {

  function TokenVaultDelegate(BaseStorage _storage, address _arbiter)
    TokenVault(_storage,_arbiter)
    public
    {}
  /**
  *  @dev Retreives the address of the EIP-20 from storage and instanties a StandardToken interface for it.
  *  @return StandardToken interface to the EIP-20 token contract.
  */
	function botcoin() public view returns (StandardToken) {
   	return StandardToken(_storage.getAddress("botCoinAddress"));
  }

  /**
  * @dev Applies a reward to the balance of a curator address.
  */
  function applyCuratorReward() onlyArbiter public {
    // TODO: this should be done by fetching a value stored by the governance board
    //       It can't currently be done this way because storage getters don't support
    //       alternative scoping for fetches.
    reserveTokens(curatorRewardRate());
    setBalance(tx.origin, this.balance() + curatorRewardRate());
    BalanceUpdate(this.balance());
  }

  function applyDeveloperReward() onlyArbiter public {
    require(devRewardRate() >= availableBalance());
    botcoin().transfer(tx.origin, devRewardRate());
  }

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

  function setDevRewardRate(uint rate) onlyOwner public {
    _storage.setUint(keccak256('curatorEmissionRate'), rate);
  }

  function devRewardRate() private returns (uint) {
    return _storage.getUint(keccak256('devEmissionRate'));
  }

  function vaultBalance() internal returns (uint) {
    return botcoin().balanceOf(address(this));
  }

	function collectCuratorReward() internal {
    uint _balance = this.balance();
    require(_balance <= vaultBalance());
   	require(botcoin().transfer(tx.origin, _balance));
    BalanceUpdate(this.balance());
  }
}
