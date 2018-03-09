pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/token/ERC20/StandardToken.sol';
import "../Upgradability/OwnableKeyed.sol";

/**
* @title BotCoinPayableRegistry 
* @dev Delegate contract for BotCoinPayment functionality
*/
contract BotCoinPayableRegistry is OwnableKeyed {

  	/* @dev Constructor for BotCoinPayableRegistry */
	function BotCoinPayableRegistry(BaseStorage storage_)
		OwnableKeyed(storage_)
	    public
		{}

	/**
	* @dev Returns address of wallet
	*/
	function tallaWallet() public view returns (address) {
		return _storage.getAddress("tallaWallet");
	}

	/**
	* @dev Returns entry price associated with id
	*/
	function getEntryPrice() public view returns (uint256) {
		return _storage.getUint("entryPrice");
	}

	/**
	* @dev Returns instance of botCoin
	*/
	function botCoin() public view returns (StandardToken) {
    	return StandardToken(_storage.getAddress("botCoinAddress"));
  	}

	/**
	* @dev Sets wallet address
	* @param tallaWallet An address associated with the recipient
	*/
	function setTallaWallet(address tallaWallet) onlyOwner public {
		require(tallaWallet != 0x0);
		_storage.setAddress("tallaWallet", tallaWallet);
	}

	/**
	* @dev Sets entry price
	* @param entryPrice A value of payment
	*/
	function setEntryPrice(uint256 entryPrice) onlyOwner public {
		_storage.setUint("entryPrice", entryPrice);
	}

	/**
	* @dev Transfers Botcoin payment from msg.sender to wallet
	*/
	function transferBotCoin() internal {
    	botCoin().transferFrom(msg.sender, tallaWallet(), getEntryPrice());
    }

}