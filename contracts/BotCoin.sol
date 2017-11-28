pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/token/StandardToken.sol';

// Development stand-in for a ERC20 token till we get the real one delivered by
// ambisafe
contract BotCoin is StandardToken {

	string public name = 'BotCoin';
	string public symbol = 'BOT';
	uint public decimals = 18;
	uint public INITIAL_SUPPLY = 1.5 * 10^9;

	function BotCoin() public {
	  totalSupply = INITIAL_SUPPLY * (10 ** decimals);
	  balances[msg.sender] = totalSupply;
	}

}
