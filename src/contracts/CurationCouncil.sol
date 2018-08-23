pragma solidity ^0.4.18;

import "./Upgradability/OwnableProxy.sol";
import "./Upgradability/PublicStorage.sol";

contract CurationCouncil is OwnableProxy {

  /** @dev Creates curation council */
  function CurationCouncil(
    PublicStorage storage_,
    address curationCouncilRegistryDelegateAddress,
    address botCoinAddress
  )
    OwnableProxy(storage_, curationCouncilRegistryDelegateAddress)
    public
  {
    storage_.setAddress(BOTCOIN_ADDR, botCoinAddress);
  }

}
