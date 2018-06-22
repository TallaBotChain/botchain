pragma solidity ^0.4.18;

import '../Vault/TokenVault.sol';
import '../Upgradability/BaseStorage.sol';
import '../Upgradability/StorageConsumer.sol';
import 'zeppelin-solidity/contracts/token/ERC20/StandardToken.sol';

/**
* @title TokenVaultDelegate
* @dev Delegate contract which implements functions to store and manipulate the balances related to
*  curator and developer incentives. It maps the balances using the IncentiveMap inherited from
*  the TokenVault interface.
*/
contract TokenVaultDelegate is TokenVault {

  function TokenVaultDelegate(BaseStorage _storage, address _arbiter)
    TokenVault(_storage,_arbiter)
    public
    {}

  /**
  *  @dev Retreives the address of the EIP-20 from storage and instanties a StandardToken interface 
  *   for it.
  *  @return StandardToken interface to the EIP-20 token contract.
  */
  function botcoin() public returns (StandardToken) {
    return StandardToken(_storage.getAddress("botCoinAddress"));
  }

  /**
  * @dev Reserves tokens from the vaults balance for a particular curator.  The reserved tokens 
  *  are reflected in the current balance of the curator.  The TokenVaults available balance and
  *  reserved balance will also reflect the change, but the vault's overall balance will remain
  *  unchanged until the curator collects the reward.
  *  Can only be executed by the Arbiter of the Vault (ideally the CurationCouncil contract).
  */
  function applyCuratorReward() onlyArbiter public {
    reserveTokens(curatorRewardRate());
    setBalance(tx.origin, balance() + curatorRewardRate());
    BalanceUpdate(balance());
  }

  /**
  * @dev Sends token reward from the vaults balance to the address of the transaction intiator.
  *  The TokenVaults available balance also reflect the change.
  *  Can only be executed by the Arbiter of the Vault (ideally the CurationCouncil contract).
  */
  function applyDeveloperReward() onlyArbiter public {
    require(developerRewardRate() <= availableBalance());
    require(botcoin().transfer(tx.origin, developerRewardRate()));
  }

  /**
  * @dev Returns the balance reflected in the Botcoin contract minus the balances
  *  that have already been reserved for curator rewards.
  */
  function availableBalance() private returns (uint) {
    return vaultBalance() - reservedBalance();
  }

  /**
   * @dev Returns the current amount of the Vault's Botcoin balance that has been reserved
   *  for curator rewards.
   */
  function reservedBalance() public returns (uint) {
    return _storage.getUint('reservedBalance');
  }

  /**
   * @dev Reserves the provided amount of tokens to be collected at future time.
   *  The available balance must be large enough to cover the requested amount.
   * @param amount the number of tokens to reserve for the transaction origin.
   */
  function reserveTokens(uint amount) private {
    uint new_reserve = amount + reservedBalance();
    require(new_reserve >= amount && new_reserve <= vaultBalance());
    _storage.setUint('reservedBalance', new_reserve);
  }

  /**
  * @dev Updates the reserved balance to reflect the change.
  *  The amount to consume must be less than or equal to the current reserved
  *  balance.
  * @param amount the count of tokens in the reserve balance to consume.
  */
  function consumeReservedTokens(uint amount) private {
    uint reserved = reservedBalance();
    require(amount <= reserved);
    _storage.setUint('reservedBalnace', reserved - amount);
  }

  /**
   * @dev Returns the current reward rate that can be claimed by a curator for doing
   *  work.
   */
  function curatorRewardRate() public returns (uint) {
    // TODO: This should be returning a value based on an asymptotic function
    // rather than an absolute value. What's the appropriate function?
    // I.E. return calculateReward(curatorRewardRate())
    return _storage.getUint('curatorEmissionRate');
  }

  /**
   * @dev Sets the reward rate that can be claimed by a curator for doing work.
   *  This can only be performed by the Owner of the Vault (ideally the GovernanceBoard).
   * @param rate the count of tokens that should be rewarded.
   */
  function setCuratorRewardRate(uint rate) onlyOwner public {
    _storage.setUint('curatorEmissionRate', rate);
  }

  /**
   * @dev Sets the reward rate that can be claimed by a developer for successfully registering.
   *  This can only be performed by the Owner of the Vault (ideally the GovernanceBoard).
   * @param rate the count of tokens that should be rewarded.
   */
  function setDeveloperRewardRate(uint rate) onlyOwner public {
    _storage.setUint('developerEmissionRate', rate);
  }

  /**
   * @dev Returns the current developer reward rate available for registrations.
   */
  function developerRewardRate() public returns (uint) {
    return _storage.getUint('developerEmissionRate');
  }

  /**
   * @dev Returns the current number of Botcoin stored in the TokenVault. This value does not
   * reflect the number of tokens that are reserved for curator rewards.
   */
  function vaultBalance() internal returns (uint) {
    return botcoin().balanceOf(address(this));
  }

  /**
   * @dev Resets the balance of the transaction origin to zero and consumes them from the reserves.
   * This should only be called after the balance has been succesfully transfered.
   */
  function resetCuratorBalance() private {
    consumeReservedTokens(balance());
    setBalance(tx.origin, 0);
    BalanceUpdate(balance());
  }

  /**
   * @dev Transfers the balance in the TokenVault to the wallet of the transactions origin.
   *  Use caution not to call this on empty balances, since this will still require gas.
   */
  function collectCuratorReward() public {
    uint _balance = balance();
    require(_balance <= reservedBalance());
    require(botcoin().transfer(tx.origin, _balance));
    resetCuratorBalance();
  }
}
