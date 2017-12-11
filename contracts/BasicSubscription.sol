pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/ownership/Ownable.sol';
import './Subscription.sol';

/**
 * @title BasicSubscription
 * @dev Basic implementation of a Subscription
 */
contract BasicSubscription is Subscription, Ownable {

  // Mapping of subscription end times; can be up to the maxSubscription time into the future
  mapping(address => uint256) subscriptionEndTimes;
  
  // Address where funds are collected
  address public wallet;
  
  uint256 cost;
  uint256 duration;
  uint256 maxSubscription;

  // Set cost of subscription for a specified duration
  // Set the maximum amount of time that a subscriber can have subscribed into the future
  function setSubscriptionParameters(uint256 _cost, uint256 _duration, uint256 _maxSubscription) onlyOwner public returns(bool) {
    //  Set contract values to passed in parameters
  }

  // Changes subscription end date
  // Forwards payment to service provider offering the subscription  
  function extendSubscription(address _subscriber, uint256 _payment) payable public returns (bool) {
    // Add funds to member's balances
    // Forward funds to service provider
  }

  function checkSubscriptionStatus(address _subscriber) public returns (bool) {
    // Calculate whether subscription has expired and return boolean
  }

  // Returns the time (date?) at which the subscriber's paid subsription expires
  function checkSubscriptionExpiration(address _subscriber) public returns (uint256) {
    // return time at which current paid subscription expires
  }
  
  // Forward funds to the fund collection wallet
  // Override to create custom fund forwarding mechanisms
  function forwardFunds() internal {
    wallet.transfer(msg.value);
  }
}
