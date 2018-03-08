pragma solidity ^0.4.18;

import "../../contracts/Upgradability/PublicStorage.sol";
import "../../contracts/Upgradability/ERC721TokenKeyed.sol";
import "../../contracts/Registry/BotCoinPayableRegistry.sol";

contract MockBotCoinPayableRegistry is BotCoinPayableRegistry {

  function MockBotCoinPayableRegistry(
    PublicStorage storage_,
    address botCoin
  )
    BotCoinPayableRegistry(storage_)
    public
  {
    storage_.setAddress("botCoinAddress", botCoin);
  }

  function makePayment() public {
    transferBotCoin();
  }

}
