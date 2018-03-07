pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/token/ERC20/StandardToken.sol';
import "levelk-upgradability-contracts/contracts/StorageConsumer/StorageConsumer.sol";

/// @title BotCoinPaymentRegistry for transferring value
contract BotCoinPaymentRegistry is StorageConsumer{
    // Required methods

    function BotCoinPaymentRegistry(BaseStorage storage_) public StorageConsumer(storage_) { }

	function tallaWallet() public view returns (address) {
		return _storage.getAddress("tallaWallet");
	}

	function getEntryPrice() public view returns (uint256) {
		return _storage.getUint("entryPrice");
	}

	function botCoin() public view returns (StandardToken) {
    	return StandardToken(_storage.getAddress("botCoinAddress"));
  	}

  	function transferBotCoin() {
    	botCoin().transferFrom(msg.sender, tallaWallet(), getEntryPrice());
    }

	function setTallaWallet(address tallaWallet) public {
		require(tallaWallet != 0x0);
		_storage.setAddress("tallaWallet", tallaWallet);
	}

	function setEntryPrice(uint256 entryPrice) public {
		_storage.setUint("entryPrice", entryPrice);
	}

}