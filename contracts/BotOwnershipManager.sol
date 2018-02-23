pragma solidity ^0.4.18;

import "levelk-upgradability-contracts/contracts/Proxy/OwnableProxy.sol";
import "levelk-upgradability-contracts/contracts/Storage/PublicStorage.sol";

contract BotOwnershipManager is OwnableProxy {

  function BotOwnershipManager(address botChainAddress, PublicStorage storage_, address delegate)
    public
    OwnableProxy(storage_, delegate)
  {
    storage_.setAddress("botChainAddress", botChainAddress);

    // Increment botCount so that the first valid bot ID will be `1`.
    _storage.setUint("botCount", 1);
  }

}