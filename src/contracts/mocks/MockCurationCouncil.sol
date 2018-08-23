pragma solidity ^0.4.18;

import "../Upgradability/PublicStorage.sol";
import '../Upgradability/StorageConsumer.sol';
import '../Vault/TokenVault.sol';

contract MockCurationCouncil is StorageConsumer {

  function MockCurationCouncil(PublicStorage storage_, address botcoin)
    StorageConsumer(storage_)
    public
  { 
    _storage.setAddress('botcoinContract', botcoin);
  }
  
  function tokenVault() public returns (TokenVault) {
    return TokenVault(_storage.getAddress('tokenVaultContract'));
  }

  function vote() public {
    tokenVault().applyCuratorReward();
  }

  function changeTokenVault(address addr) public {
    require(addr != 0x0);
    _storage.setAddress('tokenVaultContract', addr);
  }
}
