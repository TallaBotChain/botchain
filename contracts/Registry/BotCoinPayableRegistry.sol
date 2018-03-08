pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/token/ERC20/StandardToken.sol';
import "../Upgradability/OwnableKeyed.sol";

/// @title BotCoinPayableRegistry 
/// @dev Delegate contract for BotCoinPayment functionality
contract BotCoinPayableRegistry is OwnableKeyed {

	function BotCoinPayableRegistry(BaseStorage storage_)
		OwnableKeyed(storage_)
	    public
		{}

	function tallaWallet() public view returns (address) {
		return _storage.getAddress("tallaWallet");
	}

	function getEntryPrice() public view returns (uint256) {
		return _storage.getUint("entryPrice");
	}

	function botCoin() public view returns (StandardToken) {
    	return StandardToken(_storage.getAddress("botCoinAddress"));
  	}

	function setTallaWallet(address tallaWallet) onlyOwner public {
		require(tallaWallet != 0x0);
		_storage.setAddress("tallaWallet", tallaWallet);
	}

	function setEntryPrice(uint256 entryPrice) onlyOwner public {
		_storage.setUint("entryPrice", entryPrice);
	}

	function transferBotCoin() internal {
    	botCoin().transferFrom(msg.sender, tallaWallet(), getEntryPrice());
    }

}