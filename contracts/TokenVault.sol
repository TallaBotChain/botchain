pragma solidity ^0.4.18;

import "./Upgradability/OwnableProxy.sol";
import "./Upgradability/PublicStorage.sol";

contract TokenVault is OwnableProxy {

  /** @dev Creates developer registry*/
  function TokenVault(
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
