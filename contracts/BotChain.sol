pragma solidity ^0.4.18;

import "levelk-upgradability-contracts/contracts/Proxy/OwnableProxy.sol";
import "levelk-upgradability-contracts/contracts/Storage/PublicStorage.sol";
import "levelk-upgradability-contracts/contracts/StorageConsumer/StorageConsumer.sol";
import "./Delegates/BotChainDelegate.sol";
import "./BotOwnershipManager.sol";

contract BotChain is StorageConsumer, OwnableProxy {

  function BotChain(PublicStorage storage_, address delegate)
    public
    StorageConsumer(storage_)
    OwnableProxy(delegate)
  {
    storage_.setAddress("owner", msg.sender);
    storage_.setAddress("botOwnershipManager", new BotOwnershipManager(BotChainDelegate(this)));
  }

}
