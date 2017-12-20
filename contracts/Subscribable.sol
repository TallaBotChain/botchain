pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/ownership/Ownable.sol';
import './TokenSubscription.sol';

/**
 * @title Subscribable
 * @dev The Subscribable has a Subscription contract passed in and provides
 * functions that simplify authorization of features requiring subscription
 */
contract Subscribable {

	TokenSubscription public tokenSubscription;

	function Subscribable(TokenSubscription _tokenSubscription) {
		tokenSubscription = _tokenSubscription;
	}

  function isSubscribed(address _subscriber) returns(bool) {
  	return tokenSubscription.checkStatus(_subscriber);
  }
}
