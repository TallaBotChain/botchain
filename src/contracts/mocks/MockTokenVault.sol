pragma solidity ^0.4.18;

import "../Upgradability/PublicStorage.sol";
import '../Delegates/TokenVaultDelegate.sol';

contract MockTokenVault is TokenVaultDelegate {

  function MockTokenVault(PublicStorage storage_, address arbiter, address botcoinAddr)
    TokenVaultDelegate(storage_, arbiter) public
  { 
    storage_.setAddress("botCoinAddress", botcoinAddr);
  }
}
