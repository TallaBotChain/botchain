pragma solidity ^0.4.18;

import "levelk-upgradability-contracts/contracts/Proxy/OwnableProxy.sol";
import "levelk-upgradability-contracts/contracts/Storage/PublicStorage.sol";
import "./Delegates/BotChainDelegate.sol";
import "./BotOwnershipManager.sol";

contract BotChain is OwnableProxy {

  function BotChain(
    PublicStorage storage_,
    address botChainDelegateAddress,
    address botOwnershipManagerDelegateAddress
  )
    public
    OwnableProxy(storage_, botChainDelegateAddress)
  {
    storage_.setAddress("botOwnershipManager", new BotOwnershipManager(
      BotChainDelegate(this),
      storage_,
      botOwnershipManagerDelegateAddress
    ));
  }

}
