pragma solidity ^0.4.18;

import "../../contracts/Upgradability/PublicStorage.sol";
import '../../contracts/Vault/TokenVault.sol';

contract MockCurationCouncil {

  TokenVault public tokenVault;
  address _storage;
  function MockCurationCouncil(PublicStorage storage_)
    public
  { 
    _storage = storage_;
  }
  
  function vote() public {
    tokenVault.setDevRewardRate(1);
  }

  function changeTokenVault(address addr) public {
    require(addr != 0x0);
    tokenVault = TokenVault(addr);
  }
}
