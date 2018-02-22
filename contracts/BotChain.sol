pragma solidity ^0.4.18;

import "levelk-upgradability-contracts/contracts/Proxy/OwnableProxy.sol";
import "levelk-upgradability-contracts/contracts/Storage/PublicStorage.sol";
import "./Delegates/BotChainDelegate.sol";
import "./BotOwnershipManager.sol";

contract BotChain is OwnableProxy {

  function BotChain(PublicStorage storage_, address delegate)
    public
    OwnableProxy(storage_, delegate)
  {
    storage_.setAddress("botOwnershipManager", new BotOwnershipManager(BotChainDelegate(this)));
  }

}
