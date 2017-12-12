pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/ownership/Ownable.sol';
import './Subscription.sol';

/**
 * @title Subscribable
 * @dev The Subscribable has a Subscription contract passed in and provides
 * functions that simplify authorization of features requiring subscription
 */
contract Subscribable {

	Subscription public subscription;

	function Subscribable(Subscription _subscription) {
		subscription = _subscription;
	}

  function isSubscribed(address _subscriber) returns(bool) {
  	return subscription.checkStatus(_subscriber);
  }
}
