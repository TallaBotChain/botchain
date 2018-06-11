pragma solidity ^0.4.18;

import "./Upgradability/OwnableProxy.sol";
import "./Upgradability/PublicStorage.sol";

contract TokenVaultProxy is OwnableProxy {

  /** @dev Creates token vault proxy */
  function TokenVaultProxy(
    PublicStorage storage_,
    address tokenVaultDelegateAddress,
    address botCoinAddress
  )
    public
    OwnableProxy(storage_, tokenVaultDelegateAddress)
  {
  	storage_.setAddress("botCoinAddress", botCoinAddress);
  }

}
