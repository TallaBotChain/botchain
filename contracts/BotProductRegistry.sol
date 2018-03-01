pragma solidity ^0.4.18;

import "levelk-upgradability-contracts/contracts/Proxy/OwnableProxy.sol";
import "levelk-upgradability-contracts/contracts/Storage/PublicStorage.sol";

contract BotProductRegistry is OwnableProxy {

  function BotProductRegistry(
    address developerRegistryAddress,
    PublicStorage storage_,
    address delegate
  )
    OwnableProxy(storage_, delegate)
    public
  {
    storage_.setAddress("developerRegistryAddress", developerRegistryAddress);

    // Increment botProductCount so that the first valid bot ID will be `1`.
    _storage.setUint("botProductCount", 1);
  }

}