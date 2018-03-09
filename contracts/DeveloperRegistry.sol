pragma solidity ^0.4.18;

import "./Upgradability/OwnableProxy.sol";
import "./Upgradability/PublicStorage.sol";
import "./Delegates/DeveloperRegistryDelegate.sol";

contract DeveloperRegistry is OwnableProxy {

  /** @dev Creates developer registry*/
  function DeveloperRegistry(
    PublicStorage storage_,
    address developerRegistryDelegateAddress,
    address botCoinAddress
  )
    public
    OwnableProxy(storage_, developerRegistryDelegateAddress)
  {
  	storage_.setAddress("botCoinAddress", botCoinAddress);
  }

}
