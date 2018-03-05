pragma solidity ^0.4.18;

import "levelk-upgradability-contracts/contracts/Proxy/OwnableProxy.sol";
import "levelk-upgradability-contracts/contracts/Storage/PublicStorage.sol";

contract MockProxyInstance is OwnableProxy {

  function MockProxyInstance(
    PublicStorage storage_,
    address delegateAddress
  )
    public
    OwnableProxy(storage_, delegateAddress)
  {}

}
