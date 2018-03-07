pragma solidity ^0.4.18;

import "../../contracts/Upgradability/OwnableProxy.sol";
import "../../contracts/Upgradability/PublicStorage.sol";

contract MockProxyInstance is OwnableProxy {

  function MockProxyInstance(
    PublicStorage storage_,
    address delegateAddress
  )
    public
    OwnableProxy(storage_, delegateAddress)
  {}

}
